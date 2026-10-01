// Widget tests for phase 2e of plans/20260921_064200_item2-arb-string-externalization.md
// — the secondary screens and the Settings sub-screens — in all three
// languages, plus unit tests for the display-label helpers added in 2e.
//
// Each screen is pumped on a narrow phone (360x740) at 1.3x text, the size the
// earlier phase tests use, and checked for: its translated title and one of
// its rows, no English leaking into `ml` or `sa`, and no layout overflow.
// Screens that need the encrypted database or a platform plugin to build are
// covered by the helper tests and the manual release checklist instead.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_contacts_dialer/core/constants/app_permissions.dart';
import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/l10n/audit_labels.dart';
import 'package:smart_contacts_dialer/l10n/permission_labels.dart';
import 'package:smart_contacts_dialer/l10n/relationship_labels.dart';
import 'package:smart_contacts_dialer/l10n/sa_material_localizations.dart';
import 'package:smart_contacts_dialer/models/audit_entry.dart';
import 'package:smart_contacts_dialer/models/relationship.dart';
import 'package:smart_contacts_dialer/screens/appearance_screen.dart';
import 'package:smart_contacts_dialer/screens/backup/backup_restore_screen.dart';
import 'package:smart_contacts_dialer/screens/post_call_feedback_screen.dart';
import 'package:smart_contacts_dialer/screens/quick_replies_screen.dart';
import 'package:smart_contacts_dialer/screens/ringtone_volume_vibration_screen.dart';
import 'package:smart_contacts_dialer/screens/sync/sync_home_screen.dart';
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
    'Appearance',
    const AppearanceScreen(),
    (l) => [l.titleAppearance, l.descThemeModeRow],
    ['Appearance', 'Choose between Light, Dark, or System mode'],
  ),
  _Case(
    'Backup & Restore',
    const BackupRestoreScreen(),
    (l) => [l.titleBackupRestore, l.actionBackUpNow, l.descBackUpNow],
    ['Backup & Restore', 'Back up now', 'Restore from a file'],
  ),
  _Case(
    'Sync home',
    const SyncHomeScreen(),
    (l) => [
      l.titleSyncToAnotherDevice,
      l.titleSendToDevice,
      l.descSendToDevice,
    ],
    ['Sync to Another Device', 'Send to Another Device'],
  ),
  _Case(
    'Post-call options',
    const PostCallFeedbackScreen(),
    (l) => [l.titlePostCallOptions, l.labelAskAfterCalls],
    ['Post-call Options', 'Ask after calls'],
  ),
  _Case(
    'Volume & vibration',
    const RingtoneVolumeVibrationScreen(),
    (l) => [l.titleVolumeVibration, l.labelRingtoneVolume],
    ['Volume & Vibration', 'Ringtone volume', 'Vibrate on incoming calls'],
  ),
  _Case(
    'Quick replies',
    const QuickRepliesScreen(),
    (l) => [l.labelQuickReplies, l.actionAddReply],
    ['Quick replies', 'Add a reply'],
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

  group('display-label helpers', () {
    for (final locale in _locales) {
      final l = lookupAppLocalizations(Locale(locale));

      test('[$locale] every audit action, source and field has a label', () {
        for (final a in AuditAction.values) {
          expect(auditActionLabel(l, a), isNotEmpty);
          expect(auditUndoDescription(l, a), isNotEmpty);
        }
        final sources = AuditSource.values.map((s) => auditSourceLabel(l, s));
        expect(sources.toSet(), hasLength(AuditSource.values.length));
        for (final english in AuditEntry.contactFieldLabels.values) {
          final shown = auditFieldLabel(l, english);
          expect(shown, isNotEmpty);
          if (locale != 'en') expect(shown, isNot(english), reason: english);
        }
        expect(auditValueText(l, 'Yes'), l.actionYes);
        expect(auditValueText(l, '+91 98765'), '+91 98765');
      });

      test('[$locale] every permission row is translated', () {
        for (final p in kAppPermissions) {
          final title = permissionTitle(l, p);
          final reason = permissionReason(l, p);
          if (locale == 'en') {
            expect(title, p.title);
            expect(reason, p.reason);
          } else {
            expect(title, isNot(p.title), reason: p.title);
            expect(reason, isNot(p.reason), reason: p.title);
          }
        }
      });

      test('[$locale] every relationship category is translated', () {
        for (final c in RelationshipCategory.values) {
          final shown = relationshipCategoryLabel(l, c);
          if (locale == 'en') {
            expect(shown, c.displayName);
          } else {
            expect(shown, isNot(c.displayName), reason: c.displayName);
          }
        }
      });
    }
  });
}
