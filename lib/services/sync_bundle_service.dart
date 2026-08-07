// lib/services/sync_bundle_service.dart
//
// Builds and applies the P2P sync payload for [P2PSyncService]. This is the
// app-specific half of the sync: it knows the schema, the settings keys, and
// how photo / calling-card files are stored.
//
// MERGE semantics (add-only, "client wins"): the receiver KEEPS its own data.
// Incoming rows are given NEW ids on the receiver and every foreign key is
// remapped. A contact already on the receiver (same normalized name AND at
// least one shared phone number) is SKIPPED; a genuinely new contact is added,
// and its detail children + history (call logs, interactions, reminders) travel
// WITH it. Groups match by name; relationships remap both endpoints; flagged
// numbers dedupe on (number_e164, kind). See
// `plans/20260708_104631_p2p-sync-rearchitecture.md`.
//
// The emergency info card is the one exception to "add-only": it is a single
// record, not a list, so there is nothing to add to. It is only INSTALLED when
// the receiver has no card at all — one person's medical data must never
// overwrite another's. See `_applyEmergencyCard` and
// `plans/20260730_094425_emergency-card-in-backup-and-sync.md`.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/models/audit_entry.dart';
import 'package:smart_contacts_dialer/repositories/audit_repository.dart';
import 'package:smart_contacts_dialer/repositories/emergency_info_repository.dart';
import 'package:smart_contacts_dialer/utils/malayalam_transliterator.dart';
import 'package:smart_contacts_dialer/services/p2p_sync_service.dart'
    show P2PException;

/// Full clone (to a fresh phone; settings overwrite) vs incremental add-only
/// (to a phone that already has data; settings fill-only).
enum SyncMode { full, incremental }

/// A group of tables the sender can choose to share. `contacts` is the spine
/// and is always included.
enum SyncCategory {
  contacts,
  callHistory,
  groups,
  relationships,
  blockedNumbers,
  emergencyCard,
  settings,
}

/// One media file to send (photo or calling card), already read into memory.
class BundleFile {
  final String ref; // stable token, e.g. `photo_12`
  final Uint8List bytes;
  const BundleFile(this.ref, this.bytes);
}

/// One media file received, to be written to this phone's storage.
class IncomingFile {
  final String ref;
  final String ext;
  final Uint8List bytes;
  const IncomingFile({
    required this.ref,
    required this.ext,
    required this.bytes,
  });
}

/// An entry in the payload's file manifest (ref + extension), in send order.
class FileManifestEntry {
  final String ref;
  final String ext;
  const FileManifestEntry(this.ref, this.ext);
}

/// What was transferred, for the completion message. On the host these are the
/// counts SENT (skipped is 0); on the client [contactsAdded] / [contactsSkipped]
/// describe the merge outcome.
class SyncSummary {
  final int contactsAdded;
  final int contactsSkipped;
  final int groups;
  final int callLogs;
  const SyncSummary({
    required this.contactsAdded,
    this.contactsSkipped = 0,
    required this.groups,
    required this.callLogs,
  });
}

/// The built payload: the META JSON (tables + settings + file manifest) and the
/// media file bytes in manifest order.
class ExportBundle {
  final String metaJson;
  final List<BundleFile> files;
  final SyncSummary summary;
  const ExportBundle(this.metaJson, this.files, this.summary);
}

class SyncBundleService {
  static const int _schema = 1;

  /// Bumped to 2 for the connect-then-choose + add-only-merge wire format. A
  /// receiver refuses a payload from a mismatched protocol (an old immediate-
  /// send / mirror host) with a clear "update both phones" message.
  static const int _protocol = 2;

  /// A `@sync:<ref>` value in a path column means "the receiver should repoint
  /// this to the local file written for that `ref`".
  static const String _mediaSentinel = '@sync:';

  /// Which tables each shareable category carries. `contacts` (the spine)
  /// carries the contact rows plus their per-contact detail children.
  static const Map<SyncCategory, List<String>> _categoryTables = {
    SyncCategory.contacts: [
      'contacts',
      'phone_numbers',
      'emails',
      'addresses',
      'official_details',
      'social_links',
      'tags',
    ],
    SyncCategory.callHistory: ['call_logs', 'interactions', 'reminders'],
    SyncCategory.groups: ['groups', 'contact_groups'],
    SyncCategory.relationships: ['relationships'],
    SyncCategory.blockedNumbers: ['flagged_numbers'],
    SyncCategory.emergencyCard: _emergencyTables,
    SyncCategory.settings: [],
  };

