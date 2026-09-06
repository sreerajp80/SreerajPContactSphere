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
      subtitle:
          'Fast T9 search, dual-SIM controls, and intelligent calling tools',
      icon: Icons.dialpad_outlined,
      features: [
        _AppFeature(
          title: 'Multi-Script T9 Keypad Search',
          description:
              'Search contacts in milliseconds by typing numbers or letters on the dialpad. Fully supports English, Malayalam (including vowels & chillu letters), Devanagari, and more.',
          icon: Icons.grid_3x3_outlined,
          highlights: [
            'English & Malayalam',
            'Multi-script transliteration',
            'Matches names either way',
          ],
        ),
        _AppFeature(
          title: 'Speed Dial',
          description:
              'Save a person on keypad keys 1 to 9, then hold that key to call them. Holding works when the number box is empty; assigned keys carry a small dot. Secret contacts can never be put on a key.',
          icon: Icons.touch_app_outlined,
          highlights: [
            'Keys 1-9',
            'Hold a key to call',
            'Assign from the keypad or Settings',
          ],
        ),
        _AppFeature(
          title: 'Voice Dial',
          description:
              'Tap the microphone on the dialpad and say a number or a name. Speech is turned into text on your phone, in English or Malayalam, and lead-in words like "call" are dropped automatically.',
          icon: Icons.mic_none_outlined,
          highlights: [
            'Speak a number or a name',
            'English & Malayalam',
            'On-device speech',
          ],
        ),
        _AppFeature(
          title: 'Editable Dialer & Precision Editing',
          description:
              'Freely tap anywhere on the typed number to move your cursor, select digits, copy, or paste phone numbers with ease.',
          icon: Icons.edit_note_outlined,
          highlights: [
            'Cursor positioning',
            'Paste numbers',
            'Backspace at the cursor',
          ],
        ),
        _AppFeature(
          title: 'Top Contacts Quick Access',
          description:
              'A row right above the dialpad for one-tap calling. Choose what fills it: your most contacted people, the family and friends you have linked, or whoever usually answers at this time of day.',
          icon: Icons.star_outline,
          highlights: [
            'Favorites row',
            'Family & friends filter',
            'Likely to answer now',
          ],
        ),
        _AppFeature(
          title: 'Dual-SIM Calling Controls',
          description:
              'Choose between SIM 1 and SIM 2 for each call, or set a default SIM so you are not asked every time. A contact can also keep its own preferred SIM, which is used ahead of the default. Each SIM gets its own colour, and Recents shows which one a call used.',
          icon: Icons.sim_card_outlined,
          highlights: [
            'SIM 1 / SIM 2 picker',
            'Default SIM or ask each time',
            'Per-contact preferred SIM',
            'SIM shown in Recents',
          ],
        ),
        _AppFeature(
          title: 'Smart Redial & "Reach Me" Mode',
          description:
              'When a call goes unanswered or busy, schedule a redial after a delay you choose, or send a preset "trying to reach you" text in one tap.',
          icon: Icons.replay_outlined,
          highlights: [
            'Redial after your delay',
            '1-tap SMS prompt',
            'Cancel a waiting redial',
          ],
        ),
        _AppFeature(
          title: 'Spoken Caller Announcements',
          description:
              'Hear a saved caller\'s name spoken out loud when your phone rings, perfect when driving or wearing headphones. A Malayalam name is announced in Malayalam.',
          icon: Icons.record_voice_over_outlined,
          highlights: [
            'Voice caller ID',
            'Malayalam announcements',
            'Quiet-hours exception',
          ],
        ),
        _AppFeature(
          title: 'Quick Reject SMS Replies',
          description:
              'Decline incoming calls politely with preset one-tap SMS messages like "In a meeting, will call back soon."',
          icon: Icons.sms_outlined,
          highlights: [
            '1-tap decline SMS',
            'Custom quick templates',
            'Instant dispatch',
          ],
        ),
      ],
    ),
    _FeatureCategory(
      name: 'In-Call & Caller Intelligence',
      subtitle:
          'Know who is calling with rich context and seamless call controls',
      icon: Icons.person_search_outlined,
      features: [
        _AppFeature(
          title: 'Modern In-Call Screen & Conference Calling',
          description:
              'A beautiful call screen with mute, loud speaker, call hold, numeric keypad, active call swapping, and merging multi-party conference calls.',
          icon: Icons.call_end_outlined,
          highlights: [
            'Speaker & mute',
            'Call hold & swap',
            'Conference merge',
            'Full-screen incoming alert',
          ],
        ),
        _AppFeature(
          title: 'Relationship Context Cards',
          description:
              'See the caller\'s relationship badge, how long since you last spoke, personal notes, and upcoming birthdays right as the phone rings.',
          icon: Icons.badge_outlined,
          highlights: [
            'Relationship badge',
            'Last spoken days',
            'Instant notes preview',
          ],
        ),
        _AppFeature(
          title: 'Pre-Call Summary',
          description:
              'Before you ring someone, see when you last spoke, how long that call lasted, what you noted, and the local time in their city if you saved an address.',
          icon: Icons.analytics_outlined,
          highlights: [
            'Catch-up reminders',
            'Their local time',
            'Interaction timeline',
          ],
        ),
        _AppFeature(
          title: 'Post-Call Notes & Voice Transcribing',
          description:
              'Quickly jot down what you discussed right after hanging up using your keyboard or speaking aloud with automatic voice-to-text.',
          icon: Icons.note_alt_outlined,
          highlights: [
            'Voice-to-text input',
            'Post-call prompt',
            'Follow-up reminder',
          ],
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
              'Store multiple phone numbers, emails, home/work addresses, birthdays, anniversaries, social links, official details, and phonetic names.',
          icon: Icons.account_circle_outlined,
          highlights: [
            'Multi-phone & email',
            'Birthday reminders',
            'Custom labels',
          ],
        ),
        _AppFeature(
          title: '7 Relationship Spheres',
          description:
              'Every link you save sits in one of seven categories: Immediate Family, Extended Family, Family by Marriage, Professional, Educational, Social, and Service. The label inside it — "Father", "Manager" — is whatever you type.',
          icon: Icons.hub_outlined,
          highlights: [
            'Seven fixed categories',
            'Your own kinship labels',
            'Saved on both contacts',
          ],
        ),
        _AppFeature(
          title: 'Relationship Quiet Hours (DND Filter)',
          description:
              'Silence calls between the times you set, and list who should still get through — starred contacts, whole relationship categories, a tag, or named individuals. Everyone else stays quiet.',
          icon: Icons.bedtime_outlined,
          highlights: [
            'Set your quiet window',
            'Allow list, not a block list',
            'By category, tag or person',
          ],
        ),
        _AppFeature(
          title: 'Tags & Custom Groups',
          description:
              'Tag contacts with short words of your own, and build groups (like "Project Team" or "Book Club") that can carry their own ringtone.',
          icon: Icons.label_outline,
          highlights: [
            'Tag cloud explorer',
            'Custom groups',
            'Group ringtones',
          ],
        ),
        _AppFeature(
          title: 'Duplicate Contact Finder & Smart Merge',
          description:
              'Find duplicates by phone number and by name — including names written in another script — then merge them cleanly without losing any detail.',
          icon: Icons.merge_type_outlined,
          highlights: [
            'Name & number matching',
            'Safe data merge',
            'Review before merging',
          ],
        ),
        _AppFeature(
          title: 'Temporary (Ephemeral) Contacts',
          description:
              'Save a delivery driver or a one-off seller as a temporary contact and it deletes itself — after 2 hours, 24 hours, 7 days, or a single call.',
          icon: Icons.timer_outlined,
          highlights: [
            'Self-deleting entry',
            'Countdown banner',
            'Keep it permanently',
          ],
        ),
        _AppFeature(
          title: 'Connected Messaging Apps',
          description:
              'A contact shows the messengers they can be reached on — WhatsApp, Telegram, Arattai and others — read from your phone\'s own address book. Tap one to open the chat there.',
          icon: Icons.apps_outlined,
          highlights: [
            'Open chat directly',
            'Read from your phone',
            'No account needed',
          ],
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
          highlights: [
            'Biometric / PIN unlock',
            'Hidden from main list',
            'Encrypted database',
          ],
        ),
        _AppFeature(
          title: 'App Lock: Off, Device Lock or App PIN',
          description:
              'Lock the whole app behind your phone\'s fingerprint and face, or behind a separate 4–6 digit App PIN with a one-time recovery code. Secret contacts, backups and sync ask again on top of it.',
          icon: Icons.fingerprint,
          highlights: [
            'Fingerprint & Face unlock',
            'Separate App PIN',
            'One-time recovery code',
          ],
        ),
        _AppFeature(
          title: 'Screenshot Guard',
          description:
              'Blocks screenshots, screen recording, and the Recents preview while you are on a screen holding private data — contact details, a call in progress, the lock screen, secret contacts, and the audit log.',
          icon: Icons.screenshot_outlined,
          highlights: [
            'Screenshot blocking',
            'Screen recording defense',
            'Recents preview hidden',
          ],
        ),
        _AppFeature(
          title: 'Contact Change Audit Log',
          description:
              'A private, tamper-evident history of every contact created, edited or deleted, with what it looked like before and after — so an accidental change can be undone.',
          icon: Icons.history_edu_outlined,
          highlights: [
            'Before & after snapshots',
            'Undo a change',
            'Signed export',
          ],
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
          highlights: [
            'Instant QR vCard',
            'Built-in camera scanner',
            '1-tap address book import',
          ],
        ),
        _AppFeature(
          title: 'AirQR Animated Code Streaming',
          description:
              'A photo or a long contact card will not fit in one QR code. AirQR splits it across many frames and plays them as an animation for the other phone\'s camera to read — no Bluetooth, no network, no pairing.',
          icon: Icons.sensors,
          highlights: [
            'Sends photos & full cards',
            'Camera-only transfer',
            'Live progress while it streams',
          ],
        ),
        _AppFeature(
          title: 'On-Device Business Card Scanner',
          description:
              'Snap a photo of any physical business card to extract name, phone, email, and company details instantly—all processed 100% on your phone without cloud upload.',
          icon: Icons.document_scanner_outlined,
          highlights: [
            'On-device AI OCR',
            'Zero cloud upload',
            'Selectable field import',
          ],
        ),
        _AppFeature(
          title: 'Offline Bluetooth LE Share',
          description:
              'Discover nearby ContactSphere devices and send contacts directly over Bluetooth Low Energy without needing internet or pairing codes.',
          icon: Icons.bluetooth_outlined,
          highlights: [
            'Zero internet required',
            'Auto device discovery',
            'Receiver must confirm',
          ],
        ),
        _AppFeature(
          title: 'CSV & vCard Import / Export',
          description:
              'Bring contacts in from a CSV or vCard (.vcf) file, or write your address book out as one, then choose where it goes through the system share sheet.',
          icon: Icons.import_export_outlined,
          highlights: [
            'CSV in and out',
            'vCard (.vcf) in and out',
            'Secret contacts left out',
          ],
        ),
      ],
    ),
    _FeatureCategory(
      name: 'Data Sync & Backup',
      subtitle:
          'Keep your contacts safe, synchronized, and recoverable anywhere',
      icon: Icons.cloud_sync_outlined,
      features: [
        _AppFeature(
          title: 'Device Contacts & Call Log Sync',
          description:
              'Copy contacts between the app and your phone\'s address book in whichever direction you choose — you run each one yourself. The phone\'s call log flows into Recents on its own.',
          icon: Icons.sync,
          highlights: [
            'Either direction, on demand',
            'Adds and updates, never deletes',
            'Call log arrives automatically',
          ],
        ),
        _AppFeature(
          title: 'Local Wi-Fi Device-to-Device Sync',
          description:
              'Transfer contacts between two phones on the same Wi-Fi network, encrypted with a pairing code that never leaves the screen. Nothing is uploaded, and nothing on the receiving phone is deleted.',
          icon: Icons.wifi_tethering,
          highlights: [
            'Direct phone to phone',
            'Encrypted with a QR pairing code',
            'No cloud needed',
          ],
        ),
        _AppFeature(
          title: 'Online Provider Sync & Encrypted Cloud Backup',
          description:
              'Optionally sync contacts with Google, Microsoft or a CardDAV server, and upload a password-encrypted backup file to Google Drive, OneDrive or your own WebDAV storage.',
          icon: Icons.cloud_outlined,
          highlights: [
            'Google, Microsoft & WebDAV',
            'Password-encrypted file',
            'Secret contacts never uploaded',
          ],
        ),
        _AppFeature(
          title: 'Offline Backup & Restore Files',
          description:
              'Save everything — contacts, call history, photos, settings and the emergency card — into one password-locked file, and restore it on any phone. The password is the only key; the app never stores it.',
          icon: Icons.backup_outlined,
          highlights: [
            'Export to file',
            'Safe encrypted format',
            'Restore replaces everything',
          ],
        ),
      ],
    ),
    _FeatureCategory(
      name: 'Call Defense & Spam Blocking',
      subtitle: 'Shield yourself from spam calls and unwanted numbers',
      icon: Icons.shield_outlined,
      features: [
        _AppFeature(
          title: 'Automatic Call Screening',
          description:
              'A built-in screening service inspects every incoming number before your phone rings and turns away anything on your blocked list — checked entirely on this phone, against your own list.',
          icon: Icons.phone_disabled_outlined,
          highlights: [
            'Rejected before it rings',
            'Nothing looked up online',
            'Default dialer integration',
          ],
        ),
        _AppFeature(
          title: 'Blocked Numbers Manager',
          description:
              'Block a number with a long-press in Recents, from the Block control during a call, or by typing it in yourself. Blocking during a live call hangs it up at once, and blocked calls still appear in Recents so you can see who tried.',
          icon: Icons.block_outlined,
          highlights: [
            'Block from Recents or in-call',
            'Blocklist manager',
            'Unblock anytime',
          ],
        ),
        _AppFeature(
          title: 'Block Unknown Callers',
          description:
              'Turn away calls that arrive with no number or a withheld one. They are rejected before ringing and still written into Recents as blocked.',
          icon: Icons.no_accounts_outlined,
          highlights: [
            'Hidden numbers rejected',
            'Still logged in Recents',
            'One switch to turn on',
          ],
        ),
        _AppFeature(
          title: 'Caller Identification & Spam Filter',
          description:
              'Label callers who are not in your contacts using what can be worked out locally — telemarketing and service number series, numbers you marked as spam, and the network\'s verified-caller flag. Flagged callers can ring silently instead of loudly.',
          icon: Icons.label_outline,
          highlights: [
            'Labels unknown callers',
            'Ring spam silently',
            'Mark a number as spam',
          ],
        ),
      ],
    ),
    _FeatureCategory(
      name: 'Personalization & Accessibility',
      subtitle:
          'Customize the appearance, audio, and regional settings to your taste',
      icon: Icons.palette_outlined,
      features: [
        _AppFeature(
          title: 'Theme, Accent Color & Typography',
          description:
              'Switch between Light, Dark, or System mode, choose an accent colour, and set the font and text size. Three bundled fonts cover both Malayalam and English.',
          icon: Icons.color_lens_outlined,
          highlights: [
            'Dark & Light mode',
            'Curated color palettes',
            'Font & text size',
          ],
        ),
        _AppFeature(
          title: 'Per-SIM, Group & Contact Ringtones',
          description:
              'Assign distinctive ringtones to SIM 1 vs SIM 2, to a group, or to a single contact. The most specific one wins: the contact\'s tone, then their group\'s, then the SIM\'s.',
          icon: Icons.notifications_active_outlined,
          highlights: [
            'Distinct ringtone per SIM',
            'Group ringtones',
            'Per-contact ringtones',
          ],
        ),
        _AppFeature(
          title: 'Emergency Info Lock-Screen Card',
          description:
              'Set vital medical info (blood group, allergies, emergency contacts) visible on your lock screen for first responders without unlocking.',
          icon: Icons.medical_information_outlined,
          highlights: [
            'Lock-screen access',
            'Per-field privacy toggle',
            'Direct emergency dial',
          ],
        ),
        _AppFeature(
          title: 'Default Country Dialing Code',
          description:
              'Tell the app which country your plain, un-prefixed numbers belong to. It is what lets a call from +91 98765 43210 be recognised as the 98765 43210 in your contacts, and it is used to match blocked numbers too.',
          icon: Icons.public_outlined,
          highlights: [
            'Auto country prefix',
            'International format',
            'Matches callers to contacts',
          ],
        ),
        _AppFeature(
          title: 'Contact Counts & Search Index',
          description:
              'See how many contacts sit on the phone and in the app, and check the health of the search index that makes T9 and name search fast. Rebuild it in seconds if a contact stops turning up.',
          icon: Icons.manage_search_outlined,
          highlights: [
            'Device vs app counts',
            'Index health check',
            'One-tap rebuild',
          ],
        ),
        _AppFeature(
          title: 'In-App Help & Guides',
          description:
              'Over twenty plain-English guides covering every feature here — calling, blocking, sync, backups, privacy, sharing and more — plus a FAQ and troubleshooting page. All offline, inside the app.',
          icon: Icons.help_center_outlined,
          highlights: [
            'Guide for every feature',
            'FAQ & troubleshooting',
            'Works offline',
          ],
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('Features')),
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
