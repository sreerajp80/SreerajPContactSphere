// lib/screens/features_screen.dart
import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

/// One feature item displayed on the Features screen.
class _AppFeature {
  final String title;
  final String description;
  final IconData icon;
  final List<String> highlights;

  const _AppFeature({
    required this.title,
    required this.description,
    required this.icon,
    required this.highlights,
  });
}

/// A category grouping related features.
class _FeatureCategory {
  final String name;
  final String subtitle;
  final IconData icon;
  final List<_AppFeature> features;

  const _FeatureCategory({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.features,
  });
}

/// Lists all features of ContactSphere, grouped by category with visual cards.
class FeaturesScreen extends StatelessWidget {
  const FeaturesScreen({super.key});

  /// The feature catalog in the app's language. Built per call rather than
  /// held as a const list, because every string comes from the ARB.
  static List<_FeatureCategory> _categoriesFor(AppLocalizations l) => [
    _FeatureCategory(
      name: l.featureC0Name,
      subtitle: l.featureC0Subtitle,
      icon: Icons.dialpad_outlined,
      features: [
        _AppFeature(
          title: l.featureC0F0Title,
          description: l.featureC0F0Desc,
          icon: Icons.grid_3x3_outlined,
          highlights: [l.featureC0F0H0, l.featureC0F0H1, l.featureC0F0H2],
        ),
        _AppFeature(
          title: l.featureC0F1Title,
          description: l.featureC0F1Desc,
          icon: Icons.touch_app_outlined,
          highlights: [l.featureC0F1H0, l.featureC0F1H1, l.featureC0F1H2],
        ),
        _AppFeature(
          title: l.featureC0F2Title,
          description: l.featureC0F2Desc,
          icon: Icons.mic_none_outlined,
          highlights: [l.featureC0F2H0, l.featureC0F2H1, l.featureC0F2H2],
        ),
        _AppFeature(
          title: l.featureC0F3Title,
          description: l.featureC0F3Desc,
          icon: Icons.edit_note_outlined,
          highlights: [l.featureC0F3H0, l.featureC0F3H1, l.featureC0F3H2],
        ),
        _AppFeature(
          title: l.featureC0F4Title,
          description: l.featureC0F4Desc,
          icon: Icons.star_outline,
          highlights: [l.featureC0F4H0, l.featureC0F4H1, l.featureC0F4H2],
        ),
        _AppFeature(
          title: l.featureC0F5Title,
          description: l.featureC0F5Desc,
          icon: Icons.sim_card_outlined,
          highlights: [
            l.featureC0F5H0,
            l.featureC0F5H1,
            l.featureC0F5H2,
            l.featureC0F5H3,
          ],
        ),
        _AppFeature(
          title: l.featureC0F6Title,
          description: l.featureC0F6Desc,
          icon: Icons.replay_outlined,
          highlights: [l.featureC0F6H0, l.featureC0F6H1, l.featureC0F6H2],
        ),
        _AppFeature(
          title: l.featureC0F7Title,
          description: l.featureC0F7Desc,
          icon: Icons.record_voice_over_outlined,
          highlights: [l.featureC0F7H0, l.featureC0F7H1, l.featureC0F7H2],
        ),
        _AppFeature(
          title: l.featureC0F8Title,
          description: l.featureC0F8Desc,
          icon: Icons.sms_outlined,
          highlights: [l.featureC0F8H0, l.featureC0F8H1, l.featureC0F8H2],
        ),
      ],
    ),
    _FeatureCategory(
      name: l.featureC1Name,
      subtitle: l.featureC1Subtitle,
      icon: Icons.person_search_outlined,
      features: [
        _AppFeature(
          title: l.featureC1F0Title,
          description: l.featureC1F0Desc,
          icon: Icons.call_end_outlined,
          highlights: [
            l.featureC1F0H0,
            l.featureC1F0H1,
            l.featureC1F0H2,
            l.featureC1F0H3,
          ],
        ),
        _AppFeature(
          title: l.featureC1F1Title,
          description: l.featureC1F1Desc,
          icon: Icons.badge_outlined,
          highlights: [l.featureC1F1H0, l.featureC1F1H1, l.featureC1F1H2],
        ),
        _AppFeature(
          title: l.featureC1F2Title,
          description: l.featureC1F2Desc,
          icon: Icons.analytics_outlined,
          highlights: [l.featureC1F2H0, l.featureC1F2H1, l.featureC1F2H2],
        ),
        _AppFeature(
          title: l.featureC1F3Title,
          description: l.featureC1F3Desc,
          icon: Icons.note_alt_outlined,
          highlights: [l.featureC1F3H0, l.featureC1F3H1, l.featureC1F3H2],
        ),
      ],
    ),
    _FeatureCategory(
      name: l.featureC2Name,
      subtitle: l.featureC2Subtitle,
      icon: Icons.people_alt_outlined,
      features: [
        _AppFeature(
          title: l.featureC2F0Title,
          description: l.featureC2F0Desc,
          icon: Icons.account_circle_outlined,
          highlights: [l.featureC2F0H0, l.featureC2F0H1, l.featureC2F0H2],
        ),
        _AppFeature(
          title: l.featureC2F1Title,
          description: l.featureC2F1Desc,
          icon: Icons.hub_outlined,
          highlights: [l.featureC2F1H0, l.featureC2F1H1, l.featureC2F1H2],
        ),
        _AppFeature(
          title: l.featureC2F2Title,
          description: l.featureC2F2Desc,
          icon: Icons.bedtime_outlined,
          highlights: [l.featureC2F2H0, l.featureC2F2H1, l.featureC2F2H2],
        ),
        _AppFeature(
          title: l.featureC2F3Title,
          description: l.featureC2F3Desc,
          icon: Icons.label_outline,
          highlights: [l.featureC2F3H0, l.featureC2F3H1, l.featureC2F3H2],
        ),
        _AppFeature(
          title: l.featureC2F4Title,
          description: l.featureC2F4Desc,
          icon: Icons.merge_type_outlined,
          highlights: [l.featureC2F4H0, l.featureC2F4H1, l.featureC2F4H2],
        ),
        _AppFeature(
          title: l.featureC2F5Title,
          description: l.featureC2F5Desc,
          icon: Icons.timer_outlined,
          highlights: [l.featureC2F5H0, l.featureC2F5H1, l.featureC2F5H2],
        ),
        _AppFeature(
          title: l.featureC2F6Title,
          description: l.featureC2F6Desc,
          icon: Icons.apps_outlined,
          highlights: [l.featureC2F6H0, l.featureC2F6H1, l.featureC2F6H2],
        ),
      ],
    ),
    _FeatureCategory(
      name: l.featureC3Name,
      subtitle: l.featureC3Subtitle,
      icon: Icons.shield_outlined,
      features: [
        _AppFeature(
          title: l.featureC3F0Title,
          description: l.featureC3F0Desc,
          icon: Icons.lock_outline,
          highlights: [l.featureC3F0H0, l.featureC3F0H1, l.featureC3F0H2],
        ),
        _AppFeature(
          title: l.featureC3F1Title,
          description: l.featureC3F1Desc,
          icon: Icons.fingerprint,
          highlights: [l.featureC3F1H0, l.featureC3F1H1, l.featureC3F1H2],
        ),
        _AppFeature(
          title: l.featureC3F2Title,
          description: l.featureC3F2Desc,
          icon: Icons.screenshot_outlined,
          highlights: [l.featureC3F2H0, l.featureC3F2H1, l.featureC3F2H2],
        ),
        _AppFeature(
          title: l.featureC3F3Title,
          description: l.featureC3F3Desc,
          icon: Icons.history_edu_outlined,
          highlights: [l.featureC3F3H0, l.featureC3F3H1, l.featureC3F3H2],
        ),
      ],
    ),
    _FeatureCategory(
      name: l.featureC4Name,
      subtitle: l.featureC4Subtitle,
      icon: Icons.qr_code_scanner_outlined,
      features: [
        _AppFeature(
          title: l.featureC4F0Title,
          description: l.featureC4F0Desc,
          icon: Icons.qr_code_2_outlined,
          highlights: [l.featureC4F0H0, l.featureC4F0H1, l.featureC4F0H2],
        ),
        _AppFeature(
          title: l.featureC4F1Title,
          description: l.featureC4F1Desc,
          icon: Icons.sensors,
          highlights: [l.featureC4F1H0, l.featureC4F1H1, l.featureC4F1H2],
        ),
        _AppFeature(
          title: l.featureC4F2Title,
          description: l.featureC4F2Desc,
          icon: Icons.document_scanner_outlined,
          highlights: [l.featureC4F2H0, l.featureC4F2H1, l.featureC4F2H2],
        ),
        _AppFeature(
          title: l.featureC4F3Title,
          description: l.featureC4F3Desc,
          icon: Icons.bluetooth_outlined,
          highlights: [l.featureC4F3H0, l.featureC4F3H1, l.featureC4F3H2],
        ),
        _AppFeature(
          title: l.featureC4F4Title,
          description: l.featureC4F4Desc,
          icon: Icons.import_export_outlined,
          highlights: [l.featureC4F4H0, l.featureC4F4H1, l.featureC4F4H2],
        ),
      ],
    ),
    _FeatureCategory(
      name: l.featureC5Name,
      subtitle: l.featureC5Subtitle,
      icon: Icons.cloud_sync_outlined,
      features: [
        _AppFeature(
          title: l.featureC5F0Title,
          description: l.featureC5F0Desc,
          icon: Icons.sync,
          highlights: [l.featureC5F0H0, l.featureC5F0H1, l.featureC5F0H2],
        ),
        _AppFeature(
          title: l.featureC5F1Title,
          description: l.featureC5F1Desc,
          icon: Icons.wifi_tethering,
          highlights: [l.featureC5F1H0, l.featureC5F1H1, l.featureC5F1H2],
        ),
        _AppFeature(
          title: l.featureC5F2Title,
          description: l.featureC5F2Desc,
          icon: Icons.cloud_outlined,
          highlights: [l.featureC5F2H0, l.featureC5F2H1, l.featureC5F2H2],
        ),
        _AppFeature(
          title: l.featureC5F3Title,
          description: l.featureC5F3Desc,
          icon: Icons.backup_outlined,
          highlights: [l.featureC5F3H0, l.featureC5F3H1, l.featureC5F3H2],
        ),
      ],
    ),
    _FeatureCategory(
      name: l.featureC6Name,
      subtitle: l.featureC6Subtitle,
      icon: Icons.shield_outlined,
      features: [
        _AppFeature(
          title: l.featureC6F0Title,
          description: l.featureC6F0Desc,
          icon: Icons.phone_disabled_outlined,
          highlights: [l.featureC6F0H0, l.featureC6F0H1, l.featureC6F0H2],
        ),
        _AppFeature(
          title: l.featureC6F1Title,
          description: l.featureC6F1Desc,
          icon: Icons.block_outlined,
          highlights: [l.featureC6F1H0, l.featureC6F1H1, l.featureC6F1H2],
        ),
        _AppFeature(
          title: l.featureC6F2Title,
          description: l.featureC6F2Desc,
          icon: Icons.no_accounts_outlined,
          highlights: [l.featureC6F2H0, l.featureC6F2H1, l.featureC6F2H2],
        ),
        _AppFeature(
          title: l.featureC6F3Title,
          description: l.featureC6F3Desc,
          icon: Icons.label_outline,
          highlights: [l.featureC6F3H0, l.featureC6F3H1, l.featureC6F3H2],
        ),
      ],
    ),
    _FeatureCategory(
      name: l.featureC7Name,
      subtitle: l.featureC7Subtitle,
      icon: Icons.palette_outlined,
      features: [
        _AppFeature(
          title: l.featureC7F0Title,
          description: l.featureC7F0Desc,
          icon: Icons.color_lens_outlined,
          highlights: [l.featureC7F0H0, l.featureC7F0H1, l.featureC7F0H2],
        ),
        _AppFeature(
          title: l.featureC7F1Title,
          description: l.featureC7F1Desc,
          icon: Icons.notifications_active_outlined,
          highlights: [l.featureC7F1H0, l.featureC7F1H1, l.featureC7F1H2],
        ),
        _AppFeature(
          title: l.featureC7F2Title,
          description: l.featureC7F2Desc,
          icon: Icons.medical_information_outlined,
          highlights: [l.featureC7F2H0, l.featureC7F2H1, l.featureC7F2H2],
        ),
        _AppFeature(
          title: l.featureC7F3Title,
          description: l.featureC7F3Desc,
          icon: Icons.public_outlined,
          highlights: [l.featureC7F3H0, l.featureC7F3H1, l.featureC7F3H2],
        ),
        _AppFeature(
          title: l.featureC7F4Title,
          description: l.featureC7F4Desc,
          icon: Icons.manage_search_outlined,
          highlights: [l.featureC7F4H0, l.featureC7F4H1, l.featureC7F4H2],
        ),
        _AppFeature(
          title: l.featureC7F5Title,
          description: l.featureC7F5Desc,
          icon: Icons.help_center_outlined,
          highlights: [l.featureC7F5H0, l.featureC7F5H1, l.featureC7F5H2],
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).titleFeatures)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _buildHeaderCard(context, colors),
          const SizedBox(height: 20),
          for (final category in _categoriesFor(
            AppLocalizations.of(context),
          )) ...[
            _buildCategoryHeader(context, category, colors),
            const SizedBox(height: 10),
            _buildCategoryCard(context, category, colors),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, AppColors colors) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.12),
              theme.colorScheme.secondary.withValues(alpha: 0.04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: colors.brandGradient,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: colors.gradientStart.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.stars_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).titleFeaturesHeader,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context).descFeaturesHeader,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.mutedText,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(
    BuildContext context,
    _FeatureCategory category,
    AppColors colors,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(category.icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                category.name.toUpperCase(),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            category.subtitle,
            style: theme.textTheme.bodySmall?.copyWith(color: colors.mutedText),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    _FeatureCategory category,
    AppColors colors,
  ) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < category.features.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: colors.mutedText.withValues(alpha: 0.18),
              ),
            _buildFeatureTile(context, category.features[i], colors),
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureTile(
    BuildContext context,
    _AppFeature feature,
    AppColors colors,
  ) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(feature.icon, color: accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feature.description,
                  style: TextStyle(
                    color: colors.mutedText,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                if (feature.highlights.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: feature.highlights.map((h) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: accent.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          h,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: accent,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
