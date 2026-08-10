// lib/screens/help/cloud_sync_help_screen.dart
//
// User-facing documentation for Cloud Contact Sync & Cloud Backup, shown from Settings → Help.
// Explains 2-way live contact sync vs password-encrypted cloud backups, multi-provider setup,
// and privacy rules for secret vault contacts and cloud backup files.

import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/theme/app_theme.dart';

class CloudSyncHelpScreen extends StatelessWidget {
  const CloudSyncHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cloud Sync & Backup')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: const [
          _Intro(
            'ContactSphere connects with Google, Microsoft, and CardDAV/WebDAV '
            'servers. You can use a single provider or decouple them — syncing live '
            'contacts with one service while backing up your encrypted database to another.',
          ),
          SizedBox(height: 24),

          _Section(
            icon: Icons.sync_rounded,
            title: 'Contact Sync vs Cloud Backup',
            children: [
              _Bullet(
                'Online Contact Sync (Live 2-Way): synchronizes individual contact cards '
                '(names, phone numbers, emails) directly with Google People API, Microsoft Graph '
                'Contacts, or CardDAV address books. Synced contacts appear in your online address book.',
              ),
              _Bullet(
                'Encrypted Cloud Backup: exports a full, password-encrypted .csbak file '
                'containing your complete database (all contacts, call history, call notes, tags, settings, '
                'and emergency info) to cloud file storage (Google Drive AppData, Microsoft OneDrive, or WebDAV).',
              ),
            ],
          ),

          _Section(
            icon: Icons.alt_route_rounded,
            title: 'Mixing cloud providers',
            children: [
              _Bullet(
                'You can use Google for live contact sync while storing encrypted cloud backups on '
                'Microsoft OneDrive or a self-hosted WebDAV server.',
              ),
              _Bullet(
                'In Settings → Online Sync, toggle "Contact Sync: On" and "Cloud Backup: Off" '
                'for your Google account.',
              ),
              _Bullet(
                'Add your Microsoft or WebDAV account separately and select it when uploading '
                'encrypted cloud backups in Settings → Cloud Backup.',
              ),
            ],
          ),

          _Section(
            icon: Icons.security_rounded,
            title: 'Privacy & Security',
            children: [
              _Bullet(
                'Secret Vault Contacts: contacts saved as Secret in ContactSphere are app-only and '
                'are NEVER uploaded or synced to online contact providers (Google Contacts, Outlook, or CardDAV).',
              ),
              _Bullet(
                'Encrypted Payload: Cloud backup files (.csbak) are encrypted locally using PBKDF2 '
                'and AES-GCM with your personal passphrase before upload. The cloud provider cannot read '
                'your backup data.',
              ),
            ],
          ),

          SizedBox(height: 8),
          _Footer(
            'Tip: You can manage all configured accounts under Settings → Online Sync. Each account can '
            'have independent toggles for live contact sync and cloud backup.',
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
