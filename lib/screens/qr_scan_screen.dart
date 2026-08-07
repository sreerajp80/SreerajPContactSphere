// lib/screens/qr_scan_screen.dart
//
// Camera QR scanner for importing a contact: reads a vCard QR code (the kind
// our own share dialog renders — widgets/qr_share_dialog.dart — or any
// standard contacts-app code) and routes it through the same review/import
// flow the .vcf-intent path in main.dart uses: a single contact opens the
// Add/Edit screen pre-filled, several get a confirm dialog and a bulk import
// through ContactSyncService. Pops with `true` when at least one contact was
// saved, so the caller can reload its list.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:smart_contacts_dialer/models/contact.dart';
import 'package:smart_contacts_dialer/services/contact_sync_service.dart';
import 'package:smart_contacts_dialer/services/vcard_service.dart';
import 'package:smart_contacts_dialer/screens/add_edit_contact_screen.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );

  /// True from the first accepted detection until scanning resumes (or the
  /// screen pops). onDetect keeps firing on every camera frame that shows the
  /// code, so the first hit wins and the rest are dropped.
  bool _handling = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handling) return;

    String? raw;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue?.trim();
      if (value != null && value.isNotEmpty) {
        raw = value;
        break;
      }
    }
    if (raw == null) return;

    _handling = true;
    await _controller.stop();

    if (!raw.toUpperCase().startsWith('BEGIN:VCARD')) {
      await _resumeAfterMessage('Not a contact QR code');
      return;
    }

    List<Contact> parsed;
    try {
      parsed = await VCardService().fromVCard(raw);
    } catch (_) {
      parsed = const <Contact>[];
    }
    if (parsed.isEmpty) {
      await _resumeAfterMessage('Could not read a contact from this code');
      return;
    }

    if (parsed.length == 1) {
      if (!mounted) return;
      // Review before saving; AddEditContactScreen's save runs the normal
      // two-way sync (app DB + device book), same as the vCard-intent flow.
      final saved = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => AddEditContactScreen(contact: parsed.first),
        ),
      );
      if (!mounted) return;
      if (saved == true) {
        Navigator.of(context).pop(true);
      } else {
        await _resume();
      }
      return;
    }

    // A single QR rarely holds several contacts, but the vCard format allows
    // it — confirm and bulk-import, mirroring the multi-contact .vcf flow.
    if (!mounted) return;
    final approved = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Import contacts'),
        content: Text(
          'This QR code contains ${parsed.length} contacts. Import them '
          'into ContactSphere and your phone contacts?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text('Import'),
          ),
        ],
      ),
    );
    if (approved != true) {
      await _resume();
      return;
    }

    final sync = ContactSyncService();
    var imported = 0;
    for (final contact in parsed) {
      try {
        await sync.saveContact(contact);
        imported++;
      } catch (_) {
        // Keep going; report what actually made it.
      }
    }
    if (!mounted) return;
    if (imported > 0) {
      Navigator.of(context).pop(true);
    } else {
      await _resumeAfterMessage('Import failed');
    }
  }

  Future<void> _resumeAfterMessage(String message) async {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
    await _resume();
  }

  Future<void> _resume() async {
    if (!mounted) return;
    try {
      await _controller.start();
    } catch (_) {
      // The camera error (if any) surfaces through the scanner's errorBuilder.
    }
    _handling = false;
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan QR code'),
        actions: [
          // The controller is a ValueNotifier of the scanner state; rebuild the
          // torch button as the torch toggles (or turns out to be absent).
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: _controller,
            builder: (context, state, _) {
              if (state.torchState == TorchState.unavailable) {
                return const SizedBox.shrink();
              }
              final on = state.torchState == TorchState.on;
              return IconButton(
                icon: Icon(
                  on ? Icons.flash_on : Icons.flash_off,
                  color: on ? Colors.amber : Colors.white,
                ),
                tooltip: on ? 'Turn torch off' : 'Turn torch on',
                onPressed: () => _controller.toggleTorch(),
              );
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) => _ScannerError(error: error),
          ),
          // Aiming frame + hint. IgnorePointer so the preview keeps receiving
          // gestures (e.g. tap-to-focus if ever enabled).
          IgnorePointer(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: accent, width: 3),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'Point the camera at a contact QR code',
                    style: TextStyle(color: Colors.white, fontSize: 13.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-screen scanner failure state; permission denial gets its own wording
/// since it's the one the user can fix themselves.
class _ScannerError extends StatelessWidget {
  final MobileScannerException error;

  const _ScannerError({required this.error});

  @override
  Widget build(BuildContext context) {
    final denied = error.errorCode == MobileScannerErrorCode.permissionDenied;
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                denied ? Icons.no_photography_outlined : Icons.error_outline,
                color: Colors.white70,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                denied
                    ? 'Camera access is needed to scan QR codes.\n'
                          'Allow Camera for ContactSphere in system settings '
                          'and come back.'
                    : 'The camera could not be started.\n'
                          '${error.errorDetails?.message ?? ''}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
