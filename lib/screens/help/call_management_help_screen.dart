// lib/screens/help/call_management_help_screen.dart
import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

class CallManagementHelpScreen extends StatelessWidget {
  const CallManagementHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).helpCallManagementText),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          _Intro(AppLocalizations.of(context).helpCallManagementIntro),
          const SizedBox(height: 24),

          _Section(
            icon: Icons.call_end_outlined,
            title: AppLocalizations.of(context).helpCallManagementTitle1,
            children: [
              _Bullet(AppLocalizations.of(context).helpCallManagementBullet1),
              _Bullet(AppLocalizations.of(context).helpCallManagementBullet2),
              _Bullet(AppLocalizations.of(context).helpCallManagementBullet3),
              _Bullet(AppLocalizations.of(context).helpCallManagementBullet4),
            ],
          ),

          _Section(
            icon: Icons.touch_app_outlined,
            title: AppLocalizations.of(context).helpCallManagementTitle2,
            children: [
              _Bullet(AppLocalizations.of(context).helpCallManagementBullet5),
              _Bullet(AppLocalizations.of(context).helpCallManagementBullet6),
              _Bullet(AppLocalizations.of(context).helpCallManagementBullet7),
              _Bullet(AppLocalizations.of(context).helpCallManagementBullet8),
              _Bullet(AppLocalizations.of(context).helpCallManagementBullet9),
            ],
          ),

          _Section(
            icon: Icons.sim_card_outlined,
            title: AppLocalizations.of(context).helpCallManagementTitle3,
            children: [
              _Bullet(AppLocalizations.of(context).helpCallManagementBullet10),
              _Bullet(AppLocalizations.of(context).helpCallManagementBullet11),
              _Bullet(AppLocalizations.of(context).helpCallManagementBullet12),
              _Bullet(AppLocalizations.of(context).helpCallManagementBullet13),
              _Bullet(AppLocalizations.of(context).helpCallManagementBullet14),
              _Bullet(AppLocalizations.of(context).helpCallManagementBullet15),
              _Bullet(AppLocalizations.of(context).helpCallManagementBullet16),
            ],
          ),

          _Section(
            icon: Icons.replay_outlined,
            title: AppLocalizations.of(context).helpCallManagementTitle4,
            children: [
              _Bullet(AppLocalizations.of(context).helpCallManagementBullet17),
              _Bullet(AppLocalizations.of(context).helpCallManagementBullet18),
              _Bullet(AppLocalizations.of(context).helpCallManagementBullet19),
              _Bullet(AppLocalizations.of(context).helpCallManagementBullet20),
            ],
          ),

          _Section(
            icon: Icons.record_voice_over_outlined,
            title: AppLocalizations.of(context).helpCallManagementTitle5,
            children: [
              _Bullet(AppLocalizations.of(context).helpCallManagementBullet21),
              _Bullet(AppLocalizations.of(context).helpCallManagementBullet22),
              _Bullet(AppLocalizations.of(context).helpCallManagementBullet23),
            ],
          ),

          _Section(
            icon: Icons.sms_outlined,
            title: AppLocalizations.of(context).helpCallManagementTitle6,
            children: [
              _Bullet(AppLocalizations.of(context).helpCallManagementBullet24),
              _Bullet(AppLocalizations.of(context).helpCallManagementBullet25),
            ],
          ),

          const SizedBox(height: 8),
          _Footer(AppLocalizations.of(context).helpCallManagementFooter),
        ],
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  final String text;
  const _Intro(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    return Text(
      text,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: colors.mutedText,
        height: 1.5,
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _Section({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final accent = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.mutedText,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final String text;
  const _Footer(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: accent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
