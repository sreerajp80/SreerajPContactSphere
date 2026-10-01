// lib/screens/help/privacy_security_help_screen.dart
import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

class PrivacySecurityHelpScreen extends StatelessWidget {
  const PrivacySecurityHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).helpPrivacySecurityText),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          _Intro(AppLocalizations.of(context).helpPrivacySecurityIntro),
          const SizedBox(height: 24),

          _Section(
            icon: Icons.lock_outline,
            title: AppLocalizations.of(context).helpPrivacySecurityTitle1,
            children: [
              _Bullet(AppLocalizations.of(context).helpPrivacySecurityBullet1),
              _Bullet(AppLocalizations.of(context).helpPrivacySecurityBullet2),
              _Bullet(AppLocalizations.of(context).helpPrivacySecurityBullet3),
            ],
          ),

          _Section(
            icon: Icons.fingerprint,
            title: AppLocalizations.of(context).helpPrivacySecurityTitle2,
            children: [
              _Bullet(AppLocalizations.of(context).helpPrivacySecurityBullet4),
              _Bullet(AppLocalizations.of(context).helpPrivacySecurityBullet5),
            ],
          ),

          _Section(
            icon: Icons.screenshot_outlined,
            title: AppLocalizations.of(context).helpPrivacySecurityTitle3,
            children: [
              _Bullet(AppLocalizations.of(context).helpPrivacySecurityBullet6),
              _Bullet(AppLocalizations.of(context).helpPrivacySecurityBullet7),
            ],
          ),

          _Section(
            icon: Icons.history_edu_outlined,
            title: AppLocalizations.of(context).helpPrivacySecurityTitle4,
            children: [
              _Bullet(AppLocalizations.of(context).helpPrivacySecurityBullet8),
              _Bullet(AppLocalizations.of(context).helpPrivacySecurityBullet9),
              _Bullet(AppLocalizations.of(context).helpPrivacySecurityBullet10),
              _Bullet(AppLocalizations.of(context).helpPrivacySecurityBullet11),
            ],
          ),

          const SizedBox(height: 8),
          _Footer(AppLocalizations.of(context).helpPrivacySecurityFooter),
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
