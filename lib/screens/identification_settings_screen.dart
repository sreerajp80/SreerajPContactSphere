// lib/screens/identification_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

/// Caller & spam identification preferences, reached from Settings →
/// SIM & calling. Two independent toggles:
///  - Caller identification: label callers who aren't saved contacts with what
///    can be determined locally (telemarketing / service number series, your
///    spam marks, the network's verification flag).
///  - Filter suspected spam: flagged callers ring silently instead of loudly
///    (enforced by the native call-screening service).
class IdentificationSettingsScreen extends StatelessWidget {
  const IdentificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final accent = Theme.of(context).colorScheme.primary;
    final settings = context.watch<AppSettings>();

    return Scaffold(
      appBar: AppBar(title: const Text('Identification')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              value: settings.callerIdEnabled,
              activeThumbColor: accent,
              onChanged: (v) =>
                  context.read<AppSettings>().setCallerIdEnabled(v),
              title: const Text(
                'Caller identification',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                'Label callers who aren’t in your contacts — telemarketing '
                'and service numbers, numbers you marked as spam',
                style: TextStyle(color: colors.mutedText, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            margin: EdgeInsets.zero,
            child: SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              value: settings.spamFilterEnabled,
              activeThumbColor: accent,
              onChanged: (v) =>
                  context.read<AppSettings>().setSpamFilterEnabled(v),
              title: const Text(
                'Filter suspected spam',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                'Suspected spam calls ring silently. They still appear in '
                'Recents and can be answered',
                style: TextStyle(color: colors.mutedText, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _howItWorksCard(colors),
        ],
      ),
    );
  }

  /// Honest explanation of where identification comes from (and doesn't).
  Widget _howItWorksCard(AppColors colors) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: colors.mutedText, size: 20),
                const SizedBox(width: 10),
                const Text(
                  'How identification works',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Identification happens on your phone — nothing is sent '
              'anywhere. ContactSphere recognises registered telemarketing '
              '(140…) and service (160…) number series, numbers you have '
              'marked as spam from Recents, and shows a warning when your '
              'network reports that a caller’s number could not be verified.\n\n'
              'Mobile networks only deliver the caller’s number, not a name, '
              'so callers outside your contacts can’t be identified by name. '
              'Spam filtering needs ContactSphere to be your default phone '
              'app.',
              style: TextStyle(
                color: colors.mutedText,
                fontSize: 13.5,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
