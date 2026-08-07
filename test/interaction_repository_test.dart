// Unit tests for InteractionRepository and the read paths that depend on it.
//
// Runs sqflite on the host VM via sqflite_common_ffi (the default sqflite
// factory is Android-only and unavailable under `flutter test`). The device
// call-log query and lifecycle reconciliation are platform-channel bound and
// are verified manually on a device — here we cover the persistence layer:
// logging, the updateCallOutcome back-fill, and that the services read it back.

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/repositories/interaction_repository.dart';
import 'package:smart_contacts_dialer/services/pre_call_summary_service.dart';
import 'package:smart_contacts_dialer/services/relationship_scoring_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.setTestDatabaseName('smart_contacts_test_interaction.db');
  });

  setUp(() async {
    // Start each test from a clean schema.
    await DatabaseHelper().close();
    await databaseFactory.deleteDatabase(
      join(await getDatabasesPath(), 'smart_contacts_test_interaction.db'),
    );
  });

  tearDown(() async {
    await DatabaseHelper().close();
  });

  /// Inserts a bare contact and returns its id.
  Future<int> insertContact() async {
    final db = await DatabaseHelper().database;
    return db.insert('contacts', {'first_name': 'Test'});
  }

  test(
    'logCall and logInteraction insert rows the summary reads back',
    () async {
      final repo = InteractionRepository();
      final contactId = await insertContact();

      await repo.logCall(
        contactId: contactId,
        phoneNumber: '+1 555 0100',
        duration: 42,
      );
      await repo.logInteraction(
        contactId: contactId,
        emotionalTone: 'positive',
      );

      final summary = await PreCallSummaryService().getPreCallSummary(
        contactId,
      );

      expect(summary.recentInteractions, hasLength(1));
      expect(summary.lastCallDuration, 42);
    },
  );

  test(
    'updateCallOutcome back-fills duration/type/timestamp on both rows',
    () async {
      final repo = InteractionRepository();
      final db = await DatabaseHelper().database;
      final contactId = await insertContact();

      // Provisional rows: duration unknown.
      final callLogId = await repo.logCall(
        contactId: contactId,
        phoneNumber: '5550100',
      );
      final interactionId = await repo.logInteraction(contactId: contactId);

      const realTimestamp = '2026-06-28T10:00:00.000';
      await repo.updateCallOutcome(
        callLogId: callLogId,
        interactionId: interactionId,
        duration: 137,
        callType: 'outgoing',
        timestamp: realTimestamp,
      );

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

      expect(callRow['duration'], 137);
      expect(callRow['call_type'], 'outgoing');
      expect(callRow['timestamp'], realTimestamp);
      expect(interactionRow['duration'], 137);
      expect(interactionRow['timestamp'], realTimestamp);

      final summary = await PreCallSummaryService().getPreCallSummary(
        contactId,
      );
      expect(summary.lastCallDuration, 137);
    },
  );

  test('a logged interaction drives a non-zero relationship score', () async {
    final repo = InteractionRepository();
    final db = await DatabaseHelper().database;
    final contactId = await insertContact();

    await repo.logInteraction(contactId: contactId, emotionalTone: 'positive');

    final score = await RelationshipScoringService().calculateRelationshipScore(
      contactId,
    );
    expect(score, greaterThan(0));

    // The score is denormalized back onto the contact row.
    final contactRow = (await db.query(
      'contacts',
      where: 'id = ?',
      whereArgs: [contactId],
    )).single;
    expect(contactRow['relationship_score'], greaterThan(0));
  });
}