  /// The emergency info card: one `emergency_info` row plus its
  /// `emergency_contacts` rows. Listed PARENT → CHILD, and `emergency_contacts`
  /// must load after `contacts` (its `contact_id` is a foreign key).
  static const List<String> _emergencyTables = [
    'emergency_info',
    'emergency_contacts',
  ];

  /// Per-contact child tables that are inserted verbatim (with a remapped
  /// `contact_id`) for every NEWLY-ADDED contact. Detail children first, then
  /// the history tables that "follow" a new contact.
  static const List<String> _perContactChildTables = [
    'phone_numbers',
    'emails',
    'addresses',
    'official_details',
    'social_links',
    'tags',
    'call_logs',
    'interactions',
    'reminders',
  ];

  /// Every table a full backup carries, listed PARENT → CHILD so inserts always
  /// find their referenced rows already present (foreign keys stay ON). Reverse
  /// the list for deletes (CHILD → PARENT) so a wipe never orphans a reference.
  /// `merged_device_ids` and `confirmed_merge_phones` are wiped but never
  /// re-loaded (they are device-local address-book bookkeeping and are not
  /// part of a backup), so no stale link survives a restore.
  static const List<String> _allManagedTables = [
    'contacts',
    'groups',
    'phone_numbers',
    'emails',
    'addresses',
    'official_details',
    'social_links',
    'tags',
    'contact_groups',
    'call_logs',
    'interactions',
    'reminders',
    'relationships',
    'flagged_numbers',
    'merged_device_ids',
    'confirmed_merge_phones',
  ];

  /// Tables a full backup carries that are wiped ONLY when the incoming bundle
  /// actually holds them (see [_managedTablesFor]).
  ///
  /// The emergency card joined the bundle after backups already existed at this
  /// DB version, so an older backup file passes the schema-version gate while
  /// carrying no card at all. Wiping unconditionally would erase the card that
  /// is on the phone; skipping the wipe leaves it exactly as an older restore
  /// left it.
  static const List<String> _optionalManagedTables = _emergencyTables;

  /// [_allManagedTables] plus whichever [_optionalManagedTables] the incoming
  /// bundle carries, in PARENT → CHILD order.
  static List<String> _managedTablesFor(Map<String, dynamic> tables) => [
    ..._allManagedTables,
    ..._optionalManagedTables.where(tables.containsKey),
  ];

  /// Device-neutral settings keys that travel with the sync. SIM-account-keyed
  /// keys (default_sim_id, per_sim_ringtones, per_sim_colors) are intentionally
  /// excluded — they reference the sender's physical SIMs. Keep in step with
  /// the key constants in [AppSettings].
  static const List<String> _syncedSettingKeys = [
    'theme_mode',
    'accent_color_light',
    'accent_color_dark',
    'post_call_feedback_enabled',
    'dialer_top_source',
    'default_country',
    'include_secret_in_export',
    'block_unknown_callers',
    'caller_id_enabled',
    'spam_filter_enabled',
    'ringtone_volume_percent',
    'vibrate_on_incoming_call',
    'ask_sim_before_call',
    'quick_replies',
  ];

  // Validation caps, applied to a received payload BEFORE anything is written.
  static const int _maxTotalRows = 500000;
  static const int _maxFieldLen = 200000;

  // ===========================================================================
  // Export (host / sender side)
  // ===========================================================================

