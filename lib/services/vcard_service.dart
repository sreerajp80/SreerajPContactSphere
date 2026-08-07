// lib/services/vcard_service.dart
//
// Builds and parses vCards (RFC 2426, version 3.0) for single-contact sharing,
// whole-book export/import, and the QR-code share payload. No hand-rolled vCard
// syntax here: the app `Contact` is mapped to a `flutter_contacts` contact with
// the exact same mappers the two-way device sync uses (DeviceContactService),
// and flutter_contacts' pure-Dart vCard writer/reader does the serialization —
// so a shared vCard always matches what the device book would hold.

import 'package:flutter_contacts/flutter_contacts.dart' as fc;

import 'package:smart_contacts_dialer/models/address.dart';
import 'package:smart_contacts_dialer/models/contact.dart';
import 'package:smart_contacts_dialer/services/device_contact_service.dart';

class VCardService {
  static final VCardService _instance = VCardService._internal();
  factory VCardService() => _instance;
  VCardService._internal();

  final DeviceContactService _mapper = DeviceContactService();

  /// Above this many characters a QR code becomes too dense for phone cameras
  /// to scan reliably (hard capacity is ~2.9 KB; readability degrades well
  /// before that), so [qrPayload] progressively trims the vCard to fit.
  static const int qrMaxChars = 1200;

  /// The vCard version to serialize with. Standard vCard 3.0 (RFC 2426) is
  /// used for all exports so external messaging apps (e.g. WhatsApp, Telegram)
  /// and modern device contact readers can parse and preview the contact card natively.
  static fc.VCardVersion _version(bool externalShare) => fc.VCardVersion.v3;

  /// [c] serialized as a single vCard block. [includePhoto] embeds the avatar
  /// as base64 when the photo file exists. Pass [externalShare] true for a
  /// `.vcf` that will be imported on another phone (see [_version]).
  String toVCard(
    Contact c, {
    bool includePhoto = true,
    bool externalShare = false,
  }) {
    final raw = fc.FlutterContacts.vCard.export(
      _mapper.mapToDevice(c, includePhoto: includePhoto),
      version: _version(externalShare),
    );
    return _postProcessVCard(raw, externalShare);
  }

  /// All of [contacts] concatenated into one multi-contact vCard document —
  /// the standard whole-address-book `.vcf` layout. Pass [externalShare] true
  /// for a `.vcf` that will be imported on another phone (see [_version]).
  String toVCardAll(
    List<Contact> contacts, {
    bool includePhoto = true,
    bool externalShare = false,
  }) {
    final raw = fc.FlutterContacts.vCard.exportAll([
      for (final c in contacts)
        _mapper.mapToDevice(c, includePhoto: includePhoto),
    ], version: _version(externalShare));
    return _postProcessVCard(raw, externalShare);
  }

  /// Normalizes phone type parameters (TEL;TYPE=CELL) and CRLF line endings
  /// for strict vCard parsers like WhatsApp.
  String _postProcessVCard(String raw, bool externalShare) {
    if (!externalShare) return raw;
    final lines = raw.split(RegExp(r'\r?\n'));
    final processed = lines.map((line) {
      if (line.startsWith('TEL;TYPE=VOICE:')) {
        return line.replaceFirst('TEL;TYPE=VOICE:', 'TEL;TYPE=CELL:');
      }
      if (line.startsWith('TEL:')) {
        return line.replaceFirst('TEL:', 'TEL;TYPE=CELL:');
      }
      if (line.startsWith('TEL;TYPE=') &&
          !line.contains('CELL') &&
          !line.contains('MOBILE') &&
          !line.contains('HOME') &&
          !line.contains('WORK')) {
        return line.replaceFirst('TEL;TYPE=', 'TEL;TYPE=CELL,');
      }
      return line;
    }).join('\r\n');
    return '$processed\r\n';
  }

  /// Parses every `BEGIN:VCARD … END:VCARD` block in [text] into app contacts,
  /// skipping blocks with no usable name. Parsed contacts are app-only rows
  /// ([Contact.deviceId] null) until saved through ContactSyncService, which
  /// pushes them to the device book. [persistPhotos] writes embedded photos to
  /// disk; pass false in host-side tests where path_provider is unavailable.
  Future<List<Contact>> fromVCard(
    String text, {
    bool persistPhotos = true,
  }) async {
    final parsed = fc.FlutterContacts.vCard.import(text);
    final result = <Contact>[];
    for (final d in parsed) {
      final c = await _mapper.mapToApp(d, persistPhoto: persistPhotos);
      if (c == null) continue;
      // The mapper carries the source's id over as a device link; a vCard is
      // free-standing text, so there is no device row to link to.
      c.deviceId = null;
      result.add(c);
    }
    return result;
  }

  /// The vCard used as a QR-code payload: never a photo (far too large), and
  /// when the result would still be too dense to scan, social links and then
  /// addresses are dropped — name, phones, emails, and org details always stay.
  String qrPayload(Contact c) {
    final slim =
        Contact(
            salutation: c.salutation,
            firstName: c.firstName,
            middleName: c.middleName,
            lastName: c.lastName,
            dob: c.dob,
          )
          ..phoneNumbers = c.phoneNumbers
          ..emails = c.emails
          ..addresses = c.addresses
          ..socialLinks = c.socialLinks
          ..officialDetails = c.officialDetails;

    var payload = toVCard(slim, includePhoto: false);
    if (payload.length <= qrMaxChars) return payload;

    slim.socialLinks = [];
    payload = toVCard(slim, includePhoto: false);
    if (payload.length <= qrMaxChars) return payload;

    // Keep the org name (it rides on an address row's companyName) but drop
    // the street addresses themselves.
    slim.addresses = [
      for (final a in c.addresses)
        if (a.companyName?.isNotEmpty ?? false)
          Address(type: a.type, companyName: a.companyName),
    ];
    return toVCard(slim, includePhoto: false);
  }
}
