// lib/screens/help/biometrics_help_screen.dart
//
// User-facing documentation for the biometric lock, shown from Settings → Help.
// Written in plain English and mirrors the real behavior in [AuthService] and
// its call sites: what the fingerprint / face check protects and where it is
// asked for. If that behavior changes, update this page to match.

import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

class BiometricsHelpScreen extends StatelessWidget {
  const BiometricsHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).helpBiometricsText),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          _Intro(AppLocalizations.of(context).helpBiometricsIntro),
          const SizedBox(height: 24),

          _Section(
            icon: Icons.lock_person_outlined,
            title: AppLocalizations.of(context).helpBiometricsTitle1,
            children: [
              _Bullet(AppLocalizations.of(context).helpBiometricsBullet1),
              _Bullet(AppLocalizations.of(context).helpBiometricsBullet2),
              _Bullet(AppLocalizations.of(context).helpBiometricsBullet3),
              _Bullet(AppLocalizations.of(context).helpBiometricsBullet4),
              _Bullet(AppLocalizations.of(context).helpBiometricsBullet5),
              _Bullet(AppLocalizations.of(context).helpBiometricsBullet6),
              _Bullet(AppLocalizations.of(context).helpBiometricsBullet7),
            ],
          ),

          _Section(
            icon: Icons.fingerprint,
            title: AppLocalizations.of(context).helpBiometricsTitle2,
            children: [
              _Bullet(AppLocalizations.of(context).helpBiometricsBullet8),
              _Bullet(AppLocalizations.of(context).helpBiometricsBullet9),
              _Bullet(AppLocalizations.of(context).helpBiometricsBullet10),
            ],
          ),

          _Section(
            icon: Icons.shield_outlined,
            title: AppLocalizations.of(context).helpBiometricsTitle3,
            children: [
              _Bullet(AppLocalizations.of(context).helpBiometricsBullet11),
              _Bullet(AppLocalizations.of(context).helpBiometricsBullet12),
            ],
          ),

          const SizedBox(height: 8),
          _Footer(AppLocalizations.of(context).helpBiometricsFooter),
        ],
      ),
    );
  }
}

/// The lead paragraph at the top of the article.
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

/// One titled section: an accent icon + heading, then its bullet points.
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

/// A single bullet line inside a [_Section].
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

/// The closing tip, set apart in a soft accent panel.
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
