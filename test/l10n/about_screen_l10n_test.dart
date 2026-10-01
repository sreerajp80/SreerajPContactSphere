// Tests for phase 2g of plans/20260921_064200_item2-arb-string-externalization.md
// — the trilingual `assets/config/app_config.json` and the About screen.
//
// The unit tests cover LocalizedText resolution and AppConfig parsing. The
// widget tests pump the About screen with the real config file in `en`,
// `ml` and `sa` and check that labels and config values are shown in the
// active language, that no English leaks into `ml` or `sa`, and that the
// screen lays out without any error at phone width and 1.3x text.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_contacts_dialer/core/config/app_config.dart';
import 'package:smart_contacts_dialer/core/config/config_service.dart';
import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/l10n/sa_material_localizations.dart';
import 'package:smart_contacts_dialer/screens/about_screen.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

import '../helpers/tooltip_checks.dart';

const _delegates = <LocalizationsDelegate<dynamic>>[
  AppLocalizations.delegate,
  SaMaterialLocalizationsDelegate(),
  SaCupertinoLocalizationsDelegate(),
  SaWidgetsLocalizationsDelegate(),
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalizedText', () {
    test('a plain string reads the same in every language', () {
      const text = LocalizedText.plain('someone@example.com');
      for (final lang in ['en', 'ml', 'sa']) {
        expect(text.resolve(lang), 'someone@example.com');
      }
    });

    test('a locale map resolves exact language, then English', () {
      final text = LocalizedText.fromJson({'en': 'Author', 'ml': 'രചയിതാവ്'});
      expect(text.resolve('ml'), 'രചയിതാവ്');
      expect(text.resolve('sa'), 'Author');
    });

    test('a wrong type falls back instead of throwing', () {
      final text = LocalizedText.fromJson(42, fallback: 'Fallback');
      expect(text.resolve('en'), 'Fallback');
    });
  });

  group('AppConfig', () {
    test('the bundled config parses with trilingual display values', () {
      final json =
          jsonDecode(File('assets/config/app_config.json').readAsStringSync())
              as Map<String, dynamic>;
      final config = AppConfig.fromJson(json);
      expect(config.appName.resolve('en'), 'SreerajP Contacts Sphere');
      expect(config.appName.resolve('ml'), isNot('SreerajP Contacts Sphere'));
      expect(config.details.keys, contains('author'));
      expect(
        config.details['email']!.resolve('sa'),
        config.details['email']!.resolve('en'),
      );
    });
  });

  for (final locale in ['en', 'ml', 'sa']) {
    testWidgets('[$locale] About screen', (tester) async {
      final l10n = lookupAppLocalizations(Locale(locale));
      final english = lookupAppLocalizations(const Locale('en'));
      final configText = File(
        'assets/config/app_config.json',
      ).readAsStringSync();
      final config = AppConfig.fromJson(
        jsonDecode(configText) as Map<String, dynamic>,
      );

      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(360, 1600);
      addTearDown(tester.view.reset);

      final original = FlutterError.onError;
      // Record every Flutter error, not only overflows: a row that cannot lay
      // out at all (a long value in a ListTile trailing slot) reports as an
      // assertion, not an overflow.
      final errors = <String>[];
      FlutterError.onError = (details) {
        errors.add(details.exceptionAsString().split('\n').first);
      };

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.calm(const Color(0xFF007A78)),
          locale: Locale(locale),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: _delegates,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.3)),
            child: child!,
          ),
          home: AboutScreen(
            configService: ConfigService(loadAsset: (_) async => configText),
          ),
        ),
      );
      // loadAndVerify() also asks the platform for package info, which only
      // settles with real async time in a widget test.
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await tester.pumpAndSettle();
      FlutterError.onError = original;
      expectAllIconButtonsHaveTooltips(tester);

      expect(find.text(l10n.titleAbout), findsOneWidget);
      expect(find.text(l10n.labelVersion), findsOneWidget);
      expect(find.text(l10n.aboutDetailAuthor), findsOneWidget);
      expect(find.text(config.appName.resolve(locale)), findsOneWidget);
      expect(
        find.text(config.details['author']!.resolve(locale)),
        findsOneWidget,
      );
      if (locale != 'en') {
        for (final text in [
          english.titleAbout,
          english.labelVersion,
          english.aboutDetailAuthor,
          english.aboutDetailLicense,
          config.description.resolve('en'),
        ]) {
          expect(find.text(text), findsNothing, reason: '"$text" leaked');
        }
      }
      expect(errors, isEmpty, reason: errors.join('\n'));
    });
  }
}
