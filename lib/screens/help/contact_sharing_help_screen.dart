// lib/screens/help/contact_sharing_help_screen.dart
import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

class ContactSharingHelpScreen extends StatelessWidget {
  const ContactSharingHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).helpContactSharingText),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          _Intro(AppLocalizations.of(context).helpContactSharingIntro),
          const SizedBox(height: 24),

          _Section(
            icon: Icons.qr_code_2_outlined,
            title: AppLocalizations.of(context).helpContactSharingTitle1,
            children: [
              _Bullet(AppLocalizations.of(context).helpContactSharingBullet1),
              _Bullet(AppLocalizations.of(context).helpContactSharingBullet2),
              _Bullet(AppLocalizations.of(context).helpContactSharingBullet3),
            ],
          ),

          _Section(
            icon: Icons.document_scanner_outlined,
            title: AppLocalizations.of(context).helpContactSharingTitle2,
            children: [
              _Bullet(AppLocalizations.of(context).helpContactSharingBullet4),
              _Bullet(AppLocalizations.of(context).helpContactSharingBullet5),
              _Bullet(AppLocalizations.of(context).helpContactSharingBullet6),
              _Bullet(AppLocalizations.of(context).helpContactSharingBullet7),
            ],
          ),

          _Section(
            icon: Icons.bluetooth_outlined,
            title: AppLocalizations.of(context).helpContactSharingTitle3,
            children: [
              _Bullet(AppLocalizations.of(context).helpContactSharingBullet8),
              _Bullet(AppLocalizations.of(context).helpContactSharingBullet9),
              _Bullet(AppLocalizations.of(context).helpContactSharingBullet10),
              _Bullet(AppLocalizations.of(context).helpContactSharingBullet11),
            ],
          ),

          const SizedBox(height: 8),
          _Footer(AppLocalizations.of(context).helpContactSharingFooter),
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
