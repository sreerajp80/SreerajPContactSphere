// lib/screens/help/caller_id_spam_help_screen.dart
//
// User-facing documentation for caller identification, spam filtering, and the
// "block unknown callers" switch. Mirrors the real behavior in
// [IdentificationSettingsScreen], [BlockedNumbersScreen],
// `ContactSphereCallScreeningService.kt` and the identification badge in
// `in_call_screen.dart`. If that behavior changes, update this page.

import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/screens/help/help_article.dart';

class CallerIdSpamHelpScreen extends StatelessWidget {
  const CallerIdSpamHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return HelpArticleScaffold(
      title: AppLocalizations.of(context).helpCallerIdSpamTitle1,
      children: [
        HelpIntro(AppLocalizations.of(context).helpCallerIdSpamIntro),
        const SizedBox(height: 24),

        HelpSection(
          icon: Icons.label_outline,
          title: AppLocalizations.of(context).helpCallerIdSpamTitle2,
          children: [
            HelpBullet(AppLocalizations.of(context).helpCallerIdSpamBullet1),
            HelpBullet(AppLocalizations.of(context).helpCallerIdSpamBullet2),
            HelpBullet(AppLocalizations.of(context).helpCallerIdSpamBullet3),
            HelpBullet(AppLocalizations.of(context).helpCallerIdSpamBullet4),
          ],
        ),

        HelpSection(
          icon: Icons.volume_off_outlined,
          title: AppLocalizations.of(context).helpCallerIdSpamTitle3,
          children: [
            HelpBullet(AppLocalizations.of(context).helpCallerIdSpamBullet5),
            HelpBullet(AppLocalizations.of(context).helpCallerIdSpamBullet6),
            HelpBullet(AppLocalizations.of(context).helpCallerIdSpamBullet7),
          ],
        ),

        HelpSection(
          icon: Icons.no_accounts_outlined,
          title: AppLocalizations.of(context).helpCallerIdSpamTitle4,
          children: [
            HelpBullet(AppLocalizations.of(context).helpCallerIdSpamBullet8),
            HelpBullet(AppLocalizations.of(context).helpCallerIdSpamBullet9),
            HelpBullet(AppLocalizations.of(context).helpCallerIdSpamBullet10),
          ],
        ),

        HelpSection(
          icon: Icons.report_outlined,
          title: AppLocalizations.of(context).helpCallerIdSpamTitle5,
          children: [
            HelpBullet(AppLocalizations.of(context).helpCallerIdSpamBullet11),
            HelpBullet(AppLocalizations.of(context).helpCallerIdSpamBullet12),
            HelpBullet(AppLocalizations.of(context).helpCallerIdSpamBullet13),
          ],
        ),

        const SizedBox(height: 8),
        HelpFooter(AppLocalizations.of(context).helpCallerIdSpamFooter),
      ],
    );
  }
}
