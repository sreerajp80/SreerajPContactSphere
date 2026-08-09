// lib/screens/typography_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

/// Configuration screen for Font family and Text size scale settings.
class TypographySettingsScreen extends StatelessWidget {
  const TypographySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();

    return Scaffold(
      appBar: AppBar(title: const Text('Typography & Text Size')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          _label(context, 'FONT'),
          const SizedBox(height: 10),
          for (final font in AppFont.values) ...[
            _FontTile(
              font: font,
              selected: settings.appFont == font,
              onTap: () => context.read<AppSettings>().setAppFont(font),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 18),
          _label(context, 'TEXT SIZE'),
          const SizedBox(height: 10),
          SegmentedButton<AppTextScale>(
            segments: [
              for (final scale in AppTextScale.values)
                ButtonSegment(value: scale, label: Text(scale.label)),
            ],
            selected: {settings.appTextScale},
            showSelectedIcon: false,
            onSelectionChanged: (s) =>
                context.read<AppSettings>().setAppTextScale(s.first),
          ),
        ],
      ),
    );
  }

  Widget _label(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.labelLarge?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
      ),
    );
  }
}

class _FontTile extends StatelessWidget {
  final AppFont font;
  final bool selected;
  final VoidCallback onTap;

  const _FontTile({
    required this.font,
    required this.selected,
    required this.onTap,
  });

  static const String _englishSample = 'The quick brown fox • 0123';
  static const String _malayalamSample = 'മലയാളം സുന്ദരമാണ്';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final accent = theme.colorScheme.primary;
    final family = font.family;

    return Material(
      color: colors.cardSurface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? accent
                  : theme.dividerColor.withValues(alpha: 0.4),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      font.label,
                      style: TextStyle(
                        fontFamily: family,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _englishSample,
                      style: TextStyle(
                        fontFamily: family,
                        fontSize: 14,
                        color: colors.mutedText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _malayalamSample,
                      style: TextStyle(
                        fontFamily: family,
                        fontSize: 16,
                        color: colors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected ? accent : colors.mutedText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
