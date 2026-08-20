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
                'Identical Phone Numbers: Contacts sharing the exact same phone number or formatted mobile number.',
              ),
              _Bullet(
                'Matching Names: Contacts with identical or near-identical first and last names across different accounts.',
              ),
              _Bullet(
                'Matching Email Addresses: Contacts sharing the same personal or work email address.',
              ),
            ],
          ),

          _Section(
            icon: Icons.merge_type_outlined,
            title: 'Smart Merging Process',
            children: [
              _Bullet(
                'Open Contacts → Tap the options menu → Select "Find Duplicates".',
              ),
              _Bullet(
                'ContactSphere groups matching records into clear comparison cards so you can see what data will be combined.',
              ),
              _Bullet(
                'Safe Combination: All distinct phone numbers, emails, addresses, birthdays, and notes from both contacts are preserved and unified into one master contact.',
              ),
              _Bullet(
                'You can review every merge individually or tap "Merge All" to clean up your entire address book in one step.',
              ),
            ],
          ),

          _Section(
            icon: Icons.undo_outlined,
            title: 'Safety & Reversibility',
            children: [
              _Bullet(
                'Before running bulk merges, you can create a quick backup file under Settings → Backup.',
              ),
              _Bullet(
                'If two contacts were merged by mistake, you can easily re-edit the contact profile to separate or adjust numbers.',
              ),
            ],
          ),

          SizedBox(height: 8),
          _Footer(
            'Tip: Run "Find Duplicates" after syncing with your phonebook or importing contacts from another device to keep everything organized.',
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
