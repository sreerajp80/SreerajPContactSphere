// Widget tests for the speed-dial behaviour of the dialer keypad.
//
// Two things are checked that only show up on a real keypad:
//
//  * the "assigned" dot is an overlay, so a key still lays out on a narrow
//    screen — the digit and its letter legend must not overflow;
//  * a long press only acts when the number box is EMPTY, so a stray long press
//    while a number is being typed can never start a call to someone else.
//
// `pumpAndSettle` must not be used here: the contact picker's loading spinner
// animates forever, so "no more frames scheduled" never arrives and the test
// would hang until the timeout. [_settle] pumps against real wall-clock time
// instead, which also lets the unawaited database reads finish before the next
// test closes the database.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/repositories/speed_dial_repository.dart';
import 'package:smart_contacts_dialer/screens/dialer_screen.dart';
import 'package:smart_contacts_dialer/services/telecom_service.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

const String _dbName = 'smart_contacts_test_dialer_speed_dial.db';

Future<void> _settle(WidgetTester tester, {int rounds = 20}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
  }
}

/// Pumps the dialer on a small phone-sized viewport — 360x740 logical pixels,
/// about the narrowest screen Android phones ship with, so the keypad is laid
/// out under real pressure. (Legend width itself is covered by
/// dialer_keypad_legend_test.dart.)
Future<void> _pumpDialer(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(360, 740);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ChangeNotifierProvider<AppSettings>(
      create: (_) => AppSettings(),
      child: MaterialApp(
        theme: AppTheme.calm(const Color(0xFF007A78)),
        home: const DialerScreen(),
      ),
    ),
  );
  await _settle(tester);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.setTestDatabaseName(_dbName);

    // The dialer mixes in CallLifecycleMixin, which talks to the native Telecom
    // bridge. Stub both channels so the screen builds off-device: no SIMs, no
    // active call, and a call-event stream that never emits.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(TelecomService.methodChannel, (call) async {
          switch (call.method) {
            case 'getSimAccounts':
              return <Object?>[];
            default:
              return null;
          }
        });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockStreamHandler(
          TelecomService.eventChannel,
          MockStreamHandler.inline(onListen: (args, sink) {}),
        );
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      ..setMockMethodCallHandler(TelecomService.methodChannel, null)
      ..setMockStreamHandler(TelecomService.eventChannel, null);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await DatabaseHelper().close();
    await databaseFactory.deleteDatabase(
      join(await getDatabasesPath(), _dbName),
    );
  });

  tearDown(() async {
    await DatabaseHelper().close();
  });

  testWidgets('the keypad lays out on a narrow screen with a key assigned', (
    tester,
  ) async {
    await tester.runAsync(
      () => SpeedDialRepository().assign(slot: 2, phoneNumber: '9876543210'),
    );

    await _pumpDialer(tester);

    // Every digit key still renders...
    for (final digit in const ['1', '2', '3', '9', '0']) {
      expect(find.text(digit), findsWidgets, reason: 'key $digit missing');
    }
    // ...and nothing overflowed (an overflow is reported as an exception).
    expect(tester.takeException(), isNull);
  });

  testWidgets('a long press does nothing while a number is being typed', (
    tester,
  ) async {
    await _pumpDialer(tester);

    // Type a digit, so the number box is no longer empty.
    await tester.tap(find.text('5').first);
    await _settle(tester, rounds: 6);

    // Key 3 holds nothing. With an empty box this would open the picker; with
    // a number typed it must do nothing at all.
    await tester.longPress(find.text('3').first);
    await _settle(tester, rounds: 10);

    expect(find.text('Speed dial 3'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('long-pressing an empty key opens the picker to assign it', (
    tester,
  ) async {
    await _pumpDialer(tester);

    await tester.longPress(find.text('4').first);
    await _settle(tester);

    // The contact picker sheet opens, titled for the key being filled.
    expect(find.text('Speed dial 4'), findsOneWidget);
  });
}
