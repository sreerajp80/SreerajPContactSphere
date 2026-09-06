// Tests for SpeedDialRepository — the keypad keys 1-9 bound to a saved number.
//
// Runs the real schema on the host VM via sqflite_common_ffi, so the foreign
// key and the slot primary key are the ones a phone actually has.

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/models/contact.dart';
import 'package:smart_contacts_dialer/models/phone_number.dart';
import 'package:smart_contacts_dialer/repositories/contact_repository.dart';
import 'package:smart_contacts_dialer/repositories/speed_dial_repository.dart';

const String _dbName = 'smart_contacts_test_speed_dial.db';

Future<int> _addContact(
  ContactRepository repo, {
  required String firstName,
  String number = '9876543210',
  bool isSecret = false,
}) {
  final contact = Contact(firstName: firstName, isSecret: isSecret)
    ..phoneNumbers = [PhoneNumber(number: number, type: 'personal')];
  return repo.insertContact(contact);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.setTestDatabaseName(_dbName);
  });

  setUp(() async {
    await DatabaseHelper().close();
    await databaseFactory.deleteDatabase(
      join(await getDatabasesPath(), _dbName),
    );
  });

  tearDown(() async {
    await DatabaseHelper().close();
  });

  group('SpeedDialRepository', () {
    test('assign stores a slot and all() reads it back with the name', () async {
      final contacts = ContactRepository();
      final repo = SpeedDialRepository();
      final id = await _addContact(contacts, firstName: 'Anu');

      final saved = await repo.assign(
        slot: 2,
        phoneNumber: '9876543210',
        contactId: id,
      );
      expect(saved, isTrue);

      final all = await repo.all();
      expect(all.keys, [2]);
      expect(all[2]!.contactId, id);
      expect(all[2]!.phoneNumber, '9876543210');
      expect(all[2]!.displayName, 'Anu');
      expect(all[2]!.label, 'Anu');
    });

    test('a second assign to the same key replaces the first', () async {
      final contacts = ContactRepository();
      final repo = SpeedDialRepository();
      final anu = await _addContact(contacts, firstName: 'Anu');
      final ravi = await _addContact(
        contacts,
        firstName: 'Ravi',
        number: '9000000000',
      );

      await repo.assign(slot: 5, phoneNumber: '9876543210', contactId: anu);
      await repo.assign(slot: 5, phoneNumber: '9000000000', contactId: ravi);

      final all = await repo.all();
      expect(all.length, 1);
      expect(all[5]!.contactId, ravi);
      expect(all[5]!.phoneNumber, '9000000000');
    });

    test('clear frees the key', () async {
      final repo = SpeedDialRepository();
      await repo.assign(slot: 7, phoneNumber: '9876543210');
      expect(await repo.forSlot(7), isNotNull);

      await repo.clear(7);
      expect(await repo.forSlot(7), isNull);
      expect(await repo.all(), isEmpty);
    });

    test('a secret contact can never be put on a key', () async {
      final contacts = ContactRepository();
      final repo = SpeedDialRepository();
      final id = await _addContact(
        contacts,
        firstName: 'Hidden',
        isSecret: true,
      );

      final saved = await repo.assign(
        slot: 1,
        phoneNumber: '9876543210',
        contactId: id,
      );

      expect(saved, isFalse);
      expect(await repo.all(), isEmpty);
      expect(await repo.forSlot(1), isNull);
    });

    test('a key stops showing when its contact is made secret', () async {
      final contacts = ContactRepository();
      final repo = SpeedDialRepository();
      final id = await _addContact(contacts, firstName: 'Anu');
      await repo.assign(slot: 4, phoneNumber: '9876543210', contactId: id);
      expect(await repo.forSlot(4), isNotNull);

      // Updating the contact to secret frees the key (ContactRepository does
      // this inside the same transaction as the update).
      final contact = (await contacts.getContactById(id))!..isSecret = true;
      await contacts.updateContact(contact);

      expect(await repo.forSlot(4), isNull);
      expect(await repo.all(), isEmpty);
    });

    test('deleting the contact frees its key', () async {
      final contacts = ContactRepository();
      final repo = SpeedDialRepository();
      final id = await _addContact(contacts, firstName: 'Anu');
      await repo.assign(slot: 9, phoneNumber: '9876543210', contactId: id);

      await contacts.deleteContact(id);

      expect(await repo.all(), isEmpty);
    });

    test('slots outside 1-9 and blank numbers are refused', () async {
      final repo = SpeedDialRepository();

      expect(await repo.assign(slot: 0, phoneNumber: '9876543210'), isFalse);
      expect(await repo.assign(slot: 10, phoneNumber: '9876543210'), isFalse);
      expect(await repo.assign(slot: 3, phoneNumber: '   '), isFalse);
      expect(await repo.all(), isEmpty);
      expect(await repo.forSlot(0), isNull);
    });

    test('a bare number with no contact is labelled by its number', () async {
      final repo = SpeedDialRepository();
      await repo.assign(slot: 8, phoneNumber: '1800 111 222');

      final entry = await repo.forSlot(8);
      expect(entry, isNotNull);
      expect(entry!.contactId, isNull);
      expect(entry.displayName, isNull);
      expect(entry.label, '1800 111 222');
    });
  });
}
