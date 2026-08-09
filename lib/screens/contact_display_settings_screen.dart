// lib/screens/contact_display_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

/// Configuration screen for Contact Display & Formatting options.
class ContactDisplaySettingsScreen extends StatelessWidget {
  const ContactDisplaySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final accent = Theme.of(context).colorScheme.primary;
    final settings = context.watch<AppSettings>();

    return Scaffold(
      appBar: AppBar(title: const Text('Display & Formatting')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _SortOrderCard(colors: colors, accent: accent, settings: settings),
          const SizedBox(height: 12),
          _HideWithoutPhoneCard(colors: colors, accent: accent, settings: settings),
        ],
      ),
    );
  }
}

class _SortOrderCard extends StatelessWidget {
  final AppColors colors;
  final Color accent;
  final AppSettings settings;

  const _SortOrderCard({
    required this.colors,
    required this.accent,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sort order',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              'How contacts are ordered in lists',
              style: TextStyle(color: colors.mutedText, fontSize: 13),
            ),
            const SizedBox(height: 8),
            SegmentedButton<ContactSortOrder>(
              segments: const [
                ButtonSegment(
                  value: ContactSortOrder.firstName,
                  label: Text('First name'),
                ),
                ButtonSegment(
                  value: ContactSortOrder.lastName,
                  label: Text('Last name'),
                ),
              ],
              selected: {settings.contactSortOrder},
              onSelectionChanged: (s) =>
                  context.read<AppSettings>().setContactSortOrder(s.first),
            ),
          ],
        ),
      ),
    );
  }
}

class _HideWithoutPhoneCard extends StatelessWidget {
  final AppColors colors;
  final Color accent;
  final AppSettings settings;

  const _HideWithoutPhoneCard({
    required this.colors,
    required this.accent,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        value: settings.hideContactsWithoutPhone,
        activeThumbColor: accent,
        onChanged: (v) =>
            context.read<AppSettings>().setHideContactsWithoutPhone(v),
        title: const Text(
          'Hide contacts without phone numbers',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          'Contacts with only emails or addresses won\'t show in the main list',
          style: TextStyle(color: colors.mutedText, fontSize: 13),
        ),
      ),
    );
  }
}
