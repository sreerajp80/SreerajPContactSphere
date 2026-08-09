// lib/services/emergency_share_service.dart
//
// Formats and exports the In Case of Emergency (ICE) card as plain text or a
// PNG image via the system share sheet (`SharePlus`).

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:smart_contacts_dialer/models/emergency_info.dart';
import 'package:smart_contacts_dialer/utils/filename_utils.dart';

class EmergencyShareService {
  static final EmergencyShareService _instance = EmergencyShareService._internal();
  factory EmergencyShareService() => _instance;
  EmergencyShareService._internal();

  /// Builds a clean, plain-text representation of the ICE card.
  String formatAsText(EmergencyInfo info) {
    final buffer = StringBuffer();
    buffer.writeln('🚨 IN CASE OF EMERGENCY (ICE) 🚨');

    final owner = (info.ownerName ?? '').trim();
    if (info.showOwnerName && owner.isNotEmpty) {
      buffer.writeln('Name: $owner');
    }

    final rows = info.visibleRows();
    if (rows.isNotEmpty) {
      buffer.writeln('\n--- Medical Information ---');
      for (final r in rows) {
        buffer.writeln('• ${r.label}: ${r.value}');
      }
    }

    final contacts = info.visibleContacts();
    if (contacts.isNotEmpty) {
      buffer.writeln('\n--- Emergency Contacts ---');
      for (final c in contacts) {
        final rel = (c.relationLabel ?? '').trim();
        final relStr = rel.isNotEmpty ? ' ($rel)' : '';
        buffer.writeln('• ${c.displayName.trim()}$relStr: ${c.number.trim()}');
      }
    }

    return buffer.toString().trim();
  }

  /// Renders a high-resolution ICE card as a PNG image in the temporary directory.
  Future<File> renderCardImage(EmergencyInfo info) async {
    const double width = 1080;
    final rows = info.visibleRows();
    final contacts = info.visibleContacts();

    // Dynamically measure required height based on content sections
    double estimatedHeight = 320; // Header banner + margins + footer
    estimatedHeight += rows.length * 64;
    estimatedHeight += contacts.length * 90;
    if (rows.isNotEmpty) estimatedHeight += 80;
    if (contacts.isNotEmpty) estimatedHeight += 80;
    final height = estimatedHeight.clamp(720.0, 2400.0);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Background: Clean off-white
    final bgPaint = Paint()..color = const Color(0xFFF9FAFB);
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), bgPaint);

    // Header Banner: Emergency Red
    const headerRect = Rect.fromLTWH(0, 0, width, 200);
    final headerPaint = Paint()..color = const Color(0xFFDC2626);
    canvas.drawRect(headerRect, headerPaint);

    // Header Text
    final headerTextPainter = TextPainter(
      text: const TextSpan(
        text: 'IN CASE OF EMERGENCY (ICE)',
        style: TextStyle(
          color: Colors.white,
          fontSize: 42,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: width - 80);
    headerTextPainter.paint(canvas, Offset((width - headerTextPainter.width) / 2, 75));

    double currentY = 240;

    // Owner Name Card Section
    final owner = (info.ownerName ?? '').trim();
    if (info.showOwnerName && owner.isNotEmpty) {
      final namePainter = TextPainter(
        text: TextSpan(
          text: owner,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 48,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: width - 120);
      namePainter.paint(canvas, Offset(60, currentY));
      currentY += namePainter.height + 30;
    }

    // Medical Details Section
    if (rows.isNotEmpty) {
      final sectionPainter = TextPainter(
        text: const TextSpan(
          text: 'MEDICAL INFORMATION',
          style: TextStyle(
            color: Color(0xFFDC2626),
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: width - 120);
      sectionPainter.paint(canvas, Offset(60, currentY));
      currentY += 45;

      // Divider line
      final linePaint = Paint()
        ..color = const Color(0xFFE5E7EB)
        ..strokeWidth = 2;
      canvas.drawLine(Offset(60, currentY), Offset(width - 60, currentY), linePaint);
      currentY += 25;

      for (final r in rows) {
        final labelPainter = TextPainter(
          text: TextSpan(
            text: '${r.label}: ',
            style: const TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 32,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        labelPainter.paint(canvas, Offset(60, currentY));

        final valPainter = TextPainter(
          text: TextSpan(
            text: r.value,
            style: TextStyle(
              color: r.label == EmergencyInfo.labelBloodGroup ? const Color(0xFFDC2626) : const Color(0xFF1F2937),
              fontSize: 32,
              fontWeight: r.label == EmergencyInfo.labelBloodGroup ? FontWeight.w900 : FontWeight.w500,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: width - 120 - labelPainter.width);
        valPainter.paint(canvas, Offset(60 + labelPainter.width, currentY));

        currentY += valPainter.height + 20;
      }
      currentY += 20;
    }

    // Emergency Contacts Section
    if (contacts.isNotEmpty) {
      final sectionPainter = TextPainter(
        text: const TextSpan(
          text: 'EMERGENCY CONTACTS',
          style: TextStyle(
            color: Color(0xFFDC2626),
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: width - 120);
      sectionPainter.paint(canvas, Offset(60, currentY));
      currentY += 45;

      // Divider line
      final linePaint = Paint()
        ..color = const Color(0xFFE5E7EB)
        ..strokeWidth = 2;
      canvas.drawLine(Offset(60, currentY), Offset(width - 60, currentY), linePaint);
      currentY += 25;

      for (final c in contacts) {
        final rel = (c.relationLabel ?? '').trim();
        final relStr = rel.isNotEmpty ? ' ($rel)' : '';

        final namePainter = TextPainter(
          text: TextSpan(
            text: '${c.displayName.trim()}$relStr',
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 34,
              fontWeight: FontWeight.w700,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: width - 120);
        namePainter.paint(canvas, Offset(60, currentY));
        currentY += namePainter.height + 8;

        final numPainter = TextPainter(
          text: TextSpan(
            text: c.number.trim(),
            style: const TextStyle(
              color: Color(0xFF2563EB),
              fontSize: 32,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: width - 120);
        numPainter.paint(canvas, Offset(60, currentY));
        currentY += numPainter.height + 25;
      }
    }

    // End Recording & Render to PNG Image
    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('Failed to encode ICE card image');
    }

    final dir = await getTemporaryDirectory();
    final safeOwner = sanitizeFileName(owner.isEmpty ? 'card' : owner);
    final file = File(p.join(dir.path, 'ice_card_$safeOwner.png'));
    await file.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
    return file;
  }

  /// Shares the ICE card as formatted plain text via the system share sheet.
  Future<void> shareAsText(EmergencyInfo info) async {
    final text = formatAsText(info);
    final owner = (info.ownerName ?? '').trim();
    final subject = owner.isNotEmpty ? 'ICE Card - $owner' : 'ICE Emergency Info';
    await SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: subject,
      ),
    );
  }

  /// Shares the ICE card as a PNG card image via the system share sheet.
  Future<void> shareAsImage(EmergencyInfo info) async {
    final imageFile = await renderCardImage(info);
    final owner = (info.ownerName ?? '').trim();
    final subject = owner.isNotEmpty ? 'ICE Card - $owner' : 'ICE Emergency Info';
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(imageFile.path, mimeType: 'image/png')],
        subject: subject,
      ),
    );
  }
}
