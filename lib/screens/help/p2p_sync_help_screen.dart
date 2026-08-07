// lib/screens/help/p2p_sync_help_screen.dart
//
// User-facing documentation for the "Sync to Another Device" (P2P) feature,
// shown from Settings → Help. The content is written in plain English and mirrors
// the real behavior in [SyncBundleService] and [P2PSyncService]: what is copied,
// what is deliberately left out, Full vs Selective sync, and the add-only merge.
// If that behavior changes, update this page to match.

import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/theme/app_theme.dart';

class P2PSyncHelpScreen extends StatelessWidget {
  const P2PSyncHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sync to Another Device')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: const [
          _Intro(
            'Copy your contacts (and more) from one phone to another over the '
            'same Wi-Fi network. There is no internet, cloud, or account '
            'involved — the two phones talk directly to each other. Both phones '
            'must be running this app.',
          ),
          SizedBox(height: 24),

          _Section(
            icon: Icons.checklist_rounded,
            title: 'Before you start',
            children: [
              _Bullet('Put both phones on the same Wi-Fi network.'),
              _Bullet(
                'Make sure both phones run the same version of this app. If '
                'the versions do not match, sync stops and asks you to update '
                'both phones.',
              ),
              _Bullet(
                'On the phone that is sending, open "Send to Another Device". '
                'On the phone that is receiving, open "Receive from Another '
                'Device".',
              ),
            ],
          ),

          _Section(
            icon: Icons.qr_code_2_rounded,
            title: 'How the two phones connect',
            children: [
              _Bullet('The sending phone shows a pairing code and a QR code.'),
              _Bullet(
                'The receiving phone scans that QR code, or you type the '
                'pairing code in by hand.',
              ),
              _Bullet(
                'The pairing code is only ever shown on screen — it is never '
                'sent over the network. The whole transfer is encrypted using '
                'that code, so if the wrong code is used the connection simply '
                'fails.',
              ),
            ],
          ),

          _Section(
            icon: Icons.tune_rounded,
            title: 'Full Sync vs Selective Sync',
            children: [
              _Bullet(
                'Full Sync sends everything below in one go. The sender\'s app '
                'settings replace the receiver\'s, and the sender\'s own '
                'profile ("Self") card is added to the receiver as a normal '
                'contact (it never replaces the receiver\'s own profile).',
              ),
              _Bullet(
                'Selective Sync sends only the groups of data you pick. '
                'Contacts are always included. Settings only fill in blanks '
                '(they never overwrite what the receiver already set), and the '
                'sender\'s "Self" card is not sent.',
              ),
            ],
          ),

          _Section(
            icon: Icons.cloud_done_outlined,
            title: 'What gets synced',
            children: [
              _Bullet(
                'Contacts and their details: phone numbers, emails, '
                'addresses, official details, social links, and tags.',
              ),
              _Bullet('Contact photos and calling-card photos.'),
              _Bullet('Call history: call logs, interactions, and reminders.'),
              _Bullet('Groups and who belongs to them.'),
              _Bullet('Relationships between contacts.'),
              _Bullet('Blocked numbers.'),
              _Bullet(
                'Your emergency info card — on a Full Sync, or when you tick it '
                'while choosing what to share. The receiving phone takes it '
                'only if it has no card of its own, so nobody\'s medical '
                'details get replaced.',
              ),
              _Bullet(
                'App settings that are not tied to a specific phone — such as '
                'theme, accent color, default country, quick replies, and '
                'call-handling options.',
              ),
            ],
          ),

          _Section(
            icon: Icons.block_flipped,
            title: 'What is never synced',
            children: [
              _Bullet(
                'Ringtones. A ringtone points at a file on the sending phone, '
                'which would not exist on the other phone.',
              ),
              _Bullet(
                'SIM-specific settings, such as the default SIM and per-SIM '
                'ringtones or colors. These refer to the physical SIM cards in '
                'the sending phone.',
              ),
            ],
          ),

          _Section(
            icon: Icons.merge_type_rounded,
            title: 'Nothing on the receiving phone is deleted',
            children: [
              _Bullet(
                'Sync only adds. The receiving phone keeps all of its own '
                'data — nothing is erased or overwritten by the contacts that '
                'come in.',
              ),
              _Bullet(
                'A contact you already have (same name and at least one shared '
                'phone number) is skipped, not duplicated. Only brand-new '
                'contacts are added, and their details and call history come '
                'across with them.',
              ),
              _Bullet(
                'Because an existing contact is skipped, the sender\'s call '
                'history for that contact is not merged in — only new contacts '
                'bring their history.',
              ),
            ],
          ),

          _Section(
            icon: Icons.lock_outline_rounded,
            title: 'Your data stays private',
            children: [
              _Bullet(
                'The transfer happens directly between the two phones on your '
                'local Wi-Fi. Nothing is uploaded to the internet or to any '
                'server.',
              ),
              _Bullet(
                'Opening sync is protected by your device lock, because the '
                'data can include secret contacts.',
              ),
            ],
          ),

          SizedBox(height: 8),
          _Footer(
            'Tip: keep both phones awake and on the same Wi-Fi until the sync '
            'finishes.',
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
