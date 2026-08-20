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
      name: 'Smart Dialer & Calling',
      subtitle: 'Fast T9 search, dual-SIM controls, and intelligent calling tools',
      icon: Icons.dialpad_outlined,
      features: [
        _AppFeature(
          title: 'Multi-Script T9 Keypad Search',
          description:
              'Search contacts in milliseconds by typing numbers or letters on the dialpad. Fully supports English, Malayalam (including vowels & chillu letters), Devanagari, and more.',
          icon: Icons.grid_3x3_outlined,
          highlights: ['English & Malayalam', 'Multi-script transliteration', 'Speed dial shortcuts'],
        ),
        _AppFeature(
          title: 'Editable Dialer & Precision Editing',
          description:
              'Freely tap anywhere on the typed number to move your cursor, select digits, copy, or paste phone numbers with ease.',
          icon: Icons.edit_note_outlined,
          highlights: ['Cursor positioning', 'Paste numbers', 'Clear dialer safeguard'],
        ),
        _AppFeature(
          title: 'Top Contacts Quick Access',
          description:
              'A handy row right above the dialer showing either your most frequently called contacts or favorite family and friends for 1-tap calling.',
          icon: Icons.star_outline,
          highlights: ['Frequency scoring', 'Family & friends filter', '1-tap call'],
        ),
        _AppFeature(
          title: 'Dual-SIM Calling Controls',
          description:
              'Effortlessly choose between SIM 1 and SIM 2 for each call, or set a preferred default SIM for individual contacts.',
          icon: Icons.sim_card_outlined,
          highlights: ['SIM 1 / SIM 2 picker', 'Per-contact default SIM', 'SIM usage history'],
        ),
        _AppFeature(
          title: 'Smart Redial & "Reach Me" Mode',
          description:
              'When a call goes unanswered or busy, schedule automated redial reminders or send a friendly 1-tap "trying to reach you" SMS text.',
          icon: Icons.replay_outlined,
          highlights: ['Auto-retry timer', '1-tap SMS prompt', 'Custom retry intervals'],
        ),
        _AppFeature(
          title: 'Spoken Caller Announcements',
          description:
              'Hear the caller\'s name or phone number spoken out loud when your phone rings, perfect when driving or wearing headphones.',
          icon: Icons.record_voice_over_outlined,
          highlights: ['Voice caller ID', 'Custom prefix/suffix', 'Headset-only option'],
        ),
        _AppFeature(
          title: 'Quick Reject SMS Replies',
          description:
              'Decline incoming calls politely with preset one-tap SMS messages like "In a meeting, will call back soon."',
          icon: Icons.sms_outlined,
          highlights: ['1-tap decline SMS', 'Custom quick templates', 'Instant dispatch'],
        ),
      ],
    ),
    _FeatureCategory(
      name: 'In-Call & Caller Intelligence',
      subtitle: 'Know who is calling with rich context and seamless call controls',
      icon: Icons.person_search_outlined,
      features: [
        _AppFeature(
          title: 'Modern In-Call Screen & Conference Calling',
          description:
              'A beautiful call screen with mute, loud speaker, call hold, numeric keypad, active call swapping, and merging multi-party conference calls.',
          icon: Icons.call_end_outlined,
          highlights: ['Speaker & mute', 'Call hold & swap', 'Conference merge', 'Full-screen incoming alert'],
        ),
        _AppFeature(
          title: 'Relationship Context Cards',
          description:
              'See the caller\'s relationship badge, how long since you last spoke, personal notes, and upcoming birthdays right as the phone rings.',
          icon: Icons.badge_outlined,
          highlights: ['Relationship badge', 'Last spoken days', 'Instant notes preview'],
        ),
        _AppFeature(
          title: 'Pre-Call Intelligence & Reminders',
          description:
              'Helpful reminders and statistics about how often you stay in touch, prompting you to follow up with loved ones and colleagues.',
          icon: Icons.analytics_outlined,
          highlights: ['Catch-up reminders', 'Interaction statistics', 'Call history trends'],
        ),
        _AppFeature(
          title: 'Post-Call Notes & Voice Transcribing',
          description:
              'Quickly jot down what you discussed right after hanging up using your keyboard or speaking aloud with automatic voice-to-text.',
          icon: Icons.note_alt_outlined,
          highlights: ['Voice-to-text input', 'Post-call prompt', 'Interaction timeline'],
        ),
      ],
    ),
    _FeatureCategory(
      name: 'Contact Management & Relations',
      subtitle: 'Organize your network into meaningful spheres and circles',
      icon: Icons.people_alt_outlined,
      features: [
        _AppFeature(
          title: 'Rich Contact Profiles',
          description:
              'Store multiple phone numbers, emails, home/work addresses, birthdays, anniversaries, social links, phonetic names, and custom fields.',
          icon: Icons.account_circle_outlined,
          highlights: ['Multi-phone & email', 'Birthday reminders', 'Custom labels & fields'],
        ),
        _AppFeature(
          title: '7 Relationship Spheres',
          description:
              'Group your contacts into 7 intuitive spheres: Family, Close Friends, Friends, Work, Professional, Acquaintance, and Services.',
          icon: Icons.hub_outlined,
          highlights: ['Sphere grouping', 'Custom kinship labels', 'Visual sphere badges'],
        ),
        _AppFeature(
          title: 'Relationship Quiet Hours (DND Filter)',
          description:
              'Silence calls during sleep or work hours while allowing vital circles (like immediate Family or Close Friends) to ring through.',
          icon: Icons.bedtime_outlined,
          highlights: ['Custom quiet schedules', 'VIP circle bypass', 'Per-sphere quiet rules'],
        ),
        _AppFeature(
          title: 'Color Tags & Custom Groups',
          description:
              'Assign colorful tags and create custom groups (like "Project Team" or "Book Club") for quick filtering and bulk actions.',
          icon: Icons.label_outline,
          highlights: ['Color-coded tags', 'Custom groups', 'Tag cloud explorer'],
        ),
        _AppFeature(
          title: 'Duplicate Contact Finder & Smart Merge',
          description:
              'Automatically detect duplicate contacts by matching names, phone numbers, or emails, and merge them cleanly without losing any data.',
          icon: Icons.merge_type_outlined,
          highlights: ['Smart match detection', 'Safe data merge', 'Preview before merging'],
        ),
      ],
    ),
    _FeatureCategory(
      name: 'Privacy, Security & Vault',
      subtitle: 'Protect your sensitive contacts and private conversations',
      icon: Icons.shield_outlined,
      features: [
        _AppFeature(
          title: 'Secret Contacts Vault',
          description:
              'Hide sensitive personal or business contacts in a protected vault. They are completely invisible in the main list until unlocked.',
          icon: Icons.lock_outline,
          highlights: ['Biometric / PIN unlock', 'Hidden from main list', 'Encrypted database'],
        ),
        _AppFeature(
          title: 'Biometric & App PIN Lock',
          description:
              'Lock the entire app or private sections using your phone\'s fingerprint, face unlock, or a custom app security PIN.',
          icon: Icons.fingerprint,
          highlights: ['Fingerprint & Face unlock', 'App PIN fallback', 'Automatic re-lock'],
        ),
        _AppFeature(
          title: 'Screenshot Guard',
          description:
              'Prevents other apps or users from taking screenshots or recording video while viewing secret contacts and security settings.',
          icon: Icons.screenshot_outlined,
          highlights: ['Screenshot blocking', 'Screen recording defense', 'Privacy toggle'],
        ),
        _AppFeature(
          title: 'Security Audit Log',
          description:
              'Keeps a private, tamper-proof history of every time secret contacts, exports, or security settings were accessed.',
          icon: Icons.history_edu_outlined,
          highlights: ['Access timestamps', 'Action breakdown', 'Full transparency'],
        ),
      ],
    ),
    _FeatureCategory(
      name: 'Instant Contact Sharing & Scanning',
      subtitle: 'Exchange contact cards quickly without typing',
      icon: Icons.qr_code_scanner_outlined,
      features: [
        _AppFeature(
          title: 'vCard QR Code Generator & Scanner',
          description:
              'Create a QR code of your contact card for others to scan in seconds, or use the camera to scan and save anyone\'s QR contact card.',
          icon: Icons.qr_code_2_outlined,
          highlights: ['Instant QR vCard', 'Built-in camera scanner', '1-tap address book import'],
        ),
        _AppFeature(
          title: 'On-Device Business Card Scanner',
          description:
              'Snap a photo of any physical business card to extract name, phone, email, and company details instantly—all processed 100% on your phone without cloud upload.',
          icon: Icons.document_scanner_outlined,
          highlights: ['On-device AI OCR', 'Zero cloud upload', 'Selectable field import'],
        ),
        _AppFeature(
          title: 'Offline Bluetooth LE Share',
          description:
              'Discover nearby ContactSphere devices and send contacts directly over Bluetooth Low Energy without needing internet or pairing codes.',
          icon: Icons.bluetooth_outlined,
          highlights: ['Zero internet required', 'Auto device discovery', 'Fast encrypted transfer'],
        ),
      ],
    ),
    _FeatureCategory(
      name: 'Data Sync & Backup',
      subtitle: 'Keep your contacts safe, synchronized, and recoverable anywhere',
      icon: Icons.cloud_sync_outlined,
      features: [
        _AppFeature(
          title: 'Device Contacts & Call Log Sync',
          description:
              'Two-way synchronization between ContactSphere\'s local database, your phone\'s system contacts, and Android call history.',
          icon: Icons.sync,
          highlights: ['Two-way live sync', 'Call history import', 'Conflict resolution'],
        ),
        _AppFeature(
          title: 'Local Wi-Fi Direct (P2P) Device Sync',
          description:
              'Transfer contacts between two phones on the same Wi-Fi network with end-to-end encryption and zero cloud servers.',
          icon: Icons.wifi_tethering,
          highlights: ['Direct P2P transfer', 'End-to-end encrypted', 'No cloud needed'],
        ),
        _AppFeature(
          title: 'Encrypted Cloud Sync & Google Drive',
          description:
              'Optionally sync contacts and backups to your personal Google Drive or WebDAV cloud storage with password-protected encryption.',
          icon: Icons.cloud_outlined,
          highlights: ['Google Drive & WebDAV', 'Password-encrypted vault', 'Automatic backups'],
        ),
        _AppFeature(
          title: 'Offline Backup & Restore Files',
          description:
              'Export full database backups to protected files and restore them anytime on a new device with password or biometric verification.',
          icon: Icons.backup_outlined,
          highlights: ['Export to file', 'Safe encrypted format', 'One-tap restore'],
        ),
      ],
    ),
    _FeatureCategory(
      name: 'Call Defense & Spam Blocking',
      subtitle: 'Shield yourself from spam calls and unwanted numbers',
      icon: Icons.shield_outlined,
      features: [
        _AppFeature(
          title: 'Automatic Call Screening & Spam Defense',
          description:
              'Built-in call screening service that inspects incoming calls in real-time to silence or drop known spam and blacklisted numbers.',
          icon: Icons.phone_disabled_outlined,
          highlights: ['Real-time screening', 'Silent spam reject', 'Default dialer integration'],
        ),
        _AppFeature(
          title: 'Blocked Numbers Manager',
          description:
              'Easily block any number directly from call history or contact details, and manage your full blocklist in one convenient place.',
          icon: Icons.block_outlined,
          highlights: ['1-tap number blocking', 'Blocklist manager', 'Unblock anytime'],
        ),
      ],
    ),
    _FeatureCategory(
      name: 'Personalization & Accessibility',
      subtitle: 'Customize the appearance, audio, and regional settings to your taste',
      icon: Icons.palette_outlined,
      features: [
        _AppFeature(
          title: 'Theme & Accent Color Engine',
          description:
              'Switch between Light, Dark, or System mode with curated vibrant accent colors and modern glassmorphic visual cards.',
          icon: Icons.color_lens_outlined,
          highlights: ['Dark & Light mode', 'Curated color palettes', 'Modern glass styling'],
        ),
        _AppFeature(
          title: 'Per-SIM & Group Ringtones',
          description:
              'Assign distinctive ringtones and vibration patterns to SIM 1 vs SIM 2, or set special melodies for family and close friends.',
          icon: Icons.notifications_active_outlined,
          highlights: ['Distinct ringtone per SIM', 'Group ringtones', 'Custom vibration styles'],
        ),
        _AppFeature(
          title: 'Emergency Info Lock-Screen Card',
          description:
              'Set vital medical info (blood group, allergies, emergency contacts) visible on your lock screen for first responders without unlocking.',
          icon: Icons.medical_information_outlined,
          highlights: ['Lock-screen access', 'Per-field privacy toggle', 'Direct emergency dial'],
        ),
        _AppFeature(
          title: 'Default Country Dialing Code',
          description:
              'Automatically format local and international phone numbers with your selected default country code for seamless dialing.',
          icon: Icons.public_outlined,
          highlights: ['Auto country prefix', 'International format', 'Smart carrier detection'],
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
                    'Explore every intelligent tool, privacy safeguard, and calling feature designed for you.',
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