  /// Builds the payload for [mode]. In [SyncMode.full] every category is
  /// included; in [SyncMode.incremental] only [categories] (contacts is always
  /// forced on as the spine).
  Future<ExportBundle> exportBundle({
    required SyncMode mode,
    Set<SyncCategory>? categories,
  }) async {
    final included = <SyncCategory>{
      SyncCategory.contacts, // always the spine
      if (mode == SyncMode.full) ...SyncCategory.values,
      ...?categories,
    };

    final includedTables = <String>{
      for (final c in included) ..._categoryTables[c]!,
    };

    final db = await DatabaseHelper().database;
    final dbVersion = await _dbVersion(db);

    final tables = <String, List<Map<String, dynamic>>>{};
    final files = <BundleFile>[];
    final manifest = <Map<String, dynamic>>[];

    for (final table in includedTables) {
      final rows = await db.query(table);
      if (table == 'contacts') {
        final staged = <Map<String, dynamic>>[];
        for (final raw in rows) {
          final row = Map<String, dynamic>.from(raw);
          row['photo_path'] = _stageMedia(
            row['photo_path'] as String?,
            'photo_${row['id']}',
            files,
            manifest,
          );
          row['card_photo_path'] = _stageMedia(
            row['card_photo_path'] as String?,
            'card_${row['id']}',
            files,
            manifest,
          );
          // Ringtones are intentionally not synced: the path points at a
          // device-local file that is meaningless on the other phone.
          row['ringtone_path'] = null;
          staged.add(row);
        }
        tables[table] = staged;
      } else {
        tables[table] = [for (final r in rows) Map<String, dynamic>.from(r)];
      }
    }

    final settings = included.contains(SyncCategory.settings)
        ? await _collectSettings()
        : [];

    final meta = <String, dynamic>{
      'protocol': _protocol,
      'schema': _schema,
      'dbVersion': dbVersion,
      'mode': mode == SyncMode.full ? 'full' : 'incremental',
      'categories': [for (final c in included) c.name],
      'tables': tables,
      'settings': settings,
      'files': manifest,
    };

    final summary = SyncSummary(
      contactsAdded: tables['contacts']?.length ?? 0,
      groups: tables['groups']?.length ?? 0,
      callLogs: tables['call_logs']?.length ?? 0,
    );
    return ExportBundle(jsonEncode(meta), files, summary);
  }

  /// If [path] points at a real file, reads it, registers a media frame, and
  /// returns the `@sync:<ref>` sentinel to store in the row. Otherwise returns
  /// null (a missing file becomes no photo on the other phone).
  String? _stageMedia(
    String? path,
    String ref,
    List<BundleFile> files,
    List<Map<String, dynamic>> manifest,
  ) {
    if (path == null || path.isEmpty) return null;
    final file = File(path);
    if (!file.existsSync()) return null;
    final bytes = file.readAsBytesSync();
    final ext = p.extension(path).replaceFirst('.', '');
    files.add(BundleFile(ref, bytes));
    manifest.add({'ref': ref, 'ext': ext.isEmpty ? 'img' : ext});
    return '$_mediaSentinel$ref';
  }

