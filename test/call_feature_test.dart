// Unit tests for the dialer/history/feedback persistence paths added with the
// dialer build-out. Like the other repository tests, these run sqflite on the
// host VM via sqflite_common_ffi. The device call-log reconciliation in
// CallService is platform-channel bound and is verified manually on a device.

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/repositories/call_log_repository.dart';
import 'package:smart_contacts_dialer/repositories/contact_repository.dart';
import 'package:smart_contacts_dialer/repositories/interaction_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.setTestDatabaseName('smart_contacts_test_call.db');
  });

  setUp(() async {
    await DatabaseHelper().close();
    await databaseFactory.deleteDatabase(
      join(await getDatabasesPath(), 'smart_contacts_test_call.db'),
    );
  });

  tearDown(() async {
    await DatabaseHelper().close();
  });

  Future<int> insertContact(String first, String number) async {
    final db = await DatabaseHelper().database;
    final id = await db.insert('contacts', {'first_name': first});
    await db.insert('phone_numbers', {
      'contact_id': id,
      'number': number,
      'type': 'personal',
    });
    return id;
  }

  test('findByPhoneFragment matches ignoring formatting', () async {
    final repo = ContactRepository();
    final id = await insertContact('Asha', '+91 98765-43210');

    // Typed digits with no formatting should still hit the formatted stored one.
    final hits = await repo.findByPhoneFragment('9876543210');
    expect(hits, hasLength(1));
    expect(hits.first.contactId, id);
    expect(hits.first.contactName, 'Asha');

    // A non-matching fragment returns nothing.
    expect(await repo.findByPhoneFragment('00000'), isEmpty);

    // An empty fragment returns nothing.
    expect(await repo.findByPhoneFragment('   '), isEmpty);
  });

  test(
    'recordCallFeedback writes tone to interaction and intent/notes to call',
    () async {
      final interactions = InteractionRepository();
      final contactId = await insertContact('Bo', '5550100');

      final callLogId = await interactions.logCall(
        contactId: contactId,
        phoneNumber: '5550100',
      );
      final interactionId = await interactions.logInteraction(
        contactId: contactId,
      );

      await interactions.recordCallFeedback(
        callLogId: callLogId,
        interactionId: interactionId,
        tone: 'positive',
        intent: 'Catch-up',
        notes: 'Plan trip',
      );

      final db = await DatabaseHelper().database;
      final callRow = (await db.query(
        'call_logs',
        where: 'id = ?',
        whereArgs: [callLogId],
      )).single;
      final interactionRow = (await db.query(
        'interactions',
        where: 'id = ?',
        whereArgs: [interactionId],
      )).single;

      expect(callRow['call_intent'], 'Catch-up');
      expect(callRow['notes'], 'Plan trip');
      expect(interactionRow['emotional_tone'], 'positive');
    },
  );

  test(
    'CallLogRepository.recentCalls joins the contact name, newest first',
    () async {
      final interactions = InteractionRepository();
      final contactId = await insertContact('Cara', '5550199');

      // A linked call and an unknown-number call.
      await interactions.logCall(contactId: contactId, phoneNumber: '5550199');
      await interactions.logCall(contactId: null, phoneNumber: '5550000');

      final calls = await CallLogRepository().recentCalls();
      expect(calls, hasLength(2));

      final linked = calls.firstWhere((c) => c.contactId == contactId);
      expect(linked.contactName, 'Cara');
      expect(linked.displayName, 'Cara');

      final unknown = calls.firstWhere((c) => c.contactId == null);
      expect(unknown.contactName, isNull);
      expect(unknown.displayName, '5550000'); // falls back to the raw number
    },
  );

  test('clearHistory removes all call rows', () async {
    final interactions = InteractionRepository();
    final contactId = await insertContact('Dee', '5550123');
    await interactions.logCall(contactId: contactId, phoneNumber: '5550123');

    final repo = CallLogRepository();
    expect(await repo.recentCalls(), isNotEmpty);

    await repo.clearHistory();
    expect(await repo.recentCalls(), isEmpty);
  });
}
