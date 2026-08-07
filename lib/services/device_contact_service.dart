// lib/services/device_contact_service.dart
//
// Thin wrapper over `flutter_contacts` that maps the device address book to and
// from the app's own `Contact` aggregate. Every platform call is defensive: a
// denied permission, a non-Android host (e.g. `flutter test`, where there is no
// platform channel), or any plugin error degrades to a safe default instead of
// throwing — mirroring PermissionService's never-throw philosophy so the rest of
// the app keeps working without device access.

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:smart_contacts_dialer/core/logging/app_logger.dart';
import 'package:smart_contacts_dialer/models/address.dart';
import 'package:smart_contacts_dialer/models/contact.dart';
import 'package:smart_contacts_dialer/models/email.dart';
import 'package:smart_contacts_dialer/models/official_details.dart';
import 'package:smart_contacts_dialer/models/phone_number.dart';
import 'package:smart_contacts_dialer/models/social_link.dart';
import 'package:smart_contacts_dialer/services/device_account.dart';

class DeviceContactService {
  static final DeviceContactService _instance =
      DeviceContactService._internal();
  factory DeviceContactService() => _instance;
  DeviceContactService._internal();

  /// Native bridge used only to create a contact in the phone's **local**
  /// (NULL/NULL) account. flutter_contacts 2.1.0 cannot target the local
  /// account — an empty `Account` is discarded and `create()` falls back to the
  /// user's default (cloud) account — so the "Device" destination is written
  /// through this channel instead. Real accounts still go through the plugin.
  static const MethodChannel _localChannel = MethodChannel(
    'contact_sphere/contacts_local',
  );

