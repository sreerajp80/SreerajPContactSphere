// lib/screens/help/call_screening_help_screen.dart
import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/theme/app_theme.dart';

class CallScreeningHelpScreen extends StatelessWidget {
  const CallScreeningHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Call Screening & Blocking')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: const [
          _Intro(
            'The app can turn a call away before your phone rings. Blocking is '
            'a list you build yourself, checked on this phone against the '
            'incoming number \u2014 nothing is looked up anywhere else.',
          ),
          SizedBox(height: 24),

          _Section(
            icon: Icons.shield_outlined,
            title: 'How call screening works',
            children: [
              _Bullet(
                'When a call arrives, Android hands the number to the app\'s call screening service before the phone rings.',
              ),
              _Bullet(
                'If the number is on your blocked list, the call is rejected straight away \u2014 no ring, no vibration, no incoming screen.',
              ),
              _Bullet(
                'Numbers are matched after being put into full international form using your Default country, so a number blocked as 98765 43210 also blocks +91 98765 43210.',
              ),
              _Bullet(
                'A blocked call is still written into Recents with a "Blocked" mark, so you can see who tried.',
              ),
            ],
          ),

          _Section(
            icon: Icons.block_outlined,
            title: 'Blocking a number',
            children: [
              _Bullet(
                'From Recents: long-press the call and choose "Block number". The same action then reads "Unblock number".',
              ),
              _Bullet(
                'During a call: tap Block on the call screen. This works while it is ringing and while you are talking.',
              ),
              _Bullet(
                'By hand: Settings \u2192 Contacts \u2192 Blocked numbers, then add the number yourself.',
              ),
              _Bullet(
                'Blocking a number that is on a call right now hangs that call up immediately, wherever you blocked it from.',
              ),
            ],
          ),

          _Section(
            icon: Icons.no_accounts_outlined,
            title: 'Callers with no number',
            children: [
              _Bullet(
                'Settings \u2192 Contacts \u2192 Blocked numbers also has a "Block unknown callers" switch, for calls that arrive with a hidden or withheld number.',
              ),
              _Bullet(
                'Those calls are rejected before ringing and still recorded in Recents as blocked.',
              ),
              _Bullet(
                'It does not affect ordinary numbers you have not saved \u2014 only calls that carry no number at all.',
              ),
            ],
          ),

          _Section(
            icon: Icons.volume_off_outlined,
            title: 'Silencing instead of blocking',
            children: [
              _Bullet(
                'If you would rather see the call but not be disturbed, use "Filter suspected spam" under Settings \u2192 SIM & calling \u2192 Identification. Flagged callers then ring silently.',
              ),
              _Bullet(
                'See the "Caller ID & spam filter" guide for how a caller gets flagged.',
              ),
            ],
          ),

          _Section(
            icon: Icons.phone_android_outlined,
            title: 'Default phone app is required',
            children: [
              _Bullet(
                'Android only lets the default phone app inspect a call before it rings. Without that role, blocking cannot happen early enough.',
              ),
              _Bullet(
                'Settings \u2192 Permissions shows whether the app already holds the role, and lets you ask for it.',
              ),
            ],
          ),

          SizedBox(height: 8),
          _Footer(
            'Privacy note: screening happens entirely on this phone, against your own list. No phone number is ever sent to a server, and there is no shared spam database behind it.',
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
