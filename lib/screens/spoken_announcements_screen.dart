// lib/screens/spoken_announcements_screen.dart
import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_contacts_dialer/services/telecom_service.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

/// Configuration screen for Spoken Caller Announcements (English & Malayalam).
class SpokenAnnouncementsScreen extends StatefulWidget {
  const SpokenAnnouncementsScreen({super.key});

  @override
  State<SpokenAnnouncementsScreen> createState() =>
      _SpokenAnnouncementsScreenState();
}

class _SpokenAnnouncementsScreenState extends State<SpokenAnnouncementsScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final settings = context.watch<AppSettings>();
    final accent = Theme.of(context).colorScheme.primary;
    final enabled = settings.spokenCallerAnnouncementEnabled;
    final quietHours = settings.spokenCallerQuietHoursEnabled;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).titleSpokenAnnouncement),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 2,
                    ),
                    value: enabled,
                    activeThumbColor: accent,
                    onChanged: (v) => context
                        .read<AppSettings>()
                        .setSpokenCallerAnnouncementEnabled(v),
                    title: Text(
                      AppLocalizations.of(context).labelSpokenAnnouncement,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      AppLocalizations.of(context).descSpokenAnnouncementSwitch,
                      style: TextStyle(color: colors.mutedText, fontSize: 13),
                    ),
                  ),
                  if (enabled) ...[
                    const Divider(height: 1),
                    SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 2,
                      ),
                      value: quietHours,
                      activeThumbColor: accent,
                      onChanged: (v) => context
                          .read<AppSettings>()
                          .setSpokenCallerQuietHoursEnabled(v),
                      title: Text(
                        AppLocalizations.of(context).featureC0F7H2,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        AppLocalizations.of(context).descSuppressDuringQuiet,
                        style: TextStyle(
                          color: colors.mutedText,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                    if (quietHours)
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        leading: Icon(Icons.bedtime_outlined, color: accent),
                        title: Text(
                          AppLocalizations.of(context).labelQuietHoursRange,
                        ),
                        trailing: Text(
                          '${settings.spokenCallerQuietHoursStart} – ${settings.spokenCallerQuietHoursEnd}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: accent,
                          ),
                        ),
                        onTap: () => _showQuietHoursPicker(settings),
                      ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      leading: Icon(
                        Icons.record_voice_over_outlined,
                        color: accent,
                      ),
                      title: Text(
                        AppLocalizations.of(context).labelTestAnnouncement,
                      ),
                      subtitle: Text(
                        AppLocalizations.of(context).descTestAnnouncement,
                        style: TextStyle(
                          color: colors.mutedText,
                          fontSize: 12.5,
                        ),
                      ),
                      onTap: _showTestAnnouncementDialog,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showQuietHoursPicker(AppSettings settings) async {
    final startParts = settings.spokenCallerQuietHoursStart
        .split(':')
        .map((e) => int.tryParse(e) ?? 0)
        .toList();
    final endParts = settings.spokenCallerQuietHoursEnd
        .split(':')
        .map((e) => int.tryParse(e) ?? 0)
        .toList();

    final startTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: startParts[0],
        minute: startParts.length > 1 ? startParts[1] : 0,
      ),
      helpText: AppLocalizations.of(context).hintQuietStartTimeGeneric,
    );
    if (startTime == null || !mounted) return;

    final endTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: endParts[0],
        minute: endParts.length > 1 ? endParts[1] : 0,
      ),
      helpText: AppLocalizations.of(context).hintQuietEndTimeGeneric,
    );
    if (endTime == null || !mounted) return;

    final formattedStart =
        '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final formattedEnd =
        '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

    settings.setSpokenCallerQuietHoursRange(formattedStart, formattedEnd);
  }

  void _showTestAnnouncementDialog() {
    final controller = TextEditingController(text: 'Amma');
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context).labelTestAnnouncement),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context).descEnterCallerNameToTest),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).hintCallerNameExample,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  label: const Text('Amma (English)'),
                  onPressed: () => controller.text = 'Amma',
                ),
                ActionChip(
                  label: const Text('അമ്മ (Malayalam)'),
                  onPressed: () => controller.text = 'അമ്മ',
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          FilledButton.icon(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                TelecomService().previewCallerAnnouncement(name);
              }
              Navigator.pop(ctx);
            },
            icon: const Icon(Icons.volume_up),
            label: Text(AppLocalizations.of(context).actionPlayTest),
          ),
        ],
      ),
    );
  }
}
