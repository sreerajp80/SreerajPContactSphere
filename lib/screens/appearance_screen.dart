// lib/screens/appearance_screen.dart
import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/theme/app_theme.dart';
import 'package:smart_contacts_dialer/screens/accent_color_settings_screen.dart';
import 'package:smart_contacts_dialer/screens/theme_mode_settings_screen.dart';
import 'package:smart_contacts_dialer/screens/typography_settings_screen.dart';

/// Appearance preferences hub reached from Settings → Appearance.
class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appearance')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _SettingsSectionCard(
            icon: Icons.brightness_6_outlined,
            title: 'Theme Mode',
            subtitle: 'Choose between Light, Dark, or System mode',
            onTap: () => _push(context, const ThemeModeSettingsScreen()),
          ),
          const SizedBox(height: 12),
          _SettingsSectionCard(
            icon: Icons.font_download_outlined,
            title: 'Typography & Text Size',
            subtitle: 'App font family and text scale preferences',
            onTap: () => _push(context, const TypographySettingsScreen()),
          ),
          const SizedBox(height: 12),
          _SettingsSectionCard(
            icon: Icons.color_lens_outlined,
            title: 'Accent Color',
            subtitle: 'Custom color palette, presets, and live preview',
            onTap: () => _push(context, const AccentColorSettingsScreen()),
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
