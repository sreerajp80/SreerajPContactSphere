// lib/screens/help/caller_id_spam_help_screen.dart
//
// User-facing documentation for caller identification, spam filtering, and the
// "block unknown callers" switch. Mirrors the real behavior in
// [IdentificationSettingsScreen], [BlockedNumbersScreen],
// `ContactSphereCallScreeningService.kt` and the identification badge in
// `in_call_screen.dart`. If that behavior changes, update this page.

import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/screens/help/help_article.dart';

class CallerIdSpamHelpScreen extends StatelessWidget {
  const CallerIdSpamHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HelpArticleScaffold(
      title: 'Caller ID & spam filter',
      children: [
        HelpIntro(
          'When a number that is not in your contacts calls, the app tries to '
          'say something useful about it, and can make a suspected spam call '
          'ring quietly instead of loudly. Both are switches you control, and '
          'both work entirely on this phone.',
        ),
        SizedBox(height: 24),

        HelpSection(
          icon: Icons.label_outline,
          title: 'Caller identification',
          children: [
            HelpBullet(
              'Turn it on under Settings → SIM & calling → Identification → '
              '"Caller identification".',
            ),
            HelpBullet(
              'An unknown caller gets a label built from what can be worked '
              'out locally: the telemarketing and service number series, '
              'numbers you yourself marked as spam, and the network\'s own '
              'verified-caller flag when it sends one.',
            ),
            HelpBullet(
              'The badge appears on the call screen — red for suspected spam, '
              'a softer colour for a telemarketing or service number.',
            ),
            HelpBullet(
              'No number is ever looked up on the internet. There is no caller '
              'ID database behind this and nothing is uploaded.',
            ),
          ],
        ),

        HelpSection(
          icon: Icons.volume_off_outlined,
          title: 'Filter suspected spam',
          children: [
            HelpBullet(
              'The second switch on the same screen, "Filter suspected spam", '
              'makes flagged callers ring silently instead of loudly.',
            ),
            HelpBullet(
              'The call still comes through and still lands in Recents. You '
              'are simply not disturbed by it.',
            ),
            HelpBullet(
              'Use this when you want to see who called but not be '
              'interrupted. Use blocking when you do not want the call at all.',
            ),
          ],
        ),

        HelpSection(
          icon: Icons.no_accounts_outlined,
          title: 'Block unknown callers',
          children: [
            HelpBullet(
              'Settings → Contacts → Blocked numbers has a "Block unknown '
              'callers" switch for calls that arrive with no number or a '
              'hidden one.',
            ),
            HelpBullet(
              'With it on, those calls are rejected before your phone rings, '
              'and are still written into Recents as blocked so you can see '
              'that they happened.',
            ),
            HelpBullet(
              'It does not affect a number you simply have not saved — only '
              'calls with no caller number at all.',
            ),
          ],
        ),

        HelpSection(
          icon: Icons.report_outlined,
          title: 'Marking a number as spam',
          children: [
            HelpBullet(
              'Long-press a call in Recents and choose "Mark as spam". The '
              'same action reads "Not spam" afterwards, so you can take the '
              'mark off again.',
            ),
            HelpBullet(
              'A spam mark is separate from blocking. The number can still '
              'ring you — it is now labelled, and the spam filter can silence '
              'it if that switch is on.',
            ),
            HelpBullet(
              'Your own marks feed the caller identification label, so the '
              'next call from that number is recognised.',
            ),
          ],
        ),

        SizedBox(height: 8),
        HelpFooter(
          'Tip: identification and spam filtering both need the app to be your '
          'default phone app, because Android only lets the default dialer '
          'inspect a call before it rings.',
        ),
      ],
    );
  }
}
