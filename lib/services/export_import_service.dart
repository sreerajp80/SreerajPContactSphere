// lib/services/export_import_service.dart
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:smart_contacts_dialer/models/audit_entry.dart';
import 'package:smart_contacts_dialer/models/contact.dart';
import 'package:smart_contacts_dialer/models/email.dart';
import 'package:smart_contacts_dialer/models/phone_number.dart';
import 'package:smart_contacts_dialer/repositories/contact_repository.dart';
import 'package:smart_contacts_dialer/services/contact_sync_service.dart';
import 'package:smart_contacts_dialer/services/vcard_service.dart';
import 'package:smart_contacts_dialer/utils/filename_utils.dart';

class ExportImportService {
  final ContactRepository _repository = ContactRepository();

  static const List<String> _header = [
    'Salutation',
    'First Name',
    'Middle Name',
    'Last Name',
    'Gender',
    'DOB',
    'Blood Group',
    'Anniversary',
    'Meetiversary',
    'Phone Numbers',
    'Emails',
    'Personal Address',
    'Official Address',
    'Designation',
    'Department',
    'Groups',
  ];

  /// Exports contacts to a CSV file in the temp directory and opens the
  /// system share sheet. Secret contacts are included only when
  /// [includeSecret] is true. Returns the path of the file written.
  Future<String> exportContacts({bool includeSecret = false}) async {
    final contacts = await _repository.getAllContacts(
      includeSecret: includeSecret,
    );
    return _writeAndShareCsv(contacts, 'contacts_export');
  }

  /// Exports only the secret contacts to a CSV file and opens the share
  /// sheet. Throws a [StateError] when there are no secret contacts.
  Future<String> exportSecretContacts() async {
    final contacts = await _repository.getAllContacts(secretOnly: true);
    if (contacts.isEmpty) throw StateError('No secret contacts to export');
    return _writeAndShareCsv(contacts, 'secret_contacts_export');
  }

