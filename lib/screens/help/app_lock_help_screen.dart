// lib/screens/help/app_lock_help_screen.dart
//
// User-facing documentation for App lock, shown from Settings → Help. Mirrors
// the real behavior in [SecurityScreen] (the three lock modes), [AppLockScreen]
// (device credential vs in-app PIN keypad and the "Forgot PIN?" path) and
// [AppPinSetupScreen] (4–6 digits plus a one-time recovery code). If that
// behavior changes, update this page.

import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/screens/help/help_article.dart';

class AppLockHelpScreen extends StatelessWidget {
  const AppLockHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HelpArticleScaffold(
      title: 'App lock & PIN',
      children: [
        HelpIntro(
          'App lock puts a screen in front of the whole app when you open it. '
          'You pick how it is unlocked under Settings → Security → App lock. '
          'There are three choices.',
        ),
        SizedBox(height: 24),

        HelpSection(
          icon: Icons.tune_outlined,
          title: 'The three modes',
          children: [
            HelpBullet(
              'Off — the app opens straight away. Secret contacts still ask '
              'for an unlock separately.',
            ),
            HelpBullet(
              'Device lock — uses your phone\'s own fingerprint, face, or '
              'screen-lock PIN. This choice is greyed out until you set a '
              'screen lock in Android settings.',
            ),
            HelpBullet(
              'App PIN — a separate PIN just for this app, typed on a keypad '
              'inside the app. Useful when other people know your phone PIN.',
            ),
          ],
        ),

        HelpSection(
          icon: Icons.pin_outlined,
          title: 'Setting up an App PIN',
          children: [
            HelpBullet('Choose a PIN of 4 to 6 digits and confirm it.'),
            HelpBullet(
              'You are then shown a one-time recovery code. Write it down or '
              'copy it somewhere safe — it is shown once and never again.',
            ),
            HelpBullet(
              'The PIN is not stored as you typed it, and nobody can read it '
              'back out of the app.',
            ),
          ],
        ),

        HelpSection(
          icon: Icons.help_outline,
          title: 'If you forget the App PIN',
          children: [
            HelpBullet(
              'Tap "Forgot PIN?" on the lock screen and enter your recovery '
              'code.',
            ),
            HelpBullet(
              'A correct code switches App lock off and lets you in. Set a new '
              'PIN afterwards if you still want the lock.',
            ),
            HelpBullet(
              'Without the recovery code there is no way past the lock. That '
              'is deliberate — a back door for you would be a back door for '
              'anyone.',
            ),
          ],
        ),

        HelpSection(
          icon: Icons.lock_clock_outlined,
          title: 'When you are asked again',
          children: [
            HelpBullet(
              'The lock screen returns when you come back to the app after '
              'leaving it, not on every screen inside it.',
            ),
            HelpBullet(
              'The back gesture cannot dismiss it. Only a correct unlock, or '
              'the recovery code, lets you through.',
            ),
          ],
        ),

        SizedBox(height: 8),
        HelpFooter(
          'App lock guards the door. Your secret contacts, backups, and sync '
          'have their own unlock on top of it — see the Biometric lock guide.',
        ),
      ],
    );
  }
}
