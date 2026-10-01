// lib/screens/help/relationship_categories_help_screen.dart
//
// User-facing documentation for the seven relationship categories, shown from
// Settings → Help. Mirrors the real behaviour in [RelationshipCategory] and the
// sphere view in `relationship_screen.dart`. If the categories or their default
// labels change, update this page.

import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/l10n/relationship_labels.dart';
import 'package:smart_contacts_dialer/models/relationship.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

class RelationshipCategoriesHelpScreen extends StatelessWidget {
  const RelationshipCategoriesHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).helpRelationshipCategoriesText1,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          _Intro(AppLocalizations.of(context).helpRelationshipCategoriesIntro),
          const SizedBox(height: 24),

          _Section(
            icon: Icons.hub_outlined,
            title: AppLocalizations.of(
              context,
            ).helpRelationshipCategoriesTitle1,
            children: [
              _Bullet(
                AppLocalizations.of(context).helpRelationshipCategoriesBullet1,
              ),
              _Bullet(
                AppLocalizations.of(context).helpRelationshipCategoriesBullet2,
              ),
              _Bullet(
                AppLocalizations.of(context).helpRelationshipCategoriesBullet3,
              ),
            ],
          ),

          _Section(
            icon: Icons.edit_outlined,
            title: AppLocalizations.of(
              context,
            ).helpRelationshipCategoriesTitle2,
            children: [
              _Bullet(
                AppLocalizations.of(context).helpRelationshipCategoriesBullet4,
              ),
              _Bullet(
                AppLocalizations.of(context).helpRelationshipCategoriesBullet5,
              ),
              _Bullet(
                AppLocalizations.of(context).helpRelationshipCategoriesBullet6,
              ),
            ],
          ),

          _Section(
            icon: Icons.category_outlined,
            title: AppLocalizations.of(
              context,
            ).helpRelationshipCategoriesTitle3,
            children: [
              for (final c in RelationshipCategory.values)
                _CategoryRow(category: c),
            ],
          ),

          _Section(
            icon: Icons.swap_horiz,
            title: AppLocalizations.of(
              context,
            ).helpRelationshipCategoriesTitle4,
            children: [
              _Bullet(
                AppLocalizations.of(context).helpRelationshipCategoriesBullet7,
              ),
              _Bullet(
                AppLocalizations.of(context).helpRelationshipCategoriesBullet8,
              ),
            ],
          ),

          _Section(
            icon: Icons.update,
            title: AppLocalizations.of(
              context,
            ).helpRelationshipCategoriesTitle5,
            children: [
              _Bullet(
                AppLocalizations.of(context).helpRelationshipCategoriesBullet9,
              ),
              _Bullet(
                AppLocalizations.of(context).helpRelationshipCategoriesBullet10,
              ),
            ],
          ),

          _Section(
            icon: Icons.bedtime_outlined,
            title: AppLocalizations.of(
              context,
            ).helpRelationshipCategoriesTitle6,
            children: [
              _Bullet(
                AppLocalizations.of(context).helpRelationshipCategoriesBullet11,
              ),
              _Bullet(
                AppLocalizations.of(context).helpRelationshipCategoriesBullet12,
              ),
              _Bullet(
                AppLocalizations.of(context).helpRelationshipCategoriesBullet13,
              ),
            ],
          ),

          const SizedBox(height: 8),
          _Footer(
            AppLocalizations.of(context).helpRelationshipCategoriesFooter,
          ),
        ],
      ),
    );
  }
}

/// One category line inside the "seven categories" section: emoji, name, and a
/// few of its suggested labels.
class _CategoryRow extends StatelessWidget {
  final RelationshipCategory category;
  const _CategoryRow({required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final l = AppLocalizations.of(context);
    final examples = category.suggestedLabels.take(5).join(', ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(category.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  relationshipCategoryLabel(l, category),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l.helpRelationshipCategoriesExample(
                    relationshipCategoryDescription(l, category),
                    examples,
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.mutedText,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
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
