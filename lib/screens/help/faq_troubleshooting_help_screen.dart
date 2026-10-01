// lib/screens/help/faq_troubleshooting_help_screen.dart
import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

class FaqTroubleshootingHelpScreen extends StatelessWidget {
  const FaqTroubleshootingHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).helpFaqTroubleshootingText),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          _Intro(AppLocalizations.of(context).helpFaqTroubleshootingIntro),
          const SizedBox(height: 24),

          _Section(
            icon: Icons.help_outline,
            title: AppLocalizations.of(context).helpFaqTroubleshootingTitle1,
            children: [
              _FaqItem(
                question: AppLocalizations.of(context).helpFaqTroubleshootingQ1,
                answer: AppLocalizations.of(context).helpFaqTroubleshootingA1,
              ),
              _FaqItem(
                question: AppLocalizations.of(context).helpFaqTroubleshootingQ2,
                answer: AppLocalizations.of(context).helpFaqTroubleshootingA2,
              ),
              _FaqItem(
                question: AppLocalizations.of(context).helpFaqTroubleshootingQ3,
                answer: AppLocalizations.of(context).helpFaqTroubleshootingA3,
              ),
            ],
          ),

          _Section(
            icon: Icons.dialpad,
            title: AppLocalizations.of(context).helpFaqTroubleshootingTitle2,
            children: [
              _FaqItem(
                question: AppLocalizations.of(context).helpFaqTroubleshootingQ4,
                answer: AppLocalizations.of(context).helpFaqTroubleshootingA4,
              ),
              _FaqItem(
                question: AppLocalizations.of(context).helpFaqTroubleshootingQ5,
                answer: AppLocalizations.of(context).helpFaqTroubleshootingA5,
              ),
              _FaqItem(
                question: AppLocalizations.of(context).helpFaqTroubleshootingQ6,
                answer: AppLocalizations.of(context).helpFaqTroubleshootingA6,
              ),
            ],
          ),

          _Section(
            icon: Icons.sync,
            title: AppLocalizations.of(context).helpFaqTroubleshootingTitle3,
            children: [
              _FaqItem(
                question: AppLocalizations.of(context).helpFaqTroubleshootingQ7,
                answer: AppLocalizations.of(context).helpFaqTroubleshootingA7,
              ),
              _FaqItem(
                question: AppLocalizations.of(context).helpFaqTroubleshootingQ8,
                answer: AppLocalizations.of(context).helpFaqTroubleshootingA8,
              ),
              _FaqItem(
                question: AppLocalizations.of(context).helpFaqTroubleshootingQ9,
                answer: AppLocalizations.of(context).helpFaqTroubleshootingA9,
              ),
            ],
          ),

          _Section(
            icon: Icons.lock_outline,
            title: AppLocalizations.of(context).helpFaqTroubleshootingTitle4,
            children: [
              _FaqItem(
                question: AppLocalizations.of(
                  context,
                ).helpFaqTroubleshootingQ10,
                answer: AppLocalizations.of(context).helpFaqTroubleshootingA10,
              ),
              _FaqItem(
                question: AppLocalizations.of(
                  context,
                ).helpFaqTroubleshootingQ11,
                answer: AppLocalizations.of(context).helpFaqTroubleshootingA11,
              ),
            ],
          ),

          _Section(
            icon: Icons.build_outlined,
            title: AppLocalizations.of(context).helpFaqTroubleshootingTitle5,
            children: [
              _FaqItem(
                question: AppLocalizations.of(
                  context,
                ).helpFaqTroubleshootingQ12,
                answer: AppLocalizations.of(context).helpFaqTroubleshootingA12,
              ),
              _FaqItem(
                question: AppLocalizations.of(
                  context,
                ).helpFaqTroubleshootingQ13,
                answer: AppLocalizations.of(context).helpFaqTroubleshootingA13,
              ),
              _FaqItem(
                question: AppLocalizations.of(
                  context,
                ).helpFaqTroubleshootingQ14,
                answer: AppLocalizations.of(context).helpFaqTroubleshootingA14,
              ),
              _FaqItem(
                question: AppLocalizations.of(
                  context,
                ).helpFaqTroubleshootingQ15,
                answer: AppLocalizations.of(context).helpFaqTroubleshootingA15,
              ),
              _FaqItem(
                question: AppLocalizations.of(
                  context,
                ).helpFaqTroubleshootingQ16,
                answer: AppLocalizations.of(context).helpFaqTroubleshootingA16,
              ),
            ],
          ),

          const SizedBox(height: 8),
          _Footer(AppLocalizations.of(context).helpFaqTroubleshootingFooter),
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

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final accent = theme.colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.35,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.mutedText.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(Icons.help_outline, color: accent, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(
              answer,
              style: TextStyle(
                color: colors.mutedText,
                fontSize: 13.5,
                height: 1.4,
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