  /// Encodes [contacts] as CSV, writes it to the temp directory as
  /// `<filePrefix>_<timestamp>.csv`, and opens the system share sheet. The CSV
  /// is written with a UTF-8 BOM (`addBom: true`) so Excel / Google Sheets read
  /// it as UTF-8 and show non-ASCII names (e.g. Devanagari) correctly instead of
  /// mojibake — the app's own re-import is unaffected because the csv decoder
  /// strips a leading BOM.
  Future<String> _writeAndShareCsv(
    List<Contact> contacts,
    String filePrefix,
  ) async {
    final rows = <List<dynamic>>[
      _header,
      for (final contact in contacts)
        [
          contact.salutation ?? '',
          contact.firstName,
          contact.middleName ?? '',
          contact.lastName ?? '',
          contact.gender ?? '',
          contact.dob?.toIso8601String() ?? '',
          contact.bloodGroup ?? '',
          contact.anniversary?.toIso8601String() ?? '',
          contact.meetiversary?.toIso8601String() ?? '',
          contact.phoneNumbers
              .map((ph) => '${ph.label ?? ''}:${ph.number}')
              .join(';'),
          contact.emails.map((e) => '${e.label ?? ''}:${e.email}').join(';'),
          contact.addresses
              .where((a) => a.type == 'personal')
              .map((a) => a.formatted)
              .join(' | '),
          contact.addresses
              .where((a) => a.type == 'official')
              .map((a) => a.formatted)
              .join(' | '),
          contact.officialDetails?.designation ?? '',
          contact.officialDetails?.department ?? '',
          contact.groups.join(';'),
        ],
    ];

    final csv = Csv(addBom: true).encode(rows);

    final dir = await getTemporaryDirectory();
    final baseName = contacts.length == 1
        ? sanitizeFileName(contacts.first.fullName, fallback: filePrefix)
        : '${filePrefix}_${DateTime.now().millisecondsSinceEpoch}';
    final fileName = '$baseName.csv';
    final file = File(p.join(dir.path, fileName));
    await file.writeAsString(csv);

    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], subject: fileName),
    );
    return file.path;
  }

  /// Exports contacts (photos included) as a single multi-contact vCard 3.0
  /// file in the temp directory and opens the system share sheet. Secret
  /// contacts are included only when [includeSecret] is true. Returns the
  /// path of the file written.
  Future<String> exportContactsVcf({bool includeSecret = false}) async {
    final contacts = await _repository.getAllContacts(
      includeSecret: includeSecret,
    );
    return _writeAndShareVcf(contacts, 'contacts_export');
  }

  /// Exports only the secret contacts as a vCard 3.0 file and opens the share
  /// sheet. Throws a [StateError] when there are no secret contacts.
  Future<String> exportSecretContactsVcf() async {
    final contacts = await _repository.getAllContacts(secretOnly: true);
    if (contacts.isEmpty) throw StateError('No secret contacts to export');
    return _writeAndShareVcf(contacts, 'secret_contacts_export');
  }

  /// Encodes [contacts] as one multi-contact vCard, writes it to the temp
  /// directory as `<filePrefix>_<timestamp>.vcf`, and opens the share sheet.
  Future<String> _writeAndShareVcf(
    List<Contact> contacts,
    String filePrefix,
  ) async {
    final vcf = VCardService().toVCardAll(contacts, externalShare: true);

    final dir = await getTemporaryDirectory();
    final baseName = contacts.length == 1
        ? sanitizeFileName(contacts.first.fullName, fallback: filePrefix)
        : '${filePrefix}_${DateTime.now().millisecondsSinceEpoch}';
    final fileName = '$baseName.vcf';
    final file = File(p.join(dir.path, fileName));
    await file.writeAsString(vcf);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/octet-stream')],
        subject: fileName,
      ),
    );
    return file.path;
  }

  /// Prompts the user to pick a `.vcf` file and imports every vCard in it.
  /// Returns the number of contacts imported (0 if the user cancels).
  Future<int> importContactsVcf() async {
    const typeGroup = XTypeGroup(label: 'vCard', extensions: ['vcf']);
    final XFile? picked = await openFile(acceptedTypeGroups: [typeGroup]);
    if (picked == null) return 0;
    return importVCardText(await picked.readAsString());
  }

  /// Imports every vCard block in [text]. Unlike the CSV import (app DB only),
  /// each contact is saved through [ContactSyncService], so it lands in the
  /// app DB **and** the device address book. Returns the number imported.
  Future<int> importVCardText(String text) async {
    final contacts = await VCardService().fromVCard(text);
    final sync = ContactSyncService();
    var imported = 0;
    for (final contact in contacts) {
      await sync.saveContact(contact);
      imported++;
    }
    return imported;
  }

  /// Prompts the user to pick a CSV file and imports the contacts in it.
  /// Returns the number of contacts imported. Returns 0 if the user cancels.
  Future<int> importContacts() async {
    const typeGroup = XTypeGroup(label: 'CSV', extensions: ['csv']);
    final XFile? picked = await openFile(acceptedTypeGroups: [typeGroup]);
    if (picked == null) return 0;

    final contents = await picked.readAsString();
    final rows = Csv().decode(contents);
    if (rows.length < 2) return 0; // header only or empty

    var imported = 0;
    // Skip header row.
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      final contact = _contactFromRow(row);
      if (contact == null) continue;
      await _repository.insertContact(contact, source: AuditSource.import);
      imported++;
    }
    return imported;
  }

  /// Builds a Contact from a CSV row, defensively handling short/malformed
  /// rows. Returns null when there is no usable first name.
  Contact? _contactFromRow(List<dynamic> row) {
    String cell(int i) => i < row.length ? row[i].toString() : '';
    String? cellOrNull(int i) => cell(i).isNotEmpty ? cell(i) : null;

    final firstName = cell(1).trim();
    if (firstName.isEmpty) return null;

    DateTime? parseDate(int i) {
      final v = cell(i);
      if (v.isEmpty) return null;
      return DateTime.tryParse(v);
    }

    final contact = Contact(
      salutation: cellOrNull(0),
      firstName: firstName,
      middleName: cellOrNull(2),
      lastName: cellOrNull(3),
      gender: cellOrNull(4),
      dob: parseDate(5),
      bloodGroup: cellOrNull(6),
      anniversary: parseDate(7),
      meetiversary: parseDate(8),
    );

    // Phone numbers: "label:number;label:number"
    for (final entry in _splitPairs(cell(9))) {
      contact.phoneNumbers.add(
        PhoneNumber(label: entry.key, number: entry.value, type: 'personal'),
      );
    }

    // Emails: "label:address;label:address"
    for (final entry in _splitPairs(cell(10))) {
      contact.emails.add(
        Email(label: entry.key, email: entry.value, type: 'personal'),
      );
    }

    return contact;
  }

  /// Parses a "label:value;label:value" cell into (label, value) pairs,
  /// skipping empties. A missing label yields a null label.
  Iterable<MapEntry<String?, String>> _splitPairs(String cell) sync* {
    if (cell.isEmpty) return;
    for (final part in cell.split(';')) {
      if (part.trim().isEmpty) continue;
      final idx = part.indexOf(':');
      if (idx < 0) {
        yield MapEntry(null, part.trim());
      } else {
        final label = part.substring(0, idx).trim();
        final value = part.substring(idx + 1).trim();
        if (value.isEmpty) continue;
        yield MapEntry(label.isEmpty ? null : label, value);
      }
    }
  }
}
