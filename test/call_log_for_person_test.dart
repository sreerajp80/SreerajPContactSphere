// Tests for CallLogRepository.callsForContact / callsForNumber — the History
// tab on a contact's screen and on an unsaved number's screen.
//
// Runs sqflite on the host VM via sqflite_common_ffi (the default sqflite
// factory is Android-only and unavailable under `flutter test`).

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/models/contact.dart';
import 'package:smart_contacts_dialer/models/phone_number.dart';
import 'package:smart_contacts_dialer/repositories/call_log_repository.dart';
import 'package:smart_contacts_dialer/repositories/contact_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const dbName = 'smart_contacts_test_call_for_person.db';

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.setTestDatabaseName(dbName);
  });

  setUp(() async {
    await DatabaseHelper().close();
    await databaseFactory.deleteDatabase(
      join(await getDatabasesPath(), dbName),
    );
  });

  tearDown(() async {
    await DatabaseHelper().close();
  });

  final contacts = ContactRepository();
  final calls = CallLogRepository();

  Future<int> addContact(String name, String number) {
    final contact = Contact(firstName: name)
      ..phoneNumbers = [PhoneNumber(number: number, type: 'personal')];
    return contacts.insertContact(contact);
  }

  /// Logs one call and returns its row id.
  Future<int> logCall(
    String number, {
    int? contactId,
    String when = '2026-07-20T10:00:00.000',
  }) async {
    final db = await DatabaseHelper().database;
    return db.insert('call_logs', {
      'contact_id': contactId,
      'phone_number': number,
      'call_type': 'incoming',
      'duration': 30,
      'timestamp': when,
    });
  }

  group('callsForContact', () {
    test(
      'returns the contact\'s linked calls, not another contact\'s',
      () async {
        final ramesh = await addContact('Ramesh', '9876543210');
        final vinu = await addContact('Vinu', '9000000001');
        final mine = await logCall('9876543210', contactId: ramesh);
        await logCall('9000000001', contactId: vinu);

        final hits = await calls.callsForContact(ramesh, ['9876543210']);
        expect(hits.map((c) => c.id), [mine]);
      },
    );

    test(
      'includes unlinked calls from the same number in another form',
      () async {
        final ramesh = await addContact('Ramesh', '09876543210');
        final unlinked = await logCall('+91 98765 43210');

        final hits = await calls.callsForContact(ramesh, ['09876543210']);
        expect(hits.map((c) => c.id), [unlinked]);
      },
    );

    test('skips a same-number call already linked to someone else', () async {
      final ramesh = await addContact('Ramesh', '9876543210');
      final other = await addContact('Office', '9876543210');
      await logCall('9876543210', contactId: other);

      expect(await calls.callsForContact(ramesh, ['9876543210']), isEmpty);
    });

    test('lists the newest call first', () async {
      final ramesh = await addContact('Ramesh', '9876543210');
      final older = await logCall(
        '9876543210',
        contactId: ramesh,
        when: '2026-07-01T09:00:00.000',
      );
      final newer = await logCall(
        '9876543210',
        contactId: ramesh,
        when: '2026-07-20T09:00:00.000',
      );

      final hits = await calls.callsForContact(ramesh, ['9876543210']);
      expect(hits.map((c) => c.id), [newer, older]);
    });

    test(
      'still returns linked calls when the contact has no numbers',
      () async {
        final ramesh = await addContact('Ramesh', '9876543210');
        final mine = await logCall('9876543210', contactId: ramesh);

        final hits = await calls.callsForContact(ramesh, const []);
        expect(hits.map((c) => c.id), [mine]);
      },
    );
  });

  group('callsForNumber', () {
    test('returns linked and unlinked calls for the number', () async {
      final ramesh = await addContact('Ramesh', '9876543210');
      final linked = await logCall(
        '9876543210',
        contactId: ramesh,
        when: '2026-07-20T09:00:00.000',
      );
      final unlinked = await logCall(
        '+91-98765-43210',
        when: '2026-07-19T09:00:00.000',
      );
      await logCall('9000000001');

      final hits = await calls.callsForNumber('098765 43210');
      expect(hits.map((c) => c.id), [linked, unlinked]);
    });

    test('a short code does not match a longer number ending in it', () async {
      final shortCode = await logCall('12345');
      await logCall('9876512345');

      final hits = await calls.callsForNumber('12345');
      expect(hits.map((c) => c.id), [shortCode]);
    });

    test('a number with no digits matches nothing', () async {
      await logCall('Private');

      expect(await calls.callsForNumber('Private'), isEmpty);
    });
  });
}
