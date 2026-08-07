// lib/screens/help/backup_help_screen.dart
//
// User-facing documentation for Backup & Restore, shown from Settings → Help.
// Written in plain English and mirrors the real behavior in [BackupService] and
// [SyncBundleService.replaceAllFromBundle]: what the backup holds, why the
// password matters, and that restoring replaces everything. If that behavior
// changes, update this page to match.

import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/theme/app_theme.dart';

class BackupHelpScreen extends StatelessWidget {
  const BackupHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: const [
          _Intro(
            'A backup saves everything in the app into one file that you keep. '
            'You can use it to move to a new phone or to recover after a reset — '
            'even if the new app was installed from a different source.',
          ),
          SizedBox(height: 24),

          _Section(
            icon: Icons.inventory_2_outlined,
            title: 'What the backup holds',
            children: [
              _Bullet(
                'All contacts and their details, call history, groups, '
                'relationships, and blocked / spam numbers.',
              ),
              _Bullet(
                'Contact photos and calling-card images are included inside '
                'the file.',
              ),
              _Bullet('Your app settings, such as theme and accent color.'),
              _Bullet(
                'Your emergency info card, with its emergency contacts and the '
                '"show on lock screen" switches.',
              ),
              _Bullet(
                'Custom ringtones are not included — they point at files on '
                'this phone that would not exist elsewhere.',
              ),
            ],
          ),

          _Section(
            icon: Icons.password_outlined,
            title: 'Your password is the key',
            children: [
              _Bullet(
                'The backup file is locked with a password you choose. The '
                'app does not store it anywhere.',
              ),
              _Bullet(
                'You need the same password to restore — on this phone or any '
                'other. Keep it somewhere safe.',
              ),
              _Bullet(
                'If you lose the password, the file cannot be opened. There is '
                'no way to recover it — that is what keeps your data private.',
              ),
            ],
          ),

          _Section(
            icon: Icons.restore_outlined,
            title: 'Restoring replaces everything',
            children: [
              _Bullet(
                'Restoring DELETES what is currently in the app and rebuilds '
                'it as an exact copy of the backup.',
              ),
              _Bullet(
                'It is not a merge. If you want to combine two phones without '
                'losing data, use "Sync to Another Device" instead.',
              ),
              _Bullet(
                'Restore a backup made with the same app version. A backup '
                'from a very different version may be refused.',
              ),
            ],
          ),

          SizedBox(height: 8),
          _Footer(
            'Tip: after making a backup, the app opens the share sheet so you '
            'can save the file to Files, Drive, or send it to yourself. Store it '
            'somewhere other than this phone.',
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
