// lib/screens/help/contact_sync_help_screen.dart
//
// User-facing documentation for Contacts → Sync, shown from Settings → Help.
// Written in plain English and mirrors the real behavior in
// [ContactSyncService] (merge + destructive mirror, both directions) and
// [CallLogImportService] (call-log import). If that behavior changes, update
// this page to match.

import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/theme/app_theme.dart';

class ContactSyncHelpScreen extends StatelessWidget {
  const ContactSyncHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Sync')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: const [
          _Intro(
            'Sync keeps the app and your phone in step. You control each '
            'direction yourself — nothing here runs automatically. Open it from '
            'Settings → Contacts → Device & cloud sync.',
          ),
          SizedBox(height: 24),

          _Section(
            icon: Icons.sync_outlined,
            title: 'The two normal actions',
            children: [
              _Bullet(
                'Add device contacts to app: copies the phone\'s address book '
                'into the app. It only adds or updates — it never deletes.',
              ),
              _Bullet(
                'Add app contacts to device: copies your app contacts into '
                'the phone. It only adds or updates — it never deletes. Your '
                '"Me" contact and secret contacts are never sent to the '
                'phone.',
              ),
            ],
          ),

          _Section(
            icon: Icons.sync_problem_outlined,
            title: 'Destructive sync',
            children: [
              _Bullet(
                'The two "(destructive)" actions make the target an exact '
                'copy of the source. As well as adding and updating, they '
                'delete extras — so use them with care. Each one asks you to '
                'confirm first.',
              ),
              _Bullet(
                'Add device contacts to app (destructive): after importing, '
                'it deletes app contacts that came from the phone but are no '
                'longer on it. It never deletes your "Me" contact, your secret '
                'contacts, or any contact you created only in the app.',
              ),
              _Bullet(
                'Add app contacts to device (destructive): after copying, it '
                'deletes device contacts that are not in the app. Device '
                'contacts that match your "Me" contact or a secret contact '
                'are never deleted, even though those are never copied to the '
                'phone.',
              ),
            ],
          ),

          _Section(
            icon: Icons.call_outlined,
            title: 'Call log',
            children: [
              _Bullet(
                'The phone\'s call log syncs into Recents on its own — when '
                'the app starts, when you open Recents, and when a call ends. '
                'Calls made from another dialer, or while the app was closed, '
                'come in this way. You do not have to do anything.',
              ),
              _Bullet(
                'Add device call log to app: brings in the phone\'s older call '
                'history in one go, further back than the automatic sync '
                'reaches. It skips calls the app already has, so running it '
                'again is safe.',
              ),
              _Bullet(
                'Add device call log to app (destructive): clears Recents and '
                'rebuilds it from the phone\'s call log. Any call notes or '
                'feedback you saved in the app are lost.',
              ),
              _Bullet(
                'There is no "app to device" for the call log: Android owns '
                'the phone\'s call log and records calls on its own.',
              ),
            ],
          ),

          SizedBox(height: 8),
          _Footer(
            'Tip: a destructive sync cannot be undone. If you are unsure, make a '
            'backup first (Settings → Backup & Restore).',
          ),
        ],
      ),
    );
  }
}

/// The lead paragraph at the top of the article.
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

/// One titled section: an accent icon + heading, then its bullet points.
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

/// A single bullet line inside a [_Section].
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

/// The closing tip, set apart in a soft accent panel.
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
