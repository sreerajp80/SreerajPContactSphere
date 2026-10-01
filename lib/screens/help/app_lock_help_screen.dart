// lib/screens/help/app_lock_help_screen.dart
//
// User-facing documentation for App lock, shown from Settings → Help. Mirrors
// the real behavior in [SecurityScreen] (the three lock modes), [AppLockScreen]
// (device credential vs in-app PIN keypad and the "Forgot PIN?" path) and
// [AppPinSetupScreen] (4–6 digits plus a one-time recovery code). If that
// behavior changes, update this page.

import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/screens/help/help_article.dart';

class AppLockHelpScreen extends StatelessWidget {
  const AppLockHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return HelpArticleScaffold(
      title: AppLocalizations.of(context).helpAppLockTitle1,
      children: [
        HelpIntro(AppLocalizations.of(context).helpAppLockIntro),
        const SizedBox(height: 24),

        HelpSection(
          icon: Icons.tune_outlined,
          title: AppLocalizations.of(context).helpAppLockTitle2,
          children: [
            HelpBullet(AppLocalizations.of(context).helpAppLockBullet1),
            HelpBullet(AppLocalizations.of(context).helpAppLockBullet2),
            HelpBullet(AppLocalizations.of(context).helpAppLockBullet3),
          ],
        ),

        HelpSection(
          icon: Icons.pin_outlined,
          title: AppLocalizations.of(context).helpAppLockTitle3,
          children: [
            HelpBullet(AppLocalizations.of(context).helpAppLockBullet4),
            HelpBullet(AppLocalizations.of(context).helpAppLockBullet5),
            HelpBullet(AppLocalizations.of(context).helpAppLockBullet6),
          ],
        ),

        HelpSection(
          icon: Icons.help_outline,
          title: AppLocalizations.of(context).helpAppLockTitle4,
          children: [
            HelpBullet(AppLocalizations.of(context).helpAppLockBullet7),
            HelpBullet(AppLocalizations.of(context).helpAppLockBullet8),
            HelpBullet(AppLocalizations.of(context).helpAppLockBullet9),
          ],
        ),

        HelpSection(
          icon: Icons.lock_clock_outlined,
          title: AppLocalizations.of(context).helpAppLockTitle5,
          children: [
            HelpBullet(AppLocalizations.of(context).helpAppLockBullet10),
            HelpBullet(AppLocalizations.of(context).helpAppLockBullet11),
          ],
        ),

        const SizedBox(height: 8),
        HelpFooter(AppLocalizations.of(context).helpAppLockFooter),
      ],
    );
  }
}
