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
                'Generate QR Code: Open any contact card and tap "Share QR Code" to display an industry-standard vCard QR code on your screen.',
              ),
              _Bullet(
                'Scan QR Code: Tap the QR icon in the top search bar or in contact list actions to open the camera and scan anyone\'s contact QR code.',
              ),
              _Bullet(
                'Scanned details are previewed immediately, letting you save them directly as a new contact or merge with an existing record.',
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
                'The receiver opens "Receive over Bluetooth" under Settings/Contacts, while the sender taps "Share via Bluetooth" on any contact.',
              ),
              _Bullet(
                'Devices automatically discover each other and transfer the contact securely over low-energy radio.',
              ),
            ],
          ),

          SizedBox(height: 8),
          _Footer(
            'Tip: All contact sharing methods export clean, universal vCard formats compatible with Android, iOS, and desktop address books.',
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
