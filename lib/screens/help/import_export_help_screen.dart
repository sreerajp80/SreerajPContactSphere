// lib/screens/help/import_export_help_screen.dart
//
// User-facing documentation for file import / export and the AirQR optical
// stream, shown from Settings → Help. Mirrors the real behavior in
// [ExportImportService] and [VCardService] (the Contacts → Import / Export
// menu) and [AirQrService] / [AirQrShareDialog]. If that behavior changes,
// update this page.

import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/screens/help/help_article.dart';

class ImportExportHelpScreen extends StatelessWidget {
  const ImportExportHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return HelpArticleScaffold(
      title: AppLocalizations.of(context).helpImportExportTitle1,
      children: [
        HelpIntro(AppLocalizations.of(context).helpImportExportIntro),
        const SizedBox(height: 24),

        HelpSection(
          icon: Icons.import_export_outlined,
          title: AppLocalizations.of(context).helpImportExportTitle2,
          children: [
            HelpBullet(AppLocalizations.of(context).helpImportExportBullet1),
            HelpBullet(AppLocalizations.of(context).helpImportExportBullet2),
          ],
        ),

        HelpSection(
          icon: Icons.file_download_outlined,
          title: AppLocalizations.of(context).helpImportExportTitle3,
          children: [
            HelpBullet(AppLocalizations.of(context).helpImportExportBullet3),
            HelpBullet(AppLocalizations.of(context).helpImportExportBullet4),
            HelpBullet(AppLocalizations.of(context).helpImportExportBullet5),
          ],
        ),

        HelpSection(
          icon: Icons.file_upload_outlined,
          title: AppLocalizations.of(context).helpImportExportTitle4,
          children: [
            HelpBullet(AppLocalizations.of(context).helpImportExportBullet6),
            HelpBullet(AppLocalizations.of(context).helpImportExportBullet7),
            HelpBullet(AppLocalizations.of(context).helpImportExportBullet8),
            HelpBullet(AppLocalizations.of(context).helpImportExportBullet9),
            HelpBullet(AppLocalizations.of(context).helpImportExportBullet10),
          ],
        ),

        HelpSection(
          icon: Icons.sensors,
          title: AppLocalizations.of(context).helpImportExportTitle5,
          children: [
            HelpBullet(AppLocalizations.of(context).helpImportExportBullet11),
            HelpBullet(AppLocalizations.of(context).helpImportExportBullet12),
            HelpBullet(AppLocalizations.of(context).helpImportExportBullet13),
            HelpBullet(AppLocalizations.of(context).helpImportExportBullet14),
          ],
        ),

        const SizedBox(height: 8),
        HelpFooter(AppLocalizations.of(context).helpImportExportFooter),
      ],
    );
  }
}
