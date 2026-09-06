// lib/screens/help/contact_tools_help_screen.dart
//
// User-facing documentation for three smaller contact tools: ephemeral
// (self-deleting) contacts, the connected-apps row on a contact, and the search
// index health screen. Mirrors [EphemeralContactService] and the ephemeral
// banner in `contact_detail_screen.dart`, [ConnectedAppsService], and
// [ContactIndexHealthScreen]. If that behavior changes, update this page.

import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/screens/help/help_article.dart';

class ContactToolsHelpScreen extends StatelessWidget {
  const ContactToolsHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HelpArticleScaffold(
      title: 'Contact tools',
      children: [
        HelpIntro(
          'Three smaller tools that are easy to miss: contacts that delete '
          'themselves, the messaging apps a contact can be reached on, and the '
          'search index that makes the dialer find people fast.',
        ),
        SizedBox(height: 24),

        HelpSection(
          icon: Icons.timer_outlined,
          title: 'Ephemeral (temporary) contacts',
          children: [
            HelpBullet(
              'While adding or editing a contact, switch on "Ephemeral '
              'contact". The entry then removes itself later, on its own.',
            ),
            HelpBullet(
              'Choose how long it lives: 2 hours, 24 hours, 7 days, or '
              '"Auto-delete after 1 call".',
            ),
            HelpBullet(
              'Good for a delivery driver, a cab, or a one-off seller — the '
              'number is there when you need it and gone afterwards.',
            ),
            HelpBullet(
              'Opening the contact shows a banner counting down to its '
              'removal. From there you can add another 24 hours, or tap to '
              'keep it for good.',
            ),
            HelpBullet(
              'The app checks about once a minute, so a contact disappears '
              'shortly after its time is up rather than at the exact second.',
            ),
          ],
        ),

        HelpSection(
          icon: Icons.apps_outlined,
          title: 'Connected apps',
          children: [
            HelpBullet(
              'If a messenger such as WhatsApp, Telegram or Arattai has synced '
              'itself against a contact on your phone, that contact shows a '
              'row of those apps.',
            ),
            HelpBullet(
              'Tap one to open the chat or call in that app directly. Nothing '
              'is sent by this app — it simply opens the other one.',
            ),
            HelpBullet(
              'The row is read from your phone\'s own address book, so it '
              'appears only for contacts linked to a device contact, and only '
              'while contacts permission is granted.',
            ),
          ],
        ),

        HelpSection(
          icon: Icons.manage_search_outlined,
          title: 'Contact counts & search index',
          children: [
            HelpBullet(
              'Settings → Contacts → Contact counts & search index shows how '
              'many contacts are on the phone and how many are in the app — '
              'the quickest way to see whether a sync worked.',
            ),
            HelpBullet(
              'The search index is what makes T9 keypad search, transliterated '
              'search, and name search fast.',
            ),
            HelpBullet(
              'The screen tells you either "Index healthy — all contacts are '
              'findable" or how many contacts have stale search keys.',
            ),
            HelpBullet(
              'When some are stale, a Rebuild button appears. Tap it and the '
              'keys are rebuilt for the whole address book.',
            ),
            HelpBullet(
              'Rebuild this if search stops finding a contact you know is '
              'saved, or after restoring an old backup.',
            ),
          ],
        ),

        SizedBox(height: 8),
        HelpFooter(
          'Tip: an ephemeral contact is deleted for real when its time is up. '
          'If you may want the number later, tap "Keep permanently" on the '
          'banner before it goes.',
        ),
      ],
    );
  }
}
