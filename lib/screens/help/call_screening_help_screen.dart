// lib/screens/help/call_screening_help_screen.dart
import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/theme/app_theme.dart';

class CallScreeningHelpScreen extends StatelessWidget {
  const CallScreeningHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Call Screening & Blocking')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: const [
          _Intro(
            'ContactSphere includes an automatic background call screening engine '
            'that protects you against annoying spam, telemarketers, and unwanted callers.',
          ),
          SizedBox(height: 24),

          _Section(
            icon: Icons.shield_outlined,
            title: 'How Call Screening Works',
            children: [
              _Bullet(
                'When a call arrives, Android asks ContactSphere\'s Call Screening Service to inspect the incoming phone number.',
              ),
              _Bullet(
                'If the number is on your Blocked List, the call is rejected immediately without ringing or vibrating your phone.',
              ),
              _Bullet(
                'Screened and blocked calls are silently logged in your Call History with a "Blocked" badge so you can review them anytime.',
              ),
            ],
          ),

          _Section(
            icon: Icons.block_outlined,
            title: 'Blocking Numbers',
            children: [
              _Bullet(
                'To block any number: Tap on a call entry in Call History or on a contact card, tap the 3-dots menu, and choose "Block Number".',
              ),
              _Bullet(
                'You can review and manage all blocked numbers under Settings → Blocked Numbers.',
              ),
              _Bullet(
                'Unblocking is instant: simply tap "Unblock" next to any number in your Blocked Numbers list.',
              ),
            ],
          ),

          _Section(
            icon: Icons.phone_android_outlined,
            title: 'Default Dialer Requirement',
            children: [
              _Bullet(
                'Android requires ContactSphere to be your Default Phone App to screen calls in the background and block numbers before ringing.',
              ),
              _Bullet(
                'If ContactSphere is not the default phone app, you will be prompted to grant the role under Settings → Permissions.',
              ),
            ],
          ),

          SizedBox(height: 8),
          _Footer(
            'Privacy Note: Number screening is performed 100% locally on your phone against your private blocklist. No phone numbers are ever sent to remote tracking servers.',
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
