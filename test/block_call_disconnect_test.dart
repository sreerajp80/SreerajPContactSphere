// test/block_call_disconnect_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/repositories/call_log_repository.dart';
import 'package:smart_contacts_dialer/repositories/flagged_number_repository.dart';
import 'package:smart_contacts_dialer/services/call_event_logger.dart';
import 'package:smart_contacts_dialer/services/telecom_service.dart';
import 'package:smart_contacts_dialer/utils/call_type_mapper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const dbName = 'smart_contacts_test_block_disconnect.db';
  var disconnectCalled = false;
  Map<String, dynamic>? activeCallResult;
  var blockedEvents = <Map<String, dynamic>>[];

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.setTestDatabaseName(dbName);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(TelecomService.methodChannel, (call) async {
          if (call.method == 'disconnect') {
            disconnectCalled = true;
            return null;
          }
          if (call.method == 'getActiveCall') {
            return activeCallResult;
          }
          if (call.method == 'getBlockedCallEvents') {
            final out = List<Map<String, dynamic>>.from(blockedEvents);
            blockedEvents.clear();
            return out.isEmpty ? null : out.map((e) => e).toList();
          }
          if (call.method == 'setScreeningMirror') {
            return null;
          }
          return null;
        });
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(TelecomService.methodChannel, null);
  });

  setUp(() async {
    disconnectCalled = false;
    activeCallResult = null;
    blockedEvents = [];
    await DatabaseHelper().close();
    await databaseFactory.deleteDatabase(
      join(await getDatabasesPath(), dbName),
    );
  });

  tearDown(() async {
    await DatabaseHelper().close();
  });

  group('Running call disconnect on block', () {
    test('disconnects running call if number matches blocked number', () async {
      final repo = FlaggedNumberRepository();
      activeCallResult = {
        'state': 'active',
        'hasCall': true,
        'number': '+91 98765 43210',
      };

      final added = await repo.add(
        '9876543210',
        kind: FlaggedNumberRepository.kindBlocked,
        defaultIso: 'IN',
      );

      expect(added, isTrue);
      expect(disconnectCalled, isTrue);
    });

    test('does not disconnect running call if number does not match', () async {
      final repo = FlaggedNumberRepository();
      activeCallResult = {
        'state': 'active',
        'hasCall': true,
        'number': '+91 91111 22222',
      };

      final added = await repo.add(
        '9876543210',
        kind: FlaggedNumberRepository.kindBlocked,
        defaultIso: 'IN',
      );

      expect(added, isTrue);
      expect(disconnectCalled, isFalse);
    });

    test('disconnects when the running call is the same number without '
        'its country code', () async {
      final repo = FlaggedNumberRepository();
      // Stored as +919876543210; the live call reports the national form. A
      // 10-digit overlap is a real match and must still hang up.
      activeCallResult = {
        'state': 'active',
        'hasCall': true,
        'number': '9876543210',
      };

      final added = await repo.add(
        '9876543210',
        kind: FlaggedNumberRepository.kindBlocked,
        defaultIso: 'IN',
      );

      expect(added, isTrue);
      expect(disconnectCalled, isTrue);
    });

    test('does not disconnect a different number that shares only the last '
        'seven digits', () async {
      final repo = FlaggedNumberRepository();
      // +919876543210 ends with "6543210", so a 7-digit overlap alone used to
      // count as a match and hung up an unrelated call. Matching now needs at
      // least 9 digits, the same threshold the native screening service uses.
      activeCallResult = {
        'state': 'active',
        'hasCall': true,
        'number': '6543210',
      };

      final added = await repo.add(
        '9876543210',
        kind: FlaggedNumberRepository.kindBlocked,
        defaultIso: 'IN',
      );

      expect(added, isTrue);
      expect(disconnectCalled, isFalse);
    });

    test('does not disconnect if kind is spam rather than blocked', () async {
      final repo = FlaggedNumberRepository();
      activeCallResult = {
        'state': 'active',
        'hasCall': true,
        'number': '+91 98765 43210',
      };

      final added = await repo.add(
        '9876543210',
        kind: FlaggedNumberRepository.kindSpam,
        defaultIso: 'IN',
      );

      expect(added, isTrue);
      expect(disconnectCalled, isFalse);
    });
  });

  group('Block call history logging', () {
    test('drainBlockedCalls writes blocked call into call_logs', () async {
      final now = DateTime.now();
      blockedEvents = [
        {
          'number': '+91 98765 43210',
          'at': now.millisecondsSinceEpoch,
        },
      ];

      final logger = CallEventLogger();
      await logger.drainBlockedCalls();

      final calls = await CallLogRepository().recentCalls();
      expect(calls, hasLength(1));
      expect(calls.first.phoneNumber, '+91 98765 43210');
      expect(calls.first.callType, AppCallType.blocked);
      expect(calls.first.callOutcome, AppCallOutcome.noAnswer);
      expect(calls.first.duration, 0);
    });

    test('drainBlockedCalls handles unknown caller properly', () async {
      final now = DateTime.now();
      blockedEvents = [
        {
          'number': 'Unknown',
          'at': now.millisecondsSinceEpoch,
        },
      ];

      final logger = CallEventLogger();
      await logger.drainBlockedCalls();

      final calls = await CallLogRepository().recentCalls();
      expect(calls, hasLength(1));
      expect(calls.first.phoneNumber, 'Unknown');
      expect(calls.first.callType, AppCallType.blocked);
    });
  });
}
