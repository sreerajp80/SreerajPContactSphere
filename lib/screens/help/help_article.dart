// lib/screens/help/help_article.dart
//
// The shared building blocks every help article is made of: a lead paragraph,
// titled sections with bullet points, and a closing tip panel.
//
// The older help pages (T9, biometrics, emergency info, …) each carry their own
// private copies of these widgets. New pages use the ones here instead, so the
// look stays in one place. The styling is copied from those pages on purpose —
// a page built either way renders identically.

import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/theme/app_theme.dart';

/// The lead paragraph at the top of a help article.
class HelpIntro extends StatelessWidget {
  final String text;
  const HelpIntro(this.text, {super.key});

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
class HelpSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const HelpSection({
    super.key,
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

/// A single bullet line inside a [HelpSection].
class HelpBullet extends StatelessWidget {
  final String text;
  const HelpBullet(this.text, {super.key});

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
class HelpFooter extends StatelessWidget {
  final String text;
  const HelpFooter(this.text, {super.key});

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

/// The standard help-article page: an app bar with [title] and a scrolling list
/// of [HelpIntro] / [HelpSection] / [HelpFooter] blocks, padded like the rest of
/// the help pages.
class HelpArticleScaffold extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const HelpArticleScaffold({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: children,
      ),
    );
  }
}
