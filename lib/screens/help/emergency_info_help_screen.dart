// lib/screens/help/emergency_info_help_screen.dart
//
// User-facing documentation for the emergency info card, shown from
// Settings → Help. Written in plain English and mirrors the real behavior in
// [EmergencyInfoRepository], `EmergencyCardNotifier.kt` and
// `EmergencyInfoActivity.kt`. If that behavior changes, update this page.

import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

class EmergencyInfoHelpScreen extends StatelessWidget {
  const EmergencyInfoHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).helpEmergencyInfoText),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          _Intro(AppLocalizations.of(context).helpEmergencyInfoIntro),
          const SizedBox(height: 24),

          _Section(
            icon: Icons.lock_open_outlined,
            title: AppLocalizations.of(context).helpEmergencyInfoTitle1,
            children: [
              _Bullet(AppLocalizations.of(context).helpEmergencyInfoBullet1),
              _Bullet(AppLocalizations.of(context).helpEmergencyInfoBullet2),
              _Bullet(AppLocalizations.of(context).helpEmergencyInfoBullet3),
            ],
          ),

          _Section(
            icon: Icons.visibility_outlined,
            title: AppLocalizations.of(context).helpEmergencyInfoTitle2,
            children: [
              _Bullet(AppLocalizations.of(context).helpEmergencyInfoBullet4),
              _Bullet(AppLocalizations.of(context).helpEmergencyInfoBullet5),
              _Bullet(AppLocalizations.of(context).helpEmergencyInfoBullet6),
              _Bullet(AppLocalizations.of(context).helpEmergencyInfoBullet7),
            ],
          ),

          _Section(
            icon: Icons.call_outlined,
            title: AppLocalizations.of(context).helpEmergencyInfoTitle3,
            children: [
              _Bullet(AppLocalizations.of(context).helpEmergencyInfoBullet8),
              _Bullet(AppLocalizations.of(context).helpEmergencyInfoBullet9),
            ],
          ),

          _Section(
            icon: Icons.visibility_outlined,
            title: AppLocalizations.of(context).helpEmergencyInfoTitle4,
            children: [
              _Bullet(AppLocalizations.of(context).helpEmergencyInfoBullet10),
              _Bullet(AppLocalizations.of(context).helpEmergencyInfoBullet11),
              _Bullet(AppLocalizations.of(context).helpEmergencyInfoBullet12),
              _Bullet(AppLocalizations.of(context).helpEmergencyInfoBullet13),
            ],
          ),

          _Section(
            icon: Icons.shield_outlined,
            title: AppLocalizations.of(context).helpEmergencyInfoTitle5,
            children: [
              _Bullet(AppLocalizations.of(context).helpEmergencyInfoBullet14),
              _Bullet(AppLocalizations.of(context).helpEmergencyInfoBullet15),
              _Bullet(AppLocalizations.of(context).helpEmergencyInfoBullet16),
              _Bullet(AppLocalizations.of(context).helpEmergencyInfoBullet17),
              _Bullet(AppLocalizations.of(context).helpEmergencyInfoBullet18),
            ],
          ),

          const SizedBox(height: 8),
          _Footer(AppLocalizations.of(context).helpEmergencyInfoFooter),
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
