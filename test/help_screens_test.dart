import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_contacts_dialer/screens/help/call_management_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/call_screening_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/contact_sharing_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/duplicate_merge_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/faq_troubleshooting_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/help_home_screen.dart';
import 'package:smart_contacts_dialer/screens/help/privacy_security_help_screen.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

void main() {
  testWidgets('HelpHomeScreen displays category sections and navigates', (WidgetTester tester) async {
    final theme = AppTheme.calm(const Color(0xFF007A78));

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: const HelpHomeScreen(),
      ),
    );

    expect(find.text('Help & User Guides'), findsOneWidget);
    expect(find.text('Help Center & Knowledge Base'), findsOneWidget);
    expect(find.text('CALLING & DIALER'), findsOneWidget);
    expect(find.text('Calling & In-Call Controls'), findsOneWidget);
    expect(find.text('Call Screening & Blocking'), findsOneWidget);
  });

  testWidgets('CallManagementHelpScreen renders correctly', (WidgetTester tester) async {
    final theme = AppTheme.calm(const Color(0xFF007A78));

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: const CallManagementHelpScreen(),
      ),
    );

    expect(find.text('Calling & In-Call Controls'), findsOneWidget);
    expect(find.text('In-Call Controls & Conference Calling'), findsOneWidget);
    expect(find.text('Dual-SIM Calling & Preferences'), findsOneWidget);
  });

  testWidgets('CallScreeningHelpScreen renders correctly', (WidgetTester tester) async {
    final theme = AppTheme.calm(const Color(0xFF007A78));

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: const CallScreeningHelpScreen(),
      ),
    );

    expect(find.text('Call Screening & Blocking'), findsOneWidget);
    expect(find.text('How Call Screening Works'), findsOneWidget);
    expect(find.text('Blocking Numbers'), findsOneWidget);
  });

  testWidgets('ContactSharingHelpScreen renders correctly', (WidgetTester tester) async {
    final theme = AppTheme.calm(const Color(0xFF007A78));

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: const ContactSharingHelpScreen(),
      ),
    );

    expect(find.text('Sharing & Card Scanning'), findsOneWidget);
    expect(find.text('QR Code Sharing & Scanner'), findsOneWidget);
    expect(find.text('Business Card Scanner (On-Device AI)'), findsOneWidget);
  });

  testWidgets('PrivacySecurityHelpScreen renders correctly', (WidgetTester tester) async {
    final theme = AppTheme.calm(const Color(0xFF007A78));

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: const PrivacySecurityHelpScreen(),
      ),
    );

    expect(find.text('Privacy, Security & Vault'), findsOneWidget);
    expect(find.text('Secret Contacts Vault'), findsOneWidget);
    expect(find.text('Biometrics & App PIN Protection'), findsOneWidget);
  });

  testWidgets('DuplicateMergeHelpScreen renders correctly', (WidgetTester tester) async {
    final theme = AppTheme.calm(const Color(0xFF007A78));

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: const DuplicateMergeHelpScreen(),
      ),
    );

    expect(find.text('Duplicate Contacts & Merge'), findsOneWidget);
    expect(find.text('How Duplicates are Detected'), findsOneWidget);
  });

  testWidgets('FaqTroubleshootingHelpScreen renders correctly', (WidgetTester tester) async {
    final theme = AppTheme.calm(const Color(0xFF007A78));

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: const FaqTroubleshootingHelpScreen(),
      ),
    );

    expect(find.text('FAQs & Troubleshooting'), findsOneWidget);
    expect(find.text('General & Permissions'), findsOneWidget);
    expect(find.textContaining('Why does ContactSphere need Default Phone App permission?'), findsOneWidget);
  });
}
