// lib/screens/help/contact_sharing_help_screen.dart
import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/theme/app_theme.dart';

class ContactSharingHelpScreen extends StatelessWidget {
  const ContactSharingHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sharing & Card Scanning')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: const [
          _Intro(
            'Quickly exchange contact information using modern digital QR codes, '
            'on-device business card OCR camera scanning, and offline Bluetooth LE.',
          ),
          SizedBox(height: 24),

          _Section(
            icon: Icons.qr_code_2_outlined,
            title: 'QR Code Sharing & Scanner',
            children: [
              _Bullet(
                'Show a QR code: open a contact, tap Share, and choose "Share as QR code". A standard vCard QR appears on screen for someone else to scan.',
              ),
              _Bullet(
                'Scan a QR code: open the Contacts tab, tap the three-dot menu, and choose "Scan QR code" to open the camera.',
              ),
              _Bullet(
                'What was scanned is shown to you first. You save it as a new contact only after looking at it.',
              ),
            ],
          ),

          _Section(
            icon: Icons.document_scanner_outlined,
            title: 'Business Card Scanner (On-Device AI)',
            children: [
              _Bullet(
                'Photograph any paper business card with your phone\'s camera.',
              ),
              _Bullet(
                'ContactSphere\'s optical character recognition (OCR) scans the image in seconds to extract names, phone numbers, emails, addresses, and company titles.',
              ),
              _Bullet(
                'You can review, edit, or untick any field before saving to your address book.',
              ),
              _Bullet(
                '100% On-Device Privacy: The card photo is processed locally on your phone and is never uploaded to any cloud server.',
              ),
            ],
          ),

          _Section(
            icon: Icons.bluetooth_outlined,
            title: 'Offline Bluetooth LE Share',
            children: [
              _Bullet(
                'Share contacts directly with nearby Android devices running ContactSphere without internet or pairing codes.',
              ),
              _Bullet(
                'The sender opens a contact, taps Share, and chooses "Share via Bluetooth". The receiver opens the Contacts tab, taps the three-dot menu, and chooses "Bluetooth transfer".',
              ),
              _Bullet(
                'The receiving phone shows a challenge you must confirm, so a contact cannot be pushed onto your phone without you agreeing.',
              ),
              _Bullet(
                'Devices automatically discover each other and transfer the contact securely over low-energy radio.',
              ),
            ],
          ),

          SizedBox(height: 8),
          _Footer(
            'Tip: every sharing method here uses the standard vCard format, which Android, iOS and desktop address books all understand. To send a whole address book as a file instead, see the Import & export guide.',
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
