// Widget tests for phase 2f of plans/20260921_064200_item2-arb-string-externalization.md
// — the Help articles — in all three languages.
//
// Every help screen is pumped at phone width (360 logical pixels) and 1.3x
// text on a very tall surface, so the whole article is laid out at once and a
// long Malayalam or Sanskrit paragraph anywhere in it would be caught. Each
// screen is checked for: its translated title and lead paragraph, no English
// title leaking into `ml` or `sa`, and no layout overflow.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/l10n/sa_material_localizations.dart';
import 'package:smart_contacts_dialer/screens/help/app_lock_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/backup_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/biometrics_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/call_management_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/call_screening_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/caller_id_spam_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/caller_intelligence_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/cloud_sync_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/contact_sharing_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/contact_sync_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/contact_tools_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/duplicate_merge_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/emergency_info_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/faq_troubleshooting_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/groups_tags_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/help_home_screen.dart';
import 'package:smart_contacts_dialer/screens/help/import_export_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/p2p_sync_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/permissions_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/personalization_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/privacy_security_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/relationship_categories_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/t9_dialing_help_screen.dart';
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

/// One help screen: how to build it, and its title and lead paragraph.
class _Case {
  final String name;
  final Widget screen;
  final String Function(AppLocalizations) title;
  final String Function(AppLocalizations) lead;
  const _Case(this.name, this.screen, this.title, this.lead);
}

final _cases = <_Case>[
  _Case(
    'Help home',
    const HelpHomeScreen(),
    (l) => l.helpHomeText1,
    (l) => l.helpHomeText2,
  ),
  _Case(
    'App lock',
    const AppLockHelpScreen(),
    (l) => l.helpAppLockTitle1,
    (l) => l.helpAppLockIntro,
  ),
  _Case(
    'Backup',
    const BackupHelpScreen(),
    (l) => l.helpBackupText,
    (l) => l.helpBackupIntro,
  ),
  _Case(
    'Biometrics',
    const BiometricsHelpScreen(),
    (l) => l.helpBiometricsText,
    (l) => l.helpBiometricsIntro,
  ),
  _Case(
    'Call management',
    const CallManagementHelpScreen(),
    (l) => l.helpCallManagementText,
    (l) => l.helpCallManagementIntro,
  ),
  _Case(
    'Call screening',
    const CallScreeningHelpScreen(),
    (l) => l.helpCallScreeningText,
    (l) => l.helpCallScreeningIntro,
  ),
  _Case(
    'Caller ID & spam',
    const CallerIdSpamHelpScreen(),
    (l) => l.helpCallerIdSpamTitle1,
    (l) => l.helpCallerIdSpamIntro,
  ),
  _Case(
    'Call context',
    const CallerIntelligenceHelpScreen(),
    (l) => l.helpCallerIntelligenceTitle1,
    (l) => l.helpCallerIntelligenceIntro,
  ),
  _Case(
    'Cloud sync',
    const CloudSyncHelpScreen(),
    (l) => l.helpCloudSyncText,
    (l) => l.helpCloudSyncIntro,
  ),
  _Case(
    'Contact sharing',
    const ContactSharingHelpScreen(),
    (l) => l.helpContactSharingText,
    (l) => l.helpContactSharingIntro,
  ),
  _Case(
    'Contact sync',
    const ContactSyncHelpScreen(),
    (l) => l.helpContactSyncText,
    (l) => l.helpContactSyncIntro,
  ),
  _Case(
    'Contact tools',
    const ContactToolsHelpScreen(),
    (l) => l.helpContactToolsTitle1,
    (l) => l.helpContactToolsIntro,
  ),
  _Case(
    'Duplicates',
    const DuplicateMergeHelpScreen(),
    (l) => l.helpDuplicateMergeText,
    (l) => l.helpDuplicateMergeIntro,
  ),
  _Case(
    'Emergency info',
    const EmergencyInfoHelpScreen(),
    (l) => l.helpEmergencyInfoText,
    (l) => l.helpEmergencyInfoIntro,
  ),
  _Case(
    'FAQ',
    const FaqTroubleshootingHelpScreen(),
    (l) => l.helpFaqTroubleshootingText,
    (l) => l.helpFaqTroubleshootingIntro,
  ),
  _Case(
    'Groups & tags',
    const GroupsTagsHelpScreen(),
    (l) => l.helpGroupsTagsTitle1,
    (l) => l.helpGroupsTagsIntro,
  ),
  _Case(
    'Import & export',
    const ImportExportHelpScreen(),
    (l) => l.helpImportExportTitle1,
    (l) => l.helpImportExportIntro,
  ),
  _Case(
    'P2P sync',
    const P2PSyncHelpScreen(),
    (l) => l.helpP2pSyncText,
    (l) => l.helpP2pSyncIntro,
  ),
  _Case(
    'Permissions',
    const PermissionsHelpScreen(),
    (l) => l.helpPermissionsTitle1,
    (l) => l.helpPermissionsIntro,
  ),
  _Case(
    'Personalization',
    const PersonalizationHelpScreen(),
    (l) => l.helpPersonalizationTitle1,
    (l) => l.helpPersonalizationIntro,
  ),
  _Case(
    'Privacy & security',
    const PrivacySecurityHelpScreen(),
    (l) => l.helpPrivacySecurityText,
    (l) => l.helpPrivacySecurityIntro,
  ),
  _Case(
    'Relationship categories',
    const RelationshipCategoriesHelpScreen(),
    (l) => l.helpRelationshipCategoriesText1,
    (l) => l.helpRelationshipCategoriesIntro,
  ),
  _Case(
    'T9 dialing',
    const T9DialingHelpScreen(),
    (l) => l.helpT9DialingText,
    (l) => l.helpT9DialingIntro,
  ),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final english = lookupAppLocalizations(const Locale('en'));

  for (final locale in _locales) {
    for (final c in _cases) {
      testWidgets('[$locale] ${c.name}', (tester) async {
        final l10n = lookupAppLocalizations(Locale(locale));
        tester.view.devicePixelRatio = 1.0;
        tester.view.physicalSize = const Size(360, 20000);
        addTearDown(tester.view.reset);

        final original = FlutterError.onError;
        final overflows = <String>[];
        FlutterError.onError = (details) {
          final text = details.exceptionAsString();
          if (text.contains('overflowed')) overflows.add(text);
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
            home: c.screen,
          ),
        );
        await tester.pump();
        // Restore the handler before any expect: a failing expect while it is
        // overridden makes the test binding hang instead of reporting.
        FlutterError.onError = original;
        expectAllIconButtonsHaveTooltips(tester);

        expect(find.text(c.title(l10n)), findsWidgets);
        expect(find.text(c.lead(l10n)), findsOneWidget);
        if (locale != 'en') {
          expect(find.text(c.title(english)), findsNothing);
          expect(find.text(c.lead(english)), findsNothing);
        }
        expect(overflows, isEmpty, reason: overflows.join('\n'));
      });
    }
  }
}
