// Widget tests for the first ARB-converted screen, in all three languages.
//
// Engineering standard section 8.7 requires a converted screen's widget test to
// run under `en`, `ml` and `sa`, proving that nothing overflows and that no
// English leaks through. `BlockedNumbersScreen` is the phase 2a pilot of
// plans/20260921_064200_item2-arb-string-externalization.md, so it is the
// screen that proves the whole loop: ARB -> gen-l10n -> AppLocalizations ->
// widget, including a String placeholder, an int placeholder and a localized
// date.
//
// Sanskrit needs a shim. The framework's GlobalMaterialLocalizations has no
// `sa`, so a MaterialApp pumped with `Locale('sa')` finds no MaterialLocalizations
// and asserts. Supplying the English Material strings under any unsupported
// locale is exactly what item 3 (plans/20260921_064300_item3-sanskrit-fallback-delegates.md)
// adds to the app; until then [_FallbackMaterialLocalizationsDelegate] below
// does it for the test only, so the app's own Sanskrit strings can be checked
// now.
//
// Runs sqflite on the host VM via sqflite_common_ffi so the list has a real
// row to render.

import 'package:flutter/cupertino.dart' show CupertinoLocalizations;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/repositories/flagged_number_repository.dart';
import 'package:smart_contacts_dialer/screens/blocked_numbers_screen.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

import '../helpers/tooltip_checks.dart';

const String _dbName = 'smart_contacts_test_blocked_l10n.db';

/// Serves the English Material/Cupertino strings for any locale the framework
/// does not localize itself. Test-only stand-in for item 3.
class _FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(const Locale('en'));

  @override
  bool shouldReload(_FallbackMaterialLocalizationsDelegate old) => false;
}

class _FallbackWidgetsLocalizationsDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
  const _FallbackWidgetsLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<WidgetsLocalizations> load(Locale locale) =>
      GlobalWidgetsLocalizations.delegate.load(const Locale('en'));

  @override
  bool shouldReload(_FallbackWidgetsLocalizationsDelegate old) => false;
}

class _FallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(const Locale('en'));

  @override
  bool shouldReload(_FallbackCupertinoLocalizationsDelegate old) => false;
}

/// The delegate list the tests pump with. The three `_Fallback…` entries sit
/// last, so a locale the framework does localize keeps its real translations
/// and only `sa` falls through to the English Material strings.
const List<LocalizationsDelegate<Object>> _delegates = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
  _FallbackMaterialLocalizationsDelegate(),
  _FallbackWidgetsLocalizationsDelegate(),
  _FallbackCupertinoLocalizationsDelegate(),
];

/// Pumps the screen into a tall viewport.
///
/// The screen is a plain `ListView`, which builds only the rows that fit on
/// screen. Malayalam and Sanskrit prose wraps to more lines than English, so on
/// a phone-sized window the blocked-numbers card is never built and a
/// `find.text` for it fails even though the screen is correct. A tall window
/// builds the whole page in one pass. Layout pressure is covered separately by
/// the large-font-size test below.
Future<void> _pump(WidgetTester tester, Locale locale) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(400, 2000);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ChangeNotifierProvider<AppSettings>(
      create: (_) => AppSettings(),
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: _delegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.calm(const Color(0xFF007A78)),
        home: const BlockedNumbersScreen(),
      ),
    ),
  );

  // The screen reads the blocked list from the database in initState; let that
  // future land before asserting on what is on screen.
  for (var i = 0; i < 10; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
  }
}

/// The strings this screen shows, read straight from the generated class for
/// [locale] — the test never hard-codes a translation, so a wording change in
/// the ARB file does not break it.
Future<AppLocalizations> _strings(Locale locale) =>
    AppLocalizations.delegate.load(locale);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const locales = [Locale('en'), Locale('ml'), Locale('sa')];

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.setTestDatabaseName(_dbName);
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  setUp(() async {
    await DatabaseHelper().close();
    await databaseFactory.deleteDatabase(
      join(await getDatabasesPath(), _dbName),
    );
    await FlaggedNumberRepository().add(
      '98765 43210',
      kind: FlaggedNumberRepository.kindBlocked,
      defaultIso: 'IN',
    );
  });

  tearDown(() async {
    await DatabaseHelper().close();
  });

  group('BlockedNumbersScreen renders in every supported language', () {
    for (final locale in locales) {
      testWidgets('${locale.languageCode}: every string comes from the ARB', (
        tester,
      ) async {
        final l10n = await _strings(locale);
        await _pump(tester, locale);

        expect(find.text(l10n.titleBlockedNumbers), findsOneWidget);
        expect(find.text(l10n.labelBlockUnknownCallers), findsOneWidget);
        expect(find.text(l10n.descBlockUnknownCallers), findsOneWidget);
        expect(find.text(l10n.descBlockedNumbersInfo), findsOneWidget);
        expect(find.text(l10n.actionAddNumber), findsOneWidget);
        expect(find.text(l10n.descAddNumber), findsOneWidget);
        // One row exists, so the count heading shows and the empty note does not.
        expect(find.text(l10n.labelBlockedCount(1)), findsOneWidget);
        expect(find.text(l10n.emptyBlockedNumbers), findsNothing);
        expect(
          find.byTooltip(l10n.tooltipUnblock),
          findsOneWidget,
          reason: 'icon-only unblock button must keep a localized tooltip',
        );
        expectAllIconButtonsHaveTooltips(tester);
      });

      testWidgets('${locale.languageCode}: the block dialog is localized', (
        tester,
      ) async {
        final l10n = await _strings(locale);
        await _pump(tester, locale);

        await tester.tap(find.text(l10n.actionAddNumber));
        await tester.pumpAndSettle();

        expect(find.text(l10n.titleBlockNumber), findsOneWidget);
        expect(find.text(l10n.labelPhoneNumber), findsOneWidget);
        expect(find.text(l10n.hintPhoneNumberExample), findsOneWidget);
        expect(find.text(l10n.actionCancel), findsOneWidget);
        expect(find.text(l10n.actionBlock), findsOneWidget);
      });

      testWidgets('${locale.languageCode}: no English leaks into ml or sa', (
        tester,
      ) async {
        final en = await _strings(const Locale('en'));
        await _pump(tester, locale);

        if (locale.languageCode == 'en') return;
        for (final englishOnly in [
          en.titleBlockedNumbers,
          en.labelBlockUnknownCallers,
          en.descBlockUnknownCallers,
          en.actionAddNumber,
          en.descAddNumber,
          en.emptyBlockedNumbers,
        ]) {
          expect(
            find.text(englishOnly),
            findsNothing,
            reason: 'English "$englishOnly" is showing under $locale',
          );
        }
      });
    }

    testWidgets('a large system font size does not overflow in any language', (
      tester,
    ) async {
      for (final locale in locales) {
        tester.view.devicePixelRatio = 1.0;
        tester.view.physicalSize = const Size(320, 640);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          ChangeNotifierProvider<AppSettings>(
            create: (_) => AppSettings(),
            child: MaterialApp(
              locale: locale,
              localizationsDelegates: _delegates,
              supportedLocales: AppLocalizations.supportedLocales,
              theme: AppTheme.calm(const Color(0xFF007A78)),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(1.6)),
                child: child!,
              ),
              home: const BlockedNumbersScreen(),
            ),
          ),
        );
        for (var i = 0; i < 10; i++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 20)),
          );
          await tester.pump();
        }

        // An overflow is reported as an exception, so a clean pump is the proof.
        expect(
          tester.takeException(),
          isNull,
          reason: 'layout overflowed under $locale at a 1.6x font size',
        );
      }
    });
  });
}
