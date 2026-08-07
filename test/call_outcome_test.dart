// test/call_outcome_test.dart
//
// `call_logs.call_outcome` records **what happened** on a call, next to
// `call_type` which only says which way it went. Without it an outgoing call
// that was picked up and one that rang out are identical rows.
//
// These tests pin the two rules that keep the column honest:
//  - the device call log may only ever *fill* an outcome, never overwrite one
//    the app observed live (it infers from duration, and some devices round a
//    short answered call down to 0 seconds), and
//  - the column heals itself onto a database that predates it.

import 'package:call_log/call_log.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/repositories/call_log_repository.dart';
import 'package:smart_contacts_dialer/repositories/interaction_repository.dart';
import 'package:smart_contacts_dialer/utils/call_type_mapper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const dbName = 'smart_contacts_test_call_outcome.db';
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

  Future<Map<String, Object?>> onlyRow() async {
    final db = await DatabaseHelper().database;
    final rows = await db.query('call_logs');
    expect(rows, hasLength(1));
    return rows.first;
  }

  final placedAt = DateTime(2026, 8, 6, 11, 42);

  group('outcomeFromDuration', () {
    test('a call with talk time was answered', () {
      expect(outcomeFromDuration(38), AppCallOutcome.answered);
      expect(outcomeFromDuration(1), AppCallOutcome.answered);
    });

    test('a zero-second call was not answered', () {
      expect(outcomeFromDuration(0), AppCallOutcome.noAnswer);
    });

    test('a null duration is unknown, not unanswered', () {
      // A provisional row (placed, not yet reconciled) has no duration. Reading
      // that as "nobody answered" would label a call still in progress.
      expect(outcomeFromDuration(null), isNull);
    });
  });

  group('mapDeviceCallOutcome', () {
    test('a rejected entry is a decline, which duration alone cannot say', () {
      expect(
        mapDeviceCallOutcome(CallType.rejected, 0),
        AppCallOutcome.declined,
      );
    });

    test('a voicemail entry means the person never picked up', () {
      expect(
        mapDeviceCallOutcome(CallType.voiceMail, 12),
        AppCallOutcome.noAnswer,
      );
    });

    test('everything else falls back to the duration', () {
      expect(
        mapDeviceCallOutcome(CallType.outgoing, 38),
        AppCallOutcome.answered,
      );
      expect(
        mapDeviceCallOutcome(CallType.outgoing, 0),
        AppCallOutcome.noAnswer,
      );
    });
  });

  group('normalizeCallOutcome', () {
    test('keeps a value we know', () {
      expect(normalizeCallOutcome('busy'), AppCallOutcome.busy);
    });

    test('drops anything else, so no unmapped native string reaches the UI', () {
      expect(normalizeCallOutcome('DISCONNECT_CAUSE_17'), isNull);
      expect(normalizeCallOutcome(''), isNull);
      expect(normalizeCallOutcome(null), isNull);
    });
  });

  group('callOutcomeLabel', () {
    test('an answered call gets no label — its duration already says so', () {
      expect(callOutcomeLabel(AppCallOutcome.answered), isNull);
    });

    test('an unknown outcome invents no text', () {
      expect(callOutcomeLabel(null), isNull);
    });

    test('each reason a call failed to connect reads differently', () {
      expect(callOutcomeLabel(AppCallOutcome.noAnswer), 'No answer');
      expect(callOutcomeLabel(AppCallOutcome.busy), 'Busy');
      expect(callOutcomeLabel(AppCallOutcome.declined), 'Declined');
      expect(callOutcomeLabel(AppCallOutcome.cancelled), 'Cancelled');
      expect(callOutcomeLabel(AppCallOutcome.failed), 'Failed');
    });

    test('a call nobody picked up reads by direction', () {
      // Same stored fact, two names: we rang them / they rang us.
      expect(
        callOutcomeLabel(AppCallOutcome.noAnswer, AppCallType.outgoing),
        'No answer',
      );
      expect(
        callOutcomeLabel(AppCallOutcome.noAnswer, AppCallType.incoming),
        'Missed',
      );
      expect(
        callOutcomeLabel(AppCallOutcome.noAnswer, AppCallType.missed),
        'Missed',
      );
    });

    test('other outcomes read the same whichever way the call went', () {
      for (final type in [AppCallType.incoming, AppCallType.outgoing]) {
        expect(callOutcomeLabel(AppCallOutcome.busy, type), 'Busy');
        expect(callOutcomeLabel(AppCallOutcome.declined, type), 'Declined');
        expect(callOutcomeLabel(AppCallOutcome.failed, type), 'Failed');
      }
    });
  });

  group('outgoingDidNotConnect', () {
    test('an unknown outcome keeps the plain outgoing arrow', () {
      // Rows written before this column existed must look exactly as they did.
      expect(outgoingDidNotConnect(null), isFalse);
    });

    test('answered keeps the plain arrow; every other reason does not', () {
      expect(outgoingDidNotConnect(AppCallOutcome.answered), isFalse);
      expect(outgoingDidNotConnect(AppCallOutcome.noAnswer), isTrue);
      expect(outgoingDidNotConnect(AppCallOutcome.busy), isTrue);
      expect(outgoingDidNotConnect(AppCallOutcome.declined), isTrue);
      expect(outgoingDidNotConnect(AppCallOutcome.cancelled), isTrue);
      expect(outgoingDidNotConnect(AppCallOutcome.failed), isTrue);
    });
  });

  group('the device log may only fill an outcome, never replace one', () {
    test('backfill leaves an outcome the app already observed', () async {
      // The app watched this call reach ACTIVE, so it is answered — even though
      // the device logged it as 0 seconds (a very short call, rounded down).
      final id = await interactions.logCall(
        contactId: null,
        phoneNumber: '+919000000010',
        callOutcome: AppCallOutcome.answered,
        duration: 1,
        timestamp: placedAt,
      );

      await interactions.backfillFromDeviceLog(
        callLogId: id,
        duration: 0,
        callType: 'outgoing',
        callOutcome: AppCallOutcome.noAnswer,
      );

      final row = await onlyRow();
      expect(row['call_outcome'], AppCallOutcome.answered);
    });

    test('backfill fills an outcome the row is missing', () async {
      final id = await interactions.logCall(
        contactId: null,
        phoneNumber: '+919000000010',
        timestamp: placedAt,
      );

      await interactions.backfillFromDeviceLog(
        callLogId: id,
        duration: 0,
        callType: 'outgoing',
        callOutcome: AppCallOutcome.noAnswer,
      );

      final row = await onlyRow();
      expect(row['call_outcome'], AppCallOutcome.noAnswer);
    });

    test('a deduped insert does not overwrite the stored outcome', () async {
      // The live logger observed a decline; the import then matches the same
      // call and offers its weaker duration-derived reading.
      await interactions.logCallIfNew(
        contactId: null,
        phoneNumber: '+919000000010',
        callOutcome: AppCallOutcome.declined,
        duration: 0,
        timestamp: placedAt,
      );
      await interactions.logCallIfNew(
        contactId: null,
        phoneNumber: '9000000010',
        callOutcome: AppCallOutcome.noAnswer,
        duration: 0,
        timestamp: placedAt.add(const Duration(seconds: 3)),
      );

      final row = await onlyRow();
      expect(row['call_outcome'], AppCallOutcome.declined);
    });

    test('a deduped insert fills an outcome the stored row lacks', () async {
      // The provisional row written at placement knows nothing yet.
      await interactions.logCall(
        contactId: null,
        phoneNumber: '+919000000010',
        timestamp: placedAt,
      );
      await interactions.logCallIfNew(
        contactId: null,
        phoneNumber: '9000000010',
        callOutcome: AppCallOutcome.busy,
        duration: 0,
        timestamp: placedAt.add(const Duration(seconds: 3)),
      );

      final row = await onlyRow();
      expect(row['call_outcome'], AppCallOutcome.busy);
    });
  });

  group('an observed outcome may only fill a gap', () {
    test('it fills a row that has no outcome', () async {
      final id = await interactions.logCall(
        contactId: null,
        phoneNumber: '+919000000010',
        duration: 0,
        timestamp: placedAt,
      );

      final changed = await interactions.backfillObservedOutcome(
        callLogId: id,
        callOutcome: AppCallOutcome.busy,
      );

      expect(changed, isTrue);
      expect((await onlyRow())['call_outcome'], AppCallOutcome.busy);
    });

    test('it leaves an outcome that is already there', () async {
      // The screen that placed the call latched the reason first; a later drain
      // of the native journal must not talk over it.
      final id = await interactions.logCall(
        contactId: null,
        phoneNumber: '+919000000010',
        callOutcome: AppCallOutcome.declined,
        duration: 0,
        timestamp: placedAt,
      );

      final changed = await interactions.backfillObservedOutcome(
        callLogId: id,
        callOutcome: AppCallOutcome.noAnswer,
      );

      expect(changed, isFalse, reason: 'nothing to fill, so nothing changed');
      expect((await onlyRow())['call_outcome'], AppCallOutcome.declined);
    });
  });

  group('rows that still need an outcome', () {
    test('a row with a duration but no outcome is still incomplete', () async {
      // Written before the column existed: the import is the only thing that
      // will ever fill it in, so it has to keep offering.
      final db = await DatabaseHelper().database;
      await db.insert('call_logs', {
        'phone_number': '+919000000010',
        'call_type': 'outgoing',
        'duration': 0,
        'timestamp': placedAt.toIso8601String(),
      });

      final stored = await callLogs.storedCallsForMatching();
      expect(stored, hasLength(1));
      expect(stored.first.callOutcome, isNull);
      expect(stored.first.needsOutcome, isTrue);
    });

    test('a fully recorded row needs nothing', () async {
      await interactions.logCall(
        contactId: null,
        phoneNumber: '+919000000010',
        callOutcome: AppCallOutcome.answered,
        duration: 38,
        timestamp: placedAt,
      );

      final stored = await callLogs.storedCallsForMatching();
      expect(stored.single.needsOutcome, isFalse);
    });
  });

  group('migration onto a database written before the column', () {
    test('the column is added and seeded from what the rows do say', () async {
      // Rebuild call_logs without call_outcome, the way a pre-v27 DB has it,
      // then reopen so the PRAGMA-checked self-heal runs (see _onOpen). The
      // heal is deliberately not version-gated: a development build that bumped
      // the version before this migration existed would skip it forever.
      final db = await DatabaseHelper().database;
      await db.execute('DROP TABLE call_logs');
      await db.execute('''
        CREATE TABLE call_logs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          contact_id INTEGER,
          phone_number TEXT NOT NULL,
          call_type TEXT CHECK(call_type IN ('incoming', 'outgoing', 'missed', 'blocked')),
          duration INTEGER,
          timestamp TEXT DEFAULT CURRENT_TIMESTAMP,
          call_intent TEXT,
          notes TEXT,
          sim_id TEXT,
          sim_label TEXT,
          FOREIGN KEY (contact_id) REFERENCES contacts (id) ON DELETE SET NULL
        )
      ''');
      final ts = placedAt.toIso8601String();
      await db.insert('call_logs', {
        'phone_number': '111',
        'call_type': 'outgoing',
        'duration': 38,
        'timestamp': ts,
      });
      await db.insert('call_logs', {
        'phone_number': '222',
        'call_type': 'missed',
        'duration': 0,
        'timestamp': ts,
      });
      await db.insert('call_logs', {
        'phone_number': '333',
        'call_type': 'outgoing',
        'duration': 0,
        'timestamp': ts,
      });
      await DatabaseHelper().close();

      final healed = await DatabaseHelper().database;
      final rows = await healed.query('call_logs', orderBy: 'phone_number');
      expect(rows.map((r) => r['call_outcome']), [
        // Real talk time settles it.
        AppCallOutcome.answered,
        // A missed call is a call nobody took.
        AppCallOutcome.noAnswer,
        // An outgoing 0-second row from before the column: we cannot tell
        // "nobody answered" from "never reconciled", so we say nothing rather
        // than label it wrong.
        null,
      ]);
    });
  });
}
