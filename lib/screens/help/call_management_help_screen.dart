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
            icon: Icons.touch_app_outlined,
            title: 'Speed Dial',
            children: [
              _Bullet(
                'Keypad keys 1 to 9 can each hold one person. Hold a key on the dialer to call them.',
              ),
              _Bullet(
                'Holding only works when the number box is empty, so a long press while you are typing never starts a call.',
              ),
              _Bullet(
                'To set a key: hold an empty key on the dialer and pick a contact, or go to Settings → Speed Dial. If the contact has more than one number you are asked which one to save.',
              ),
              _Bullet(
                'A key that holds someone shows a small coloured dot above the digit.',
              ),
              _Bullet(
                'Secret contacts cannot be put on a key, and a key is freed automatically if you delete its contact or make it secret.',
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
                'Settings → SIM & calling → SIM Cards & Accounts sets the default SIM for outgoing calls, or switches on "Ask before each call" so you are asked every time.',
              ),
              _Bullet(
                'One person can have their own SIM: open the contact, tap Edit, and choose it under "Preferred SIM". Calls to them then use that SIM instead of the default one.',
              ),
              _Bullet(
                'With "Ask before each call" switched on you are still asked, but the SIM that call would have used is already ticked, so it is one tap.',
              ),
              _Bullet(
                'If that SIM is later removed from the phone, calls quietly fall back to your default SIM.',
              ),
              _Bullet(
                'The same screen gives each SIM its own colour, so you can tell at a glance which line a call is on.',
              ),
              _Bullet(
                'Recents shows which SIM was used for each incoming, outgoing, or missed call.',
              ),
            ],
          ),

          _Section(
            icon: Icons.replay_outlined,
            title: 'Smart Redial & "Reach Me" SMS',
            children: [
              _Bullet(
                'When an outgoing call is busy or unanswered, the app offers to redial the number for you after a delay.',
              ),
              _Bullet(
                'You can instead send a preset "Reach Me" text in one tap, to say you tried to get through.',
              ),
              _Bullet(
                'Settings → SIM & calling → Smart Redial & "Reach Me" sets the default retry delay and the preset message, and lists the redials that are waiting to run.',
              ),
              _Bullet(
                'A scheduled redial is the one place the app dials on its own, and only because you set the delay yourself. Cancel a waiting redial from that same list.',
              ),
            ],
          ),

          _Section(
            icon: Icons.record_voice_over_outlined,
            title: 'Spoken Caller Announcements',
            children: [
              _Bullet(
                'Turn it on under Settings → SIM & calling → Spoken caller announcement. The app then says the caller\'s name over the ringtone — "Amma calling".',
              ),
              _Bullet(
                'A Malayalam name is announced in Malayalam. Use the Test button on that screen to hear how a name sounds before a real call arrives.',
              ),
              _Bullet(
                'Switch on the quiet-hours exception, and set its time range, to stay silent at night while the phone still rings.',
              ),
            ],
          ),

          _Section(
            icon: Icons.sms_outlined,
            title: 'Quick SMS Decline Replies',
            children: [
              _Bullet(
                'Cannot answer right now? Tap Reply on the incoming call screen to decline the call and send a preset text instead.',
              ),
              _Bullet(
                'Write your own messages under Settings → SIM & calling → Quick replies.',
              ),
            ],
          ),

          SizedBox(height: 8),
          _Footer(
            'Tip: make this your Default Phone App — Settings → Permissions shows whether it already is. Without that role, Android does not hand over the in-call controls or the full-screen incoming alert.',
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
