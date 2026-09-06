// lib/screens/help/privacy_security_help_screen.dart
import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/theme/app_theme.dart';

class PrivacySecurityHelpScreen extends StatelessWidget {
  const PrivacySecurityHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy, Security & Vault')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: const [
          _Intro(
            'SreerajP Contacts Sphere is built from the ground up to guarantee '
            'uncompromising privacy, encrypted local storage, and granular security controls.',
          ),
          SizedBox(height: 24),

          _Section(
            icon: Icons.lock_outline,
            title: 'Secret Contacts Vault',
            children: [
              _Bullet(
                'What is a Secret Contact? Any contact marked as "Secret" is completely hidden from the main contact list, T9 dialer searches, and general export files.',
              ),
              _Bullet(
                'Seeing them: tap the padlock icon in the top bar of the Contacts tab and unlock with your fingerprint, face, or device PIN. The list then shows the secret contacts alongside the rest.',
              ),
              _Bullet(
                'Tap the padlock again to hide them. They also hide when you leave the contact list, so they are never left showing behind you.',
              ),
            ],
          ),

          _Section(
            icon: Icons.fingerprint,
            title: 'Biometrics & App PIN Protection',
            children: [
              _Bullet(
                'You can secure the entire app or sensitive sections using your device\'s biometric sensors (fingerprint / face unlock).',
              ),
              _Bullet(
                'If your phone has no biometric hardware, or you want a code separate from your phone PIN, set an App PIN under Settings → Security → App lock. See the "App lock & PIN" guide.',
              ),
            ],
          ),

          _Section(
            icon: Icons.screenshot_outlined,
            title: 'Screenshot Guard',
            children: [
              _Bullet(
                'Screenshot guard blocks screenshots, screen recording, and the preview Android shows in Recents, while you are on a screen holding private data.',
              ),
              _Bullet(
                'Turn it on or off under Settings → Security → Screenshot guard.',
              ),
            ],
          ),

          _Section(
            icon: Icons.history_edu_outlined,
            title: 'Security Audit Log',
            children: [
              _Bullet(
                'The audit log records every change to a contact — created, edited, or deleted — with what it looked like before and after.',
              ),
              _Bullet(
                'Open an entry to see exactly what changed, and undo it if the change was a mistake.',
              ),
              _Bullet(
                'Entries are chained together with a cryptographic hash, so an entry cannot be quietly altered or removed without it showing.',
              ),
              _Bullet(
                'Settings → Security → Audit log, which asks for your unlock first. It can also export a signed copy of the log.',
              ),
            ],
          ),

          SizedBox(height: 8),
          _Footer(
            'Security principle: everything is stored on this phone in a database encrypted with a key held in the phone\'s hardware keystore. There is no tracking, no advertising, and no server of ours to talk to.',
          ),
        ],
      ),
    );
  }
}

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
