// lib/screens/help/faq_troubleshooting_help_screen.dart
import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/theme/app_theme.dart';

class FaqTroubleshootingHelpScreen extends StatelessWidget {
  const FaqTroubleshootingHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FAQs & Troubleshooting')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: const [
          _Intro(
            'Find quick answers to common questions about permissions, default dialer setup, '
            'privacy, sync options, and troubleshooting steps in ContactSphere.',
          ),
          SizedBox(height: 24),

          _Section(
            icon: Icons.help_outline,
            title: 'General & Permissions',
            children: [
              _FaqItem(
                question: 'Why does ContactSphere need Default Phone App permission?',
                answer:
                    'Android requires an app to be set as the Default Phone App to show incoming call alerts, enable conference merging/call swap, and automatically screen and block spam calls.',
              ),
              _FaqItem(
                question: 'Are my contacts uploaded to external servers?',
                answer:
                    'No. ContactSphere is built with an offline-first architecture. All contacts, call logs, notes, and photos reside in your encrypted local SQLite database. No data is sent to external servers unless you explicitly configure your personal Google Drive / WebDAV cloud backup.',
              ),
              _FaqItem(
                question: 'Why are some permissions optional?',
                answer:
                    'Permissions like Bluetooth (for BLE sharing), Camera (for QR & business card OCR scanning), and Microphone (for voice notes) are requested only when you use those specific features.',
              ),
            ],
          ),

          _Section(
            icon: Icons.dialpad,
            title: 'Dialer & Calling',
            children: [
              _FaqItem(
                question: 'How do I search Malayalam or Devanagari names on T9?',
                answer:
                    'Simply press the keys corresponding to the consonant group or English transliteration (e.g. typing 2-6-4-5 matches both "Anil" and "അനിൽ"). You can also switch the active dialpad script under Settings → Dialpad Script.',
              ),
              _FaqItem(
                question: 'How do I choose which SIM to call from?',
                answer:
                    'On dual-SIM phones, the dialer display includes dedicated SIM 1 and SIM 2 call buttons. You can also assign a default SIM for individual contacts in their edit profile.',
              ),
              _FaqItem(
                question: 'Why didn\'t a call ring during Relationship Quiet Hours?',
                answer:
                    'If you enabled Quiet Hours for specific relationship spheres (like Work or Acquaintances), calls from those contacts are silenced during your scheduled quiet time, while VIP contacts (like Family) ring normally.',
              ),
            ],
          ),

          _Section(
            icon: Icons.sync,
            title: 'Sync, Cloud & Backups',
            children: [
              _FaqItem(
                question: 'What is the difference between Local Wi-Fi Sync and Cloud Sync?',
                answer:
                    'Local Wi-Fi P2P sync transfers contacts directly between two phones on your home Wi-Fi with zero internet or cloud servers. Cloud Sync connects to your personal Google Drive or WebDAV storage for automatic online backups across devices.',
              ),
              _FaqItem(
                question: 'What happens if I forget my Backup password?',
                answer:
                    'Backup files are strongly encrypted with your chosen password for security. Because there are no central servers, a lost backup password cannot be recovered. Keep your password safe or use biometric authentication.',
              ),
              _FaqItem(
                question: 'Will syncing with my phone contacts delete anything?',
                answer:
                    'Standard sync merges new and updated contacts safely. Destructive / Mirror sync will warn you explicitly before replacing or removing any contacts.',
              ),
            ],
          ),

          _Section(
            icon: Icons.lock_outline,
            title: 'Privacy & Secret Contacts',
            children: [
              _FaqItem(
                question: 'How do I restore access if biometric unlock fails?',
                answer:
                    'If your fingerprint or face is not recognized, tap the PIN option to authenticate with your custom ContactSphere App PIN or your phone\'s screen lock PIN.',
              ),
              _FaqItem(
                question: 'Why does the screen go black when switching apps?',
                answer:
                    'Screenshot Guard protects sensitive views from being captured in Android\'s recent apps preview or by background recording tools.',
              ),
            ],
          ),

          _Section(
            icon: Icons.build_outlined,
            title: 'Troubleshooting & Maintenance',
            children: [
              _FaqItem(
                question: 'Search is slow or not finding new contacts. How to fix?',
                answer:
                    'Open Settings → Contact Index Health and tap "Rebuild Search Index". This refreshes T9 stems, phonetic tables, and search caches in a few seconds.',
              ),
              _FaqItem(
                question: 'How do I clean up duplicate contacts?',
                answer:
                    'Go to Contacts → Menu → "Find Duplicates". The app analyzes matching phone numbers, names, and emails, allowing you to merge them with 1 tap.',
              ),
            ],
          ),

          SizedBox(height: 8),
          _Footer(
            'Need further assistance? Check the individual guides in the Help menu or inspect your permissions under Settings → Permissions.',
          ),
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

  const _FaqItem({
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final accent = theme.colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colors.mutedText.withValues(alpha: 0.12),
        ),
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
