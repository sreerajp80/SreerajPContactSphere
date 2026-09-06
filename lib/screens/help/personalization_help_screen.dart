// lib/screens/help/personalization_help_screen.dart
//
// User-facing documentation for how the app looks and sounds: theme, accent
// colour, fonts and text size, contact display options, ringtones, volume and
// vibration, and the default country. Mirrors [AppearanceScreen],
// [TypographySettingsScreen], [ContactDisplaySettingsScreen],
// [RingtoneSettingsScreen] / [PerSimRingtoneScreen] and [DefaultCountryScreen].
// If those screens change, update this page.

import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/screens/help/help_article.dart';

class PersonalizationHelpScreen extends StatelessWidget {
  const PersonalizationHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HelpArticleScaffold(
      title: 'Look, sound & region',
      children: [
        HelpIntro(
          'Almost everything about how the app looks, what it sounds like, and '
          'how it reads phone numbers can be changed. Here is where each '
          'setting lives.',
        ),
        SizedBox(height: 24),

        HelpSection(
          icon: Icons.palette_outlined,
          title: 'Theme and colour',
          children: [
            HelpBullet(
              'Settings → Appearance → Theme Mode: Light, Dark, or System. '
              'System follows your phone\'s own dark-mode setting.',
            ),
            HelpBullet(
              'Settings → Appearance → Accent Color: pick a preset or build '
              'your own colour. The preview updates as you choose.',
            ),
          ],
        ),

        HelpSection(
          icon: Icons.text_fields_outlined,
          title: 'Font and text size',
          children: [
            HelpBullet(
              'Settings → Appearance → Typography & Text Size sets the font '
              'and how large text is drawn.',
            ),
            HelpBullet(
              'Three Malayalam-capable fonts are built in — Manjari, Anek '
              'Malayalam, and Noto Sans Malayalam. Each covers Malayalam and '
              'English, so names in either script stay readable.',
            ),
            HelpBullet(
              'The fonts ship inside the app. Nothing is downloaded, and this '
              'works with no internet.',
            ),
          ],
        ),

        HelpSection(
          icon: Icons.sort_by_alpha,
          title: 'How the contact list reads',
          children: [
            HelpBullet(
              'Settings → Contacts → Display & formatting sets the sort order '
              '(by first name or last name).',
            ),
            HelpBullet(
              'The same screen can hide contacts that have no phone number, '
              'which tidies a list imported from an email account.',
            ),
          ],
        ),

        HelpSection(
          icon: Icons.music_note_outlined,
          title: 'Ringtones, volume and vibration',
          children: [
            HelpBullet(
              'Settings → Ringtone → Volume & vibration sets the ringtone '
              'volume and whether incoming calls vibrate.',
            ),
            HelpBullet(
              'Settings → Ringtone → Per-SIM ringtones gives SIM 1 and SIM 2 '
              'different tones, so you know which line is ringing.',
            ),
            HelpBullet(
              'A group can carry its own ringtone, and any contact can be '
              'given one while editing them.',
            ),
            HelpBullet(
              'When several apply, the most specific wins: the contact\'s own '
              'tone first, then their group\'s, then the SIM\'s.',
            ),
            HelpBullet(
              'Ringtones are not included in backups or in a sync to another '
              'phone, because they point at a sound file on this phone.',
            ),
          ],
        ),

        HelpSection(
          icon: Icons.public_outlined,
          title: 'Default country',
          children: [
            HelpBullet(
              'Settings → Default country tells the app which country your '
              'plain, un-prefixed numbers belong to.',
            ),
            HelpBullet(
              'It is what lets the app see that a call from +91 98765 43210 is '
              'the same person as the 98765 43210 saved in your contacts.',
            ),
            HelpBullet(
              'Blocked numbers are matched the same way, so a number blocked '
              'in local form still blocks the international form.',
            ),
            HelpBullet(
              'Getting this wrong is the usual reason a saved contact shows up '
              'as an unknown caller.',
            ),
          ],
        ),

        SizedBox(height: 8),
        HelpFooter(
          'Tip: theme, accent colour, fonts and the default country travel to '
          'another phone on a sync. Ringtones and SIM choices stay behind, '
          'because they belong to this handset.',
        ),
      ],
    );
  }
}
