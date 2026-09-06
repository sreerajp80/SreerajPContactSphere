// lib/screens/help/groups_tags_help_screen.dart
//
// User-facing documentation for groups and tags, shown from Settings → Help.
// Mirrors the real behavior in [GroupsScreen] (groups and group ringtones),
// [TagCloudScreen] / [TagContactsScreen] (the Tags tab), and the multi-select
// mode in `contact_list_screen.dart`. If that behavior changes, update this page.

import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/screens/help/help_article.dart';

class GroupsTagsHelpScreen extends StatelessWidget {
  const GroupsTagsHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HelpArticleScaffold(
      title: 'Groups & tags',
      children: [
        HelpIntro(
          'Groups and tags are two different ways to sort the same address '
          'book. A contact belongs to groups you build by hand, and carries '
          'tags you type as short labels. Both are yours — the app never '
          'creates one on its own.',
        ),
        SizedBox(height: 24),

        HelpSection(
          icon: Icons.group_outlined,
          title: 'Groups',
          children: [
            HelpBullet(
              'Open the Contacts tab and tap the group icon in the top bar to '
              'see all your groups.',
            ),
            HelpBullet(
              'Create a group, give it a name, and add members. A contact can '
              'be in more than one group.',
            ),
            HelpBullet(
              'A group can carry its own ringtone. Pick one from the phone\'s '
              'ringtones or from an audio file in your folders.',
            ),
            HelpBullet(
              'The group ringtone is used for members who do not have their '
              'own ringtone set. A ringtone on the contact always wins.',
            ),
          ],
        ),

        HelpSection(
          icon: Icons.sell_outlined,
          title: 'Tags',
          children: [
            HelpBullet(
              'A tag is a short word you attach to a contact while editing '
              'them — "plumber", "school", "trek group". There is no fixed '
              'list; type whatever fits.',
            ),
            HelpBullet(
              'The Tags tab at the bottom of the app shows every tag in use as '
              'a cloud. A tag used by more contacts is drawn larger.',
            ),
            HelpBullet(
              'Tap a tag to see everyone who carries it. From there you can '
              'call, message, or open any of them.',
            ),
            HelpBullet(
              'Tags also work as an exception list for quiet hours, so a whole '
              'tag can be allowed to ring through.',
            ),
          ],
        ),

        HelpSection(
          icon: Icons.checklist_outlined,
          title: 'Working on many contacts at once',
          children: [
            HelpBullet(
              'Long-press a contact in the list to start selecting. Tap more '
              'contacts to add them to the selection.',
            ),
            HelpBullet(
              'The top bar then offers "Select all" and "Delete selected", so '
              'you can clear out many contacts in one step.',
            ),
            HelpBullet(
              'Tap the cross in the top bar to leave selection mode without '
              'changing anything.',
            ),
          ],
        ),

        SizedBox(height: 8),
        HelpFooter(
          'Tip: use a group when the set is fixed and you want one ringtone for '
          'it. Use a tag when you only want to find those people again later.',
        ),
      ],
    );
  }
}
