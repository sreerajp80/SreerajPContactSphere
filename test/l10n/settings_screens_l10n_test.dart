// Widget tests for phase 2d of plans/20260921_064200_item2-arb-string-externalization.md
// — the Settings screens — in all three languages.
//
// Each screen is pumped on a narrow phone (360x740) at 1.3x text, the size the
// phase 2b and 2c tests use, and checked for: its translated title and one of
// its rows, no English leaking into `ml` or `sa`, and no layout overflow.
// Font rendering itself stays on the manual release checklist (standard 8.3.3).

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/l10n/sa_material_localizations.dart';
import 'package:smart_contacts_dialer/screens/contact_display_settings_screen.dart';
import 'package:smart_contacts_dialer/screens/contact_sync_settings_screen.dart';
import 'package:smart_contacts_dialer/screens/contacts_settings_screen.dart';
import 'package:smart_contacts_dialer/screens/identification_settings_screen.dart';
import 'package:smart_contacts_dialer/screens/ringtone_settings_screen.dart';
import 'package:smart_contacts_dialer/screens/screenshot_guard_settings_screen.dart';
import 'package:smart_contacts_dialer/screens/settings_screen.dart';
import 'package:smart_contacts_dialer/screens/sim_settings_screen.dart';
import 'package:smart_contacts_dialer/screens/theme_mode_settings_screen.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/state/locale_controller.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

import '../helpers/tooltip_checks.dart';

const _locales = ['en', 'ml', 'sa'];

const _delegates = <LocalizationsDelegate<dynamic>>[
  AppLocalizations.delegate,
  SaMaterialLocalizationsDelegate(),
  SaCupertinoLocalizationsDelegate(),
  SaWidgetsLocalizationsDelegate(),
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

/// One screen under test: how to build it, text that must appear, and English
/// that must not appear under `ml` or `sa`.
class _Case {
  final String name;
  final Widget screen;
  final List<String> Function(AppLocalizations) expected;
  final List<String> english;
  const _Case(this.name, this.screen, this.expected, this.english);
}

final _cases = <_Case>[
  _Case(
    'Settings',
    const SettingsScreen(),
    (l) => [l.titleSettings, l.titleSecurity, l.descSecurityCard],
    ['Settings', 'Security', 'Speed Dial'],
  ),
  _Case(
    'Contacts settings',
    const ContactsSettingsScreen(),
    (l) => [l.navContacts, l.labelDisplayFormatting],
    ['Display & formatting', 'Blocked numbers'],
  ),
  _Case(
    'SIM & calling',
    const SimSettingsScreen(),
    (l) => [l.titleSimCalling, l.labelSimCardsAccounts],
    ['SIM & calling', 'SIM Cards & Accounts'],
  ),
  _Case(
    'Ringtone',
    const RingtoneSettingsScreen(),
    (l) => [l.labelRingtone, l.labelVolumeVibration],
    ['Ringtone', 'Volume & vibration'],
  ),
  _Case(
    'Theme mode',
    const ThemeModeSettingsScreen(),
    (l) => [l.labelLight, l.labelDark, l.labelSystem],
    ['Light', 'Dark', 'System'],
  ),
  _Case(
    'Screenshot guard',
    const ScreenshotGuardSettingsScreen(),
    (l) => [l.titleScreenshotGuard, l.labelBlockScreenshots],
    ['Screenshot Guard', 'Block screenshots'],
  ),
  _Case(
    'Identification',
    const IdentificationSettingsScreen(),
    (l) => [l.labelIdentification, l.labelCallerIdentification],
    ['Identification', 'Caller identification'],
  ),
  _Case(
    'Display & formatting',
    const ContactDisplaySettingsScreen(),
    (l) => [l.labelSortOrder, l.labelFirstName],
    ['Sort order', 'First name'],
  ),
  _Case(
    'Contact sync',
    const ContactSyncSettingsScreen(),
    (l) => [l.titleSync, l.actionAddDeviceToApp],
    ['Sync', 'Add device contacts to app'],
  ),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final locale in _locales) {
    for (final c in _cases) {
      testWidgets('[$locale] ${c.name}', (tester) async {
        final l10n = lookupAppLocalizations(Locale(locale));
        tester.view.devicePixelRatio = 1.0;
        tester.view.physicalSize = const Size(360, 740);
        addTearDown(tester.view.reset);
        SharedPreferences.setMockInitialValues({'app_language': locale});
        final prefs = await SharedPreferences.getInstance();

        final original = FlutterError.onError;
        final overflows = <String>[];
        FlutterError.onError = (details) {
          final text = details.exceptionAsString();
          if (text.contains('overflowed')) overflows.add(text);
        };

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => AppSettings()),
              ChangeNotifierProvider(create: (_) => LocaleController(prefs)),
            ],
            child: MaterialApp(
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
              home: c.screen,
            ),
          ),
        );
        await tester.pump();
        // Restore the handler before any expect: a failing expect while it is
        // overridden makes the test binding hang instead of reporting.
        FlutterError.onError = original;
        expectAllIconButtonsHaveTooltips(tester);

        for (final text in c.expected(l10n)) {
          expect(find.text(text), findsWidgets, reason: text);
        }
        if (locale != 'en') {
          for (final text in c.english) {
            expect(find.text(text), findsNothing, reason: '"$text" leaked');
          }
        }
        expect(overflows, isEmpty, reason: overflows.join('\n'));
      });
    }
  }
}
