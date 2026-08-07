// Tests for CallLogRepository.searchCalls — the Recents screen search.
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

  const dbName = 'smart_contacts_test_call_search.db';

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.setTestDatabaseName(dbName);
  });

  setUp(() async {
    await DatabaseHelper().close();
    await databaseFactory.deleteDatabase(join(await getDatabasesPath(), dbName));
  });

  tearDown(() async {
    await DatabaseHelper().close();
  });

  final contacts = ContactRepository();
  final calls = CallLogRepository();

  /// Logs one call, optionally linked to a newly created contact.
  Future<void> logCall({
    required String number,
    String? contactName,
    String when = '2026-07-20T10:00:00.000',
  }) async {
    int? contactId;
    if (contactName != null) {
      final contact = Contact(firstName: contactName)
        ..phoneNumbers = [PhoneNumber(number: number, type: 'personal')];
      contactId = await contacts.insertContact(contact);
    }
    final db = await DatabaseHelper().database;
    await db.insert('call_logs', {
      'contact_id': contactId,
      'phone_number': number,
      'call_type': 'incoming',
      'duration': 30,
      'timestamp': when,
    });
  }

  Future<List<String>> search(String query) async {
    final hits = await calls.searchCalls(query);
    return hits.map((c) => c.displayName).toList();
  }

  test('finds a call by the linked contact name', () async {
    await logCall(number: '9876543210', contactName: 'Ramesh');
    await logCall(number: '9000000001', contactName: 'Vinu');

    expect(await search('Ramesh'), ['Ramesh']);
  });

  test('finds a call by a Malayalam name typed in English', () async {
    await logCall(number: '9876543210', contactName: 'മൈക്കിൾ');
    await logCall(number: '9000000001', contactName: 'സുരേഷ്');

    expect(await search('Michael'), ['മൈക്കിൾ']);
    expect(await search('Suresh'), ['സുരേഷ്']);
  });

  test('finds an unknown number by its digits', () async {
    await logCall(number: '+91 98765 43210');

    expect(await search('43210'), isNotEmpty);
    expect(await search('9876'), isNotEmpty);
  });

  test('a letters-only query does not match every number', () async {
    await logCall(number: '9876543210'); // unknown, no contact

    expect(await search('Ramesh'), isEmpty);
  });

  test('a blank query returns nothing', () async {
    await logCall(number: '9876543210', contactName: 'Ramesh');

    expect(await search(''), isEmpty);
    expect(await search('   '), isEmpty);
  });

  test('results stay newest first', () async {
    await logCall(
      number: '9000000001',
      contactName: 'Ramesh',
      when: '2026-07-01T10:00:00.000',
    );
    await logCall(
      number: '9000000002',
      contactName: 'Ramya',
      when: '2026-07-24T10:00:00.000',
    );

    expect(await search('Ram'), ['Ramya', 'Ramesh']);
  });
}
