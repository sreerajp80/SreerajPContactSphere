// lib/screens/identification_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
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
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).labelIdentification),
      ),
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
              title: Text(
                AppLocalizations.of(context).labelCallerIdentification,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(
                AppLocalizations.of(context).descCallerIdentification,
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
              title: Text(
                AppLocalizations.of(context).labelFilterSuspectedSpam,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(
                AppLocalizations.of(context).descFilterSpam,
                style: TextStyle(color: colors.mutedText, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _howItWorksCard(context, colors),
        ],
      ),
    );
  }

  /// Honest explanation of where identification comes from (and doesn't).
  Widget _howItWorksCard(BuildContext context, AppColors colors) {
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
                Text(
                  AppLocalizations.of(context).labelHowIdentificationWorks,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context).descHowIdentificationWorks,
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
