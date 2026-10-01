// lib/screens/help/contact_tools_help_screen.dart
//
// User-facing documentation for three smaller contact tools: ephemeral
// (self-deleting) contacts, the connected-apps row on a contact, and the search
// index health screen. Mirrors [EphemeralContactService] and the ephemeral
// banner in `contact_detail_screen.dart`, [ConnectedAppsService], and
// [ContactIndexHealthScreen]. If that behavior changes, update this page.

import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/screens/help/help_article.dart';

class ContactToolsHelpScreen extends StatelessWidget {
  const ContactToolsHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return HelpArticleScaffold(
      title: AppLocalizations.of(context).helpContactToolsTitle1,
      children: [
        HelpIntro(AppLocalizations.of(context).helpContactToolsIntro),
        const SizedBox(height: 24),

        HelpSection(
          icon: Icons.timer_outlined,
          title: AppLocalizations.of(context).helpContactToolsTitle2,
          children: [
            HelpBullet(AppLocalizations.of(context).helpContactToolsBullet1),
            HelpBullet(AppLocalizations.of(context).helpContactToolsBullet2),
            HelpBullet(AppLocalizations.of(context).helpContactToolsBullet3),
            HelpBullet(AppLocalizations.of(context).helpContactToolsBullet4),
            HelpBullet(AppLocalizations.of(context).helpContactToolsBullet5),
          ],
        ),

        HelpSection(
          icon: Icons.apps_outlined,
          title: AppLocalizations.of(context).helpContactToolsTitle3,
          children: [
            HelpBullet(AppLocalizations.of(context).helpContactToolsBullet6),
            HelpBullet(AppLocalizations.of(context).helpContactToolsBullet7),
            HelpBullet(AppLocalizations.of(context).helpContactToolsBullet8),
          ],
        ),

        HelpSection(
          icon: Icons.manage_search_outlined,
          title: AppLocalizations.of(context).helpContactToolsTitle4,
          children: [
            HelpBullet(AppLocalizations.of(context).helpContactToolsBullet9),
            HelpBullet(AppLocalizations.of(context).helpContactToolsBullet10),
            HelpBullet(AppLocalizations.of(context).helpContactToolsBullet11),
            HelpBullet(AppLocalizations.of(context).helpContactToolsBullet12),
            HelpBullet(AppLocalizations.of(context).helpContactToolsBullet13),
          ],
        ),

        const SizedBox(height: 8),
        HelpFooter(AppLocalizations.of(context).helpContactToolsFooter),
      ],
    );
  }
}
