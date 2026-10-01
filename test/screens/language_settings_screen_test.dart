// Widget tests for the in-app language picker (engineering standard 8.4),
// run in all three languages as section 8.7 requires.
//
// The harness mirrors the app's root wiring: a LocaleController provider with
// MaterialApp.locale driven by it, the same resolver, and the same delegate
// order (Sa* ahead of Global). The picker is pushed on top of a home route so
// the tests can prove a language change keeps the user on the picker instead
// of popping them back home.

import 'dart:ui' show CheckedState;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/l10n/sa_material_localizations.dart';
import 'package:smart_contacts_dialer/screens/language_settings_screen.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/state/locale_controller.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

import '../helpers/tooltip_checks.dart';

const _homeText = 'HOME ROUTE';

Future<LocaleController> _pump(
  WidgetTester tester, {
  required String saved,
}) async {
  SharedPreferences.setMockInitialValues({LocaleController.prefKey: saved});
  final controller = await LocaleController.load();

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppSettings>(create: (_) => AppSettings()),
        ChangeNotifierProvider<LocaleController>.value(value: controller),
      ],
      child: Consumer<LocaleController>(
        builder: (context, c, _) => MaterialApp(
          locale: c.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            SaMaterialLocalizationsDelegate(),
            SaCupertinoLocalizationsDelegate(),
            SaWidgetsLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          localeListResolutionCallback: (preferred, _) =>
              LocaleController.resolve(preferred, const []),
          theme: AppTheme.calm(const Color(0xFF007A78)),
          home: const Scaffold(body: Text(_homeText)),
        ),
      ),
    ),
  );

  final nav = tester.state<NavigatorState>(find.byType(Navigator));
  nav.push(
    MaterialPageRoute<void>(builder: (_) => const LanguageSettingsScreen()),
  );
  await tester.pumpAndSettle();
  return controller;
}

Future<AppLocalizations> _strings(String code) =>
    AppLocalizations.delegate.load(Locale(code));

/// Whether the row for [value] is announced as checked. Reads the merged
/// semantics node a screen reader lands on (the one holding the row's label),
/// so it proves the selection is exposed to TalkBack, not just drawn.
bool _isSelected(WidgetTester tester, String value) {
  final row = find.descendant(
    of: find.byKey(ValueKey('language_option_$value')),
    matching: find.byType(Text),
  );
  final node = tester.getSemantics(row.first);
  return node.getSemanticsData().flagsCollection.isChecked ==
      CheckedState.isTrue;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final code in LocaleController.supported) {
    group('LanguageSettingsScreen under $code', () {
      testWidgets('all four options render, in their own scripts', (
        tester,
      ) async {
        await _pump(tester, saved: code);
        final l10n = await _strings(code);

        expect(find.text(l10n.titleLanguage), findsOneWidget);
        expect(find.text(l10n.labelSystemDefault), findsOneWidget);
        expect(find.text(l10n.descLanguageSystemDefault), findsOneWidget);
        // Endonyms read the same whatever language the app is in.
        expect(find.text('English'), findsOneWidget);
        expect(find.text('മലയാളം'), findsOneWidget);
        expect(find.text('संस्कृतम्'), findsOneWidget);
        expect(tester.takeException(), isNull);
        expectAllIconButtonsHaveTooltips(tester);
      });

      testWidgets('System default is first and the current one is marked', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await _pump(tester, saved: code);

        final tiles = tester
            .widgetList<RadioListTile<String>>(
              find.byType(RadioListTile<String>),
            )
            .map((t) => t.value)
            .toList();
        expect(tiles, ['system', 'en', 'ml', 'sa']);

        for (final value in LocaleController.options) {
          expect(
            _isSelected(tester, value),
            value == code,
            reason: '$value selection mark is wrong while $code is saved',
          );
        }
        handle.dispose();
      });

      testWidgets('no English chrome leaks into ml or sa', (tester) async {
        if (code == 'en') return;
        await _pump(tester, saved: code);
        final en = await _strings('en');

        expect(find.text(en.titleLanguage), findsNothing);
        expect(find.text(en.labelSystemDefault), findsNothing);
        expect(find.text(en.descLanguageSystemDefault), findsNothing);
      });
    });
  }

  testWidgets('tapping a language applies it at once and stays on the picker', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final controller = await _pump(tester, saved: 'en');
    final ml = await _strings('ml');

    await tester.tap(find.text('മലയാളം'));
    await tester.pumpAndSettle();

    // MaterialApp.locale changed without a restart…
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.locale, const Locale('ml'));
    expect(controller.value, 'ml');
    // …the screen redrew in Malayalam and is still on top, not popped home.
    expect(find.text(ml.titleLanguage), findsOneWidget);
    expect(find.text(_homeText), findsNothing);
    expect(find.byType(LanguageSettingsScreen), findsOneWidget);
    expect(_isSelected(tester, 'ml'), isTrue);
    expect(_isSelected(tester, 'en'), isFalse);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(LocaleController.prefKey), 'ml');

    // And back to System default.
    await tester.tap(find.text(ml.labelSystemDefault));
    await tester.pumpAndSettle();
    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).locale, isNull);
    expect(prefs.getString(LocaleController.prefKey), 'system');
    expect(find.byType(LanguageSettingsScreen), findsOneWidget);
    handle.dispose();
  });

  testWidgets('a large font size does not overflow in any language', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.reset);
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    for (final code in LocaleController.supported) {
      await _pump(tester, saved: code);
      expect(
        tester.takeException(),
        isNull,
        reason: 'layout overflowed under $code at a 1.6x font size',
      );
    }
  });
}
