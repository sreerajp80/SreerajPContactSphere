// lib/screens/help/permissions_help_screen.dart
//
// User-facing documentation for the permissions the app asks for, shown from
// Settings → Help. Mirrors the catalog in `lib/core/constants/app_permissions.dart`
// and the Explicit / Implicit split rendered by [PermissionsScreen]. If a
// permission is added or its reason changes, update this page.

import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/screens/help/help_article.dart';

class PermissionsHelpScreen extends StatelessWidget {
  const PermissionsHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return HelpArticleScaffold(
      title: AppLocalizations.of(context).helpPermissionsTitle1,
      children: [
        HelpIntro(AppLocalizations.of(context).helpPermissionsIntro),
        const SizedBox(height: 24),

        HelpSection(
          icon: Icons.rule_outlined,
          title: AppLocalizations.of(context).helpPermissionsTitle2,
          children: [
            HelpBullet(AppLocalizations.of(context).helpPermissionsBullet1),
            HelpBullet(AppLocalizations.of(context).helpPermissionsBullet2),
          ],
        ),

        HelpSection(
          icon: Icons.phone_android_outlined,
          title: AppLocalizations.of(context).helpPermissionsTitle3,
          children: [
            HelpBullet(AppLocalizations.of(context).helpPermissionsBullet3),
            HelpBullet(AppLocalizations.of(context).helpPermissionsBullet4),
            HelpBullet(AppLocalizations.of(context).helpPermissionsBullet5),
            HelpBullet(AppLocalizations.of(context).helpPermissionsBullet6),
          ],
        ),

        HelpSection(
          icon: Icons.contacts_outlined,
          title: AppLocalizations.of(context).helpPermissionsTitle4,
          children: [
            HelpBullet(AppLocalizations.of(context).helpPermissionsBullet7),
            HelpBullet(AppLocalizations.of(context).helpPermissionsBullet8),
            HelpBullet(AppLocalizations.of(context).helpPermissionsBullet9),
            HelpBullet(AppLocalizations.of(context).helpPermissionsBullet10),
            HelpBullet(AppLocalizations.of(context).helpPermissionsBullet11),
          ],
        ),

        HelpSection(
          icon: Icons.notifications_none_outlined,
          title: AppLocalizations.of(context).helpPermissionsTitle5,
          children: [
            HelpBullet(AppLocalizations.of(context).helpPermissionsBullet12),
            HelpBullet(AppLocalizations.of(context).helpPermissionsBullet13),
            HelpBullet(AppLocalizations.of(context).helpPermissionsBullet14),
          ],
        ),

        HelpSection(
          icon: Icons.share_outlined,
          title: AppLocalizations.of(context).helpPermissionsTitle6,
          children: [
            HelpBullet(AppLocalizations.of(context).helpPermissionsBullet15),
            HelpBullet(AppLocalizations.of(context).helpPermissionsBullet16),
            HelpBullet(AppLocalizations.of(context).helpPermissionsBullet17),
          ],
        ),

        HelpSection(
          icon: Icons.do_not_disturb_on_outlined,
          title: AppLocalizations.of(context).helpPermissionsTitle7,
          children: [
            HelpBullet(AppLocalizations.of(context).helpPermissionsBullet18),
            HelpBullet(AppLocalizations.of(context).helpPermissionsBullet19),
            HelpBullet(AppLocalizations.of(context).helpPermissionsBullet20),
          ],
        ),

        const SizedBox(height: 8),
        HelpFooter(AppLocalizations.of(context).helpPermissionsFooter),
      ],
    );
  }
}
