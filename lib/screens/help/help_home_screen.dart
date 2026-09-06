// lib/screens/help/help_home_screen.dart
//
// "Help" hub reached from Settings. Lists in-app help topics grouped into intuitive categories.
// Covers calling, screening, privacy, sync, sharing, organization, emergency info, and FAQs.

import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/theme/app_theme.dart';
import 'package:smart_contacts_dialer/screens/help/app_lock_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/backup_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/biometrics_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/call_management_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/call_screening_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/caller_id_spam_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/caller_intelligence_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/cloud_sync_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/contact_sharing_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/contact_sync_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/contact_tools_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/duplicate_merge_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/emergency_info_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/faq_troubleshooting_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/groups_tags_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/import_export_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/p2p_sync_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/permissions_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/personalization_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/privacy_security_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/relationship_categories_help_screen.dart';
import 'package:smart_contacts_dialer/screens/help/t9_dialing_help_screen.dart';

class HelpHomeScreen extends StatelessWidget {
  const HelpHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('Help & User Guides')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _buildHeaderCard(context, colors),
          const SizedBox(height: 20),

          _buildSectionHeader(
            context,
            'Calling & Dialer',
            Icons.dialpad_outlined,
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.grid_3x3_outlined,
            title: 'T9 Dialing & Malayalam',
            subtitle:
                'How multi-script T9 search works and where Malayalam vowels (അ to അഃ) are mapped.',
            onTap: () => _push(context, const T9DialingHelpScreen()),
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.call_end_outlined,
            title: 'Calling & In-Call Controls',
            subtitle:
                'Conference merge, hold and swap, dual-SIM options, smart redial, and spoken caller names.',
            onTap: () => _push(context, const CallManagementHelpScreen()),
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.phone_disabled_outlined,
            title: 'Call Screening & Blocking',
            subtitle:
                'Blocking a number before it rings, blocked unknown callers, and why the default dialer role is needed.',
            onTap: () => _push(context, const CallScreeningHelpScreen()),
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.label_outline,
            title: 'Caller ID & Spam Filter',
            subtitle:
                'Labelling unknown callers, ringing suspected spam silently, and marking a number as spam.',
            onTap: () => _push(context, const CallerIdSpamHelpScreen()),
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.insights_outlined,
            title: 'Call Context & Notes',
            subtitle:
                'Pre-call summary, "Likely to answer now", and the notes you write after a call.',
            onTap: () => _push(context, const CallerIntelligenceHelpScreen()),
          ),
          const SizedBox(height: 22),

          _buildSectionHeader(
            context,
            'Organization & Sharing',
            Icons.people_alt_outlined,
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.hub_outlined,
            title: 'Relationship Spheres',
            subtitle:
                'The 7 categories from Immediate Family to Service, your own labels, and quiet hours.',
            onTap: () =>
                _push(context, const RelationshipCategoriesHelpScreen()),
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.sell_outlined,
            title: 'Groups & Tags',
            subtitle:
                'Building groups, group ringtones, the tag cloud, and selecting many contacts at once.',
            onTap: () => _push(context, const GroupsTagsHelpScreen()),
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.merge_type_outlined,
            title: 'Duplicate Contacts & Merge',
            subtitle:
                'How identical names, phones, and emails are detected and merged without data loss.',
            onTap: () => _push(context, const DuplicateMergeHelpScreen()),
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.qr_code_scanner_outlined,
            title: 'Sharing & Card Scanning',
            subtitle:
                'QR contact codes, the on-device business card scanner, and sharing over Bluetooth.',
            onTap: () => _push(context, const ContactSharingHelpScreen()),
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.import_export_outlined,
            title: 'Import & Export Files',
            subtitle:
                'CSV and vCard files in and out, and AirQR for sending more than one QR code can hold.',
            onTap: () => _push(context, const ImportExportHelpScreen()),
          ),
          const SizedBox(height: 22),

