// lib/screens/help/call_screening_help_screen.dart
import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

class CallScreeningHelpScreen extends StatelessWidget {
  const CallScreeningHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).helpCallScreeningText),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          _Intro(AppLocalizations.of(context).helpCallScreeningIntro),
          const SizedBox(height: 24),

          _Section(
            icon: Icons.shield_outlined,
            title: AppLocalizations.of(context).helpCallScreeningTitle1,
            children: [
              _Bullet(AppLocalizations.of(context).helpCallScreeningBullet1),
              _Bullet(AppLocalizations.of(context).helpCallScreeningBullet2),
              _Bullet(AppLocalizations.of(context).helpCallScreeningBullet3),
              _Bullet(AppLocalizations.of(context).helpCallScreeningBullet4),
            ],
          ),

          _Section(
            icon: Icons.block_outlined,
            title: AppLocalizations.of(context).helpCallScreeningTitle2,
            children: [
              _Bullet(AppLocalizations.of(context).helpCallScreeningBullet5),
              _Bullet(AppLocalizations.of(context).helpCallScreeningBullet6),
              _Bullet(AppLocalizations.of(context).helpCallScreeningBullet7),
              _Bullet(AppLocalizations.of(context).helpCallScreeningBullet8),
            ],
          ),

          _Section(
            icon: Icons.no_accounts_outlined,
            title: AppLocalizations.of(context).helpCallScreeningTitle3,
            children: [
              _Bullet(AppLocalizations.of(context).helpCallScreeningBullet9),
              _Bullet(AppLocalizations.of(context).helpCallScreeningBullet10),
              _Bullet(AppLocalizations.of(context).helpCallScreeningBullet11),
            ],
          ),

          _Section(
            icon: Icons.volume_off_outlined,
            title: AppLocalizations.of(context).helpCallScreeningTitle4,
            children: [
              _Bullet(AppLocalizations.of(context).helpCallScreeningBullet12),
              _Bullet(AppLocalizations.of(context).helpCallScreeningBullet13),
            ],
          ),

          _Section(
            icon: Icons.phone_android_outlined,
            title: AppLocalizations.of(context).helpCallScreeningTitle5,
            children: [
              _Bullet(AppLocalizations.of(context).helpCallScreeningBullet14),
              _Bullet(AppLocalizations.of(context).helpCallScreeningBullet15),
            ],
          ),

          const SizedBox(height: 8),
          _Footer(AppLocalizations.of(context).helpCallScreeningFooter),
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
