// lib/screens/help/groups_tags_help_screen.dart
//
// User-facing documentation for groups and tags, shown from Settings → Help.
// Mirrors the real behavior in [GroupsScreen] (groups and group ringtones),
// [TagCloudScreen] / [TagContactsScreen] (the Tags tab), and the multi-select
// mode in `contact_list_screen.dart`. If that behavior changes, update this page.

import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/screens/help/help_article.dart';

class GroupsTagsHelpScreen extends StatelessWidget {
  const GroupsTagsHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return HelpArticleScaffold(
      title: AppLocalizations.of(context).helpGroupsTagsTitle1,
      children: [
        HelpIntro(AppLocalizations.of(context).helpGroupsTagsIntro),
        const SizedBox(height: 24),

        HelpSection(
          icon: Icons.group_outlined,
          title: AppLocalizations.of(context).helpGroupsTagsTitle2,
          children: [
            HelpBullet(AppLocalizations.of(context).helpGroupsTagsBullet1),
            HelpBullet(AppLocalizations.of(context).helpGroupsTagsBullet2),
            HelpBullet(AppLocalizations.of(context).helpGroupsTagsBullet3),
            HelpBullet(AppLocalizations.of(context).helpGroupsTagsBullet4),
          ],
        ),

        HelpSection(
          icon: Icons.sell_outlined,
          title: AppLocalizations.of(context).helpGroupsTagsTitle3,
          children: [
            HelpBullet(AppLocalizations.of(context).helpGroupsTagsBullet5),
            HelpBullet(AppLocalizations.of(context).helpGroupsTagsBullet6),
            HelpBullet(AppLocalizations.of(context).helpGroupsTagsBullet7),
            HelpBullet(AppLocalizations.of(context).helpGroupsTagsBullet8),
          ],
        ),

        HelpSection(
          icon: Icons.checklist_outlined,
          title: AppLocalizations.of(context).helpGroupsTagsTitle4,
          children: [
            HelpBullet(AppLocalizations.of(context).helpGroupsTagsBullet9),
            HelpBullet(AppLocalizations.of(context).helpGroupsTagsBullet10),
            HelpBullet(AppLocalizations.of(context).helpGroupsTagsBullet11),
          ],
        ),

        const SizedBox(height: 8),
        HelpFooter(AppLocalizations.of(context).helpGroupsTagsFooter),
      ],
    );
  }
}