  Future<List<Map<String, dynamic>>> _collectSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final out = <Map<String, dynamic>>[];
    for (final key in _syncedSettingKeys) {
      if (!prefs.containsKey(key)) continue;
      final value = prefs.get(key);
      if (value == null) continue;
      final String type;
      dynamic stored = value;
      if (value is bool) {
        type = 'bool';
      } else if (value is int) {
        type = 'int';
      } else if (value is double) {
        type = 'double';
      } else if (value is List) {
        type = 'stringList';
        stored = value.map((e) => e.toString()).toList();
      } else {
        type = 'string';
        stored = value.toString();
      }
      out.add({'key': key, 'type': type, 'value': stored});
    }
    return out;
  }

  // ===========================================================================
  // Manifest read (client side, before receiving media frames)
  // ===========================================================================

  /// The ordered file manifest embedded in [metaJson]. The client reads exactly
  /// this many media frames after META.
  static List<FileManifestEntry> manifestFrom(String metaJson) {
    final meta = jsonDecode(metaJson);
    if (meta is! Map || meta['files'] is! List) return const [];
    return [
      for (final f in (meta['files'] as List))
        if (f is Map)
          FileManifestEntry(
            (f['ref'] ?? '').toString(),
            (f['ext'] ?? 'img').toString(),
          ),
    ];
  }

  // ===========================================================================
  // Apply (client side, add-only MERGE)
  // ===========================================================================

  Future<SyncSummary> applyBundle(
    String metaJson,
    List<IncomingFile> files,
  ) async {
    final meta = jsonDecode(metaJson);
    if (meta is! Map) throw const P2PException('Corrupt sync data');

    if (meta['protocol'] != _protocol) {
      throw const P2PException(
        'The other phone uses a different sync version. Update both phones to '
        'the same app version, then try again.',
      );
    }

    final db = await DatabaseHelper().database;
    final localVersion = await _dbVersion(db);
    final senderVersion = meta['dbVersion'];
    if (senderVersion is! int || senderVersion != localVersion) {
      throw P2PException(
        'The two phones run different app versions (data schema '
        'v$senderVersion vs v$localVersion). Update both to the same version, '
        'then try again.',
      );
    }

    final tablesRaw = meta['tables'];
    if (tablesRaw is! Map) {
      throw const P2PException('Corrupt sync data (tables)');
    }
    final tables = tablesRaw.cast<String, dynamic>();
    _validateCaps(tables);

    final fullMode = meta['mode'] == 'full';

    // 1. Write incoming media to this phone's storage; map ref → new local path.
    final refToPath = await _writeIncomingMedia(files);

    // 2. Group the incoming phone numbers by their sender contact id, so each
    //    incoming contact's natural key (name + phones) can be computed.
    final phonesBySender = <int, List<String>>{};
    for (final row in _rowsOf(tables['phone_numbers'])) {
      final cid = _asInt(row['contact_id']);
      final number = row['number'];
      if (cid == null || number is! String) continue;
      final key = _phoneKey(number);
      if (key.isEmpty) continue;
      (phonesBySender[cid] ??= <String>[]).add(key);
    }

    var added = 0, skipped = 0, groupsAdded = 0, callLogsAdded = 0;

    await db.transaction((txn) async {
      // 3. Index the receiver's existing contacts by name key → [(id, phones)].
      final existing = await _loadExistingContactIndex(txn);

      // 4. Decide add vs skip for each incoming contact; remember the mapping.
      final senderToReceiver = <int, int>{}; // sender contact id → receiver id
      final addedSenderIds = <int>{};

      for (final raw in _rowsOf(tables['contacts'])) {
        final senderId = _asInt(raw['id']);
        if (senderId == null) continue;
        // The sender's owner ("Self") card only travels on a Full Sync, and even
        // then it lands as a NORMAL contact (is_self forced to 0 below) so it
        // never overwrites the receiver's own identity. On a selective sync it is
        // skipped entirely.
        if (_asInt(raw['is_self']) == 1 && !fullMode) continue;

        final nameKey = _nameKey(raw);
        final phoneKeys = phonesBySender[senderId] ?? const <String>[];
        final matchId = _findMatch(existing, nameKey, phoneKeys);

        if (matchId != null) {
          senderToReceiver[senderId] = matchId;
          skipped++;
          continue;
        }

        final row = Map<String, Object?>.from(raw)
          ..remove('id')
          // A sender's Self card (Full Sync only) lands as a normal contact; the
          // receiver keeps its own owner card. No-op for ordinary contacts.
          ..['is_self'] = 0
          ..['device_id'] =
              null // stale link to the sender's address book
          ..['photo_path'] = _resolveMedia(raw['photo_path'], refToPath)
          ..['card_photo_path'] = _resolveMedia(
            raw['card_photo_path'],
            refToPath,
          )
          // Ringtones are not synced; drop any path an older payload carried.
          ..['ringtone_path'] = null
          // Recompute the search keys rather than trusting the sender's: an
          // older peer sends none at all, and a peer with a stale key would
          // hand us a contact that search cannot find.
          ..['name_translit'] = searchKey(DatabaseHelper.contactSearchName(raw))
          ..['name_phonetic'] = phoneticCode(
            DatabaseHelper.contactSearchName(raw),
          );
        final newId = await txn.insert('contacts', row);
        senderToReceiver[senderId] = newId;
        addedSenderIds.add(senderId);
        added++;
        // So a duplicate later in the same payload matches this new row.
        existing.add(_ExistingContact(newId, nameKey, phoneKeys.toSet()));
      }

      // 5. Per-contact children + history — only for NEWLY-ADDED contacts.
      for (final table in _perContactChildTables) {
        if (!tables.containsKey(table)) continue;
        for (final raw in _rowsOf(tables[table])) {
          final senderCid = _asInt(raw['contact_id']);
          if (senderCid == null || !addedSenderIds.contains(senderCid)) {
            continue;
          }
          final row = Map<String, Object?>.from(raw)
            ..remove('id')
            ..['contact_id'] = senderToReceiver[senderCid];
          await txn.insert(table, row);
          if (table == 'call_logs') callLogsAdded++;
        }
      }

      // 6. Groups: match by name (groups.name is UNIQUE); map sender → receiver.
      final senderToGroup = <int, int>{};
      if (tables.containsKey('groups')) {
        final byName = <String, int>{};
        for (final g in await txn.query('groups', columns: ['id', 'name'])) {
          byName[(g['name'] ?? '').toString()] = g['id'] as int;
        }
        for (final raw in _rowsOf(tables['groups'])) {
          final senderGid = _asInt(raw['id']);
          if (senderGid == null) continue;
          final name = (raw['name'] ?? '').toString();
          final existingId = byName[name];
          if (existingId != null) {
            senderToGroup[senderGid] = existingId;
          } else {
            final row = Map<String, Object?>.from(raw)..remove('id');
            final newId = await txn.insert('groups', row);
            senderToGroup[senderGid] = newId;
            byName[name] = newId;
            groupsAdded++;
          }
        }
      }

      // 7. contact_groups (composite PK, no id): only for added contacts; remap
      //    both keys; skip a membership the receiver already has.
      if (tables.containsKey('contact_groups')) {
        final existingPairs = <String>{};
        for (final cg in await txn.query('contact_groups')) {
          existingPairs.add('${cg['contact_id']}:${cg['group_id']}');
        }
        for (final raw in _rowsOf(tables['contact_groups'])) {
          final scid = _asInt(raw['contact_id']);
          final sgid = _asInt(raw['group_id']);
          if (scid == null || !addedSenderIds.contains(scid)) continue;
          final rcid = senderToReceiver[scid];
          final rgid = sgid == null ? null : senderToGroup[sgid];
          if (rcid == null || rgid == null) continue;
          final key = '$rcid:$rgid';
          if (!existingPairs.add(key)) continue;
          await txn.insert('contact_groups', {
            'contact_id': rcid,
            'group_id': rgid,
          });
        }
      }

      // 8. relationships: remap BOTH endpoints (added or matched); dedupe.
      if (tables.containsKey('relationships')) {
        final existingRel = <String>{};
        for (final r in await txn.query('relationships')) {
          existingRel.add(
            '${r['contact_id']}:${r['related_contact_id']}:${r['relationship_type']}',
          );
        }
        for (final raw in _rowsOf(tables['relationships'])) {
          final scid = _asInt(raw['contact_id']);
          final srid = _asInt(raw['related_contact_id']);
          final rcid = scid == null ? null : senderToReceiver[scid];
          final rrid = srid == null ? null : senderToReceiver[srid];
          if (rcid == null || rrid == null) continue; // endpoint not present
          final type = raw['relationship_type'];
          final key = '$rcid:$rrid:$type';
          if (!existingRel.add(key)) continue;
          await txn.insert('relationships', {
            'contact_id': rcid,
            'related_contact_id': rrid,
            'relationship_type': type,
          });
        }
      }

      // 9. flagged_numbers: dedupe on (number_e164, kind).
      if (tables.containsKey('flagged_numbers')) {
        final existingFlag = <String>{};
        for (final f in await txn.query(
          'flagged_numbers',
          columns: ['number_e164', 'kind'],
        )) {
          existingFlag.add('${f['number_e164']}:${f['kind']}');
        }
        for (final raw in _rowsOf(tables['flagged_numbers'])) {
          final key = '${raw['number_e164']}:${raw['kind']}';
          if (!existingFlag.add(key)) continue;
          final row = Map<String, Object?>.from(raw)..remove('id');
          await txn.insert('flagged_numbers', row);
        }
      }

      // 10. Emergency info card: install only onto a phone that has none.
      await _applyEmergencyCard(txn, tables, senderToReceiver);

      // 11. One summary audit row: an incoming sync writes its rows table-wise
      // rather than through ContactRepository, so logging it per contact would
      // both be wrong (no snapshots) and bury the rest of the history.
      if (added > 0) {
        await AuditRepository.record(
          txn,
          contactId: null,
          contactName: 'Sync from another device',
          action: AuditAction.create,
          source: AuditSource.p2pSync,
          summary:
              '$added contact${added == 1 ? '' : 's'} added, '
              '$skipped already here',
        );
      }
    });

    // 12. Settings: overwrite on a full clone, fill-only on incremental.
    await _restoreSettings(meta['settings'], overwrite: fullMode);

    // If a card was installed, publish it (a no-op when none was).
    if (tables.containsKey('emergency_info')) {
      await EmergencyInfoRepository().pushMirror();
    }

    return SyncSummary(
      contactsAdded: added,
      contactsSkipped: skipped,
      groups: groupsAdded,
      callLogs: callLogsAdded,
    );
  }

  /// Installs the incoming emergency info card — but ONLY when this phone has no
  /// card of its own (no `emergency_info` row and no `emergency_contacts` rows).
  ///
  /// The card is a single record, so there is no add-only merge to do: either it
  /// fills an empty slot or the receiver keeps what it already has. Overwriting
  /// would silently replace one person's medical details with another's, which is
  /// exactly what must never happen — a phone that already has a card is left
  /// untouched.
  ///
  /// `contact_id` is remapped through [senderToReceiver] (which covers both the
  /// contacts added by this sync and the ones matched to existing rows). When the
  /// referenced contact did not travel at all the column is set to NULL: the
  /// entry snapshots the name and number, so the card still shows and dials.
  Future<void> _applyEmergencyCard(
    DatabaseExecutor txn,
    Map<String, dynamic> tables,
    Map<int, int> senderToReceiver,
  ) async {
    if (!tables.containsKey('emergency_info')) return;

    final existingInfo = await txn.query('emergency_info', limit: 1);
    final existingEntries = await txn.query('emergency_contacts', limit: 1);
    if (existingInfo.isNotEmpty || existingEntries.isNotEmpty) return;

    final infoRows = _rowsOf(tables['emergency_info']);
    if (infoRows.isEmpty) return;
    // The table holds at most one row; ignore anything beyond the first.
    await txn.insert('emergency_info', {
      ...infoRows.first,
      'id': EmergencyInfoRepository.rowId,
    });

    for (final raw in _rowsOf(tables['emergency_contacts'])) {
      final senderCid = _asInt(raw['contact_id']);
      final row = Map<String, Object?>.from(raw)
        ..remove('id')
        ..['contact_id'] = senderCid == null
            ? null
            : senderToReceiver[senderCid];
      await txn.insert('emergency_contacts', row);
    }
  }

  // ===========================================================================
  // Restore (FULL REPLACE) — used by BackupService, not by P2P sync
  // ===========================================================================

  /// Replaces ALL current data with the snapshot in [metaJson] + [files].
  ///
  /// Unlike [applyBundle] (add-only MERGE), this WIPES every managed table and
  /// reloads the backup VERBATIM: original ids, `is_self`, and `name_translit`
  /// are all preserved, so the result is an exact copy of the backup. Only the
  /// photo / calling-card paths are rewritten to the freshly written local files
  /// and ringtone paths are dropped (device-local). Settings are overwritten.
  ///
  /// The emergency info card travels too, and because a full replace keeps the
  /// original contact ids, `emergency_contacts.contact_id` stays valid with no
  /// remapping. A backup written before the card was part of the bundle carries
  /// no `emergency_info` / `emergency_contacts` key, and those tables are then
  /// left untouched rather than wiped (see [_optionalManagedTables]).
  ///
  /// Foreign keys stay ON: rows are deleted CHILD → PARENT and inserted
  /// PARENT → CHILD, so every reference is valid throughout. (SQLite ignores
  /// `PRAGMA foreign_keys` inside a transaction, so ordering — not toggling — is
  /// what keeps the load consistent.)
  Future<void> replaceAllFromBundle(
    String metaJson,
    List<IncomingFile> files,
  ) async {
    final meta = jsonDecode(metaJson);
    if (meta is! Map) throw const P2PException('Corrupt backup data');
    final tablesRaw = meta['tables'];
    if (tablesRaw is! Map) {
      throw const P2PException('Corrupt backup data (tables)');
    }
    final tables = tablesRaw.cast<String, dynamic>();
    _validateCaps(tables);

    // Write incoming media first; map ref → new local path.
    final refToPath = await _writeIncomingMedia(files);

    final managed = _managedTablesFor(tables);
    final db = await DatabaseHelper().database;
    await db.transaction((txn) async {
      // 1. Wipe every managed table, children first so no FK is left dangling.
      for (final table in managed.reversed) {
        await txn.delete(table);
      }
      // 2. Reload the snapshot verbatim, parents first so FKs always resolve.
      for (final table in managed) {
        final rows = _rowsOf(tables[table]);
        for (final raw in rows) {
          final row = Map<String, Object?>.from(raw);
          if (table == 'contacts') {
            row['photo_path'] = _resolveMedia(raw['photo_path'], refToPath);
            row['card_photo_path'] = _resolveMedia(
              raw['card_photo_path'],
              refToPath,
            );
            // Ringtone paths point at device-local files; drop them.
            row['ringtone_path'] = null;
          }
          await txn.insert(table, row);
        }
      }
      // Contact rows land verbatim, so a backup taken before a search key
      // existed restores rows with that key missing or stale — and search would
      // quietly miss those contacts. Rebuild both keys from the restored names.
      await DatabaseHelper().rebuildContactSearchKeys(txn);

      // The audit log describes the database that was just replaced: its rows
      // point at contact ids that now belong to the backup's contacts, so an
      // undo could write onto the wrong person. Drop it and start the history
      // at the restore. (The log is not in the managed tables, so the wipe above
      // does not touch it — this delete is deliberate, not incidental.)
      await txn.delete('audit_log');

      // A restore rewrites the contact tables wholesale rather than going
      // through ContactRepository, so it logs ONE summary entry instead of one
      // per contact. It carries no snapshot: the state it replaced is the whole
      // database, which the backup file itself already holds.
      final restored = _rowsOf(tables['contacts']).length;
      await AuditRepository.record(
        txn,
        contactId: null,
        contactName: 'All contacts',
        action: AuditAction.update,
        source: AuditSource.restore,
        summary: 'Everything replaced from a backup ($restored contacts)',
      );
    });

    // A full restore overwrites the current settings with the backup's.
    await _restoreSettings(meta['settings'], overwrite: true);

    // The lock-screen card is a copy of the rows we just replaced, so republish
    // (or clear) it now instead of leaving the old one up until the next launch.
    await EmergencyInfoRepository().pushMirror();
  }

  /// Writes incoming media into app storage and returns a ref → local-path map.
  /// Skipped entirely when there is no media (avoids touching path_provider on
  /// hosts/tests that lack it).
  Future<Map<String, String>> _writeIncomingMedia(
    List<IncomingFile> files,
  ) async {
    final refToPath = <String, String>{};
    if (files.isEmpty) return refToPath;
    final dir = Directory(
      p.join((await getApplicationDocumentsDirectory()).path, 'sync_media'),
    );
    await dir.create(recursive: true);
    for (final f in files) {
      final ext = f.ext.isEmpty ? 'img' : f.ext;
      final file = File(p.join(dir.path, '${_sanitize(f.ref)}.$ext'));
      await file.writeAsBytes(f.bytes, flush: true);
      refToPath[f.ref] = file.path;
    }
    return refToPath;
  }

  /// Loads the receiver's contacts as [_ExistingContact]s (id + name key + the
  /// set of that contact's phone keys) for natural-key matching.
  Future<List<_ExistingContact>> _loadExistingContactIndex(
    DatabaseExecutor txn,
  ) async {
    final contacts = await txn.query(
      'contacts',
      columns: ['id', 'first_name', 'middle_name', 'last_name'],
    );
    final phones = await txn.query(
      'phone_numbers',
      columns: ['contact_id', 'number'],
    );
    final phonesByContact = <int, Set<String>>{};
    for (final row in phones) {
      final cid = _asInt(row['contact_id']);
      final number = row['number'];
      if (cid == null || number is! String) continue;
      final key = _phoneKey(number);
      if (key.isEmpty) continue;
      (phonesByContact[cid] ??= <String>{}).add(key);
    }
    return [
      for (final c in contacts)
        _ExistingContact(
          c['id'] as int,
          _nameKey(c),
          phonesByContact[c['id'] as int] ?? const <String>{},
        ),
    ];
  }

  /// A receiver contact matches an incoming one when the normalized name is
  /// equal AND they share at least one phone number. A name-only or phone-only
  /// coincidence is NOT a match (chosen key: name + phone).
  int? _findMatch(
    List<_ExistingContact> existing,
    String nameKey,
    List<String> phoneKeys,
  ) {
    if (nameKey.isEmpty || phoneKeys.isEmpty) return null;
    final incoming = phoneKeys.toSet();
    for (final e in existing) {
      if (e.nameKey != nameKey) continue;
      if (e.phoneKeys.any(incoming.contains)) return e.id;
    }
    return null;
  }

  /// Normalized full name: first + middle + last, lowercased, spaces collapsed.
  String _nameKey(Map<dynamic, dynamic> row) {
    final parts = [
      row['first_name'],
      row['middle_name'],
      row['last_name'],
    ].whereType<String>().where((s) => s.trim().isNotEmpty).join(' ');
    return parts.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Phone match key: digits only, last 10 (folds most country-code variance).
  String _phoneKey(String number) {
    final digits = number.replaceAll(RegExp(r'\D'), '');
    return digits.length > 10 ? digits.substring(digits.length - 10) : digits;
  }

  List<Map<String, Object?>> _rowsOf(dynamic tableValue) {
    if (tableValue is! List) return [];
    return [
      for (final r in tableValue)
        if (r is Map) Map<String, Object?>.from(r),
    ];
  }

  int? _asInt(Object? v) => v is int ? v : (v is num ? v.toInt() : null);

  /// Turns a stored path value into a local one: a `@sync:<ref>` sentinel maps
  /// to the file we just wrote (or null if it's missing); anything else is
  /// dropped (a raw sender path is meaningless here).
  Object? _resolveMedia(Object? value, Map<String, String> refToPath) {
    if (value is! String || value.isEmpty) return null;
    if (value.startsWith(_mediaSentinel)) {
      final ref = value.substring(_mediaSentinel.length);
      return refToPath[ref];
    }
    return null;
  }

  void _validateCaps(Map<String, dynamic> tables) {
    var total = 0;
    for (final entry in tables.entries) {
      final rows = entry.value;
      if (rows is! List) continue;
      total += rows.length;
      if (total > _maxTotalRows) {
        throw const P2PException('Sync data is too large; aborting');
      }
      for (final row in rows) {
        if (row is! Map) continue;
        for (final v in row.values) {
          if (v is String && v.length > _maxFieldLen) {
            throw const P2PException(
              'A field in the sync data is too large; aborting',
            );
          }
        }
      }
    }
  }

  Future<void> _restoreSettings(
    dynamic settings, {
    required bool overwrite,
  }) async {
    if (settings is! List) return;
    final prefs = await SharedPreferences.getInstance();
    for (final e in settings) {
      if (e is! Map) continue;
      final key = e['key'];
      final type = e['type'];
      final value = e['value'];
      if (key is! String || type is! String) continue;
      if (!_syncedSettingKeys.contains(key)) continue; // ignore unexpected keys
      // Fill-only (incremental): never override a key the receiver already set.
      if (!overwrite && prefs.containsKey(key)) continue;
      try {
        switch (type) {
          case 'bool':
            await prefs.setBool(key, value as bool);
            break;
          case 'int':
            await prefs.setInt(key, (value as num).toInt());
            break;
          case 'double':
            await prefs.setDouble(key, (value as num).toDouble());
            break;
          case 'stringList':
            await prefs.setStringList(
              key,
              (value as List).map((e) => e.toString()).toList(),
            );
            break;
          default:
            await prefs.setString(key, value.toString());
        }
      } catch (_) {
        // Skip a malformed setting rather than fail the whole sync.
      }
    }
  }

  String _sanitize(String ref) =>
      ref.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');

  /// The schema version sqflite stored for this database (via PRAGMA
  /// user_version). Used to refuse a sync between mismatched app versions.
  Future<int> _dbVersion(Database db) async {
    final result = await db.rawQuery('PRAGMA user_version');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}

/// A receiver contact reduced to its match key (id + normalized name + phone
/// keys), used to decide whether an incoming contact is already present.
class _ExistingContact {
  final int id;
  final String nameKey;
  final Set<String> phoneKeys;
  _ExistingContact(this.id, this.nameKey, this.phoneKeys);
}
