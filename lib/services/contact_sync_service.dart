// lib/services/contact_sync_service.dart
//
// Orchestrates the two contact sources — the app's SQLite store
// (ContactRepository) and the device address book (DeviceContactService) — for
// the three cross-cutting operations the screens need: a merged read, a
// two-way save, and a delete that propagates to the device. Keeps the
// repository pure SQLite; all device interaction is funnelled through here.
//
// Secret rules (enforced in [saveContact]): a secret contact is NEVER written to
// the device, and making a contact secret removes it from the device and clears
// the link, so secret contacts are app-only.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_contacts_dialer/core/logging/app_logger.dart';
import 'package:smart_contacts_dialer/models/audit_entry.dart';
import 'package:smart_contacts_dialer/models/contact.dart';
import 'package:smart_contacts_dialer/models/email.dart';
import 'package:smart_contacts_dialer/models/phone_number.dart';
import 'package:smart_contacts_dialer/repositories/contact_repository.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart'
    show ContactSortOrder;
import 'package:smart_contacts_dialer/services/device_account.dart';
import 'package:smart_contacts_dialer/services/device_contact_service.dart';

/// Which stage of a device→app pull is running. [fetching] is reading the
/// device address book (size unknown yet); [merging] is saving the fetched
/// contacts into the app DB (counts known).
enum SyncPhase { fetching, merging }

/// A snapshot of how far [ContactSyncService.syncFromDevice] has progressed,
/// published on [ContactSyncService.onSyncProgress]. `null` on that stream
/// means "no sync running".
class SyncProgress {
  final SyncPhase phase;

  /// Contacts merged so far / to merge in total. Both are 0 while [phase] is
  /// [SyncPhase.fetching] (the device book hasn't been counted yet).
  final int processed;
  final int total;

  const SyncProgress.fetching()
    : phase = SyncPhase.fetching,
      processed = 0,
      total = 0;

  const SyncProgress.merging(this.processed, this.total)
    : phase = SyncPhase.merging;
}

/// Outcome of [ContactSyncService.syncToDevice]: how many device contacts were
/// freshly created versus overwritten in place.
class SyncToDeviceResult {
  /// New device contacts written (app rows that had no device match).
  final int created;

  /// Existing device contacts overwritten (matched by link, phone, or name).
  final int updated;

  /// Contacts whose device write failed (counted honestly, not as success).
  final int failed;

  const SyncToDeviceResult(this.created, this.updated, [this.failed = 0]);

  /// Total device rows successfully written this run.
  int get total => created + updated;
}

class ContactSyncService {
  static final ContactSyncService _instance = ContactSyncService._internal();
  factory ContactSyncService() => _instance;
  ContactSyncService._internal();

  /// Persisted flag marking that the device book has been pulled into the app at
  /// least once. Lets the UI show local contacts immediately and sync in the
  /// background on subsequent launches, reserving the blocking first-run sync
  /// for when there's genuinely nothing to show yet.
  static const String _kInitialSyncDone = 'contacts_initial_sync_done';

  final ContactRepository _repo = ContactRepository();
  final DeviceContactService _device = DeviceContactService();

  /// Fires (with the number of changed rows) each time [syncFromDevice]
  /// completes a successful pull. Screens listen to refresh their local reads —
  /// crucially covering the first launch, where the startup sync only finishes
  /// after the user grants the contacts permission, long after the list has
  /// already rendered its (empty) first read. Never closed: the service is an
  /// app-lifetime singleton.
  final StreamController<int> _syncCompleted =
      StreamController<int>.broadcast();

  Stream<int> get onSyncCompleted => _syncCompleted.stream;

  /// Signals that local contact data changed outside a device sync (e.g. a full
  /// backup restore replaced every table). Screens listening to
  /// [onSyncCompleted] refresh their local reads, so a restore that lands on the
  /// already-mounted Contacts tab updates without a manual re-query.
  void notifyLocalDataChanged() => _syncCompleted.add(0);

  /// Live progress of the in-flight [syncFromDevice]: a [SyncProgress] per
  /// update while it runs, then `null` when it ends (success or failure — the
  /// terminal `null` is guaranteed, so listeners can never be left showing a
  /// stale progress state). Never closed: app-lifetime singleton.
  final StreamController<SyncProgress?> _syncProgress =
      StreamController<SyncProgress?>.broadcast();

