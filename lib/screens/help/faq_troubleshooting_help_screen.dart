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
                question:
                    'Why does ContactSphere need Default Phone App permission?',
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
                    'Permissions such as Bluetooth (for nearby sharing), Camera (for QR and business-card scanning), and Microphone (for dictating call notes) are asked for only when you first use that feature. Refusing one disables just that feature. See the "Permissions explained" guide for the full list.',
              ),
            ],
          ),

          _Section(
            icon: Icons.dialpad,
            title: 'Dialer & Calling',
            children: [
              _FaqItem(
                question:
                    'How do I search Malayalam or Devanagari names on T9?',
                answer:
                    'Press the keys for the consonant group, or type the name as it sounds in English (typing 2-6-4-5 matches both "Anil" and "അനിൽ"). To change which script the keypad shows, use the "Dialpad script" card on the main Settings page.',
              ),
              _FaqItem(
                question: 'How do I choose which SIM to call from?',
                answer:
                    'On dual-SIM phones the dialer gives you separate SIM 1 and SIM 2 call buttons. To stop choosing every time, set a default SIM under Settings → SIM & calling → SIM Cards & Accounts, or switch on "Ask before each call" there.',
              ),
              _FaqItem(
                question: 'Why didn\'t a call ring during quiet hours?',
                answer:
                    'Quiet hours silence everything except the people you allow. Open Settings → SIM & calling → Relationship-tier quiet hours and add whoever should still get through — starred contacts, whole relationship categories, a tag, or named individuals. Anyone not on that list is silenced until the quiet hours end.',
              ),
            ],
          ),

          _Section(
            icon: Icons.sync,
            title: 'Sync, Cloud & Backups',
            children: [
              _FaqItem(
                question:
                    'What is the difference between Local Wi-Fi Sync and Cloud Sync?',
                answer:
                    'Local Wi-Fi sync copies data straight from one phone to another on the same network, with no internet and no account. Online sync and cloud backup use accounts you add yourself — Google, Microsoft, or a CardDAV/WebDAV server — and are off until you set one up.',
              ),
              _FaqItem(
                question: 'What happens if I forget my Backup password?',
                answer:
                    'A backup file is encrypted with the password you chose, and the app never stores it. There is no server to ask, so a lost password means the file cannot be opened. Write it down somewhere safe before you need it.',
              ),
              _FaqItem(
                question:
                    'Will syncing with my phone contacts delete anything?',
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
                    'The phone\'s own unlock prompt falls back to your screen-lock PIN, pattern, or password. If you use an App PIN instead and have forgotten it, tap "Forgot PIN?" on the lock screen and enter the recovery code you were given when you set it up.',
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
                question:
                    'Search is slow or not finding new contacts. How to fix?',
                answer:
                    'Open Settings → Contacts → Contact counts & search index. If any contacts have stale search keys, a Rebuild button appears — tap it and the keys are rebuilt in a few seconds.',
              ),
              _FaqItem(
                question:
                    'A blocked number still shows in Recents. Is it ringing?',
                answer:
                    'No. A blocked call is rejected before your phone rings, but it is still written into Recents with a "Blocked" mark so you can see that someone tried. If you would rather see the call and just not be disturbed, use "Filter suspected spam" instead of blocking.',
              ),
              _FaqItem(
                question: 'A contact vanished on its own. Why?',
                answer:
                    'It was probably saved as an ephemeral (temporary) contact, which deletes itself after 2 hours, 24 hours, 7 days, or one call. Opening such a contact shows a countdown banner with a "Keep Permanently" button.',
              ),
              _FaqItem(
                question: 'Where are groups and tags?',
                answer:
                    'Groups are behind the group icon in the top bar of the Contacts tab. Tags have their own tab at the bottom of the app, drawn as a cloud where a tag used by more people appears larger.',
              ),
              _FaqItem(
                question: 'How do I clean up duplicate contacts?',
                answer:
                    'Open the Contacts tab, tap the three-dot menu, and choose "Find Duplicates". Matching is by phone number and by name (including transliterated names). Review each set, then merge it, or use "Merge all sets".',
              ),
            ],
          ),

          SizedBox(height: 8),
          _Footer(
            'Still stuck? Open the matching guide in Help, or check Settings → Permissions to see whether the feature is simply missing a permission.',
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
