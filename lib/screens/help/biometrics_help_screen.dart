// lib/screens/help/biometrics_help_screen.dart
//
// User-facing documentation for the biometric lock, shown from Settings → Help.
// Written in plain English and mirrors the real behavior in [AuthService] and
// its call sites: what the fingerprint / face check protects and where it is
// asked for. If that behavior changes, update this page to match.

import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/theme/app_theme.dart';

class BiometricsHelpScreen extends StatelessWidget {
  const BiometricsHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Biometric lock')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: const [
          _Intro(
            'SreerajP Contacts Sphere can ask for your fingerprint or face before it shows '
            'or moves your most private data. It uses your phone\'s own lock — '
            'the app never sees or stores your fingerprint or face.',
          ),
          SizedBox(height: 24),

          _Section(
            icon: Icons.lock_person_outlined,
            title: 'Where you are asked',
            children: [
              _Bullet(
                'Viewing your secret contacts. These are hidden from the '
                'normal contact list until you unlock them.',
              ),
              _Bullet(
                'Exporting secret contacts, so a private contact cannot be '
                'sent out of the app without your say-so.',
              ),
              _Bullet(
                'Opening "Sync to Another Device", because a sync can include '
                'your secret contacts.',
              ),
            ],
          ),

          _Section(
            icon: Icons.fingerprint,
            title: 'What counts as "you"',
            children: [
              _Bullet(
                'Any fingerprint or face you have set up on the phone is '
                'accepted.',
              ),
              _Bullet(
                'If you have not set up a fingerprint or face, the phone falls '
                'back to your screen-lock PIN, pattern, or password.',
              ),
            ],
          ),

          _Section(
            icon: Icons.shield_outlined,
            title: 'Your privacy',
            children: [
              _Bullet(
                'The check is handled by Android, not by SreerajP Contacts Sphere. The '
                'app only learns whether the unlock passed or failed.',
              ),
              _Bullet(
                'This works offline. Nothing about your fingerprint or face '
                'ever leaves the phone.',
              ),
            ],
          ),

          SizedBox(height: 8),
          _Footer(
            'Tip: set up a screen lock (fingerprint, face, or PIN) in Android '
            'settings. Without any lock, this protection cannot be applied.',
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