  Stream<SyncProgress?> get onSyncProgress => _syncProgress.stream;

  /// The latest value published on [onSyncProgress] (`null` when no sync is
  /// running), so a screen that mounts mid-sync can seed its UI immediately
  /// instead of waiting for the next stream event.
  SyncProgress? _currentProgress;
  SyncProgress? get currentProgress => _currentProgress;

  void _reportProgress(SyncProgress? progress) {
    _currentProgress = progress;
    _syncProgress.add(progress);
  }

  /// Whether [syncFromDevice] has completed successfully at least once. Returns
  /// false when the flag is absent or preferences are unavailable.
  Future<bool> hasCompletedInitialSync() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_kInitialSyncDone) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// A lightweight, paged read of the app's stored contacts for the list (slim
  /// summaries — name, primary phone, photo, score; no full hydration). Pass
  /// [limit]/[offset] to page; omit [limit] for the whole set.
  Future<List<Contact>> localSummaries({
    bool includeSecret = false,
    bool favoritesOnly = false,
    bool sortByLastName = false,
    bool requirePhone = false,
    int? limit,
    int offset = 0,
  }) {
    return _repo.getContactSummaries(
      includeSecret: includeSecret,
      favoritesOnly: favoritesOnly,
      sortByLastName: sortByLastName,
      requirePhone: requirePhone,
      limit: limit,
      offset: offset,
    );
  }

  /// The "Self" contact (phone owner) as a slim summary for pinning to the top
  /// of the list, or null when none is set.
  Future<Contact?> selfSummary() => _repo.getSelfSummary();

  /// The fully hydrated "Self" contact, or null when none is set.
  Future<Contact?> selfContact() => _repo.getSelfContact();

  /// A contact's full phone numbers, loaded on demand (the list carries only the
  /// primary number in its slim summaries). Used to decide/populate the call
  /// number chooser when Call is tapped.
  Future<List<PhoneNumber>> phoneNumbersFor(int contactId) =>
      _repo.getPhoneNumbers(contactId);

  /// A contact's emails, loaded on demand (the list carries only the primary
  /// email in its slim summaries). Used to resolve the address when the Email
  /// quick-action is tapped.
  Future<List<Email>> emailsFor(int contactId) => _repo.getEmails(contactId);

  /// DB-backed slim search across the whole address book (name/phone/email).
  Future<List<Contact>> searchSummaries(
    String query, {
    bool includeSecret = false,
    bool favoritesOnly = false,
  }) {
    return _repo.searchContactSummaries(
      query,
      includeSecret: includeSecret,
      favoritesOnly: favoritesOnly,
    );
  }

  /// Every distinct tag with its contact count (respecting the secret filter),
  /// for the Tag Cloud screen.
  Future<List<TagCount>> tagCounts({bool includeSecret = false}) {
    return _repo.getTagCounts(includeSecret: includeSecret);
  }

  /// Every distinct tag name in use, for autocomplete suggestions on the
  /// Add/Edit contact screen.
  Future<List<String>> allTagNames() => _repo.getDistinctTagNames();

  /// Slim summaries of the contacts carrying an exact [tag], for the per-tag
  /// list opened from the Tag Cloud (respecting the secret filter).
  Future<List<Contact>> contactsByTag(
    String tag, {
    bool includeSecret = false,
  }) {
    return _repo.getContactSummariesByTag(tag, includeSecret: includeSecret);
  }

  /// Contacts sharing a house or employer with those already picked, to suggest
  /// as further members of a group or tag.
  Future<List<AffiliationPeer>> affiliationPeers(
    Set<int> seedContactIds, {
    bool includeSecret = false,
  }) {
    return _repo.getAffiliationPeers(
      seedContactIds,
      includeSecret: includeSecret,
    );
  }

  /// Moves every contact from tag [from] onto tag [to] — a rename when nothing
  /// uses [to], a merge when something does. Returns contacts changed.
  ///
  /// Tags live only in the app DB (the device address book has no equivalent
  /// field), so unlike [saveContact] there is nothing to push to the device.
  Future<int> retagAll(String from, String to) => _repo.retagAll(from, to);

  /// Adds [tag] to [contactIds], skipping contacts that already carry it.
  Future<int> addTagToContacts(String tag, Set<int> contactIds) =>
      _repo.addTagToContacts(tag, contactIds);

  /// Removes [tag] from [contactIds] only, leaving other carriers untouched.
  Future<int> removeTagFromContacts(String tag, Set<int> contactIds) =>
      _repo.removeTagFromContacts(tag, contactIds);

  /// Deletes [tag] when no contact carries it; false means it is still in use.
  Future<bool> deleteEmptyTag(String tag) => _repo.deleteEmptyTag(tag);

  /// Total stored-contact count (respecting the secret filter), for paging.
  Future<int> contactCount({
    bool includeSecret = false,
    bool requirePhone = false,
  }) {
    return _repo.countContacts(
      includeSecret: includeSecret,
      requirePhone: requirePhone,
    );
  }

  /// Per-letter contact counts for the list's section headers (e.g.
  /// `{'A': 12, '#': 3}`). Mirrors the [localSummaries] filters so the totals
  /// match the list.
  Future<Map<String, int>> sectionCounts({
    bool includeSecret = false,
    bool favoritesOnly = false,
    bool sortByLastName = false,
    bool requirePhone = false,
  }) {
    return _repo.getSectionCounts(
      includeSecret: includeSecret,
      favoritesOnly: favoritesOnly,
      sortByLastName: sortByLastName,
      requirePhone: requirePhone,
    );
  }

  /// Mean relationship score across all (filtered) contacts, for the health hero.
  Future<double> averageScore({bool includeSecret = false}) {
    return _repo.averageRelationshipScore(includeSecret: includeSecret);
  }

  /// App contacts unioned with device contacts that are not already represented
  /// in the app — de-duplicated by `device_id` (the app row winning) **and** by
  /// normalized phone, so a device contact that duplicates an app row (or an
  /// earlier device row) by number is hidden. Device-only entries come back with
  /// `id == null` and `deviceId` set. Sorted by first name.
  ///
  /// Pass `fetchDevice: false` for a cheap local-only read (e.g. refreshing the
  /// list after a read-only navigation or a mutation that already synced to the
  /// device): it skips the device book fetch and returns just the app DB rows.
  Future<List<Contact>> mergedContacts({
    bool includeSecret = false,
    bool fetchDevice = true,
    bool sortByLastName = false,
    bool requirePhone = false,
  }) async {
    final app = await _repo.getAllContacts(includeSecret: includeSecret);

    List<Contact> device = const <Contact>[];
    if (fetchDevice && await _device.isGranted()) {
      device = await _device.fetchDeviceContacts() ?? const <Contact>[];
    }

    final linked = app.map((c) => c.deviceId).whereType<String>().toSet();
    // Index the app rows' numbers by owner so a device-only contact that
    // duplicates an existing contact (same number AND same name) is suppressed.
    // A number match alone is not identity — different people share numbers
    // (family landline, office desk) — so those stay visible.
    final phoneOwners = <String, Contact>{};
    for (final c in app) {
      for (final ph in c.phoneNumbers) {
        final digits = ContactRepository.normalizeDigits(ph.number);
        if (digits.isNotEmpty) phoneOwners.putIfAbsent(digits, () => c);
      }
    }

    final deviceOnly = <Contact>[];
    for (final d in device) {
      if (d.deviceId == null || linked.contains(d.deviceId)) continue;
      final digitsList = d.phoneNumbers
          .map((p) => ContactRepository.normalizeDigits(p.number))
          .where((s) => s.isNotEmpty)
          .toList();
      final isDuplicate = digitsList.any((digits) {
        final owner = phoneOwners[digits];
        return owner != null && _sameName(owner, d);
      });
      if (isDuplicate) continue;
      for (final digits in digitsList) {
        phoneOwners.putIfAbsent(digits, () => d);
      }
      deviceOnly.add(d);
    }

    var all = <Contact>[...app, ...deviceOnly];
    if (requirePhone) {
      all = all.where((c) => c.phoneNumbers.isNotEmpty).toList();
    }
    final order = sortByLastName
        ? ContactSortOrder.lastName
        : ContactSortOrder.firstName;
    all.sort((a, b) {
      // Pin the "Self" contact to the very top, then sort by the chosen order.
      if (a.isSelf != b.isSelf) return a.isSelf ? -1 : 1;
      return a.sortKey(order).compareTo(b.sortKey(order));
    });
    return all;
  }

  /// Persists [c] and, per the secret rules, propagates to the device:
  /// - secret: app-only; if it was linked, delete the device contact + unlink.
  /// - not secret: create/update the matching device contact and store its id.
  /// Device writes are best-effort and never block the local save.
  /// Returns the app contact id (existing or newly inserted).
  Future<int> saveContact(Contact c) async {
    // Secret, Self, and Ephemeral contacts are app-only: never written to the
    // device book, and if one was previously linked, the device copy is removed.
    if (c.isSecret || c.isSelf || c.isEphemeral) {
      final previousDeviceId = c.deviceId;
      c.deviceId = null;
      final id = await _persist(c);
      if (previousDeviceId != null) {
        await _device.deleteDeviceContact(previousDeviceId);
      }
      return id;
    }

    // Two-way: push to the device first so we can store the resulting id. A
    // failed device write returns null; keep the previous link so a transient
    // failure never unlinks a good contact.
    final previousDeviceId = c.deviceId;
    final resultId = await _device.upsertDeviceContact(c);
    c.deviceId = resultId ?? previousDeviceId;
    return await _persist(c);
  }

  /// Merges [duplicateIds] into [primaryId] across **both** stores. The app-side
  /// merge folds the duplicates' data onto the primary and deletes their rows;
  /// then, when the contacts permission is granted, the same merge is applied to
  /// the phone book: each duplicate's device contact is deleted and the survivor
  /// is written back so the phone reflects the merged fields. Deleting the phone
  /// copies also removes what the device→app sync was re-importing, so the merge
  /// stops reappearing. Device work is best-effort; the app-side merge always
  /// happens (even with no permission). Secret / Self survivors stay app-only.
  Future<void> mergeContacts(int primaryId, List<int> duplicateIds) async {
    final ids = duplicateIds.where((id) => id != primaryId).toList();
    if (ids.isEmpty) return;

    // Capture the duplicates' phone-book links before the merge deletes them.
    final absorbedDeviceIds = await _repo.deviceIdsForContacts(ids);

    await _repo.mergeContacts(primaryId, ids);

    if (!await _device.isGranted()) return;

    final survivor = await _repo.getContactById(primaryId);
    final keepDeviceId = survivor?.deviceId;

    // Remove the duplicate contacts from the phone (never the survivor's own).
    for (final devId in absorbedDeviceIds) {
      if (devId == keepDeviceId) continue;
      await _device.deleteDeviceContact(devId);
    }

    // Reflect the merged fields on the survivor's phone contact. Secret, Self,
    // and Ephemeral contacts are app-only, so they are never pushed (mirrors [saveContact]).
    if (survivor != null && !survivor.isSecret && !survivor.isSelf && !survivor.isEphemeral) {
      final resultId = await _device.upsertDeviceContact(survivor);
      if (resultId != null && resultId != survivor.deviceId) {
        survivor.deviceId = resultId;
        await _repo.updateContact(survivor, source: AuditSource.merge);
      }
    }

    // The device book changed; let listeners (e.g. the counts card) refresh.
    _syncCompleted.add(ids.length);
  }

  /// Deletes [c] from both stores: the device address book (when linked) and the
  /// app DB (when it is a persisted app row). Covers linked app contacts and
  /// device-only contacts alike.
  Future<void> deleteContact(Contact c) async {
    if (c.deviceId != null) {
      await _device.deleteDeviceContact(c.deviceId!);
    }
    if (c.id != null) {
      await _repo.deleteContact(c.id!);
    }
  }

  /// Pulls the device book into the app DB, linking by `device_id`: inserts new
  /// device contacts and refreshes the synced fields of already-linked rows
  /// (app-only fields and secret rows are left untouched). Idempotent. No-op
  /// (returns 0) when the permission is not granted — it does not prompt; the
  /// permission flow does that. Returns the number of rows inserted/updated.
  Future<int> syncFromDevice() async {
    if (!await _device.isGranted()) return 0;

    _reportProgress(const SyncProgress.fetching());

    // Full detail (incl. photos) — this is the background pass that persists the
    // complete contact and its photo to disk, off the list's critical path.
    final List<Contact>? devices;
    try {
      devices = await _device.fetchDeviceContacts(fullDetail: true);
    } catch (_) {
      _reportProgress(null);
      rethrow;
    }

    // A failed fetch (null) must not count as a completed sync: leaving the
    // initial-sync flag unset makes the next launch retry the full pull instead
    // of silently settling for a partial book.
    if (devices == null) {
      _reportProgress(null);
      return 0;
    }

    // syncDeviceContacts reports the merging progress and the terminal null.
    final changed = await syncDeviceContacts(devices);
    _syncCompleted.add(changed);
    return changed;
  }

  /// Pushes the app's contacts into the device address book (the reverse of
  /// [syncFromDevice]). For each app contact it either **overwrites** the
  /// matching device contact or creates a new one:
  ///   - already linked (`device_id` set) → overwrite that device contact;
  ///   - otherwise a **conflict** — an existing device contact with a matching
  ///     normalized phone number (checked first) or full name — is overwritten;
  ///   - no match → a new device contact is created.
  /// The resulting device id is stored back on the app row so future writes stay
  /// linked. Secret and Self contacts are app-only and are skipped, mirroring the
  /// rules in [saveContact]. No-op (returns zeros) when the contacts permission
  /// is not granted — it does not prompt; the caller does that. [onProgress] is
  /// called with (processed, total) as the push advances.
  Future<SyncToDeviceResult> syncToDevice({
    WritableAccount? target,
    void Function(int processed, int total)? onProgress,
  }) async {
    if (!await _device.isGranted()) return const SyncToDeviceResult(0, 0);

    // Secret, Self, and Ephemeral contacts never leave the app, so they are not pushed.
    final app = await _repo.getAllContacts();
    final pushable = app.where((c) => !c.isSecret && !c.isSelf && !c.isEphemeral).toList();

    // Read the current device book once and index it for conflict lookup. First
    // owner wins (like the pull-side phone index), so a stable device entry is
    // the overwrite target when several app rows could match it.
    final devices = await _device.fetchDeviceContacts() ?? const <Contact>[];
    final devicePhoneIndex = <String, String>{}; // digits -> device_id
    final deviceNameIndex = <String, String>{}; // nameKey -> device_id
    for (final d in devices) {
      final id = d.deviceId;
      if (id == null) continue;
      for (final ph in d.phoneNumbers) {
        final digits = ContactRepository.normalizeDigits(ph.number);
        if (digits.isNotEmpty) devicePhoneIndex.putIfAbsent(digits, () => id);
      }
      final key = _nameKey(d);
      if (key.isNotEmpty) deviceNameIndex.putIfAbsent(key, () => id);
    }

    var created = 0;
    var updated = 0;
    var failed = 0;
    for (var i = 0; i < pushable.length; i++) {
      onProgress?.call(i, pushable.length);
      final c = pushable[i];

      // Resolve the overwrite target: the existing link, else a phone/name
      // conflict in the current device book.
      c.deviceId ??= _matchDeviceId(c, devicePhoneIndex, deviceNameIndex);
      final overwriting = c.deviceId != null;

      // Creates when deviceId is null (into [target]), overwrites in place
      // otherwise. A null result means the write failed — count it honestly and
      // leave the existing link untouched.
      final resultId = await _device.upsertDeviceContact(c, target: target);
      if (resultId == null) {
        failed++;
        continue;
      }
      c.deviceId = resultId;

      // Persist the (possibly new) link so the row stays matched next time.
      if (c.id != null) {
        await _repo.updateContact(c, source: AuditSource.deviceSync);
      }

      if (overwriting) {
        updated++;
      } else {
        created++;
      }

      // Keep the indexes current so two app rows can't both claim one device
      // entry within this run.
      final linked = resultId;
      for (final ph in c.phoneNumbers) {
        final digits = ContactRepository.normalizeDigits(ph.number);
        if (digits.isNotEmpty) {
          devicePhoneIndex.putIfAbsent(digits, () => linked);
        }
      }
      final key = _nameKey(c);
      if (key.isNotEmpty) deviceNameIndex.putIfAbsent(key, () => linked);
    }
    onProgress?.call(pushable.length, pushable.length);
    // Tell listeners (e.g. the "Contact counts" card) the device book changed,
    // so they refresh without waiting for a manual reload.
    _syncCompleted.add(created + updated);
    return SyncToDeviceResult(created, updated, failed);
  }

  /// Destructive device → app mirror: runs the normal [syncFromDevice] merge,
  /// then deletes app contacts that **came from the device but are gone from it**
  /// (their `device_id` is set but no longer present in the current device book).
  ///
  /// Deliberately never deletes:
  ///   - the Self contact,
  ///   - secret contacts,
  ///   - app-only contacts (no `device_id`, i.e. created in the app).
  /// So only contacts the app originally pulled from the phone, and which the
  /// phone no longer has, are removed. Returns the number of app contacts
  /// deleted. No-op (0) when the contacts permission is not granted.
  Future<int> mirrorFromDevice() async {
    if (!await _device.isGranted()) return 0;

    // Import/update first (reports its own progress + fires onSyncCompleted).
    await syncFromDevice();

    // The device ids still present on the phone.
    final devices = await _device.fetchDeviceContacts() ?? const <Contact>[];
    final deviceIds = devices
        .map((d) => d.deviceId)
        .whereType<String>()
        .toSet();

    final app = await _repo.getAllContacts(includeSecret: true);
    var deleted = 0;
    for (final c in app) {
      if (c.isSelf || c.isSecret || c.isEphemeral) continue; // protected
      final devId = c.deviceId;
      if (devId == null) continue; // app-only, protected
      if (deviceIds.contains(devId)) continue; // still on the phone
      if (c.id != null) {
        await _repo.deleteContact(c.id!, source: AuditSource.deviceSync);
        deleted++;
      }
    }
    if (deleted > 0) _syncCompleted.add(deleted);
    return deleted;
  }

  /// Destructive app → device mirror: runs the normal [syncToDevice] push, then
  /// deletes device contacts that **no app contact matches** (by link, phone, or
  /// name), so the phone book becomes exactly the app's set.
  ///
  /// The Self contact and secret contacts are included when building the "keep"
  /// set even though they are never pushed, so a device contact that corresponds
  /// to one of them (by link, phone, or name) is **never deleted**. Returns the
  /// number of device contacts deleted. No-op (0) when the contacts permission
  /// is not granted.
  Future<int> mirrorToDevice({WritableAccount? target}) async {
    if (!await _device.isGranted()) return 0;

    // Push first (creates/overwrites and stores the resulting links).
    await syncToDevice(target: target);

    // Build the keep set from the *whole* app book — including Self and secret —
    // so their device counterparts are protected from deletion.
    final app = await _repo.getAllContacts(includeSecret: true);
    final keepDeviceIds = <String>{};
    final keepPhones = <String>{};
    final keepNames = <String>{};
    for (final c in app) {
      final devId = c.deviceId;
      if (devId != null) keepDeviceIds.add(devId);
      for (final ph in c.phoneNumbers) {
        final digits = ContactRepository.normalizeDigits(ph.number);
        if (digits.isNotEmpty) keepPhones.add(digits);
      }
      final key = _nameKey(c);
      if (key.isNotEmpty) keepNames.add(key);
    }

    final devices = await _device.fetchDeviceContacts() ?? const <Contact>[];
    var deleted = 0;
    for (final d in devices) {
      final devId = d.deviceId;
      if (devId == null) continue;
      if (keepDeviceIds.contains(devId)) continue;
      final matchesPhone = d.phoneNumbers.any((p) {
        final digits = ContactRepository.normalizeDigits(p.number);
        return digits.isNotEmpty && keepPhones.contains(digits);
      });
      if (matchesPhone) continue;
      if (keepNames.contains(_nameKey(d))) continue;
      await _device.deleteDeviceContact(devId);
      deleted++;
    }
    // Always notify: the push half (syncToDevice) may have created/overwritten
    // device contacts even when nothing was deleted, so the "Contact counts"
    // card must refresh regardless of the delete count.
    _syncCompleted.add(deleted);
    return deleted;
  }

  /// The device id of an existing device contact that conflicts with [c] —
  /// a matching normalized phone number first, then a matching full name — or
  /// null when [c] is new to the device book.
  String? _matchDeviceId(
    Contact c,
    Map<String, String> phoneIndex,
    Map<String, String> nameIndex,
  ) {
    for (final ph in c.phoneNumbers) {
      final digits = ContactRepository.normalizeDigits(ph.number);
      if (digits.isEmpty) continue;
      final id = phoneIndex[digits];
      if (id != null) return id;
    }
    final key = _nameKey(c);
    if (key.isNotEmpty) return nameIndex[key];
    return null;
  }

  /// The DB half of [syncFromDevice]: merges the already-fetched, already-mapped
  /// [devices] into the app store. Exposed for tests (the device fetch is
  /// platform-bound and inert on the host VM).
  @visibleForTesting
  Future<int> syncDeviceContacts(List<Contact> devices) async {
    try {
      return await _mergeDeviceContacts(devices);
    } finally {
      // However the merge ended — success, or a throw mid-loop — the sync is
      // over; the terminal null keeps listeners from showing stale progress.
      _reportProgress(null);
    }
  }

  Future<int> _mergeDeviceContacts(List<Contact> devices) async {
    // Precompute the existing links and a phone index once, instead of two
    // lookups per device contact (~1k queries for a 500-contact book).
    final links = await _repo.deviceIdLinks(); // device_id -> contact_id
    final mergedIds = await _repo.mergedDeviceIds(); // absorbed device_ids
    final confirmedIds = await _repo
        .confirmedMergedDeviceIds(); // user-confirmed merges
    final phoneIndex = await _repo
        .phoneIndexNonSecret(); // digits -> contact_id
    final confirmedPhones = await _repo
        .confirmedMergePhones(); // digits -> contact_id (user-confirmed merges)

    var changed = 0;
    for (var i = 0; i < devices.length; i++) {
      // Every 10 contacts, not every one: enough for a smooth bar without
      // flooding listeners into a setState per contact.
      if (i % 10 == 0) {
        _reportProgress(SyncProgress.merging(i, devices.length));
      }
      final d = devices[i];
      final deviceId = d.deviceId;
      if (deviceId == null) continue;

      // Already linked (primary or absorbed): refresh device fields in place.
      final linkedId = links[deviceId];
      if (linkedId != null) {
        final existing = await _repo.getContactById(linkedId);
        // secret/ephemeral -> never overwrite an app-only row.
        if (existing == null || existing.isSecret || existing.isEphemeral) continue;

        final absorbed = mergedIds.contains(deviceId);
        final confirmed = confirmedIds.contains(deviceId);
        if (absorbed && !confirmed && !_sameName(existing, d)) {
          // Heal a wrong *automatic* absorption: an earlier sync folded this
          // device contact into [existing] because they share a number, but
          // they are different people. Unlink and give it its own row. A
          // user-confirmed merge ([confirmed]) is exempt — the user has
          // explicitly declared these the same, so a name mismatch is expected
          // and must not undo the merge.
          await _repo.removeMergedDeviceId(deviceId);
          if (existing.deviceId == deviceId) {
            // An old sync overwrote the row's own link with the absorbed id;
            // that link is bogus — clear it so both rows stay distinct.
            existing.deviceId = null;
            await _repo.updateContact(existing, source: AuditSource.deviceSync);
          }
          final newId = await _repo.insertContact(
            d,
            source: AuditSource.deviceSync,
          );
          links[deviceId] = newId;
          _indexPhones(d, phoneIndex, newId);
          changed++;
          continue;
        }

        if (absorbed && confirmed) {
          // A user-confirmed duplicate: keep the surviving row exactly as-is.
          // Its own device link supplies its identity/fields; letting a
          // differently-named absorbed copy overwrite them would make the kept
          // name flip on every sync, so skip the refresh entirely.
          continue;
        }

        if (absorbed) {
          // A true duplicate of [existing]: refresh its synced fields but keep
          // the row's own primary device link intact.
          final ownDeviceId = existing.deviceId;
          _mergeDeviceInto(existing, d);
          existing.deviceId = ownDeviceId;
        } else {
          _mergeDeviceInto(existing, d);
        }
        await _repo.updateContact(existing, source: AuditSource.deviceSync);
        changed++;
        continue;
      }

      // Not linked yet — but this phone number was already part of a
      // user-confirmed merge (Find-duplicates screen). Android can reassign a
      // device contact's internal id when it re-links/re-splits raw contacts
      // (e.g. a WhatsApp resync); that makes an already-merged duplicate look
      // brand-new here even though the user explicitly merged it. Recognise it
      // by phone number instead — no name check needed, the user already
      // confirmed these are the same person.
      final confirmedMatchId = _firstPhoneMatch(d, confirmedPhones);
      if (confirmedMatchId != null) {
        final match = await _repo.getContactById(confirmedMatchId);
        if (match != null && !match.isSecret && !match.isEphemeral) {
          await _repo.recordMergedDeviceId(
            confirmedMatchId,
            deviceId,
            confirmed: true,
          );
          links[deviceId] = confirmedMatchId;
          mergedIds.add(deviceId);
          confirmedIds.add(deviceId);
          changed++;
          continue;
        }
      }

      // Not linked yet — auto-merge dedup: absorb only a **genuine duplicate**
      // (same number AND same name). Different people can share a number
      // (family landline, office desk), so a number match alone gets its own
      // row instead of disappearing into the other contact.
      final matchId = _firstPhoneMatch(d, phoneIndex);
      if (matchId != null) {
        final match = await _repo.getContactById(matchId);
        if (match != null && _sameName(match, d)) {
          await _repo.recordMergedDeviceId(matchId, deviceId);
          links[deviceId] = matchId;
          mergedIds.add(deviceId);
          changed++;
          continue;
        }
      }

      // Brand-new contact.
      final newId = await _repo.insertContact(d, source: AuditSource.deviceSync);
      links[deviceId] = newId;
      _indexPhones(d, phoneIndex, newId);
      changed++;
    }
    _reportProgress(SyncProgress.merging(devices.length, devices.length));
    // The device book has now been pulled at least once; future launches can
    // show local contacts immediately and sync in the background.
    await _markInitialSyncDone();
    // Refresh the native ringtone mirror once for the whole sync (debounced with
    // the per-write pushes the loop above already triggered).
    _repo.pushRingtoneMirror();
    return changed;
  }

  /// Adds [d]'s numbers to the in-memory phone index, attributing them to the
  /// freshly inserted row [contactId] (first owner wins, like the DB index).
  void _indexPhones(Contact d, Map<String, int> phoneIndex, int contactId) {
    for (final ph in d.phoneNumbers) {
      final digits = ContactRepository.normalizeDigits(ph.number);
      if (digits.isNotEmpty) phoneIndex.putIfAbsent(digits, () => contactId);
    }
  }

  /// Loose person-identity check used by the dedup/absorb rules: the full name
  /// (first + middle + last), case-insensitive, whitespace-collapsed.
  static bool _sameName(Contact a, Contact b) => _nameKey(a) == _nameKey(b);

  static String _nameKey(Contact c) =>
      '${c.firstName} ${c.middleName ?? ''} ${c.lastName ?? ''}'
          .toLowerCase()
          // Drop periods/commas (e.g. "Dr." vs "Dr") so purely punctuation
          // differences don't defeat an otherwise-identical name match.
          .replaceAll(RegExp(r'[.,]'), '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

  /// The id of an existing contact whose number matches any of [d]'s phone
  /// numbers (digit-normalized), or null — the auto-merge dedup signal.
  int? _firstPhoneMatch(Contact d, Map<String, int> phoneIndex) {
    for (final ph in d.phoneNumbers) {
      final digits = ContactRepository.normalizeDigits(ph.number);
      if (digits.isEmpty) continue;
      final id = phoneIndex[digits];
      if (id != null) return id;
    }
    return null;
  }

  Future<void> _markInitialSyncDone() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kInitialSyncDone, true);
    } catch (_) {
      // Non-fatal: the in-memory sync still succeeded for this session.
    }
  }

  Future<int> _persist(Contact c) async {
    if (c.id == null) return await _repo.insertContact(c);
    await _repo.updateContact(c);
    return c.id!;
  }

  /// Copies device-sourced fields from [d] onto the existing app row [existing],
  /// preserving app-only data (gender, blood group, meetiversary, ringtone,
  /// tags, groups, relationship score/links, secret flag, id, timestamps).
  void _mergeDeviceInto(Contact existing, Contact d) {
    existing.salutation = d.salutation;
    existing.firstName = d.firstName;
    existing.middleName = d.middleName;
    existing.lastName = d.lastName;
    existing.dob = d.dob;
    existing.anniversary = d.anniversary;
    existing.phoneNumbers = d.phoneNumbers;
    existing.emails = d.emails;
    existing.addresses = d.addresses;
    existing.socialLinks = d.socialLinks;
    existing.officialDetails = d.officialDetails;
    existing.deviceId = d.deviceId;
    if (d.photoPath != null) existing.photoPath = d.photoPath;
  }
}

/// Best-effort fire-and-forget device pull, for startup where we don't want to
/// await or surface errors. Safe to call when permission may be absent (no-op).
void unawaitedSyncFromDevice() {
  ContactSyncService().syncFromDevice().catchError((Object e, StackTrace st) {
    AppLogger.error('unawaitedSyncFromDevice failed', error: e, stackTrace: st);
    return 0;
  });
}
