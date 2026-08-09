// lib/screens/sim_settings_screen.dart
import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/theme/app_theme.dart';
import 'package:smart_contacts_dialer/widgets/default_dialer_card.dart';
import 'package:smart_contacts_dialer/screens/identification_settings_screen.dart';
import 'package:smart_contacts_dialer/screens/post_call_feedback_screen.dart';
import 'package:smart_contacts_dialer/screens/quick_replies_screen.dart';
import 'package:smart_contacts_dialer/screens/relationship_quiet_hours_screen.dart';
import 'package:smart_contacts_dialer/screens/sim_preferences_screen.dart';
import 'package:smart_contacts_dialer/screens/smart_redial_settings_screen.dart';
import 'package:smart_contacts_dialer/screens/spoken_announcements_screen.dart';

/// Multi-SIM & calling settings hub. Reached from Settings.
class SimSettingsScreen extends StatelessWidget {
  const SimSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SIM & calling')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          const DefaultDialerCard(),
          const SizedBox(height: 12),
          _SettingsSectionCard(
            icon: Icons.sim_card_outlined,
            title: 'SIM Cards & Accounts',
            subtitle: 'Default SIM, ask per call, and SIM colours',
            onTap: () => _push(context, const SimPreferencesScreen()),
          ),
          const SizedBox(height: 12),
          _SettingsSectionCard(
            icon: Icons.verified_user_outlined,
            title: 'Identification',
            subtitle: 'Caller identification and spam filtering',
            onTap: () => _push(context, const IdentificationSettingsScreen()),
          ),
          const SizedBox(height: 12),
          _SettingsSectionCard(
            icon: Icons.record_voice_over_outlined,
            title: 'Spoken caller announcement',
            subtitle: 'Announce caller\'s name over ringtone',
            onTap: () => _push(context, const SpokenAnnouncementsScreen()),
          ),
          const SizedBox(height: 12),
          _SettingsSectionCard(
            icon: Icons.bedtime_outlined,
            title: 'Relationship-tier quiet hours',
            subtitle: 'Silence calls at night except for chosen relationship tiers',
            onTap: () => _push(context, const RelationshipQuietHoursScreen()),
          ),
          const SizedBox(height: 12),
          _SettingsSectionCard(
            icon: Icons.sms_outlined,
            title: 'Quick replies',
            subtitle: 'Messages offered when rejecting a call with a text',
            onTap: () => _push(context, const QuickRepliesScreen()),
          ),
          const SizedBox(height: 12),
          _SettingsSectionCard(
            icon: Icons.rate_review_outlined,
            title: 'Post-call options',
            subtitle: 'Configure the post-call feedback sheet',
            onTap: () => _push(context, const PostCallFeedbackScreen()),
          ),
          const SizedBox(height: 12),
          _SettingsSectionCard(
            icon: Icons.phone_forwarded_outlined,
            title: 'Smart Redial & "Reach Me"',
            subtitle: 'Auto-retry and reach-me SMS when calls are unanswered',
            onTap: () => _push(context, const SmartRedialSettingsScreen()),
          ),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}

/// A standard card representing a settings section. Tapping navigates to its page.
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
