// lib/screens/help/help_home_screen.dart
//
// "Help" hub reached from Settings. Lists in-app help topics grouped into intuitive categories.
// Covers calling, screening, privacy, sync, sharing, organization, emergency info, and FAQs.

import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
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
      appBar: AppBar(title: Text(AppLocalizations.of(context).helpHomeText1)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _buildHeaderCard(context, colors),
          const SizedBox(height: 20),

          _buildSectionHeader(
            context,
            AppLocalizations.of(context).helpHomeHeading1,
            Icons.dialpad_outlined,
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.grid_3x3_outlined,
            title: AppLocalizations.of(context).helpHomeTitle1,
            subtitle: AppLocalizations.of(context).helpHomeSub1,
            onTap: () => _push(context, const T9DialingHelpScreen()),
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.call_end_outlined,
            title: AppLocalizations.of(context).helpHomeTitle2,
            subtitle: AppLocalizations.of(context).helpHomeSub2,
            onTap: () => _push(context, const CallManagementHelpScreen()),
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.phone_disabled_outlined,
            title: AppLocalizations.of(context).helpHomeTitle3,
            subtitle: AppLocalizations.of(context).helpHomeSub3,
            onTap: () => _push(context, const CallScreeningHelpScreen()),
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.label_outline,
            title: AppLocalizations.of(context).helpHomeTitle4,
            subtitle: AppLocalizations.of(context).helpHomeSub4,
            onTap: () => _push(context, const CallerIdSpamHelpScreen()),
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.insights_outlined,
            title: AppLocalizations.of(context).helpHomeTitle5,
            subtitle: AppLocalizations.of(context).helpHomeSub5,
            onTap: () => _push(context, const CallerIntelligenceHelpScreen()),
          ),
          const SizedBox(height: 22),

          _buildSectionHeader(
            context,
            AppLocalizations.of(context).helpHomeHeading2,
            Icons.people_alt_outlined,
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.hub_outlined,
            title: AppLocalizations.of(context).helpHomeTitle6,
            subtitle: AppLocalizations.of(context).helpHomeSub6,
            onTap: () =>
                _push(context, const RelationshipCategoriesHelpScreen()),
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.sell_outlined,
            title: AppLocalizations.of(context).helpHomeTitle7,
            subtitle: AppLocalizations.of(context).helpHomeSub7,
            onTap: () => _push(context, const GroupsTagsHelpScreen()),
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.merge_type_outlined,
            title: AppLocalizations.of(context).helpHomeTitle8,
            subtitle: AppLocalizations.of(context).helpHomeSub8,
            onTap: () => _push(context, const DuplicateMergeHelpScreen()),
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.qr_code_scanner_outlined,
            title: AppLocalizations.of(context).helpHomeTitle9,
            subtitle: AppLocalizations.of(context).helpHomeSub9,
            onTap: () => _push(context, const ContactSharingHelpScreen()),
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.import_export_outlined,
            title: AppLocalizations.of(context).helpHomeTitle10,
            subtitle: AppLocalizations.of(context).helpHomeSub10,
            onTap: () => _push(context, const ImportExportHelpScreen()),
          ),
          const SizedBox(height: 22),

          _buildSectionHeader(
            context,
            AppLocalizations.of(context).helpHomeHeading3,
            Icons.security_outlined,
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.lock_outline,
            title: AppLocalizations.of(context).helpHomeTitle11,
            subtitle: AppLocalizations.of(context).helpHomeSub11,
            onTap: () => _push(context, const PrivacySecurityHelpScreen()),
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.fingerprint,
            title: AppLocalizations.of(context).helpHomeTitle12,
            subtitle: AppLocalizations.of(context).helpHomeSub12,
            onTap: () => _push(context, const BiometricsHelpScreen()),
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.pin_outlined,
            title: AppLocalizations.of(context).helpHomeTitle13,
            subtitle: AppLocalizations.of(context).helpHomeSub13,
            onTap: () => _push(context, const AppLockHelpScreen()),
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.verified_user_outlined,
            title: AppLocalizations.of(context).helpHomeTitle14,
            subtitle: AppLocalizations.of(context).helpHomeSub14,
            onTap: () => _push(context, const PermissionsHelpScreen()),
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.medical_information_outlined,
            title: AppLocalizations.of(context).helpHomeTitle15,
            subtitle: AppLocalizations.of(context).helpHomeSub15,
            onTap: () => _push(context, const EmergencyInfoHelpScreen()),
          ),
          const SizedBox(height: 22),

          _buildSectionHeader(
            context,
            AppLocalizations.of(context).helpHomeHeading4,
            Icons.cloud_sync_outlined,
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.wifi_tethering,
            title: AppLocalizations.of(context).helpHomeTitle16,
            subtitle: AppLocalizations.of(context).helpHomeSub16,
            onTap: () => _push(context, const P2PSyncHelpScreen()),
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.sync_outlined,
            title: AppLocalizations.of(context).helpHomeTitle17,
            subtitle: AppLocalizations.of(context).helpHomeSub17,
            onTap: () => _push(context, const ContactSyncHelpScreen()),
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.cloud_outlined,
            title: AppLocalizations.of(context).helpHomeTitle18,
            subtitle: AppLocalizations.of(context).helpHomeSub18,
            onTap: () => _push(context, const CloudSyncHelpScreen()),
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.backup_outlined,
            title: AppLocalizations.of(context).helpHomeTitle19,
            subtitle: AppLocalizations.of(context).helpHomeSub19,
            onTap: () => _push(context, const BackupHelpScreen()),
          ),
          const SizedBox(height: 22),

          _buildSectionHeader(
            context,
            AppLocalizations.of(context).helpHomeHeading5,
            Icons.tune_outlined,
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.palette_outlined,
            title: AppLocalizations.of(context).helpHomeTitle20,
            subtitle: AppLocalizations.of(context).helpHomeSub20,
            onTap: () => _push(context, const PersonalizationHelpScreen()),
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.handyman_outlined,
            title: AppLocalizations.of(context).helpHomeTitle21,
            subtitle: AppLocalizations.of(context).helpHomeSub21,
            onTap: () => _push(context, const ContactToolsHelpScreen()),
          ),
          const SizedBox(height: 22),

          _buildSectionHeader(
            context,
            AppLocalizations.of(context).helpHomeHeading6,
            Icons.question_answer_outlined,
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.help_outline,
            title: AppLocalizations.of(context).helpHomeTitle22,
            subtitle: AppLocalizations.of(context).helpHomeSub22,
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
                    AppLocalizations.of(context).helpHomeText2,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context).helpHomeText3,
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
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
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
