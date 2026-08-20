// lib/screens/features_screen.dart
import 'package:flutter/material.dart';

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

  static const List<_FeatureCategory> _categories = [
    _FeatureCategory(
      name: 'Smart Dialer & Call Management',
      subtitle: 'Effortless calling and intelligent keypad search',
      icon: Icons.dialpad_outlined,
      features: [
        _AppFeature(
          title: 'T9 Keypad Search',
          description:
              'Instantly search contacts by name or number using standard T9 '
              'keypad text spelling.',
          icon: Icons.grid_3x3_outlined,
          highlights: ['Malayalam support', 'Smart stem matching', 'Speed dial'],
        ),
        _AppFeature(
          title: 'Smart Redial & "Reach Me" Mode',
          description:
              'Automatically schedule retry timers or send a preset "trying to reach you" SMS when calls go unanswered.',
          icon: Icons.replay_outlined,
          highlights: ['Auto-retry timer', '1-tap SMS prompt', 'Custom delay picker'],
        ),
        _AppFeature(
          title: 'In-Call UI & Controls',
          description:
              'Full-featured custom in-call interface with mute, speaker, '
              'keypad, hold, call swap, and conference call capabilities.',
          icon: Icons.call_end_outlined,
          highlights: [
            'System role integration',
            'Conference call hub',
            'Full-screen incoming alert'
          ],
        ),
        _AppFeature(
          title: 'Editable Dialer & Precision Editing',
          description:
              'Select, copy, paste numbers directly in dialer input with full cursor control and clear history safeguards.',
          icon: Icons.edit_note_outlined,
          highlights: ['Text selection', 'Copy/paste support', 'Clear history safety'],
        ),
        _AppFeature(
          title: 'Top Dialer Contacts',
          description:
              'Customize your top dialer contacts row with either your most '
              'frequent recents or linked family & friends.',
          icon: Icons.star_outline,
          highlights: ['Recency scoring', 'Family & friends filter'],
        ),
      ],
    ),
    _FeatureCategory(
      name: 'Caller Context & Notes',
      subtitle: 'Know who is calling before and during every call',
      icon: Icons.person_search_outlined,
      features: [
        _AppFeature(
          title: 'Relationship Context Cards',
          description:
              'Displays live caller relationships, last contact time, notes, '
              'and upcoming events right on incoming and in-call screens.',
          icon: Icons.badge_outlined,
          highlights: ['Relationship badges', 'Last contact time', 'Pending follow-ups'],
        ),
        _AppFeature(
          title: 'Pre-Call & Caller Intelligence',
          description:
              'Smart caller profile scoring with interaction stats, call frequency, and automated follow-up prompts.',
          icon: Icons.analytics_outlined,
          highlights: ['Caller scoring', 'Interaction history', 'Follow-up alerts'],
        ),
        _AppFeature(
          title: 'Contact Notes & Voice Input',
          description:
              'Attach detailed text or voice-transcribed notes to any contact for quick recall.',
          icon: Icons.note_alt_outlined,
          highlights: ['Voice-to-text input', 'Quick notes timeline'],
        ),
      ],
    ),
    _FeatureCategory(
      name: 'Contact Sync & Privacy',
      subtitle: 'Complete control over your contacts and privacy',
      icon: Icons.security_outlined,
      features: [
        _AppFeature(
          title: 'Device Book & Call Log Sync',
          description:
              'Bi-directional synchronization between local SQLite storage, system Android contacts, and device call logs.',
          icon: Icons.sync,
          highlights: ['Auto sync', 'Duplicate linking', 'Call log import'],
        ),
        _AppFeature(
          title: 'Secret Contacts & App Lock',
          description:
              'Hide sensitive contacts behind biometric (fingerprint/face) or custom app PIN protection.',
          icon: Icons.lock_outline,
          highlights: ['Biometric unlock', 'Custom app PIN', 'Encrypted local DB'],
        ),
        _AppFeature(
          title: 'Emergency Info Card',
          description:
              'Blood group, allergies and people to call, readable on the lock screen without your PIN. Off by default, with a separate switch for every line.',
          icon: Icons.medical_information_outlined,
          highlights: ['No unlock needed', 'Per-field opt-in', 'Call from lock screen'],
        ),
      ],
    ),
    _FeatureCategory(
      name: 'Sync & Backup',
      subtitle: 'Keep your data safe and connected across devices',
      icon: Icons.cloud_sync_outlined,
      features: [
        _AppFeature(
          title: 'Local Wi-Fi P2P Sync',
          description:
              'Sync contacts directly device-to-device over encrypted local Wi-Fi without cloud servers.',
          icon: Icons.wifi_tethering,
          highlights: ['End-to-end encryption', 'QR pairing', 'No cloud dependency'],
        ),
        _AppFeature(
          title: 'Offline Backup & Restore',
          description:
              'Export full database backups to protected files and restore anytime.',
          icon: Icons.backup_outlined,
          highlights: ['Encrypted backups', 'JSON format', 'Biometric protected'],
        ),
      ],
    ),
    _FeatureCategory(
      name: 'Call Screening & Defense',
      subtitle: 'Protection against unwanted callers and spam',
      icon: Icons.shield_outlined,
      features: [
        _AppFeature(
          title: 'Native Call Screening & Blocking',
          description:
              'Automatic background call screening service filtering blocked numbers and unknown callers before ringing.',
          icon: Icons.block_outlined,
          highlights: ['Background screening', 'Spam detection', 'Blocked list manager'],
        ),
      ],
    ),
    _FeatureCategory(
      name: 'Contact Exchange',
      subtitle: 'Share contact information easily',
      icon: Icons.qr_code_scanner_outlined,
      features: [
        _AppFeature(
          title: 'QR Code Sharing & Scanner',
          description:
              'Generate vCard QR codes for quick sharing and scan codes with built-in camera scanner.',
          icon: Icons.qr_code_2_outlined,
          highlights: ['Instant vCard QR', 'Built-in scanner', 'Direct import'],
        ),
        _AppFeature(
          title: 'Business Card Scanner',
          description:
              'Photograph a paper business card and get a prefilled new contact, read entirely on this phone.',
          icon: Icons.badge_outlined,
          highlights: ['On-device OCR', 'Tick what to keep', 'No cloud upload'],
        ),
        _AppFeature(
          title: 'Bluetooth LE Share',
          description:
              'Discover nearby SreerajP Contacts Sphere devices and send contacts over Bluetooth Low Energy.',
          icon: Icons.bluetooth_outlined,
          highlights: ['BLE discovery', 'Zero pairing hassle', 'Secure payload'],
        ),
      ],
    ),
    _FeatureCategory(
      name: 'Personalization & Settings',
      subtitle: 'Tailor the app look, ringtones, permissions and calling options',
      icon: Icons.palette_outlined,
      features: [
        _AppFeature(
          title: 'Theme & Font Engine',
          description:
              'Dynamic light and dark themes with custom accent color palette and typography selection.',
          icon: Icons.color_lens_outlined,
          highlights: ['Dark mode', 'Custom accent color', 'Glassmorphic design'],
        ),
        _AppFeature(
          title: 'SIM & Ringtone Controls',
          description:
              'Multi-SIM selection, custom ringtones per contact group, and granular audio controls.',
          icon: Icons.sim_card_outlined,
          highlights: ['Dual-SIM routing', 'Group ringtones', 'Volume & vibration'],
        ),
        _AppFeature(
          title: 'Permissions & Features Explorer',
          description:
              'Transparent management of system permissions and quick access to feature guides.',
          icon: Icons.admin_panel_settings_outlined,
          highlights: ['Permission status', 'Feature discovery', 'Granular control'],
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Features'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _buildHeaderCard(context, colors),
          const SizedBox(height: 20),
          for (final category in _categories) ...[
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
                    'SreerajP Contacts Sphere Features',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Explore the powerful capabilities built into your intelligent dialer & contacts assistant.',
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
              Icon(
                category.icon,
                size: 18,
                color: theme.colorScheme.primary,
              ),
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
