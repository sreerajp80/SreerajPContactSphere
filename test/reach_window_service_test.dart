// Tests for ReachWindowService — the "usually answers after 5pm" advice.
//
// The service must stay quiet unless the contact's own history really supports
// a claim, so most of these tests assert that it returns null.
//
// Runs sqflite on the host VM via sqflite_common_ffi (the default sqflite
// factory is Android-only and unavailable under `flutter test`).

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/models/contact.dart';
import 'package:smart_contacts_dialer/models/reach_window.dart';
import 'package:smart_contacts_dialer/repositories/contact_repository.dart';
import 'package:smart_contacts_dialer/services/reach_window_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const dbName = 'smart_contacts_test_reach_window.db';

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

  Future<int> newContact(String name) =>
      contacts.insertContact(Contact(firstName: name));

  /// Logs one call [daysAgo] days back at [hour] o'clock local time.
  ///
  /// `duration` drives everything: > 0 is answered, 0 is not, null is a call
  /// still in progress.
  Future<void> logCall(
    int contactId, {
    required int hour,
    required int daysAgo,
    int? duration = 60,
    String callType = 'outgoing',
  }) async {
    final now = DateTime.now();
    final day = DateTime(now.year, now.month, now.day).subtract(
      Duration(days: daysAgo),
    );
    final at = DateTime(day.year, day.month, day.day, hour, 30);
    final db = await DatabaseHelper().database;
    await db.insert('call_logs', {
      'contact_id': contactId,
      'phone_number': '9876543210',
      'call_type': callType,
      'duration': duration,
      'timestamp': at.toIso8601String(),
    });
  }

  test('a clear evening answerer yields the evening window', () async {
    final id = await newContact('Evening');
    // Answered every evening, never answered in the morning.
    for (var i = 1; i <= 6; i++) {
      await logCall(id, hour: 19, daysAgo: i, duration: 120);
    }
    for (var i = 7; i <= 12; i++) {
      await logCall(id, hour: 9, daysAgo: i, duration: 0);
    }

    final window = await ReachWindowService().bestWindow(id);
    expect(window, isNotNull);
    expect(window!.dayPart, DayPart.evening);
    expect(window.sentence, contains('after 5pm'));
    expect(window.answerRate, 1.0);
  });

  test('too few calls says nothing at all', () async {
    final id = await newContact('Sparse');
    for (var i = 1; i <= 5; i++) {
      await logCall(id, hour: 19, daysAgo: i, duration: 120);
    }

    expect(await ReachWindowService().bestWindow(id), isNull);
  });

  test('an evenly-spread history says nothing — no window clears the margin',
      () async {
    final id = await newContact('Even');
    // Half answered in the evening, half answered in the morning — the same
    // rate either way, so neither part is worth mentioning.
    for (var i = 1; i <= 6; i++) {
      await logCall(id, hour: 19, daysAgo: i, duration: i <= 3 ? 120 : 0);
    }
    for (var i = 7; i <= 12; i++) {
      await logCall(id, hour: 9, daysAgo: i, duration: i <= 9 ? 120 : 0);
    }

    expect(await ReachWindowService().bestWindow(id), isNull);
  });

  test('missed and zero-duration outgoing calls count as not answered',
      () async {
    final id = await newContact('Missy');
    for (var i = 1; i <= 5; i++) {
      await logCall(id, hour: 19, daysAgo: i, duration: 0, callType: 'missed');
    }
    for (var i = 6; i <= 10; i++) {
      await logCall(id, hour: 19, daysAgo: i, duration: 0);
    }

    // Nothing was ever answered, so no window can beat the overall rate.
    expect(await ReachWindowService().bestWindow(id), isNull);
  });

  test('blocked calls are excluded from the counts', () async {
    final id = await newContact('Blocked');
    for (var i = 1; i <= 6; i++) {
      await logCall(id, hour: 19, daysAgo: i, duration: 120);
    }
    // Blocked rows would drag the evening rate down if they were counted.
    for (var i = 7; i <= 20; i++) {
      await logCall(
        id,
        hour: 19,
        daysAgo: i,
        duration: 0,
        callType: 'blocked',
      );
    }
    for (var i = 21; i <= 26; i++) {
      await logCall(id, hour: 9, daysAgo: i, duration: 0);
    }

    final window = await ReachWindowService().bestWindow(id);
    expect(window, isNotNull);
    expect(window!.dayPart, DayPart.evening);
    // 6 evening + 6 morning; the 14 blocked rows were dropped.
    expect(window.totalCalls, 12);
  });

  test('a call still in progress is not counted as unanswered', () async {
    final id = await newContact('InFlight');
    for (var i = 1; i <= 6; i++) {
      await logCall(id, hour: 19, daysAgo: i, duration: 120);
    }
    for (var i = 7; i <= 12; i++) {
      await logCall(id, hour: 9, daysAgo: i, duration: 0);
    }
    // Placed seconds ago, no outcome yet.
    final db = await DatabaseHelper().database;
    await db.insert('call_logs', {
      'contact_id': id,
      'phone_number': '9876543210',
      'call_type': 'outgoing',
      'duration': null,
      'timestamp': DateTime.now().toIso8601String(),
    });

    final window = await ReachWindowService().bestWindow(id);
    expect(window, isNotNull);
    expect(window!.totalCalls, 12);
  });

  test('calls older than the lookback window are ignored', () async {
    final id = await newContact('Ancient');
    // An old evening habit, well outside the 180-day window.
    for (var i = 1; i <= 10; i++) {
      await logCall(id, hour: 19, daysAgo: 200 + i, duration: 120);
    }
    for (var i = 1; i <= 6; i++) {
      await logCall(id, hour: 9, daysAgo: i, duration: 0);
    }

    expect(await ReachWindowService().bestWindow(id), isNull);
  });

  group('DayPart', () {
    test('night wraps past midnight', () {
      expect(DayPart.night.contains(23), isTrue);
      expect(DayPart.night.contains(2), isTrue);
      expect(DayPart.night.contains(12), isFalse);
      expect(DayPart.of(2), DayPart.night);
      expect(DayPart.of(9), DayPart.morning);
      expect(DayPart.of(14), DayPart.afternoon);
      expect(DayPart.of(18), DayPart.evening);
    });

    test('every hour of the day belongs to exactly one part', () {
      for (var hour = 0; hour < 24; hour++) {
        final parts = DayPart.values.where((p) => p.contains(hour)).toList();
        expect(parts, hasLength(1), reason: 'hour $hour');
      }
    });
  });
}
