// lib/screens/help/caller_intelligence_help_screen.dart
//
// User-facing documentation for the context the app shows around a call:
// the pre-call summary, the "Likely to answer now" ordering, the ringing
// context card, and the post-call notes sheet. Mirrors the real behavior in
// [PreCallSummaryService], [ReachWindowService], [CallerContextService] and
// `post_call_feedback_sheet.dart`. If that behavior changes, update this page.

import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/screens/help/help_article.dart';

class CallerIntelligenceHelpScreen extends StatelessWidget {
  const CallerIntelligenceHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HelpArticleScaffold(
      title: 'Call context & notes',
      children: [
        HelpIntro(
          'The app reads your own call history to tell you a little about a '
          'person before you ring them, while they ring you, and after you '
          'hang up. All of it is worked out on this phone from data you '
          'already have.',
        ),
        SizedBox(height: 24),

        HelpSection(
          icon: Icons.person_search_outlined,
          title: 'Before you call',
          children: [
            HelpBullet(
              'Open a contact and you see a short summary: when you last '
              'spoke, how long that call lasted, and what you noted about it.',
            ),
            HelpBullet(
              'If the contact has an address with a city, the summary also '
              'shows the local time there — useful before calling someone in '
              'another country.',
            ),
            HelpBullet(
              'When there is enough history, it suggests the time of day this '
              'person usually answers.',
            ),
          ],
        ),

        HelpSection(
          icon: Icons.schedule_outlined,
          title: '"Likely to answer now"',
          children: [
            HelpBullet(
              'The dialer shows a short row of contacts above the keypad. You '
              'choose what fills it in Settings → Dialer top contacts: Most '
              'recent, Family & friends, or Likely to answer now.',
            ),
            HelpBullet(
              '"Likely to answer now" puts the people who usually pick up at '
              'this hour first. It is worked out from your own Recents — how '
              'often calls at this time of day were answered.',
            ),
            HelpBullet(
              'This only changes the order of the row. The app never dials on '
              'its own here — every call is still a tap you make.',
            ),
          ],
        ),

        HelpSection(
          icon: Icons.badge_outlined,
          title: 'While the phone is ringing',
          children: [
            HelpBullet(
              'For a saved contact, the call screen can show their '
              'relationship, how long it has been since you last spoke, and a '
              'birthday or anniversary coming up.',
            ),
            HelpBullet(
              'A pending reminder you set for that person is shown too, so you '
              'remember why you meant to speak.',
            ),
          ],
        ),

        HelpSection(
          icon: Icons.edit_note_outlined,
          title: 'After the call',
          children: [
            HelpBullet(
              'When a call ends, a "How did it go?" sheet can appear. Note how '
              'the call went, write down what you discussed, and set a '
              'follow-up reminder.',
            ),
            HelpBullet(
              'You can dictate the note instead of typing it — tap the '
              'microphone and speak. Speech is turned into text on the phone.',
            ),
            HelpBullet(
              'Everything you save joins that contact\'s timeline, which is '
              'what the next pre-call summary reads.',
            ),
            HelpBullet(
              'If you would rather not be asked, turn the sheet off under '
              'Settings → SIM & calling → Post-call options.',
            ),
          ],
        ),

        SizedBox(height: 8),
        HelpFooter(
          'Privacy: none of this leaves the phone. There is no lookup service '
          'behind it — the app only reads your own contacts, call log, and '
          'notes from its encrypted database.',
        ),
      ],
    );
  }
}
