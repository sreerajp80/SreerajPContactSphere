import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

/// Every help article, paired with its app-bar title. Add a page here when you
/// add one to `lib/screens/help/` — the "hub links to every page" test below
/// fails if a page exists on disk but is not reachable from the hub.
final Map<String, Widget> _articles = {
  'T9 Dialing & Malayalam': const T9DialingHelpScreen(),
  'Calling & In-Call Controls': const CallManagementHelpScreen(),
  'Call Screening & Blocking': const CallScreeningHelpScreen(),
  'Caller ID & spam filter': const CallerIdSpamHelpScreen(),
  'Call context & notes': const CallerIntelligenceHelpScreen(),
  'Relationship categories': const RelationshipCategoriesHelpScreen(),
  'Groups & tags': const GroupsTagsHelpScreen(),
  'Duplicate Contacts & Merge': const DuplicateMergeHelpScreen(),
  'Sharing & Card Scanning': const ContactSharingHelpScreen(),
  'Import & export files': const ImportExportHelpScreen(),
  'Privacy, Security & Vault': const PrivacySecurityHelpScreen(),
  'Biometric lock': const BiometricsHelpScreen(),
  'App lock & PIN': const AppLockHelpScreen(),
  'Permissions explained': const PermissionsHelpScreen(),
  'Emergency info': const EmergencyInfoHelpScreen(),
  'Sync to Another Device': const P2PSyncHelpScreen(),
  'Contact Sync': const ContactSyncHelpScreen(),
  'Cloud Sync & Backup': const CloudSyncHelpScreen(),
  'Backup & Restore': const BackupHelpScreen(),
  'Look, sound & region': const PersonalizationHelpScreen(),
  'Contact tools': const ContactToolsHelpScreen(),
  'FAQs & Troubleshooting': const FaqTroubleshootingHelpScreen(),
};

Widget _wrap(Widget screen) =>
    MaterialApp(theme: AppTheme.calm(const Color(0xFF007A78)), home: screen);

/// Pumps [screen] into a very tall viewport.
///
/// The help pages are plain `ListView`s, which build only the rows that fit on
/// screen. On a phone-sized test window the later sections are never created,
/// so a `find.text` for them would fail even though the page is correct. A tall
/// window builds the whole article in one pass.
Future<void> _pumpTall(WidgetTester tester, Widget screen) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(1000, 6000);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_wrap(screen));
}

void main() {
  group('every help article builds', () {
    _articles.forEach((title, screen) {
      testWidgets('$title renders with its title', (tester) async {
        await tester.pumpWidget(_wrap(screen));
        expect(
          find.text(title),
          findsWidgets,
          reason: '$title should show its app-bar title',
        );
        expect(tester.takeException(), isNull);
      });
    });
  });

  testWidgets('HelpHomeScreen shows every section heading', (tester) async {
    await _pumpTall(tester, const HelpHomeScreen());

    expect(find.text('Help & User Guides'), findsOneWidget);
    expect(find.text('Help Center & Knowledge Base'), findsOneWidget);
    expect(find.text('CALLING & DIALER'), findsOneWidget);
    expect(find.text('ORGANIZATION & SHARING'), findsOneWidget);
    expect(find.text('PRIVACY & PROTECTION'), findsOneWidget);
    expect(find.text('SYNC & BACKUPS'), findsOneWidget);
    expect(find.text('PERSONALIZATION & TOOLS'), findsOneWidget);
    expect(find.text('FREQUENTLY ASKED QUESTIONS'), findsOneWidget);
  });

  testWidgets('HelpHomeScreen opens a topic when its card is tapped', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const HelpHomeScreen()));

    await tester.tap(find.text('Call Screening & Blocking'));
    await tester.pumpAndSettle();

    expect(find.text('How call screening works'), findsOneWidget);
  });

  test('the hub links to every help page on disk', () {
    final dir = Directory('lib/screens/help');
    final pages = dir
        .listSync()
        .whereType<File>()
        .map((f) => f.uri.pathSegments.last)
        .where((name) => name.endsWith('_help_screen.dart'))
        .where((name) => name != 'help_home_screen.dart')
        .toList();

    final hub = File(
      'lib/screens/help/help_home_screen.dart',
    ).readAsStringSync();

    for (final page in pages) {
      expect(
        hub.contains(page),
        isTrue,
        reason:
            '$page is not imported by help_home_screen.dart, so no one can '
            'reach it from the Help hub',
      );
    }

    // The map above is what proves each page builds; keep it in step with disk.
    expect(
      _articles.length,
      pages.length,
      reason:
          'help_screens_test.dart covers ${_articles.length} pages but '
          '${pages.length} exist in lib/screens/help/',
    );
  });

  testWidgets('corrected facts stay corrected', (tester) async {
    // Duplicates are matched by name and phone, never by email address.
    await _pumpTall(tester, const DuplicateMergeHelpScreen());
    expect(
      find.textContaining('Email addresses are deliberately not used'),
      findsOneWidget,
    );

    // Quiet hours are an allow list, not a list of who gets silenced.
    await _pumpTall(tester, const FaqTroubleshootingHelpScreen());
    expect(
      find.textContaining('silence everything except the people you allow'),
      findsOneWidget,
    );
  });
}
