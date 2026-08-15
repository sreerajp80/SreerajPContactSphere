// lib/screens/help/relationship_categories_help_screen.dart
//
// User-facing documentation for the seven relationship categories, shown from
// Settings → Help. Mirrors the real behaviour in [RelationshipCategory] and the
// sphere view in `relationship_screen.dart`. If the categories or their default
// labels change, update this page.

import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/models/relationship.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

class RelationshipCategoriesHelpScreen extends StatelessWidget {
  const RelationshipCategoriesHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Relationship categories')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          const _Intro(
            'Every relationship you save has two parts: a category and a label. '
            'The category is one of seven fixed buckets. The label is whatever '
            'you want to call it — "Father", "Cousin Brother", "Manager".',
          ),
          const SizedBox(height: 24),

          const _Section(
            icon: Icons.hub_outlined,
            title: 'Why categories exist',
            children: [
              _Bullet(
                'The sphere used to draw one node for every different label. '
                'With twenty or more links it turned into a crowd.',
              ),
              _Bullet(
                'Now the sphere draws at most seven nodes — one per category. '
                'The number inside a node is how many contacts sit in it.',
              ),
              _Bullet(
                'Tap a node to see everyone inside it, each with their own '
                'label. Nothing is hidden; it is only tidier.',
              ),
            ],
          ),

          const _Section(
            icon: Icons.edit_outlined,
            title: 'Adding a relationship',
            children: [
              _Bullet('Pick the contact you want to link.'),
              _Bullet('Pick one of the seven categories.'),
              _Bullet(
                'Type the label, or tap one of the suggested chips. The chips '
                'are only shortcuts — any wording you like is accepted.',
              ),
            ],
          ),

          _Section(
            icon: Icons.category_outlined,
            title: 'The seven categories',
            children: [
              for (final c in RelationshipCategory.values)
                _CategoryRow(category: c),
            ],
          ),

          const _Section(
            icon: Icons.swap_horiz,
            title: 'Both sides, one category',
            children: [
              _Bullet(
                'A link is saved on both contacts. If you save someone as your '
                'Father, you show up on their side as their Son or Daughter.',
              ),
              _Bullet(
                'The reverse side keeps the same category, so the pair always '
                'sits in the same bucket on both spheres.',
              ),
            ],
          ),

          const _Section(
            icon: Icons.update,
            title: 'Relationships you saved earlier',
            children: [
              _Bullet(
                'Old links had no category. On the first launch after this '
                'update, each one is sorted by its label — "Father" goes to '
                'Immediate Family, "Colleague" to Professional, and so on.',
              ),
              _Bullet(
                'A label the app does not recognise goes to Social. Nothing is '
                'deleted, and you can move any link to another category by '
                'tapping it and choosing "Change".',
              ),
            ],
          ),

          const SizedBox(height: 8),
          const _Footer(
            'Tip: if you are unsure where someone belongs, pick the category '
            'you would look under later. The label carries the detail.',
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
                  category.displayName,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${category.description} e.g. $examples.',
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
