// lib/screens/help/call_management_help_screen.dart
import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/theme/app_theme.dart';

class CallManagementHelpScreen extends StatelessWidget {
  const CallManagementHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calling & In-Call Controls')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: const [
          _Intro(
            'SreerajP Contacts Sphere provides an intelligent calling experience with '
            'multi-party controls, dual-SIM management, automatic redial assistance, '
            'and spoken caller announcements.',
          ),
          SizedBox(height: 24),

          _Section(
            icon: Icons.call_end_outlined,
            title: 'In-Call Controls & Conference Calling',
            children: [
              _Bullet(
                'Mute & Speaker: Tap Mute to silence your microphone, or Speaker for loud hands-free audio.',
              ),
              _Bullet(
                'Hold & Keypad: Put active calls on hold or open the dialpad to enter IVR menu digits (like pressing 1 for English).',
              ),
              _Bullet(
                'Add Call & Call Swap: Add a second participant while keeping the first call on hold. Tap Swap to switch between active callers.',
              ),
              _Bullet(
                'Conference Merge: Tap Merge to combine both active calls into a single group conference conversation.',
              ),
            ],
          ),

          _Section(
            icon: Icons.sim_card_outlined,
            title: 'Dual-SIM Calling & Preferences',
            children: [
              _Bullet(
                'On dual-SIM phones, the dialer gives you SIM 1 and SIM 2 call buttons for immediate selection.',
              ),
              _Bullet(
                'You can assign a preferred SIM to individual contacts under Contact Details → Edit Contact so that calls always route through your chosen number.',
              ),
              _Bullet(
                'Call logs clearly show which SIM card was used for incoming, outgoing, or missed calls.',
              ),
            ],
          ),

          _Section(
            icon: Icons.replay_outlined,
            title: 'Smart Redial & "Reach Me" SMS',
            children: [
              _Bullet(
                'When an outgoing call is busy or unanswered, ContactSphere offers to schedule an automatic redial reminder.',
              ),
              _Bullet(
                'You can also tap "Send SMS" to dispatch a quick "Hey, I tried reaching you" text with 1 tap.',
              ),
              _Bullet(
                'Configure your preferred redial interval and retry limit in Settings → Smart Redial.',
              ),
            ],
          ),

          _Section(
            icon: Icons.record_voice_over_outlined,
            title: 'Spoken Caller Announcements',
            children: [
              _Bullet(
                'When enabled in Settings → Spoken Announcements, the app reads the caller\'s name out loud when your phone rings.',
              ),
              _Bullet(
                'You can set it to speak always, or only when wired headphones or Bluetooth headsets are connected.',
              ),
              _Bullet(
                'Customize the speech prefix (e.g., "Incoming call from...") and speech rate to your liking.',
              ),
            ],
          ),

          _Section(
            icon: Icons.sms_outlined,
            title: 'Quick SMS Decline Replies',
            children: [
              _Bullet(
                'Cannot answer right now? Tap Quick Reply on the incoming call alert to send a preset SMS template.',
              ),
              _Bullet(
                'You can customize your own reply templates in Settings → Quick Replies.',
              ),
            ],
          ),

          SizedBox(height: 8),
          _Footer(
            'Tip: Enable ContactSphere as your Default Phone App in Android Settings to unlock full in-call controls and full-screen incoming alerts.',
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
