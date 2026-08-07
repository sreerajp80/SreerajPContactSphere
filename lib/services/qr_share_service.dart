// lib/services/qr_share_service.dart
//
// Renders a contact's QR code (vCard payload, see VCardService.qrPayload) to a
// PNG and opens the system share sheet, so the code can be sent through any
// app. The on-screen scannable view lives in widgets/qr_share_dialog.dart;
// this service is only the share-as-image path.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import 'package:smart_contacts_dialer/models/contact.dart';
import 'package:smart_contacts_dialer/services/vcard_service.dart';
import 'package:smart_contacts_dialer/utils/filename_utils.dart';

class QrShareService {
  static final QrShareService _instance = QrShareService._internal();
  factory QrShareService() => _instance;
  QrShareService._internal();

  static const int _imageSize = 1024;
  static const double _quietZone = 64;

  /// Renders [contact]'s QR code as a black-on-white PNG in the temp directory
  /// and opens the system share sheet. Returns the path of the file written.
  /// Throws when the payload exceeds QR capacity or rendering fails.
  Future<String> shareQr(Contact contact) async {
    final painter = QrPainter(
      data: VCardService().qrPayload(contact),
      version: QrVersions.auto,
      gapless: true,
    );

    // Composite onto an opaque white card with a quiet zone around the code —
    // a transparent background renders unscannable in dark-themed viewers, and
    // the QR spec requires the quiet zone for reliable scanning.
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(_imageSize - 2 * _quietZone, _imageSize - 2 * _quietZone);
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, _imageSize * 1.0, _imageSize * 1.0),
      Paint()..color = Colors.white,
    );
    canvas.translate(_quietZone, _quietZone);
    painter.paint(canvas, size);
    final image = await recorder.endRecording().toImage(_imageSize, _imageSize);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) {
      throw Exception('Could not render the QR code image');
    }

    final dir = await getTemporaryDirectory();
    final safeName = sanitizeFileName(contact.fullName);
    final file = File(p.join(dir.path, 'contact_qr_$safeName.png'));
    await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'image/png')],
        subject: contact.fullName,
      ),
    );
    return file.path;
  }
}
