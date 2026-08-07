// test/outgoing_outcome_journal_test.dart
//
// A Smart Redial retry is dialed natively, with the app possibly closed, so no
// screen is holding a pending call to latch the reason from the event stream
// onto. The native side journals the reason instead, and CallEventLogger drains
// it onto the Recents row the device-log import writes.
//
// These tests pin the rules that make a second writer for `call_outcome` safe:
//  - it only ever *fills* an outcome, never replaces one,
//  - it never inserts a row, so it cannot double up a call in Recents, and
//  - an event that arrives before the row exists is retried, not dropped — the
//    device sync that writes the row runs unawaited and routinely lands second.

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/repositories/interaction_repository.dart';
import 'package:smart_contacts_dialer/services/call_event_logger.dart';
import 'package:smart_contacts_dialer/services/telecom_service.dart';
import 'package:smart_contacts_dialer/utils/call_type_mapper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const dbName = 'smart_contacts_test_outgoing_outcome.db';
  final interactions = InteractionRepository();
  final logger = CallEventLogger();

  // What the native journal will hand back on the next drain.
  var journal = <Map<String, Object?>>[];

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.setTestDatabaseName(dbName);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(TelecomService.methodChannel, (call) async {
          if (call.method == 'getOutgoingOutcomeEvents') return journal;
          return null;
        });
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(TelecomService.methodChannel, null);
  });

  setUp(() async {
    journal = [];
    await DatabaseHelper().close();
    await databaseFactory.deleteDatabase(
      join(await getDatabasesPath(), dbName),
    );
  });

  tearDown(() async {
    await DatabaseHelper().close();
  });

  final placedAt = DateTime(2026, 8, 6, 18, 25);

  Map<String, Object?> event(
    String number,
    DateTime when,
    String outcome,
  ) => {
    'number': number,
    'at': when.millisecondsSinceEpoch,
    'outcome': outcome,
  };

  Future<List<Map<String, Object?>>> rows() async {
    final db = await DatabaseHelper().database;
    return db.query('call_logs');
  }

  test('a journaled reason lands on the row the import wrote', () async {
    // The import wrote the row from the device log: it knows the call lasted no
    // time, but not that the line was busy.
    await interactions.logCall(
      contactId: null,
      phoneNumber: '+919000000018',
      duration: 0,
      timestamp: placedAt,
    );

    // Same call from the native side: a different form of the number, and a few
    // seconds off, exactly as the two records of one call always are.
    journal = [
      event(
        '9000000018',
        placedAt.add(const Duration(seconds: 4)),
        AppCallOutcome.busy,
      ),
    ];
    await logger.drainOutgoingOutcomes();

    final stored = await rows();
    expect(stored, hasLength(1), reason: 'must patch, never insert');
    expect(stored.single['call_outcome'], AppCallOutcome.busy);
  });

  test('it never replaces an outcome the row already has', () async {
    // The screen that placed the call already latched the real reason.
    await interactions.logCall(
      contactId: null,
      phoneNumber: '+919000000018',
      callOutcome: AppCallOutcome.answered,
      duration: 1,
      timestamp: placedAt,
    );

    journal = [event('9000000018', placedAt, AppCallOutcome.noAnswer)];
    await logger.drainOutgoingOutcomes();

    expect((await rows()).single['call_outcome'], AppCallOutcome.answered);
  });

  test('an unmapped native string is ignored rather than stored', () async {
    await interactions.logCall(
      contactId: null,
      phoneNumber: '+919000000018',
      duration: 0,
      timestamp: placedAt,
    );

    journal = [event('9000000018', placedAt, 'DISCONNECT_CAUSE_17')];
    await logger.drainOutgoingOutcomes();

    expect((await rows()).single['call_outcome'], isNull);
  });

  test('a reason that arrives before its row is retried, not lost', () async {
    // The drain runs first — the device sync that writes the row is unawaited.
    journal = [event('9000000018', placedAt, AppCallOutcome.declined)];
    await logger.drainOutgoingOutcomes();

    expect(await rows(), isEmpty, reason: 'must not insert a row of its own');

    // The import lands, and Recents reloads — which drains again, this time
    // with nothing new from the native side.
    await interactions.logCall(
      contactId: null,
      phoneNumber: '+919000000018',
      duration: 0,
      timestamp: placedAt,
    );
    journal = [];
    await logger.drainOutgoingOutcomes();

    expect((await rows()).single['call_outcome'], AppCallOutcome.declined);
  });

  test('a call too far from the row is not treated as the same call', () async {
    await interactions.logCall(
      contactId: null,
      phoneNumber: '+919000000018',
      duration: 0,
      timestamp: placedAt,
    );

    // Well outside the 90-second match window: a different call to the same
    // number, so its reason must not be stamped on this row.
    journal = [
      event(
        '9000000018',
        placedAt.add(const Duration(minutes: 10)),
        AppCallOutcome.busy,
      ),
    ];
    await logger.drainOutgoingOutcomes();

    expect((await rows()).single['call_outcome'], isNull);
  });
}
