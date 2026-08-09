// lib/screens/contacts_settings_screen.dart
import 'package:flutter/material.dart';

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
      appBar: AppBar(title: const Text('Contacts')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _SettingsSectionCard(
            icon: Icons.groups_outlined,
            title: 'Contact counts & search index',
            subtitle: 'View device/app contact counts and search index status',
            onTap: () => _push(context, const ContactIndexHealthScreen()),
          ),
          const SizedBox(height: 12),
          _SettingsSectionCard(
            icon: Icons.person_add_alt_outlined,
            title: 'My Profile ("Add Me")',
            subtitle: 'Create or edit your own Self contact card',
            onTap: () => _addMe(context),
          ),
          const SizedBox(height: 12),
          _SettingsSectionCard(
            icon: Icons.sort_by_alpha,
            title: 'Display & formatting',
            subtitle: 'Sort order, name format, and display filters',
            onTap: () => _push(context, const ContactDisplaySettingsScreen()),
          ),
          const SizedBox(height: 12),
          _SettingsSectionCard(
            icon: Icons.sync,
            title: 'Device & cloud sync',
            subtitle: 'Configure device mirroring and cloud accounts',
            onTap: () => _push(context, const ContactSyncSettingsScreen()),
          ),
          const SizedBox(height: 12),
          _SettingsSectionCard(
            icon: Icons.label_outlined,
            title: 'Custom relationship labels',
            subtitle: 'Manage custom relationship labels for contacts',
            onTap: () => _push(context, const RelationshipNamesScreen()),
          ),
          const SizedBox(height: 12),
          _SettingsSectionCard(
            icon: Icons.block_outlined,
            title: 'Blocked numbers',
            subtitle: 'View and manage numbers blocked from ringing',
            onTap: () => _push(context, const BlockedNumbersScreen()),
          ),
          const SizedBox(height: 12),
          _SettingsSectionCard(
            icon: Icons.lock_outline,
            title: 'Secret contacts & export',
            subtitle: 'Export options and secret contact export controls',
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
