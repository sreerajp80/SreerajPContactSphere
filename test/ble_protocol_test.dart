// test/ble_protocol_test.dart
//
// Pure-Dart tests for the BLE contact-exchange wire protocol
// (lib/services/ble_protocol.dart): the uint32 little-endian encoding shared
// with the native peripheral, and the chunk-assembly loop the receiver runs.

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_contacts_dialer/services/ble_protocol.dart';

/// A fake sender: serves [payload] the way BleShareServer.kt does — at most
/// [chunkSize] bytes per read, sliced to the remaining length, empty at EOF.
Future<List<int>> Function(int) fakeSender(List<int> payload, int chunkSize) {
  return (int offset) async {
    if (offset >= payload.length) return const <int>[];
    final end = (offset + chunkSize).clamp(0, payload.length);
    return payload.sublist(offset, end);
  };
}

void main() {
  group('uint32 little-endian encoding', () {
    test('round-trips representative values', () {
      for (final v in <int>[0, 1, 0xFF, 0x1234, 0xFFFFFF, 0xFFFFFFFF]) {
        expect(BleProtocol.decodeUint32Le(BleProtocol.encodeUint32Le(v)), v);
      }
    });

    test('encodes least-significant byte first (matches the Kotlin side)', () {
      expect(
        BleProtocol.encodeUint32Le(0x0A0B0C0D),
        equals([0x0D, 0x0C, 0x0B, 0x0A]),
      );
    });

    test('decode ignores trailing bytes beyond the first four', () {
      expect(BleProtocol.decodeUint32Le([1, 0, 0, 0, 99, 99]), 1);
    });

    test('decode throws on fewer than 4 bytes', () {
      expect(
        () => BleProtocol.decodeUint32Le([1, 2, 3]),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('assembleChunks', () {
    final vcard = utf8.encode(
      'BEGIN:VCARD\r\nVERSION:3.0\r\nN:P;Sreeraj;;;\r\nFN:Sreeraj P\r\n'
      'TEL;TYPE=CELL:+919999999999\r\nEND:VCARD\r\n',
    );

    test('reassembles a payload served in small chunks', () async {
      final bytes = await BleProtocol.assembleChunks(
        size: vcard.length,
        readAt: fakeSender(vcard, 7),
      );
      expect(bytes, equals(Uint8List.fromList(vcard)));
    });

    test('single read when the chunk is bigger than the payload', () async {
      var reads = 0;
      final bytes = await BleProtocol.assembleChunks(
        size: vcard.length,
        readAt: (offset) {
          reads++;
          return fakeSender(vcard, 512)(offset);
        },
      );
      expect(bytes, equals(Uint8List.fromList(vcard)));
      expect(reads, 1);
    });

    test(
      'reports monotonic progress after every chunk, ending at size',
      () async {
        final calls = <(int, int)>[];
        await BleProtocol.assembleChunks(
          size: vcard.length,
          readAt: fakeSender(vcard, 10),
          onProgress: (received, total) => calls.add((received, total)),
        );
        expect(calls, isNotEmpty);
        expect(calls.last.$1, vcard.length);
        for (var i = 0; i < calls.length; i++) {
          expect(calls[i].$2, vcard.length); // total is always the full size
          if (i > 0) {
            expect(calls[i].$1, greaterThan(calls[i - 1].$1)); // strictly grows
          }
        }
      },
    );

    test('empty payload needs no reads', () async {
      final bytes = await BleProtocol.assembleChunks(
        size: 0,
        readAt: (offset) async => fail('must not read'),
      );
      expect(bytes, isEmpty);
    });

    test('throws when the sender stalls (empty chunk before the end)', () {
      expect(
        BleProtocol.assembleChunks(
          size: vcard.length + 10, // announces more than it serves
          readAt: fakeSender(vcard, 16),
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('throws when a misbehaving sender over-serves past size', () {
      expect(
        BleProtocol.assembleChunks(
          size: 5,
          readAt: (offset) async => List<int>.filled(9, 0), // ignores offset
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('throws instead of looping forever within maxReads', () {
      expect(
        BleProtocol.assembleChunks(
          size: 100,
          maxReads: 3,
          readAt: (offset) async => const [1], // 1 byte per read: too slow
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('rejects an absurd announced size', () {
      expect(
        BleProtocol.assembleChunks(
          size: BleProtocol.maxPayloadBytes + 1,
          readAt: (offset) async => const [1],
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}
