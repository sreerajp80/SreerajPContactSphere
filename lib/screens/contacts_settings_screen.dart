// lib/screens/contacts_settings_screen.dart
import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/models/contact.dart';
import 'package:smart_contacts_dialer/services/contact_sync_service.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';
import 'package:smart_contacts_dialer/screens/add_edit_contact_screen.dart';
import 'package:smart_contacts_dialer/screens/blocked_numbers_screen.dart';
import 'package:smart_contacts_dialer/screens/contact_display_settings_screen.dart';
import 'package:smart_contacts_dialer/screens/contact_index_health_screen.dart';
import 'package:smart_contacts_dialer/screens/contact_sync_settings_screen.dart';
import 'package:smart_contacts_dialer/screens/relationship_names_screen.dart';
import 'package:smart_contacts_dialer/screens/secret_contacts_export_screen.dart';

/// Contacts-related settings hub.
class ContactsSettingsScreen extends StatelessWidget {
  const ContactsSettingsScreen({super.key});

  Future<void> _addMe(BuildContext context) async {
    Contact? self;
    try {
      self = await ContactSyncService().selfContact();
    } catch (_) {}
    if (!context.mounted) return;
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => self != null
            ? AddEditContactScreen(contact: self)
            : const AddEditContactScreen(initialIsSelf: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).navContacts)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _SettingsSectionCard(
            icon: Icons.groups_outlined,
            title: AppLocalizations.of(context).labelContactCountsIndex,
            subtitle: AppLocalizations.of(context).descContactCountsIndex,
            onTap: () => _push(context, const ContactIndexHealthScreen()),
          ),
          const SizedBox(height: 12),
          _SettingsSectionCard(
            icon: Icons.person_add_alt_outlined,
            title: AppLocalizations.of(context).labelMyProfileAddMe,
            subtitle: AppLocalizations.of(context).descMyProfileAddMe,
            onTap: () => _addMe(context),
          ),
          const SizedBox(height: 12),
          _SettingsSectionCard(
            icon: Icons.sort_by_alpha,
            title: AppLocalizations.of(context).labelDisplayFormatting,
            subtitle: AppLocalizations.of(context).descDisplayFormatting,
            onTap: () => _push(context, const ContactDisplaySettingsScreen()),
          ),
          const SizedBox(height: 12),
          _SettingsSectionCard(
            icon: Icons.sync,
            title: AppLocalizations.of(context).labelDeviceCloudSync,
            subtitle: AppLocalizations.of(context).descDeviceCloudSync,
            onTap: () => _push(context, const ContactSyncSettingsScreen()),
          ),
          const SizedBox(height: 12),
          _SettingsSectionCard(
            icon: Icons.label_outlined,
            title: AppLocalizations.of(context).labelCustomRelationshipLabels,
            subtitle: AppLocalizations.of(context).descCustomRelationshipLabels,
            onTap: () => _push(context, const RelationshipNamesScreen()),
          ),
          const SizedBox(height: 12),
          _SettingsSectionCard(
            icon: Icons.block_outlined,
            title: AppLocalizations.of(context).titleBlockedNumbers,
            subtitle: AppLocalizations.of(context).descBlockedNumbersCard,
            onTap: () => _push(context, const BlockedNumbersScreen()),
          ),
          const SizedBox(height: 12),
          _SettingsSectionCard(
            icon: Icons.lock_outline,
            title: AppLocalizations.of(context).labelSecretContactsExport,
            subtitle: AppLocalizations.of(context).descSecretContactsExport,
            onTap: () => _push(context, const SecretContactsExportScreen()),
          ),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}

class _SettingsSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsSectionCard({
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
