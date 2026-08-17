// lib/services/business_card_scan_service.dart
//
// On-device OCR for the business card scanner. Wraps ML Kit's Latin text
// recognizer (google_mlkit_text_recognition): an image file path goes in, the
// recognized lines come out in reading order.
//
// Everything runs on the phone — no image and no recognized text is ever sent
// anywhere, which is the same rule the rest of the app follows for contact data.
//
// Mirrors the app's other plugin wrappers (see SpeechService): a singleton that
// never lets a raw platform error reach the UI. Failures surface as a typed
// [BusinessCardScanException] carrying a message that is safe to show.

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'package:smart_contacts_dialer/core/logging/app_logger.dart';

/// Thrown when the recognizer could not run (engine unavailable, unreadable
/// file, host test VM). [message] is user-facing.
class BusinessCardScanException implements Exception {
  final String message;

  const BusinessCardScanException(this.message);

  @override
  String toString() => 'BusinessCardScanException: $message';
}

/// The text read off one card image.
class BusinessCardText {
  /// Recognized lines, top-to-bottom then left-to-right.
  final List<String> lines;

  /// The recognizer's full text, kept so the review sheet can show exactly what
  /// was read even for lines the parser could not place.
  final String rawText;

  const BusinessCardText({required this.lines, required this.rawText});

  bool get isEmpty => lines.isEmpty;
}

class BusinessCardScanService {
  static final BusinessCardScanService _instance =
      BusinessCardScanService._internal();
  factory BusinessCardScanService() => _instance;
  BusinessCardScanService._internal();

  TextRecognizer? _recognizer;

  /// Reads [imagePath] and returns its text lines in reading order.
  ///
  /// Throws [BusinessCardScanException] when the recognizer itself fails. An
  /// image with no text is *not* an error — it comes back with empty [lines] so
  /// the scan screen can offer a retake.
  Future<BusinessCardText> readCard(String imagePath) async {
    // Latin script (the recognizer's default) — the cards in scope are Latin.
    final recognizer = _recognizer ??= TextRecognizer();
    try {
      final result = await recognizer.processImage(
        InputImage.fromFilePath(imagePath),
      );
      return BusinessCardText(
        lines: _orderedLines(result),
        rawText: result.text,
      );
    } catch (e, st) {
      AppLogger.error(
        'BusinessCardScanService.readCard failed',
        error: e,
        stackTrace: st,
      );
      throw const BusinessCardScanException(
        'The text on this image could not be read. Try again with better '
        'light, or enter the details by hand.',
      );
    }
  }

  /// Flattens the recognized blocks to lines sorted the way a person reads a
  /// card. ML Kit returns blocks in no guaranteed order, and card layout
  /// matters to the parser (the designation sits under the name), so lines are
  /// sorted by their vertical position, with overlapping lines — a two-column
  /// card — ordered left to right.
  List<String> _orderedLines(RecognizedText result) {
    final lines = <TextLine>[
      for (final block in result.blocks) ...block.lines,
    ];

    lines.sort((a, b) {
      final ab = a.boundingBox;
      final bb = b.boundingBox;
      // Treat lines whose vertical spans mostly overlap as the same row.
      final sameRow =
          (ab.center.dy - bb.center.dy).abs() <
          (ab.height < bb.height ? ab.height : bb.height) * 0.6;
      return sameRow
          ? ab.left.compareTo(bb.left)
          : ab.center.dy.compareTo(bb.center.dy);
    });

    return [
      for (final line in lines)
        if (line.text.trim().isNotEmpty) line.text.trim(),
    ];
  }

  /// Releases the native recognizer. Called when the scan screen closes.
  Future<void> dispose() async {
    final recognizer = _recognizer;
    _recognizer = null;
    if (recognizer == null) return;
    try {
      await recognizer.close();
    } catch (e) {
      AppLogger.warning('BusinessCardScanService.dispose failed', error: e);
    }
  }
}
