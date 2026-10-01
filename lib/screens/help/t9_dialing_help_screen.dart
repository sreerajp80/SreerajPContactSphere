// lib/screens/help/t9_dialing_help_screen.dart
//
// User-facing documentation for T9 Smart Dialing & Malayalam script mappings,
// reachable from Settings → Help → T9 Dialing & Malayalam.

import 'package:flutter/material.dart';
import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

class T9DialingHelpScreen extends StatelessWidget {
  const T9DialingHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).helpT9DialingText),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          _Intro(AppLocalizations.of(context).helpT9DialingIntro),
          const SizedBox(height: 24),

          _Section(
            icon: Icons.sort_by_alpha,
            title: AppLocalizations.of(context).helpT9DialingTitle1,
            children: [
              _Bullet(AppLocalizations.of(context).helpT9DialingBullet1),
              _Bullet(AppLocalizations.of(context).helpT9DialingBullet2),
              _Bullet(AppLocalizations.of(context).helpT9DialingBullet3),
              _Bullet(AppLocalizations.of(context).helpT9DialingBullet4),
              _Bullet(AppLocalizations.of(context).helpT9DialingBullet5),
            ],
          ),

          _Section(
            icon: Icons.keyboard_outlined,
            title: AppLocalizations.of(context).helpT9DialingTitle2,
            children: [
              _Bullet(AppLocalizations.of(context).helpT9DialingBullet6),
              _Bullet(AppLocalizations.of(context).helpT9DialingBullet7),
            ],
          ),

          _Section(
            icon: Icons.g_translate_outlined,
            title: AppLocalizations.of(context).helpT9DialingTitle3,
            children: [
              _Bullet(AppLocalizations.of(context).helpT9DialingBullet8),
              _Bullet(AppLocalizations.of(context).helpT9DialingBullet9),
            ],
          ),

          const SizedBox(height: 8),
          _Footer(AppLocalizations.of(context).helpT9DialingFooter),
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
    final colors = theme.extension<AppColors>()!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: accent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.mutedText,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
