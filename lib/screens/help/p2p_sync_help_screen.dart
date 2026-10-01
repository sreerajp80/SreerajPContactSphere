// lib/screens/help/p2p_sync_help_screen.dart
//
// User-facing documentation for the "Sync to Another Device" (P2P) feature,
// shown from Settings → Help. The content is written in plain English and mirrors
// the real behavior in [SyncBundleService] and [P2PSyncService]: what is copied,
// what is deliberately left out, Full vs Selective sync, and the add-only merge.
// If that behavior changes, update this page to match.

import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

class P2PSyncHelpScreen extends StatelessWidget {
  const P2PSyncHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).helpP2pSyncText)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          _Intro(AppLocalizations.of(context).helpP2pSyncIntro),
          const SizedBox(height: 24),

          _Section(
            icon: Icons.checklist_rounded,
            title: AppLocalizations.of(context).helpP2pSyncTitle1,
            children: [
              _Bullet(AppLocalizations.of(context).helpP2pSyncBullet1),
              _Bullet(AppLocalizations.of(context).helpP2pSyncBullet2),
              _Bullet(AppLocalizations.of(context).helpP2pSyncBullet3),
              _Bullet(AppLocalizations.of(context).helpP2pSyncBullet4),
            ],
          ),

          _Section(
            icon: Icons.qr_code_2_rounded,
            title: AppLocalizations.of(context).helpP2pSyncTitle2,
            children: [
              _Bullet(AppLocalizations.of(context).helpP2pSyncBullet5),
              _Bullet(AppLocalizations.of(context).helpP2pSyncBullet6),
              _Bullet(AppLocalizations.of(context).helpP2pSyncBullet7),
            ],
          ),

          _Section(
            icon: Icons.tune_rounded,
            title: AppLocalizations.of(context).helpP2pSyncTitle3,
            children: [
              _Bullet(AppLocalizations.of(context).helpP2pSyncBullet8),
              _Bullet(AppLocalizations.of(context).helpP2pSyncBullet9),
            ],
          ),

          _Section(
            icon: Icons.cloud_done_outlined,
            title: AppLocalizations.of(context).helpP2pSyncTitle4,
            children: [
              _Bullet(AppLocalizations.of(context).helpP2pSyncBullet10),
              _Bullet(AppLocalizations.of(context).helpP2pSyncBullet11),
              _Bullet(AppLocalizations.of(context).helpP2pSyncBullet12),
              _Bullet(AppLocalizations.of(context).helpP2pSyncBullet13),
              _Bullet(AppLocalizations.of(context).helpP2pSyncBullet14),
              _Bullet(AppLocalizations.of(context).helpP2pSyncBullet15),
              _Bullet(AppLocalizations.of(context).helpP2pSyncBullet16),
              _Bullet(AppLocalizations.of(context).helpP2pSyncBullet17),
            ],
          ),

          _Section(
            icon: Icons.block_flipped,
            title: AppLocalizations.of(context).helpP2pSyncTitle5,
            children: [
              _Bullet(AppLocalizations.of(context).helpP2pSyncBullet18),
              _Bullet(AppLocalizations.of(context).helpP2pSyncBullet19),
            ],
          ),

          _Section(
            icon: Icons.merge_type_rounded,
            title: AppLocalizations.of(context).helpP2pSyncTitle6,
            children: [
              _Bullet(AppLocalizations.of(context).helpP2pSyncBullet20),
              _Bullet(AppLocalizations.of(context).helpP2pSyncBullet21),
              _Bullet(AppLocalizations.of(context).helpP2pSyncBullet22),
            ],
          ),

          _Section(
            icon: Icons.lock_outline_rounded,
            title: AppLocalizations.of(context).helpP2pSyncTitle7,
            children: [
              _Bullet(AppLocalizations.of(context).helpP2pSyncBullet23),
              _Bullet(AppLocalizations.of(context).helpP2pSyncBullet24),
            ],
          ),

          const SizedBox(height: 8),
          _Footer(AppLocalizations.of(context).helpP2pSyncFooter),
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
