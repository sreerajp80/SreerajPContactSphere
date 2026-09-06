// lib/screens/help/import_export_help_screen.dart
//
// User-facing documentation for file import / export and the AirQR optical
// stream, shown from Settings → Help. Mirrors the real behavior in
// [ExportImportService] and [VCardService] (the Contacts → Import / Export
// menu) and [AirQrService] / [AirQrShareDialog]. If that behavior changes,
// update this page.

import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/screens/help/help_article.dart';

class ImportExportHelpScreen extends StatelessWidget {
  const ImportExportHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HelpArticleScaffold(
      title: 'Import & export files',
      children: [
        HelpIntro(
          'You can move contacts in and out of the app as ordinary files — a '
          'spreadsheet-friendly CSV, or a vCard (.vcf) that any phone or '
          'computer address book understands.',
        ),
        SizedBox(height: 24),

        HelpSection(
          icon: Icons.import_export_outlined,
          title: 'Where to find it',
          children: [
            HelpBullet(
              'Open the Contacts tab, tap the three-dot menu in the top bar, '
              'and choose "Import / Export".',
            ),
            HelpBullet(
              'Four choices appear: Import CSV, Export CSV, Import vCard '
              '(.vcf), and Export vCard (.vcf).',
            ),
          ],
        ),

        HelpSection(
          icon: Icons.file_download_outlined,
          title: 'Importing',
          children: [
            HelpBullet(
              'You pick the file yourself through the system file picker. The '
              'app never browses your storage on its own.',
            ),
            HelpBullet(
              'Imported contacts are added to the app. When the import '
              'finishes you are told how many came in.',
            ),
            HelpBullet(
              'If the file brings in people you already have, run Contacts → '
              'menu → "Find Duplicates" afterwards to tidy up.',
            ),
          ],
        ),

        HelpSection(
          icon: Icons.file_upload_outlined,
          title: 'Exporting',
          children: [
            HelpBullet(
              'An export writes a file and then opens the system share sheet, '
              'so you decide where it goes.',
            ),
            HelpBullet(
              'An export file is plain and not password-protected. Treat it '
              'like a copy of your address book and delete it when you are '
              'done.',
            ),
            HelpBullet(
              'Secret contacts are left out of a normal export unless you turn '
              'on "Include secret contacts in export" under Settings → '
              'Contacts → Secret contacts & export.',
            ),
            HelpBullet(
              'That same screen has "Export secret contacts", which saves a '
              'separate file holding only the secret ones. It asks for your '
              'fingerprint, face, or PIN first.',
            ),
            HelpBullet(
              'For a full, password-locked copy of everything — call history, '
              'photos, settings and all — use Settings → Backup & Restore '
              'instead.',
            ),
          ],
        ),

        HelpSection(
          icon: Icons.sensors,
          title: 'AirQR: sending more than one QR code can hold',
          children: [
            HelpBullet(
              'A single QR code cannot hold a photo or a long contact card. '
              'AirQR splits the data across many frames and plays them as an '
              'animated QR code.',
            ),
            HelpBullet(
              'Open a contact, choose "Share as QR code", then tap the '
              'Air-Gap Stream button in that dialog to start the animation.',
            ),
            HelpBullet(
              'On the other phone, open Contacts → menu → "Scan QR code" and '
              'point the camera at the animation. It shows the progress while '
              'the frames come in and saves the contact once they are all '
              'there.',
            ),
            HelpBullet(
              'Nothing is sent over Bluetooth, Wi-Fi or the internet — the '
              'only path is the camera looking at the screen. Keep both phones '
              'steady until it completes.',
            ),
          ],
        ),

        SizedBox(height: 8),
        HelpFooter(
          'Tip: vCard (.vcf) is the safer choice for moving to another phone, '
          'because it keeps multiple numbers, emails and photos. CSV is best '
          'when you want to open the list in a spreadsheet.',
        ),
      ],
    );
  }
}
