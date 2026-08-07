// lib/services/ble_protocol.dart
//
// The wire protocol for BLE contact exchange, shared by the sender bridge
// (ble_share_service.dart) and the receiver (ble_receive_service.dart). The
// native peripheral (android/.../BleShareServer.kt) mirrors these UUIDs and
// encodings — keep the two in sync.
//
// A GATT attribute value is capped at 512 bytes, so the vCard is pulled in
// chunks: read `size` (uint32 LE), then loop { write the next offset to
// `offset` (uint32 LE), read `data` } until `size` bytes are assembled.

import 'dart:typed_data';

/// Fixed app-specific UUIDs (128-bit, lowercase — flutter_blue_plus compares
/// Guids case-insensitively but these are also matched in Kotlin).
class BleProtocol {
  BleProtocol._();

  static const String serviceUuid = '7f9a1b3e-c5d2-4b8a-9f6e-2d8f3a7c4e10';
  static const String sizeUuid = '7f9a1b3e-c5d2-4b8a-9f6e-2d8f3a7c4e11';
  static const String offsetUuid = '7f9a1b3e-c5d2-4b8a-9f6e-2d8f3a7c4e12';
  static const String dataUuid = '7f9a1b3e-c5d2-4b8a-9f6e-2d8f3a7c4e13';

  /// Refuse absurd `size` announcements. With photos included (base64 in
  /// vCard), a full address book can reach several MB, so 10 MB is the cap.
  /// A payload above this is a corrupt read or a hostile peer, not contacts.
  static const int maxPayloadBytes = 10 * 1024 * 1024;

  /// [v] as a 4-byte little-endian unsigned int (the `size`/`offset` format).
  static Uint8List encodeUint32Le(int v) {
    assert(v >= 0 && v <= 0xFFFFFFFF);
    return Uint8List(4)..buffer.asByteData().setUint32(0, v, Endian.little);
  }

  /// Reads the 4-byte little-endian unsigned int at the start of [bytes].
  /// Throws [FormatException] when there are fewer than 4 bytes.
  static int decodeUint32Le(List<int> bytes) {
    if (bytes.length < 4) {
      throw const FormatException('Expected at least 4 bytes for a uint32');
    }
    return Uint8List.fromList(
      bytes.sublist(0, 4),
    ).buffer.asByteData().getUint32(0, Endian.little);
  }

  /// Pulls [size] bytes by repeatedly calling [readAt] (which must write the
  /// offset and read the data characteristic) until the payload is complete.
  /// [onProgress] (if given) is called after every chunk with the running
  /// byte count and [size] — drives the receive screen's percentage on long
  /// (whole-book) transfers.
  ///
  /// Throws [StateError] on a stalled transfer (an empty chunk before [size]
  /// bytes arrived) or when the loop exceeds [maxReads] — both mean the sender
  /// went away or the link is corrupt, and the caller shows a transfer error.
  static Future<Uint8List> assembleChunks({
    required int size,
    required Future<List<int>> Function(int offset) readAt,
    void Function(int received, int total)? onProgress,
    int maxReads = 4096,
  }) async {
    if (size < 0 || size > maxPayloadBytes) {
      throw StateError('Unreasonable payload size: $size bytes');
    }
    final out = BytesBuilder(copy: false);
    var reads = 0;
    while (out.length < size) {
      if (++reads > maxReads) {
        throw StateError('Transfer did not finish within $maxReads reads');
      }
      final chunk = await readAt(out.length);
      if (chunk.isEmpty) {
        throw StateError('Transfer stalled at ${out.length} of $size bytes');
      }
      out.add(chunk);
      onProgress?.call(out.length, size);
    }
    final bytes = out.takeBytes();
    // A sender never over-serves (chunks are sliced to the remaining length),
    // so extra bytes mean the offset write was ignored; fail loudly rather
    // than hand a torn vCard to the parser.
    if (bytes.length != size) {
      throw StateError('Expected $size bytes, got ${bytes.length}');
    }
    return bytes;
  }
}
