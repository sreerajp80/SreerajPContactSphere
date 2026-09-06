// lib/screens/help/permissions_help_screen.dart
//
// User-facing documentation for the permissions the app asks for, shown from
// Settings → Help. Mirrors the catalog in `lib/core/constants/app_permissions.dart`
// and the Explicit / Implicit split rendered by [PermissionsScreen]. If a
// permission is added or its reason changes, update this page.

import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/screens/help/help_article.dart';

class PermissionsHelpScreen extends StatelessWidget {
  const PermissionsHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HelpArticleScaffold(
      title: 'Permissions explained',
      children: [
        HelpIntro(
          'Settings → Permissions lists everything the app can access, with a '
          'live status beside each one. This page explains what each is for, '
          'and what stops working if you say no.',
        ),
        SizedBox(height: 24),

        HelpSection(
          icon: Icons.rule_outlined,
          title: 'Two kinds of permission',
          children: [
            HelpBullet(
              'Explicit — Android asks you, and you can say no or change your '
              'mind later. These are the ones with Granted / Denied beside '
              'them.',
            ),
            HelpBullet(
              'Implicit — declared when the app is built and granted by the '
              'system at install. There is no prompt, because they cannot '
              'reach your personal data on their own.',
            ),
          ],
        ),

        HelpSection(
          icon: Icons.phone_android_outlined,
          title: 'For calling',
          children: [
            HelpBullet(
              'Default phone app — makes this the system dialer, so it can '
              'show its own in-call screen, full-screen incoming alerts, and '
              'screen calls before they ring. Without it, calling works but '
              'blocking and screening do not.',
            ),
            HelpBullet(
              'Phone & Call Log — place, answer and manage calls, and read '
              'back a call\'s real duration for Recents.',
            ),
            HelpBullet(
              'Foreground Call Service & Ringing — keeps a call alive and lets '
              'the app ring and show the incoming-call screen.',
            ),
            HelpBullet(
              'Screen off near ear — blanks the screen while the phone is '
              'against your ear so your cheek does not press buttons.',
            ),
          ],
        ),

        HelpSection(
          icon: Icons.contacts_outlined,
          title: 'For your contacts',
          children: [
            HelpBullet(
              'Contacts — read and sync your phone\'s address book. Without '
              'it, the app keeps its own contacts but cannot see or update the '
              'phone\'s.',
            ),
            HelpBullet(
              'Photos & Media — pick a profile photo from your gallery.',
            ),
            HelpBullet(
              'Camera — take a contact photo, scan a QR code, or scan a paper '
              'business card.',
            ),
            HelpBullet(
              'Microphone — dictate a call note instead of typing it.',
            ),
            HelpBullet(
              'Location — tag a contact with a place, and needed by Android '
              'for Bluetooth scanning on older versions.',
            ),
          ],
        ),

        HelpSection(
          icon: Icons.notifications_none_outlined,
          title: 'For reminders and the emergency card',
          children: [
            HelpBullet(
              'Notifications — show reminders for birthdays, follow-ups and '
              'missed calls, and carry the emergency info card on your lock '
              'screen.',
            ),
            HelpBullet(
              'Alarms & reminders — lets Smart Redial call back at the time '
              'you set even when the app is closed.',
            ),
            HelpBullet(
              'Start after restart — puts your emergency info card back on the '
              'lock screen after the phone reboots.',
            ),
          ],
        ),

        HelpSection(
          icon: Icons.share_outlined,
          title: 'For sharing and sync',
          children: [
            HelpBullet(
              'Bluetooth Scan, Connect and Advertise — find a nearby phone, '
              'connect to it, and be findable while sharing a contact over '
              'Bluetooth.',
            ),
            HelpBullet(
              'Internet & Wi-Fi — used only to copy your data to another phone '
              'across your own local Wi-Fi during device sync. No cloud server '
              'is contacted unless you set up online sync or cloud backup '
              'yourself.',
            ),
            HelpBullet(
              'Biometrics — unlock secret contacts, and confirm before you '
              'export or sync data that may include them.',
            ),
          ],
        ),

        HelpSection(
          icon: Icons.do_not_disturb_on_outlined,
          title: 'Saying no, and changing your mind',
          children: [
            HelpBullet(
              'Every permission is asked for only when you first use the '
              'feature that needs it. Nothing is requested at install.',
            ),
            HelpBullet(
              'Refusing one disables just that feature. The rest of the app '
              'keeps working.',
            ),
            HelpBullet(
              'A permission you denied twice shows as "Blocked". Android will '
              'not ask again — use the settings button in the top bar of the '
              'Permissions screen to change it by hand.',
            ),
          ],
        ),

        SizedBox(height: 8),
        HelpFooter(
          'The app has no advertising or analytics code and contacts no server '
          'of ours. Anything that leaves the phone leaves because you set up a '
          'sync, a share, or a cloud backup.',
        ),
      ],
    );
  }
}
