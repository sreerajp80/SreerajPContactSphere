// test/call_log_dedupe_test.dart
//
// Recents is written from two sides — the live logger when a call ends, and the
// device-log import — and a missed call used to land as two rows whenever the
// two crossed. These tests pin the DB-level guard that stops that
// ([InteractionRepository.logCallIfNew]) and the one-shot repair for the rows
// written before it existed ([CallLogRepository.mergeDuplicateCalls]).

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/repositories/call_log_repository.dart';
import 'package:smart_contacts_dialer/repositories/interaction_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const dbName = 'smart_contacts_test_call_log_dedupe.db';
  final interactions = InteractionRepository();
  final callLogs = CallLogRepository();

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

  Future<int> rowCount() async {
    final db = await DatabaseHelper().database;
    final rows = await db.query('call_logs');
    return rows.length;
  }

  Future<Map<String, Object?>> onlyRow() async {
    final db = await DatabaseHelper().database;
    final rows = await db.query('call_logs');
    expect(rows, hasLength(1));
    return rows.first;
  }

  /// A contact to link a call to — `call_logs.contact_id` is a foreign key, so
  /// the id has to be real.
  Future<int> insertContact(String firstName) async {
    final db = await DatabaseHelper().database;
    return db.insert('contacts', {'first_name': firstName});
  }

  final ringStart = DateTime(2026, 8, 6, 11, 42);

  group('logCallIfNew', () {
    test('the import row then the live row stay one row', () async {
      // The order that produced the duplicate: the device-log import inserted
      // first (its read of the stored rows had already happened), then the live
      // logger wrote its own row for the same missed call.
      await interactions.logCall(
        contactId: null,
        phoneNumber: '+919000000010',
        callType: 'missed',
        duration: 0,
        timestamp: ringStart,
        simLabel: 'BSNL MOBILE',
      );
      final contactId = await insertContact('Ravi');
      await interactions.logCallIfNew(
        contactId: contactId,
        phoneNumber: '9000000010',
        callType: 'missed',
        duration: 0,
        timestamp: ringStart.add(const Duration(seconds: 12)),
      );

      final row = await onlyRow();
      // The stored row kept what it had, and gained the contact link it lacked.
      expect(row['sim_label'], 'BSNL MOBILE');
      expect(row['contact_id'], contactId);
    });

    test('the live row then the import row stay one row', () async {
      await interactions.logCallIfNew(
        contactId: null,
        phoneNumber: '+919000000010',
        callType: 'missed',
        duration: 0,
        timestamp: ringStart,
      );
      await interactions.logCallIfNew(
        contactId: null,
        phoneNumber: '09000000010',
        callType: 'missed',
        duration: 0,
        timestamp: ringStart.add(const Duration(seconds: 30)),
        simLabel: 'BSNL MOBILE',
      );

      final row = await onlyRow();
      expect(row['sim_label'], 'BSNL MOBILE');
    });

    test('fills the outcome onto a provisional row', () async {
      // The outgoing path writes a row at placement with no duration yet.
      await interactions.logCall(
        contactId: null,
        phoneNumber: '+919876543210',
        timestamp: ringStart,
      );
      await interactions.logCallIfNew(
        contactId: null,
        phoneNumber: '+919876543210',
        duration: 45,
        timestamp: ringStart.add(const Duration(seconds: 5)),
      );

      final row = await onlyRow();
      expect(row['duration'], 45);
      expect(row['call_type'], 'outgoing');
    });

    test('two calls from one number outside the window stay two rows', () async {
      await interactions.logCallIfNew(
        contactId: null,
        phoneNumber: '+919000000010',
        callType: 'missed',
        duration: 0,
        timestamp: ringStart,
      );
      await interactions.logCallIfNew(
        contactId: null,
        phoneNumber: '+919000000010',
        callType: 'missed',
        duration: 0,
        timestamp: ringStart.add(
          CallLogRepository.matchWindow + const Duration(seconds: 10),
        ),
      );

      expect(await rowCount(), 2);
    });

    test('a call placed to a number and a missed call from it stay two rows',
        () async {
      // Different directions are never the same call, however close they are.
      await interactions.logCallIfNew(
        contactId: null,
        phoneNumber: '+919000000010',
        duration: 0,
        timestamp: ringStart,
      );
      await interactions.logCallIfNew(
        contactId: null,
        phoneNumber: '+919000000010',
        callType: 'missed',
        duration: 0,
        timestamp: ringStart.add(const Duration(seconds: 20)),
      );

      expect(await rowCount(), 2);
    });

    test('a different number at the same moment stays its own row', () async {
      await interactions.logCallIfNew(
        contactId: null,
        phoneNumber: '+919000000010',
        callType: 'missed',
        duration: 0,
        timestamp: ringStart,
      );
      await interactions.logCallIfNew(
        contactId: null,
        phoneNumber: '+919000000011',
        callType: 'missed',
        duration: 0,
        timestamp: ringStart,
      );

      expect(await rowCount(), 2);
    });
  });

  group('mergeDuplicateCalls', () {
    test('collapses a missed call that was written twice', () async {
      await interactions.logCall(
        contactId: null,
        phoneNumber: '+919000000010',
        callType: 'missed',
        duration: 0,
        timestamp: ringStart,
        simLabel: 'BSNL MOBILE',
      );
      final contactId = await insertContact('Ravi');
      await interactions.logCall(
        contactId: contactId,
        phoneNumber: '9000000010',
        callType: 'missed',
        duration: 0,
        timestamp: ringStart.add(const Duration(seconds: 25)),
      );

      expect(await callLogs.mergeDuplicateCalls(), 1);

      final row = await onlyRow();
      // The older row survives, having taken the contact link off the newer one.
      expect(row['timestamp'], ringStart.toIso8601String());
      expect(row['sim_label'], 'BSNL MOBILE');
      expect(row['contact_id'], contactId);
    });

    test('leaves genuinely separate calls alone', () async {
      await interactions.logCall(
        contactId: null,
        phoneNumber: '+919000000010',
        callType: 'missed',
        duration: 0,
        timestamp: ringStart,
      );
      await interactions.logCall(
        contactId: null,
        phoneNumber: '+919000000010',
        callType: 'missed',
        duration: 0,
        timestamp: ringStart.add(const Duration(minutes: 14)),
      );
      await interactions.logCall(
        contactId: null,
        phoneNumber: '+919000000011',
        callType: 'incoming',
        duration: 30,
        timestamp: ringStart,
      );

      expect(await callLogs.mergeDuplicateCalls(), 0);
      expect(await rowCount(), 3);
    });

    test('is idempotent — a second pass removes nothing', () async {
      await interactions.logCall(
        contactId: null,
        phoneNumber: '+919000000010',
        callType: 'missed',
        duration: 0,
        timestamp: ringStart,
      );
      await interactions.logCall(
        contactId: null,
        phoneNumber: '+919000000010',
        callType: 'missed',
        duration: 0,
        timestamp: ringStart.add(const Duration(seconds: 25)),
      );

      expect(await callLogs.mergeDuplicateCalls(), 1);
      expect(await callLogs.mergeDuplicateCalls(), 0);
    });
  });
}
