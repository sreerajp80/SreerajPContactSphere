// lib/screens/screenshot_guard_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

/// Configuration screen for Screenshot Guard & Privacy settings.
class ScreenshotGuardSettingsScreen extends StatelessWidget {
  const ScreenshotGuardSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final enabled = context.watch<AppSettings>().screenshotGuardEnabled;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).titleScreenshotGuard),
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
              value: enabled,
              activeThumbColor: theme.colorScheme.primary,
              onChanged: (v) =>
                  context.read<AppSettings>().setScreenshotGuardEnabled(v),
              secondary: const Icon(Icons.screenshot_monitor_outlined),
              title: Text(
                AppLocalizations.of(context).labelBlockScreenshots,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(
                AppLocalizations.of(context).descBlockScreenshots,
                style: TextStyle(color: colors.mutedText, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
