// lib/screens/help/emergency_info_help_screen.dart
//
// User-facing documentation for the emergency info card, shown from
// Settings → Help. Written in plain English and mirrors the real behavior in
// [EmergencyInfoRepository], `EmergencyCardNotifier.kt` and
// `EmergencyInfoActivity.kt`. If that behavior changes, update this page.

import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/theme/app_theme.dart';

class EmergencyInfoHelpScreen extends StatelessWidget {
  const EmergencyInfoHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency info')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: const [
          _Intro(
            'The emergency card holds a few facts that could help someone who '
            'finds you unwell — your blood group, your allergies, and who to '
            'call. It can be read on your lock screen without your PIN.',
          ),
          SizedBox(height: 24),

          _Section(
            icon: Icons.lock_open_outlined,
            title: 'What "without unlocking" means',
            children: [
              _Bullet(
                'While the card is on, a notification called "Emergency info" '
                'sits on your lock screen. Tapping it opens the card straight '
                'away — no PIN, fingerprint, or face needed.',
              ),
              _Bullet(
                'The phone stays locked. Only the card opens; the rest of the '
                'app, and everything else on the phone, stays shut.',
              ),
              _Bullet(
                'Android keeps its own "Emergency information" page behind the '
                'lock screen Emergency button. That page belongs to the phone '
                'maker, and no app can write into it — which is why '
                'SreerajP Contacts Sphere uses its own notification instead.',
              ),
            ],
          ),

          _Section(
            icon: Icons.visibility_outlined,
            title: 'You choose every line',
            children: [
              _Bullet('The whole feature is off until you switch it on.'),
              _Bullet(
                'Each field has its own "Show on lock screen" switch. A field '
                'you leave switched off never leaves the app.',
              ),
              _Bullet(
                'The preview at the bottom of the edit screen shows exactly '
                'what a stranger would see.',
              ),
              _Bullet(
                'Switching the card off removes the notification and wipes the '
                'copy the lock screen was reading. What you typed stays saved '
                'inside the app.',
              ),
            ],
          ),

          _Section(
            icon: Icons.call_outlined,
            title: 'Calling for help',
            children: [
              _Bullet(
                'Each person you add gets a Call button on the card. Tapping '
                'it dials them right away from the lock screen.',
              ),
              _Bullet(
                'People picked from your contacts are copied onto the card as '
                'a name and one number. Editing that contact later does not '
                'change the card — open this screen and save again.',
              ),
            ],
          ),

          _Section(
            icon: Icons.visibility_outlined,
            title: 'If the card is missing from the lock screen',
            children: [
              _Bullet(
                'Your phone decides which notifications the lock screen shows. '
                'Open Settings → Notifications → Notifications on lock screen '
                'and pick "Show conversations, default and silent".',
              ),
              _Bullet(
                'If that is set to "Hide silent notifications" or "Don\'t show '
                'any notifications", the card cannot appear there. No app can '
                'override that choice.',
              ),
              _Bullet(
                'Also check that notifications for SreerajP Contacts Sphere are on, and '
                'that the "Emergency info" notification is not turned down to '
                'silent. The edit screen warns you when either is the case, and '
                'the button there opens the right settings page.',
              ),
              _Bullet(
                'The card stays in the notification shade all the time on '
                'purpose — it is meant to be one tap away, and it cannot be '
                'swiped off by accident.',
              ),
            ],
          ),

          _Section(
            icon: Icons.shield_outlined,
            title: 'How it is stored',
            children: [
              _Bullet(
                'Your full record stays in the app\'s encrypted database, like '
                'the rest of your contacts.',
              ),
              _Bullet(
                'Only the lines you switched on are copied into a small, plain '
                'file that the lock-screen card can read while the phone is '
                'locked. That copy cannot be encrypted — a locked phone has no '
                'way to unlock it for a stranger.',
              ),
              _Bullet(
                'The copy stays inside the app\'s private storage. Other apps '
                'cannot read it, and it is left out of phone backups.',
              ),
              _Bullet(
                'The card is saved inside a password-protected SreerajP Contacts Sphere '
                'backup, so a restore on a new phone brings it back.',
              ),
              _Bullet(
                'It also travels on a Full Sync to another phone, or when you '
                'tick "Emergency info card" while choosing what to share. The '
                'other phone only takes it if it has no card of its own — your '
                'card never replaces someone else\'s.',
              ),
            ],
          ),

          SizedBox(height: 8),
          _Footer(
            'Tip: keep it short. Blood group, serious allergies, and one or '
            'two people to call are worth far more to a helper than a long '
            'medical history.',
          ),
        ],
      ),
    );
  }
}

/// The lead paragraph at the top of the article.
class _Intro extends StatelessWidget {
  final String text;
  const _Intro(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    return Text(
      text,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: colors.mutedText,
        height: 1.5,
      ),
    );
  }
}

/// One titled section: an accent icon + heading, then its bullet points.
class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _Section({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

/// A single bullet line inside a [_Section].
class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final accent = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.mutedText,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The closing tip, set apart in a soft accent panel.
class _Footer extends StatelessWidget {
  final String text;
  const _Footer(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: accent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