          _buildSectionHeader(
            context,
            'Privacy & Protection',
            Icons.security_outlined,
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.lock_outline,
            title: 'Privacy, Security & Vault',
            subtitle:
                'Secret contacts vault, biometric/PIN protection, screenshot guard, and security audit log.',
            onTap: () => _push(context, const PrivacySecurityHelpScreen()),
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.fingerprint,
            title: 'Biometric Lock Details',
            subtitle:
                'Every place the app asks for your fingerprint or face, and what happens without a screen lock.',
            onTap: () => _push(context, const BiometricsHelpScreen()),
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.pin_outlined,
            title: 'App Lock & PIN',
            subtitle:
                'The three lock modes, setting an App PIN, and the recovery code if you forget it.',
            onTap: () => _push(context, const AppLockHelpScreen()),
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.verified_user_outlined,
            title: 'Permissions Explained',
            subtitle:
                'What each permission is for, which are optional, and what stops working if you say no.',
            onTap: () => _push(context, const PermissionsHelpScreen()),
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.medical_information_outlined,
            title: 'Emergency Info Card',
            subtitle:
                'Setting lock-screen medical details and emergency contacts for first responders.',
            onTap: () => _push(context, const EmergencyInfoHelpScreen()),
          ),
          const SizedBox(height: 22),

          _buildSectionHeader(
            context,
            'Sync & Backups',
            Icons.cloud_sync_outlined,
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.wifi_tethering,
            title: 'Local Wi-Fi P2P Device Sync',
            subtitle:
                'How direct device-to-device Wi-Fi transfer works with end-to-end encryption and zero cloud.',
            onTap: () => _push(context, const P2PSyncHelpScreen()),
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.sync_outlined,
            title: 'Phonebook & Call Log Sync',
            subtitle:
                'Merging or mirroring contacts and call history with Android system storage.',
            onTap: () => _push(context, const ContactSyncHelpScreen()),
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.cloud_outlined,
            title: 'Cloud Sync & Google Drive',
            subtitle:
                'Two-way online sync, encrypted cloud backups, WebDAV setup, and vault privacy.',
            onTap: () => _push(context, const CloudSyncHelpScreen()),
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.backup_outlined,
            title: 'Offline Backup & Restore',
            subtitle:
                'Exporting encrypted backup files, password safety, and restoring on a new phone.',
            onTap: () => _push(context, const BackupHelpScreen()),
          ),
          const SizedBox(height: 22),

          _buildSectionHeader(
            context,
            'Personalization & Tools',
            Icons.tune_outlined,
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.palette_outlined,
            title: 'Look, Sound & Region',
            subtitle:
                'Theme and accent colour, fonts and text size, ringtones and vibration, and the default country.',
            onTap: () => _push(context, const PersonalizationHelpScreen()),
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.handyman_outlined,
            title: 'Contact Tools',
            subtitle:
                'Temporary self-deleting contacts, connected messaging apps, and the search index.',
            onTap: () => _push(context, const ContactToolsHelpScreen()),
          ),
          const SizedBox(height: 22),

          _buildSectionHeader(
            context,
            'Frequently Asked Questions',
            Icons.question_answer_outlined,
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.help_outline,
            title: 'FAQs & Troubleshooting Guide',
            subtitle:
                'Direct answers to top questions: permissions, default dialer, quiet hours, and search indexing.',
            onTap: () => _push(context, const FaqTroubleshootingHelpScreen()),
          ),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  Widget _buildHeaderCard(BuildContext context, AppColors colors) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.12),
              theme.colorScheme.secondary.withValues(alpha: 0.04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: colors.brandGradient,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: colors.gradientStart.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.help_center_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Help Center & Knowledge Base',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Browse in-depth guides and solutions for all features of SreerajP Contacts Sphere.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.mutedText,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
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
                child: Icon(icon, color: accent, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: colors.mutedText,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: colors.mutedText),
            ],
          ),
        ),
      ),
    );
  }
}
