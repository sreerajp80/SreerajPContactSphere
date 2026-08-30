// lib/screens/about_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:smart_contacts_dialer/core/config/app_config.dart';
import 'package:smart_contacts_dialer/core/config/config_service.dart';
import 'package:smart_contacts_dialer/core/constants/build_date.g.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

/// Shows app metadata driven by `assets/config/app_config.json` (loaded through
/// [ConfigService]). The `details` map is rendered dynamically — adding or
/// removing a key in the JSON is the only change needed (guideline §1.6).
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppConfig>(
      future: ConfigService().loadAndVerify(),
      // Render the fallback while loading so the screen never blocks.
      initialData: AppConfig.fallback,
      builder: (context, snapshot) {
        final config = snapshot.data ?? AppConfig.fallback;
        return _AboutView(config: config);
      },
    );
  }
}

class _AboutView extends StatelessWidget {
  const _AboutView({required this.config});

  final AppConfig config;

  Future<void> _openMail(String address) async {
    final uri = Uri(scheme: 'mailto', path: address.trim());
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final scheme = theme.colorScheme;

    // Fixed top rows (version/build, build date) plus one row per details entry (skip empties).
    final rows = <Widget>[
      _row(
        colors: colors,
        scheme: scheme,
        label: 'Version',
        value: '${config.version} (build ${config.build})',
      ),
      _row(
        colors: colors,
        scheme: scheme,
        label: 'Build Date',
        value: kBuildDate,
      ),
    ];
    for (final entry in config.details.entries) {
      final key = entry.key.trim();
      final value = entry.value.trim();
      if (key.isEmpty || value.isEmpty) continue;
      final isEmail = key.toLowerCase() == 'email';
      rows.add(
        _row(
          colors: colors,
          scheme: scheme,
          label: key,
          value: value,
          onTap: isEmail ? () => _openMail(value) : null,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: colors.brandGradient,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: colors.gradientStart.withValues(alpha: 0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.contacts_rounded,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  config.appName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (config.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    config.description,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.mutedText,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 28),
          Card(
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: colors.mutedText.withValues(alpha: 0.18),
                    ),
                  rows[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row({
    required AppColors colors,
    required ColorScheme scheme,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(label, style: TextStyle(color: colors.mutedText)),
      trailing: Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: onTap != null ? scheme.primary : null,
        ),
      ),
      onTap: onTap,
    );
  }
}
