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
                'Accessing Secret Contacts: Tap the Vault lock icon in the top bar or under Settings → Security and authenticate with your fingerprint, face, or App PIN.',
              ),
              _Bullet(
                'Auto-Lock: The vault automatically locks whenever you leave the screen or switch apps, keeping your private numbers safe from prying eyes.',
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
                'If your phone does not have biometric hardware or you prefer a separate passcode, you can set up a custom App PIN in Settings → Security.',
              ),
            ],
          ),

          _Section(
            icon: Icons.screenshot_outlined,
            title: 'Screenshot Guard',
            children: [
              _Bullet(
                'Screenshot Guard prevents screen captures, screen recording, and task switcher previews while browsing secure screens.',
              ),
              _Bullet(
                'Enable or disable Screenshot Guard under Settings → Security → Screenshot Guard.',
              ),
            ],
          ),

          _Section(
            icon: Icons.history_edu_outlined,
            title: 'Security Audit Log',
            children: [
              _Bullet(
                'ContactSphere records a secure, private audit log of sensitive actions such as vault unlocks, secret contact exports, and PIN updates.',
              ),
              _Bullet(
                'View the audit log in Settings → Security → Audit Log to ensure no unauthorized access has occurred.',
              ),
            ],
          ),

          SizedBox(height: 8),
          _Footer(
            'Security Principle: ContactSphere stores all data locally in an encrypted SQLite database on your device. We do not operate any tracking or advertising telemetry.',
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
