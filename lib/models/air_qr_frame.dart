// lib/models/air_qr_frame.dart
//
// Represents a single frame captured or transmitted in an optical AirQR stream.
// Supports both systematic frames (v1) and LT Fountain parity frames (LT1).

import 'dart:convert';
import 'package:flutter/foundation.dart';

@immutable
class AirQrFrame {
  final String streamId;
  final int totalBlocks;
  final int sequenceIndex;
  final bool isParity;
  final int degree;
  final List<int> indices;
  final int checksum;
  final List<int> payloadBytes;

  const AirQrFrame({
    required this.streamId,
    required this.totalBlocks,
    required this.sequenceIndex,
    required this.isParity,
    required this.degree,
    required this.indices,
    required this.checksum,
    required this.payloadBytes,
  });

  /// Parses a raw scanned QR payload string into an [AirQrFrame], or returns null if invalid.
  static AirQrFrame? parse(String raw) {
    if (!raw.startsWith('AIRQR|')) return null;

    final parts = raw.split('|');
    if (parts.length < 7) return null;

    try {
      final version = parts[1];
      final streamId = parts[2];
      final totalBlocks = int.parse(parts[3]);
      final checksum = int.parse(parts[5]);
      final payloadBytes = base64.decode(parts[6]);

      if (version == 'v1') {
        final seqIndex = int.parse(parts[4]);
        return AirQrFrame(
          streamId: streamId,
          totalBlocks: totalBlocks,
          sequenceIndex: seqIndex,
          isParity: false,
          degree: 1,
          indices: [seqIndex],
          checksum: checksum,
          payloadBytes: payloadBytes,
        );
      } else if (version == 'LT1') {
        final degreeAndIndices = parts[4].split(':');
        final degree = int.parse(degreeAndIndices[0]);
        final indices = degreeAndIndices[1]
            .split(',')
            .where((s) => s.isNotEmpty)
            .map(int.parse)
            .toList();

        return AirQrFrame(
          streamId: streamId,
          totalBlocks: totalBlocks,
          sequenceIndex: -1,
          isParity: true,
          degree: degree,
          indices: indices,
          checksum: checksum,
          payloadBytes: payloadBytes,
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('AirQrFrame parse error: $e');
    }
    return null;
  }

  /// Encodes this frame into a string format suitable for rendering as a QR code.
  String toQrString() {
    final payloadBase64 = base64.encode(payloadBytes);
    if (!isParity) {
      return 'AIRQR|v1|$streamId|$totalBlocks|$sequenceIndex|$checksum|$payloadBase64';
    } else {
      final indicesCsv = indices.join(',');
      return 'AIRQR|LT1|$streamId|$totalBlocks|$degree:$indicesCsv|$checksum|$payloadBase64';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AirQrFrame &&
          runtimeType == other.runtimeType &&
          streamId == other.streamId &&
          sequenceIndex == other.sequenceIndex &&
          isParity == other.isParity &&
          checksum == other.checksum;

  @override
  int get hashCode => Object.hash(streamId, sequenceIndex, isParity, checksum);
}
