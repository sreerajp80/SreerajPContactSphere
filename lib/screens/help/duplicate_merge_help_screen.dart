// lib/screens/help/duplicate_merge_help_screen.dart
import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/theme/app_theme.dart';

class DuplicateMergeHelpScreen extends StatelessWidget {
  const DuplicateMergeHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Duplicate Contacts & Merge')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: const [
          _Intro(
            'Keep your address book clean and clutter-free with ContactSphere\'s '
            'intelligent duplicate detection and safe one-tap merging system.',
          ),
          SizedBox(height: 24),

          _Section(
            icon: Icons.search_outlined,
            title: 'How Duplicates are Detected',
            children: [
              _Bullet(
                'Same phone number: two contacts share the same digits, or the same number once it is put into full international form.',
              ),
              _Bullet(
                'Same name: two contacts have the same full name, or the same name once it is transliterated — so "Anil" and "അനിൽ" are seen as one person.',
              ),
              _Bullet(
                'Matching spreads across a set: if A matches B and B matches C, all three are shown together as one set.',
              ),
              _Bullet(
                'Email addresses are deliberately not used, and neither are sound-alike name codes. Both produced wrong merges between unrelated people.',
              ),
            ],
          ),

          _Section(
            icon: Icons.merge_type_outlined,
            title: 'Smart Merging Process',
            children: [
              _Bullet(
                'Open the Contacts tab, tap the three-dot menu, and choose "Find Duplicates".',
              ),
              _Bullet(
                'Each set is shown as one card. The contact that will be kept is at the top; the others are ticked to be merged into it.',
              ),
              _Bullet(
                'Untick anyone who does not belong in the set, or tap a different row to keep that one instead.',
              ),
              _Bullet(
                'All the different phone numbers, emails, addresses, birthdays and notes from the set are carried over into the contact you keep. Nothing is thrown away.',
              ),
              _Bullet(
                'Merge one set with its own Merge button, or use "Merge all sets" at the bottom to do the whole list at once.',
              ),
            ],
          ),

          _Section(
            icon: Icons.undo_outlined,
            title: 'Safety & Reversibility',
            children: [
              _Bullet(
                'Before merging everything at once, make a backup under Settings → Backup & Restore. A merge cannot be undone from the duplicates screen.',
              ),
              _Bullet(
                'If a merge was wrong, open the kept contact and edit it — the extra numbers and details are all still there, so you can move them back out into a new contact.',
              ),
            ],
          ),

          SizedBox(height: 8),
          _Footer(
            'Tip: run "Find Duplicates" after a phonebook sync or a file import — that is when duplicates usually appear.',
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
