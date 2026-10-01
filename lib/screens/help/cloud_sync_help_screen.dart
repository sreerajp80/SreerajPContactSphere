// lib/screens/help/cloud_sync_help_screen.dart
//
// User-facing documentation for Cloud Contact Sync & Cloud Backup, shown from Settings → Help.
// Explains 2-way live contact sync vs password-encrypted cloud backups, multi-provider setup,
// and privacy rules for secret vault contacts and cloud backup files.

import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

class CloudSyncHelpScreen extends StatelessWidget {
  const CloudSyncHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).helpCloudSyncText),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          _Intro(AppLocalizations.of(context).helpCloudSyncIntro),
          const SizedBox(height: 24),

          _Section(
            icon: Icons.sync_rounded,
            title: AppLocalizations.of(context).helpCloudSyncTitle1,
            children: [
              _Bullet(AppLocalizations.of(context).helpCloudSyncBullet1),
              _Bullet(AppLocalizations.of(context).helpCloudSyncBullet2),
            ],
          ),

          _Section(
            icon: Icons.alt_route_rounded,
            title: AppLocalizations.of(context).helpCloudSyncTitle2,
            children: [
              _Bullet(AppLocalizations.of(context).helpCloudSyncBullet3),
              _Bullet(AppLocalizations.of(context).helpCloudSyncBullet4),
              _Bullet(AppLocalizations.of(context).helpCloudSyncBullet5),
            ],
          ),

          _Section(
            icon: Icons.security_rounded,
            title: AppLocalizations.of(context).helpCloudSyncTitle3,
            children: [
              _Bullet(AppLocalizations.of(context).helpCloudSyncBullet6),
              _Bullet(AppLocalizations.of(context).helpCloudSyncBullet7),
            ],
          ),

          const SizedBox(height: 8),
          _Footer(AppLocalizations.of(context).helpCloudSyncFooter),
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
