// lib/widgets/contact_qr_preview_dialog.dart
//
// Safety inspection and import confirmation dialog for scanned QR contact payloads.
// Displays safety badges, detected signals (overlong fields, embedded URLs), and
// allows users to review, sanitize, or edit before writing to database.

import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/services/contact_qr_safety_service.dart';

enum ContactQrImportDecision { importSanitized, importOriginal, cancel }

/// Displays safety preview for scanned contact payload and returns user decision.
Future<ContactQrImportDecision?> showContactQrPreviewDialog(
  BuildContext context,
  ContactQrSafetyReport report,
) {
  return showDialog<ContactQrImportDecision>(
    context: context,
    barrierDismissible: false,
    builder: (_) => ContactQrPreviewDialog(report: report),
  );
}

class ContactQrPreviewDialog extends StatelessWidget {
  final ContactQrSafetyReport report;

  const ContactQrPreviewDialog({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isSafe = report.isSafe;
    final isHighRisk = report.riskLevel == ContactQrRiskLevel.highRisk;

    final badgeColor = isSafe
        ? Colors.green
        : isHighRisk
        ? Colors.red
        : Colors.orange;

    final badgeIcon = isSafe
        ? Icons.verified_user_outlined
        : isHighRisk
        ? Icons.shield_outlined
        : Icons.warning_amber_rounded;

    final contactsToPreview = isHighRisk
        ? report.sanitizedContacts
        : report.originalContacts;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      title: Row(
        children: [
          Icon(badgeIcon, color: badgeColor, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isSafe ? l10n.titleScannedContact : l10n.titleSecurityCheck,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Risk Level Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.1),
                border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.summaryMessage,
                    style: TextStyle(
                      color: badgeColor.shade900,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  if (report.detectedSignals.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    for (final sig in report.detectedSignals)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '• ',
                              style: TextStyle(
                                color: badgeColor.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                sig,
                                style: TextStyle(
                                  color: badgeColor.shade800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.labelContactsToImport(contactsToPreview.length),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Contact list details preview
            for (final c in contactsToPreview) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.fullName.isNotEmpty
                          ? c.fullName
                          : l10n.labelUnnamedContact,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (c.phoneNumbers.isNotEmpty)
                      Text(
                        l10n.labelPhonesList(
                          c.phoneNumbers.map((p) => p.number).join(', '),
                        ),
                        style: theme.textTheme.bodySmall,
                      ),
                    if (c.emails.isNotEmpty)
                      Text(
                        l10n.labelEmailsList(
                          c.emails.map((e) => e.email).join(', '),
                        ),
                        style: theme.textTheme.bodySmall,
                      ),
                    if (c.socialLinks.isNotEmpty)
                      Text(
                        l10n.labelWebLinksList(
                          c.socialLinks.map((s) => s.value).join(', '),
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.blue.shade700,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(ContactQrImportDecision.cancel),
          child: Text(l10n.actionCancel),
        ),
        if (!isSafe)
          TextButton(
            onPressed: () => Navigator.of(
              context,
            ).pop(ContactQrImportDecision.importSanitized),
            child: Text(l10n.actionImportSafeOnly),
          ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop(ContactQrImportDecision.importOriginal),
          child: Text(isSafe ? l10n.actionImport : l10n.actionImportAll),
        ),
      ],
    );
  }
}
