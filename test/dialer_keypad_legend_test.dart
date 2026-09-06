// Widget tests for the letter legend under each dialpad key.
//
// The legend ("ABC", "PQRS", and the secondary script when one is chosen) used
// to be a plain Row with a fixed font size, so it asked for whatever width its
// letters needed and overflowed the key when that width was not there. These
// tests pin the three ways it ran out of room:
//
//  * a narrow screen,
//  * a large system font size,
//  * the wider English + secondary-script legend.
//
// An overflow is reported as an exception, so a clean pump is the proof.
//
// Height is covered too: keys grow taller with the system font size, so a large
// setting must not clip the digit — and must not push the call button off the
// bottom of the screen either.
//
// `pumpAndSettle` must not be used here: the dialer keeps animations running,
// so "no more frames scheduled" never arrives. [_settle] pumps against real
// wall-clock time instead, which also lets the unawaited database reads finish
// before the next test closes the database.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/screens/dialer_screen.dart';
import 'package:smart_contacts_dialer/services/telecom_service.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

const String _dbName = 'smart_contacts_test_dialer_legend.db';

Future<void> _settle(WidgetTester tester, {int rounds = 20}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
  }
}

/// Pumps the dialer under layout pressure: a viewport of [size], the system
/// font size at [textScale], and an optional secondary [script] on the keys.
Future<void> _pumpDialer(
  WidgetTester tester, {
  Size size = const Size(360, 740),
  double textScale = 1.0,
  DialpadScript? script,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  final settings = AppSettings();
  if (script != null) {
    await settings.setDialpadScript(script);
  }

  await tester.pumpWidget(
    ChangeNotifierProvider<AppSettings>.value(
      value: settings,
      child: MaterialApp(
        theme: AppTheme.calm(const Color(0xFF007A78)),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
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

  testWidgets('the legend fits on a 320-pixel-wide screen', (tester) async {
    await _pumpDialer(tester, size: const Size(320, 640));

    // "PQRS" is the widest English legend after "WXYZ"; both must be there.
    expect(find.text('PQRS'), findsOneWidget);
    expect(find.text('WXYZ'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the keypad fits at a large system font size', (tester) async {
    await _pumpDialer(tester, textScale: 1.5);

    expect(find.text('PQRS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the legend fits with a secondary script on the keys', (
    tester,
  ) async {
    await _pumpDialer(tester, script: DialpadScript.malayalam);

    // English and Malayalam share the row, with a separator between them.
    expect(find.text('PQRS'), findsOneWidget);
    expect(find.text(' · '), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the legend fits on a narrow screen with a secondary script', (
    tester,
  ) async {
    // The worst width case: the narrowest screen and the widest legend.
    await _pumpDialer(
      tester,
      size: const Size(320, 640),
      script: DialpadScript.malayalam,
    );

    expect(find.text('PQRS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the keypad fits on a narrow screen at a large font size with '
      'a secondary script', (tester) async {
    // The worst case in both directions at once.
    await _pumpDialer(
      tester,
      size: const Size(320, 640),
      textScale: 1.5,
      script: DialpadScript.malayalam,
    );

    expect(find.text('PQRS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the call button stays on screen when the keypad grows', (
    tester,
  ) async {
    await _pumpDialer(tester, size: const Size(320, 640), textScale: 1.5);

    // Taller keys take their extra height from the flexible strip above the
    // pad. If they ever took it from below instead, the call button would be
    // pushed off the bottom of the screen.
    final callButton = find.byIcon(Icons.call).hitTestable();
    expect(callButton, findsWidgets);
    final box = tester.getRect(callButton.first);
    expect(box.bottom, lessThanOrEqualTo(640.0));
    expect(tester.takeException(), isNull);
  });
}
