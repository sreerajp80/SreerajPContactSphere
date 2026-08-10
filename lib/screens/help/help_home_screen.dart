// lib/screens/help/help_home_screen.dart
//
// "Help" hub reached from Settings. Lists in-app help topics. Kept as a hub (not
// a direct link to one article) so more topics can be added later without
// re-touching Settings. Holds the P2P sync guide and the biometric-lock guide.

import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/theme/app_theme.dart';
import 'package:smart_contacts_dialer/screens/help/backup_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/biometrics_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/cloud_sync_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/contact_sync_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/emergency_info_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/p2p_sync_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/t9_dialing_help_screen.dart';

class HelpHomeScreen extends StatelessWidget {
  const HelpHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _HelpTopicCard(
            icon: Icons.dialpad,
            title: 'T9 Dialing & Malayalam',
            subtitle:
                'How multi-script T9 search works and where Malayalam vowels '
                '(അ to അഃ) are mapped.',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const T9DialingHelpScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _HelpTopicCard(
            icon: Icons.sync_alt,
            title: 'Sync to Another Device',
            subtitle:
                'How Wi-Fi sync works, what it copies, and what it never touches.',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const P2PSyncHelpScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _HelpTopicCard(
            icon: Icons.sync_outlined,
            title: 'Contact Sync',
            subtitle:
                'Merge or mirror contacts and call log with the device, and '
                'what destructive sync deletes.',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ContactSyncHelpScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _HelpTopicCard(
            icon: Icons.cloud_sync_outlined,
            title: 'Cloud Sync & Backup',
            subtitle:
                '2-way online contact sync, encrypted cloud backups, multi-provider setup, and vault privacy.',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CloudSyncHelpScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _HelpTopicCard(
            icon: Icons.backup_outlined,
            title: 'Backup & Restore',
            subtitle:
                'What a backup holds, why the password matters, and how restore '
                'works.',
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const BackupHelpScreen())),
          ),
          const SizedBox(height: 12),
          _HelpTopicCard(
            icon: Icons.medical_information_outlined,
            title: 'Emergency info',
            subtitle:
                'What the lock-screen card shows, who can read it, and how to '
                'switch it off.',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EmergencyInfoHelpScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _HelpTopicCard(
            icon: Icons.fingerprint,
            title: 'Biometric lock',
            subtitle:
                'What the fingerprint / face check protects and where it is used.',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BiometricsHelpScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single help topic row, styled to match the Settings / Sync cards.
class _HelpTopicCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HelpTopicCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final accent = theme.colorScheme.primary;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(color: colors.mutedText, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colors.mutedText),
            ],
          ),
        ),
      ),
    );
  }
}
