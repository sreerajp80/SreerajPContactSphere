// test/air_qr_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_contacts_dialer/models/air_qr_frame.dart';
import 'package:smart_contacts_dialer/services/air_qr_service.dart';

void main() {
  group('AirQrService & AirQrFrame', () {
    test('computeCrc32 calculates consistent checksums', () {
      final bytes = [65, 66, 67, 68]; // "ABCD"
      final crc1 = AirQrService.computeCrc32(bytes);
      final crc2 = AirQrService.computeCrc32(bytes);
      expect(crc1, equals(crc2));
      expect(crc1, isNot(equals(0)));
    });

    test('encodePayload generates systematic and parity frames', () {
      const samplePayload = 'BEGIN:VCARD\r\nVERSION:3.0\r\nFN:John Doe\r\nTEL:1234567890\r\nEND:VCARD';
      final frames = AirQrService.encodePayload(samplePayload, blockSize: 30);

      expect(frames.isNotEmpty, isTrue);
      expect(frames.any((f) => !f.isParity), isTrue); // Has systematic frames
      expect(frames.any((f) => f.isParity), isTrue); // Has fountain parity frames
    });

    test('AirQrFrame.parse and toQrString round-trip systematic frame', () {
      const frame = AirQrFrame(
        streamId: '123456',
        totalBlocks: 5,
        sequenceIndex: 2,
        isParity: false,
        degree: 1,
        indices: [2],
        checksum: 987654,
        payloadBytes: [1, 2, 3, 4],
      );

      final qrStr = frame.toQrString();
      final parsed = AirQrFrame.parse(qrStr);

      expect(parsed, isNotNull);
      expect(parsed!.streamId, equals('123456'));
      expect(parsed.totalBlocks, equals(5));
      expect(parsed.sequenceIndex, equals(2));
      expect(parsed.isParity, isFalse);
      expect(parsed.checksum, equals(987654));
      expect(parsed.payloadBytes, equals([1, 2, 3, 4]));
    });

    test('AirQrFrame.parse and toQrString round-trip LT Fountain parity frame', () {
      const frame = AirQrFrame(
        streamId: '123456',
        totalBlocks: 5,
        sequenceIndex: -1,
        isParity: true,
        degree: 2,
        indices: [0, 2],
        checksum: 987654,
        payloadBytes: [5, 6, 7, 8],
      );

      final qrStr = frame.toQrString();
      final parsed = AirQrFrame.parse(qrStr);

      expect(parsed, isNotNull);
      expect(parsed!.streamId, equals('123456'));
      expect(parsed.isParity, isTrue);
      expect(parsed.degree, equals(2));
      expect(parsed.indices, equals([0, 2]));
    });

    test('AirQrService full encode and decode stream reassembly', () {
      const payload = 'BEGIN:VCARD\r\nVERSION:3.0\r\nFN:Alice Smith\r\nTEL:9876543210\r\nEMAIL:alice@example.com\r\nEND:VCARD';
      final frames = AirQrService.encodePayload(payload, blockSize: 40);

      final decoder = AirQrService();
      AirQrProgress progress = const AirQrProgress(status: AirQrStatus.idle);

      for (final frame in frames) {
        progress = decoder.processFrameString(frame.toQrString(), progress);
        if (progress.status == AirQrStatus.completed) break;
      }

      expect(progress.status, equals(AirQrStatus.completed));
      expect(progress.reassembledContent, equals(payload));
    });
  });
}
