// lib/screens/qr_scan_screen.dart
//
// Camera QR scanner for importing contacts: supports both single static vCard
// QR codes and multi-frame optical AirQR streams (AirQrService). All scanned
// payloads are validated through ContactQrSafetyService and displayed in
// ContactQrPreviewDialog before saving or editing.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:smart_contacts_dialer/models/contact.dart';
import 'package:smart_contacts_dialer/services/air_qr_service.dart';
import 'package:smart_contacts_dialer/services/contact_qr_safety_service.dart';
import 'package:smart_contacts_dialer/services/contact_sync_service.dart';
import 'package:smart_contacts_dialer/services/vcard_service.dart';
import 'package:smart_contacts_dialer/screens/add_edit_contact_screen.dart';
import 'package:smart_contacts_dialer/widgets/contact_qr_preview_dialog.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );

  final AirQrService _airQrService = AirQrService();
  AirQrProgress _airProgress = const AirQrProgress(status: AirQrStatus.idle);

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

    // Handle Optical AirQR Stream Frame
    if (raw.startsWith('AIRQR|')) {
      final progress = _airQrService.processFrameString(raw, _airProgress);
      setState(() {
        _airProgress = progress;
      });

      if (progress.status == AirQrStatus.receiving) {
        // Keep camera scanning frames
        return;
      }

      if (progress.status == AirQrStatus.error) {
        await _resumeAfterMessage(
          progress.errorMessage ?? 'AirQR stream reassembly failed',
        );
        _airQrService.reset();
        setState(() {
          _airProgress = const AirQrProgress(status: AirQrStatus.idle);
        });
        return;
      }

      if (progress.status == AirQrStatus.completed &&
          progress.reassembledContent != null) {
        _handling = true;
        await _controller.stop();
        final content = progress.reassembledContent!;
        _airQrService.reset();
        setState(() {
          _airProgress = const AirQrProgress(status: AirQrStatus.idle);
        });
        await _processScannedPayload(content);
        return;
      }
    }

    // Handle Standard Static Single QR Code
    if (raw.toUpperCase().startsWith('BEGIN:VCARD')) {
      _handling = true;
      await _controller.stop();
      await _processScannedPayload(raw);
      return;
    }

    // Unrecognized format
    if (!_handling && _airProgress.status == AirQrStatus.idle) {
      _handling = true;
      await _controller.stop();
      await _resumeAfterMessage('Not a valid contact or AirQR code');
    }
  }

  Future<void> _processScannedPayload(String rawPayload) async {
    List<Contact> parsed;
    try {
      parsed = await VCardService().fromVCard(rawPayload);
    } catch (_) {
      parsed = const <Contact>[];
    }

    if (parsed.isEmpty) {
      await _resumeAfterMessage('Could not read a contact from this payload');
      return;
    }

    if (!mounted) return;

    // Safety Inspection
    final report = ContactQrSafetyService().analyzePayload(rawPayload, parsed);
    final decision = await showContactQrPreviewDialog(context, report);

    if (decision == null || decision == ContactQrImportDecision.cancel) {
      await _resume();
      return;
    }

    final contactsToImport =
        decision == ContactQrImportDecision.importSanitized
            ? report.sanitizedContacts
            : report.originalContacts;

    if (contactsToImport.isEmpty) {
      await _resumeAfterMessage('No valid contacts to import');
      return;
    }

    if (contactsToImport.length == 1) {
      if (!mounted) return;
      final saved = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => AddEditContactScreen(contact: contactsToImport.first),
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

    // Multi-contact bulk import
    final sync = ContactSyncService();
    var imported = 0;
    for (final contact in contactsToImport) {
      try {
        await sync.saveContact(contact);
        imported++;
      } catch (_) {
        // Keep going
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
      // Handled in errorBuilder
    }
    _handling = false;
    setState(() {
      _airProgress = const AirQrProgress(status: AirQrStatus.idle);
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final isReceivingAirStream =
        _airProgress.status == AirQrStatus.receiving;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          isReceivingAirStream ? 'Receiving AirQR Stream' : 'Scan QR code',
        ),
        actions: [
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
          // Aiming frame + hint
          IgnorePointer(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isReceivingAirStream ? Colors.blue : accent,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                const SizedBox(height: 24),
                if (!isReceivingAirStream)
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
                      'Point camera at static or animated AirQR code',
                      style: TextStyle(color: Colors.white, fontSize: 13.5),
                    ),
                  ),
              ],
            ),
          ),
          // Live AirQR Stream Progress Overlay
          if (isReceivingAirStream)
            Positioned(
              left: 24,
              right: 24,
              bottom: 40,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade400, width: 1.5),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'AirQR Receiving... ${_airProgress.progressPercent}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${_airProgress.fps.toStringAsFixed(1)} FPS',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _airProgress.progressRatio,
                        backgroundColor: Colors.grey.shade800,
                        color: Colors.blue,
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Captured ${_airProgress.receivedBlockCount} of ${_airProgress.totalBlocks} blocks',
                      style: TextStyle(
                        color: Colors.grey.shade300,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

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