  /// True when the contacts permission is already granted (no prompt).
  Future<bool> isGranted() async {
    try {
      return await fc.FlutterContacts.permissions.has(
        fc.PermissionType.readWrite,
      );
    } catch (e, st) {
      AppLogger.error(
        'DeviceContactService.isGranted failed',
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }

  /// Ensures read+write access to the device book, prompting if needed.
  /// Returns false (never throws) when denied or unavailable.
  Future<bool> ensurePermission() async {
    try {
      if (await isGranted()) return true;
      final status = await fc.FlutterContacts.permissions.request(
        fc.PermissionType.readWrite,
      );
      return status == fc.PermissionStatus.granted ||
          status == fc.PermissionStatus.limited;
    } catch (e, st) {
      AppLogger.error(
        'DeviceContactService.ensurePermission failed',
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }

  /// Properties pulled for the fast list path: enough to render and search a
  /// card (name, phone, email) but **no photos** and none of the heavy detail —
  /// the full-res/thumbnail photo bytes are what make a 500+ contact fetch slow.
  static const Set<fc.ContactProperty> _lightProperties = {
    fc.ContactProperty.name,
    fc.ContactProperty.phone,
    fc.ContactProperty.email,
  };

  /// All device contacts mapped to app [Contact]s (each with [deviceId] set).
  /// Returns an empty list when the permission is missing (a legitimate
  /// "nothing to read"), but **null when the fetch itself failed** — callers
  /// like the DB sync must be able to tell a broken read from an empty book,
  /// so a transient failure is never mistaken for "no contacts". Never throws.
  ///
  /// [fullDetail] pulls every property **including photos** and persists each
  /// photo to disk — used by the background DB sync. The default light fetch
  /// skips photos and the disk writes so the list can be shown quickly.
  Future<List<Contact>?> fetchDeviceContacts({bool fullDetail = false}) async {
    try {
      if (!await ensurePermission()) return const <Contact>[];
      final devices = await fc.FlutterContacts.getAll(
        properties: fullDetail ? fc.ContactProperties.all : _lightProperties,
      );
      final result = <Contact>[];
      for (final d in devices) {
        final mapped = await _toApp(d, persistPhoto: fullDetail);
        if (mapped != null) result.add(mapped);
      }
      return result;
    } catch (e, st) {
      AppLogger.error(
        'DeviceContactService.fetchDeviceContacts failed',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// How many contacts are in the device address book, or null when the
  /// permission is not granted or the read fails (so callers can distinguish
  /// "unknown" from a real zero). Uses the light fetch (no photos). Never throws.
  Future<int?> deviceContactCount() async {
    try {
      if (!await isGranted()) return null;
      final devices = await fetchDeviceContacts();
      return devices?.length;
    } catch (e, st) {
      AppLogger.error(
        'DeviceContactService.deviceContactCount failed',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// The destinations the app can write device contacts to: the phone's local
  /// "Device" storage first, then the real platform accounts (Google, …). Empty
  /// (never throws) when the permission is missing or the query fails.
  Future<List<WritableAccount>> writableAccounts() async {
    final result = <WritableAccount>[WritableAccount.local];
    try {
      if (!await isGranted()) return result;
      final accounts = await fc.FlutterContacts.accounts.getAll();
      for (final a in accounts) {
        result.add(WritableAccount.forAccount(a));
      }
    } catch (e, st) {
      AppLogger.error(
        'DeviceContactService.writableAccounts failed',
        error: e,
        stackTrace: st,
      );
    }
    return result;
  }

  /// Creates or updates the device contact mirroring [c] and returns its device
  /// id, or **null on failure** so callers can tell a real write from a failed
  /// one (a device-write failure must never block the local save). [target]
  /// picks where a *new* contact is created — the local "Device" storage
  /// (written natively) or a real account (written through the plugin);
  /// defaults to local. Updates go by id and ignore [target].
  Future<String?> upsertDeviceContact(
    Contact c, {
    WritableAccount? target,
  }) async {
    try {
      if (!await ensurePermission()) return null;

      final existingId = c.deviceId;
      if (existingId != null) {
        // In flutter_contacts 2.1.0 `get()` THROWS for a missing id (it does not
        // return null), so a stale link — the device contact was deleted out
        // from under us — must be caught here and fall through to recreate.
        fc.Contact? existing;
        try {
          existing = await fc.FlutterContacts.get(
            existingId,
            properties: fc.ContactProperties.all,
          );
        } catch (_) {
          existing = null;
        }
        if (existing != null) {
          await fc.FlutterContacts.update(_toDevice(c, base: existing));
          return existingId;
        }
        // Stale link — recreate below.
      }

      final dest = target ?? WritableAccount.local;
      if (dest.isLocal) {
        return await _createLocalContact(c);
      }
      return await fc.FlutterContacts.create(
        _toDevice(c),
        account: dest.account,
      );
    } catch (e, st) {
      AppLogger.error(
        'DeviceContactService.upsertDeviceContact failed',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// Creates [c] in the phone's local (NULL/NULL) account via the native
  /// bridge, returning the new contact id or null on failure.
  Future<String?> _createLocalContact(Contact c) async {
    try {
      final id = await _localChannel.invokeMethod<String>(
        'createLocalContact',
        _localPayload(c),
      );
      return (id != null && id.isNotEmpty) ? id : null;
    } catch (e, st) {
      AppLogger.error(
        'DeviceContactService._createLocalContact failed',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// Deletes the device contact with [deviceId]. Best-effort; swallows errors.
  Future<void> deleteDeviceContact(String deviceId) async {
    try {
      if (!await ensurePermission()) return;
      await fc.FlutterContacts.delete(deviceId);
    } catch (e, st) {
      AppLogger.error(
        'DeviceContactService.deleteDeviceContact failed',
        error: e,
        stackTrace: st,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Public mapping (used by VCardService for vCard/QR share and import)
  // ---------------------------------------------------------------------------

  /// Maps an app [Contact] to a `flutter_contacts` contact without touching the
  /// device book — the same mapping the two-way sync writes with. Pass
  /// [includePhoto] false for payloads that must stay small (QR codes).
  fc.Contact mapToDevice(Contact c, {bool includePhoto = true}) =>
      _toDevice(c, includePhoto: includePhoto);

  /// Maps a `flutter_contacts` contact (e.g. parsed from a vCard) to an app
  /// [Contact], or null when it has no usable name. [persistPhoto] writes the
  /// embedded photo to disk and sets [Contact.photoPath]; pass false in
  /// host-side tests where path_provider is unavailable.
  Future<Contact?> mapToApp(fc.Contact d, {bool persistPhoto = true}) =>
      _toApp(d, persistPhoto: persistPhoto);

  // ---------------------------------------------------------------------------
  // Mapping: device -> app
  // ---------------------------------------------------------------------------

  Future<Contact?> _toApp(fc.Contact d, {bool persistPhoto = true}) async {
    final name = d.name;
    final first = (name?.first?.trim().isNotEmpty ?? false)
        ? name!.first!.trim()
        : null;
    // app Contact.firstName is required & non-empty; fall back to the display
    // name, then — like the OS contacts app — to the first phone number or
    // email, so a nameless device contact is still shown instead of dropped.
    final firstName =
        first ??
        ((d.displayName?.trim().isNotEmpty ?? false)
            ? d.displayName!.trim()
            : null) ??
        _firstNonBlank(d.phones.map((p) => p.number)) ??
        _firstNonBlank(d.emails.map((e) => e.address));
    if (firstName == null) return null; // nothing usable to show

    final contact = Contact(
      deviceId: d.id,
      salutation: _blankToNull(name?.prefix),
      firstName: firstName,
      middleName: _blankToNull(name?.middle),
      lastName: _blankToNull(name?.last),
    );

    contact.phoneNumbers = [
      for (final ph in d.phones)
        PhoneNumber(
          number: ph.number,
          label: _labelText(ph.label.customLabel, ph.label.label.name),
          type: 'personal',
          isPrimary: ph.isPrimary ?? false,
        ),
    ];

    contact.emails = [
      for (final e in d.emails)
        Email(
          email: e.address,
          label: _labelText(e.label.customLabel, e.label.label.name),
          type: 'personal',
          isPrimary: e.isPrimary ?? false,
        ),
    ];

    contact.addresses = [
      for (final a in d.addresses)
        Address(
          type: a.label.label == fc.AddressLabel.work ? 'official' : 'personal',
          street: _blankToNull(a.street),
          cityTown: _blankToNull(a.city),
          state: _blankToNull(a.state),
          postalCode: _blankToNull(a.postalCode),
          country: _blankToNull(a.country),
        ),
    ];

    // Organization -> official details (designation/department). A company name
    // with no matching address is preserved as an official address.
    if (d.organizations.isNotEmpty) {
      final org = d.organizations.first;
      final designation = _blankToNull(org.jobTitle);
      final department = _blankToNull(org.departmentName);
      if (designation != null || department != null) {
        contact.officialDetails = OfficialDetails(
          designation: designation,
          department: department,
        );
      }
      final company = _blankToNull(org.name);
      if (company != null &&
          !contact.addresses.any((a) => a.type == 'official')) {
        contact.addresses.add(Address(type: 'official', companyName: company));
      }
    }

    contact.socialLinks = [
      for (final s in d.socialMedias)
        SocialLink(
          label: _labelText(s.label.customLabel, s.label.label.name),
          value: s.username,
        ),
      for (final w in d.websites) SocialLink(label: 'website', value: w.url),
    ];

    // Events -> dob / anniversary.
    for (final ev in d.events) {
      final date = DateTime(ev.year ?? 1900, ev.month, ev.day);
      if (ev.label.label == fc.EventLabel.birthday) {
        contact.dob = date;
      } else if (ev.label.label == fc.EventLabel.anniversary) {
        contact.anniversary = date;
      }
    }

    if (persistPhoto) contact.photoPath = await _persistPhoto(d);
    return contact;
  }

  // ---------------------------------------------------------------------------
  // Mapping: app -> device
  // ---------------------------------------------------------------------------

  fc.Contact _toDevice(
    Contact c, {
    fc.Contact? base,
    bool includePhoto = true,
  }) {
    final phones = [
      for (final ph in c.phoneNumbers)
        fc.Phone(number: ph.number, label: _phoneLabel(ph.label)),
    ];
    final emails = [
      for (final e in c.emails)
        fc.Email(address: e.email, label: _emailLabel(e.label)),
    ];
    final addresses = [
      for (final a in c.addresses)
        fc.Address(
          street: [
            a.houseName,
            a.street,
            a.postOffice,
            a.villageMunicipality,
          ].where((e) => e != null && e.isNotEmpty).join(', '),
          city: a.cityTown,
          state: a.state,
          postalCode: a.postalCode,
          country: a.country,
          label: a.type == 'official'
              ? const fc.Label(fc.AddressLabel.work)
              : const fc.Label(fc.AddressLabel.home),
        ),
    ];

    final organizations = <fc.Organization>[];
    final od = c.officialDetails;
    final officialCompany = c.addresses
        .firstWhere(
          (a) => a.type == 'official' && (a.companyName?.isNotEmpty ?? false),
          orElse: () => Address(type: 'official'),
        )
        .companyName;
    if ((od != null && !od.isEmpty) || (officialCompany?.isNotEmpty ?? false)) {
      organizations.add(
        fc.Organization(
          name: officialCompany ?? '',
          jobTitle: od?.designation ?? '',
          departmentName: od?.department ?? '',
        ),
      );
    }

    final socialMedias = [
      for (final s in c.socialLinks)
        fc.SocialMedia(
          username: s.value,
          label: fc.Label(fc.SocialMediaLabel.other, s.label),
        ),
    ];

    final events = <fc.Event>[];
    if (c.dob != null) {
      events.add(
        fc.Event(
          year: c.dob!.year,
          month: c.dob!.month,
          day: c.dob!.day,
          label: const fc.Label(fc.EventLabel.birthday),
        ),
      );
    }
    if (c.anniversary != null) {
      events.add(
        fc.Event(
          year: c.anniversary!.year,
          month: c.anniversary!.month,
          day: c.anniversary!.day,
          label: const fc.Label(fc.EventLabel.anniversary),
        ),
      );
    }

    return fc.Contact(
      id: base?.id,
      metadata: base?.metadata,
      name: fc.Name(
        prefix: c.salutation ?? '',
        first: c.firstName,
        middle: c.middleName ?? '',
        last: c.lastName ?? '',
      ),
      phones: phones,
      emails: emails,
      addresses: addresses,
      organizations: organizations,
      socialMedias: socialMedias,
      events: events,
      photo: includePhoto ? _photoBytes(c) : null,
    );
  }

  // ---------------------------------------------------------------------------
  // Mapping: app -> native local-insert payload
  // ---------------------------------------------------------------------------

  // Standard ContactsContract type ints, resolved here so the native writer
  // stays a dumb builder. (Phone/Email/Postal/Event CommonDataKinds TYPE_*.)
  static const int _phoneTypeHome = 1;
  static const int _phoneTypeMobile = 2;
  static const int _phoneTypeWork = 3;
  static const int _phoneTypeCustom = 0;
  static const int _emailTypeHome = 1;
  static const int _emailTypeWork = 2;
  static const int _emailTypeCustom = 0;
  static const int _postalTypeHome = 1;
  static const int _postalTypeWork = 2;
  static const int _eventTypeAnniversary = 1;
  static const int _eventTypeBirthday = 3;

  /// Builds the compact map the native `createLocalContact` consumes. Mirrors
  /// the field set of [_toDevice]; social links are omitted on the local path
  /// (they use no standard mimetype) — they are preserved when writing to a real
  /// account through the plugin.
  Map<String, dynamic> _localPayload(Contact c) {
    final phones = [
      for (final ph in c.phoneNumbers)
        if (ph.number.trim().isNotEmpty)
          () {
            final (type, label) = _phoneAndroidType(ph.label);
            return {'number': ph.number, 'type': type, 'label': label};
          }(),
    ];
    final emails = [
      for (final e in c.emails)
        if (e.email.trim().isNotEmpty)
          () {
            final (type, label) = _emailAndroidType(e.label);
            return {'address': e.email, 'type': type, 'label': label};
          }(),
    ];
    final addresses = [
      for (final a in c.addresses)
        {
          'street': [
            a.houseName,
            a.street,
            a.postOffice,
            a.villageMunicipality,
          ].where((e) => e != null && e.isNotEmpty).join(', '),
          'city': a.cityTown,
          'state': a.state,
          'postalCode': a.postalCode,
          'country': a.country,
          'type': a.type == 'official' ? _postalTypeWork : _postalTypeHome,
        },
    ];

    final od = c.officialDetails;
    final officialCompany = c.addresses
        .firstWhere(
          (a) => a.type == 'official' && (a.companyName?.isNotEmpty ?? false),
          orElse: () => Address(type: 'official'),
        )
        .companyName;
    final Map<String, dynamic>? organization =
        ((od != null && !od.isEmpty) || (officialCompany?.isNotEmpty ?? false))
        ? {
            'company': officialCompany,
            'title': od?.designation,
            'department': od?.department,
          }
        : null;

    final events = <Map<String, dynamic>>[];
    if (c.dob != null) {
      events.add({
        'type': _eventTypeBirthday,
        'year': c.dob!.year == 1900 ? null : c.dob!.year,
        'month': c.dob!.month,
        'day': c.dob!.day,
      });
    }
    if (c.anniversary != null) {
      events.add({
        'type': _eventTypeAnniversary,
        'year': c.anniversary!.year == 1900 ? null : c.anniversary!.year,
        'month': c.anniversary!.month,
        'day': c.anniversary!.day,
      });
    }

    // All social links become Im rows natively — matching the plugin path
    // (`_toDevice` maps every social link to a SocialMedia/Im row, never a
    // website), so a local-account save keeps them and they round-trip back.
    final socialLinks = [
      for (final s in c.socialLinks)
        if (s.value.trim().isNotEmpty) {'value': s.value, 'label': s.label},
    ];

    return {
      'prefix': c.salutation,
      'first': c.firstName,
      'middle': c.middleName,
      'last': c.lastName,
      'phones': phones,
      'emails': emails,
      'addresses': addresses,
      'organization': organization,
      'events': events,
      'socialLinks': socialLinks,
      'photo': _photoRawBytes(c),
    };
  }

  /// (androidType, customLabel) for a free-text phone [label].
  static (int, String?) _phoneAndroidType(String? label) {
    switch (label?.toLowerCase().trim()) {
      case 'mobile':
      case 'cell':
        return (_phoneTypeMobile, null);
      case 'home':
        return (_phoneTypeHome, null);
      case 'work':
      case 'office':
        return (_phoneTypeWork, null);
      case null:
      case '':
        return (_phoneTypeMobile, null);
      default:
        return (_phoneTypeCustom, label);
    }
  }

  /// (androidType, customLabel) for a free-text email [label].
  static (int, String?) _emailAndroidType(String? label) {
    switch (label?.toLowerCase().trim()) {
      case 'home':
        return (_emailTypeHome, null);
      case 'work':
      case 'office':
        return (_emailTypeWork, null);
      case null:
      case '':
        return (_emailTypeHome, null);
      default:
        return (_emailTypeCustom, label);
    }
  }

  /// Raw photo bytes for the native payload (Uint8List), or null.
  Uint8List? _photoRawBytes(Contact c) {
    try {
      final path = c.photoPath;
      if (path == null) return null;
      final file = File(path);
      if (!file.existsSync()) return null;
      return file.readAsBytesSync();
    } catch (e, st) {
      AppLogger.error(
        'DeviceContactService._photoRawBytes failed',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static String? _blankToNull(String? s) =>
      (s != null && s.trim().isNotEmpty) ? s.trim() : null;

  /// The first non-blank value in [values] (trimmed), or null.
  static String? _firstNonBlank(Iterable<String> values) {
    for (final v in values) {
      final t = v.trim();
      if (t.isNotEmpty) return t;
    }
    return null;
  }

  /// Prefers a free-text custom label; falls back to the enum name, dropping the
  /// uninformative defaults so they don't surface as visible labels.
  static String? _labelText(String? custom, String enumName) {
    if (custom != null && custom.trim().isNotEmpty) return custom.trim();
    if (enumName == 'mobile' || enumName == 'home' || enumName == 'other') {
      return null;
    }
    return enumName;
  }

  static fc.Label<fc.PhoneLabel> _phoneLabel(String? label) {
    switch (label?.toLowerCase().trim()) {
      case 'mobile':
      case 'cell':
        return const fc.Label(fc.PhoneLabel.mobile);
      case 'home':
        return const fc.Label(fc.PhoneLabel.home);
      case 'work':
      case 'office':
        return const fc.Label(fc.PhoneLabel.work);
      case null:
      case '':
        return const fc.Label(fc.PhoneLabel.mobile);
      default:
        return fc.Label(fc.PhoneLabel.other, label);
    }
  }

  static fc.Label<fc.EmailLabel> _emailLabel(String? label) {
    switch (label?.toLowerCase().trim()) {
      case 'home':
        return const fc.Label(fc.EmailLabel.home);
      case 'work':
      case 'office':
        return const fc.Label(fc.EmailLabel.work);
      case null:
      case '':
        return const fc.Label(fc.EmailLabel.home);
      default:
        return fc.Label(fc.EmailLabel.other, label);
    }
  }

  fc.Photo? _photoBytes(Contact c) {
    try {
      final path = c.photoPath;
      if (path == null) return null;
      final file = File(path);
      if (!file.existsSync()) return null;
      final bytes = file.readAsBytesSync();
      return fc.Photo(fullSize: bytes, thumbnail: bytes);
    } catch (e, st) {
      AppLogger.error(
        'DeviceContactService._photoBytes failed',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// Writes the device contact's photo (if any) to a file under the app's
  /// documents dir and returns its path, or null when there is no photo.
  Future<String?> _persistPhoto(fc.Contact d) async {
    try {
      final Uint8List? bytes = d.photo?.fullSize ?? d.photo?.thumbnail;
      if (bytes == null || bytes.isEmpty) return null;
      final dir = await getApplicationDocumentsDirectory();
      final photoDir = Directory(p.join(dir.path, 'device_photos'));
      if (!await photoDir.exists()) await photoDir.create(recursive: true);
      // vCard-parsed contacts have no device id — fall back to a unique name.
      final id = d.id;
      final baseName = (id != null && id.isNotEmpty)
          ? id
          : 'vcf_${DateTime.now().microsecondsSinceEpoch}';
      final file = File(p.join(photoDir.path, '$baseName.jpg'));
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    } catch (e, st) {
      AppLogger.error(
        'DeviceContactService._persistPhoto failed',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }
}
