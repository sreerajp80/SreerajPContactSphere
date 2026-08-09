// lib/widgets/qr_share_dialog.dart
//
// On-screen QR code for a contact: another phone scans it straight off the
// screen (the payload is a standard vCard any camera/contacts app understands),
// or the Share button exports it as a PNG through the system share sheet.
// The code sits on a white card in both themes — a QR needs dark-on-light
// contrast to scan, so the card does not follow the surface color.

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:smart_contacts_dialer/models/contact.dart';
import 'package:smart_contacts_dialer/services/qr_share_service.dart';
import 'package:smart_contacts_dialer/services/vcard_service.dart';

import 'package:smart_contacts_dialer/widgets/air_qr_share_dialog.dart';

/// Shows [contact]'s QR code with a share action.
Future<void> showQrShareDialog(BuildContext context, Contact contact) {
  return showDialog<void>(
    context: context,
    builder: (_) => QrShareDialog(contact: contact),
  );
}

class QrShareDialog extends StatefulWidget {
  final Contact contact;

  const QrShareDialog({super.key, required this.contact});

  @override
  State<QrShareDialog> createState() => _QrShareDialogState();
}

class _QrShareDialogState extends State<QrShareDialog> {
  bool _sharing = false;

  Future<void> _share() async {
    setState(() => _sharing = true);
    try {
      await QrShareService().shareQr(widget.contact);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not share QR: $e')));
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final payload = VCardService().qrPayload(widget.contact);

    return AlertDialog(
      title: Text(widget.contact.fullName),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Scan with any phone camera to add this contact.',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            // The tight SizedBox is load-bearing: AlertDialog measures its
            // content with IntrinsicWidth, and QrImageView is built around a
            // LayoutBuilder, which throws on intrinsic-size queries (aborting
            // layout every frame — nothing paints and the barrier eats taps).
            // A tight box answers the query itself so the LayoutBuilder is
            // never asked.
            child: SizedBox.square(
              dimension: 240,
              child: QrImageView(
                data: payload,
                size: 240,
                backgroundColor: Colors.white,
                errorStateBuilder: (_, _) => const Center(
                  child: Text(
                    'This contact has too much detail to fit in a QR code.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Air-Gap Stream (Full Contact)',
          icon: const Icon(Icons.sensors, color: Colors.blue),
          onPressed: () {
            Navigator.of(context).pop();
            showAirQrShareDialog(context, contact: widget.contact);
          },
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        FilledButton.icon(
          onPressed: _sharing ? null : _share,
          icon: const Icon(Icons.share, size: 18),
          label: const Text('Share'),
        ),
      ],
    );
  }
}
