// lib/screens/help/caller_intelligence_help_screen.dart
//
// User-facing documentation for the context the app shows around a call:
// the pre-call summary, the "Likely to answer now" ordering, the ringing
// context card, and the post-call notes sheet. Mirrors the real behavior in
// [PreCallSummaryService], [ReachWindowService], [CallerContextService] and
// `post_call_feedback_sheet.dart`. If that behavior changes, update this page.

import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/screens/help/help_article.dart';

class CallerIntelligenceHelpScreen extends StatelessWidget {
  const CallerIntelligenceHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return HelpArticleScaffold(
      title: AppLocalizations.of(context).helpCallerIntelligenceTitle1,
      children: [
        HelpIntro(AppLocalizations.of(context).helpCallerIntelligenceIntro),
        const SizedBox(height: 24),

        HelpSection(
          icon: Icons.person_search_outlined,
          title: AppLocalizations.of(context).helpCallerIntelligenceTitle2,
          children: [
            HelpBullet(
              AppLocalizations.of(context).helpCallerIntelligenceBullet1,
            ),
            HelpBullet(
              AppLocalizations.of(context).helpCallerIntelligenceBullet2,
            ),
            HelpBullet(
              AppLocalizations.of(context).helpCallerIntelligenceBullet3,
            ),
          ],
        ),

        HelpSection(
          icon: Icons.schedule_outlined,
          title: AppLocalizations.of(context).helpCallerIntelligenceTitle3,
          children: [
            HelpBullet(
              AppLocalizations.of(context).helpCallerIntelligenceBullet4,
            ),
            HelpBullet(
              AppLocalizations.of(context).helpCallerIntelligenceBullet5,
            ),
            HelpBullet(
              AppLocalizations.of(context).helpCallerIntelligenceBullet6,
            ),
          ],
        ),

        HelpSection(
          icon: Icons.badge_outlined,
          title: AppLocalizations.of(context).helpCallerIntelligenceTitle4,
          children: [
            HelpBullet(
              AppLocalizations.of(context).helpCallerIntelligenceBullet7,
            ),
            HelpBullet(
              AppLocalizations.of(context).helpCallerIntelligenceBullet8,
            ),
          ],
        ),

        HelpSection(
          icon: Icons.edit_note_outlined,
          title: AppLocalizations.of(context).helpCallerIntelligenceTitle5,
          children: [
            HelpBullet(
              AppLocalizations.of(context).helpCallerIntelligenceBullet9,
            ),
            HelpBullet(
              AppLocalizations.of(context).helpCallerIntelligenceBullet10,
            ),
            HelpBullet(
              AppLocalizations.of(context).helpCallerIntelligenceBullet11,
            ),
            HelpBullet(
              AppLocalizations.of(context).helpCallerIntelligenceBullet12,
            ),
          ],
        ),

        const SizedBox(height: 8),
        HelpFooter(AppLocalizations.of(context).helpCallerIntelligenceFooter),
      ],
    );
  }
}
