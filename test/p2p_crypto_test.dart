// Unit tests for the P2P sync crypto + pairing-code helpers. No database or
// socket here — just the code helpers and the encrypt/decrypt round-trip (via
// the @visibleForTesting hooks), including the key guarantee that a wrong
// pairing code fails to decrypt.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_contacts_dialer/services/p2p_sync_service.dart';

void main() {
  final service = P2PSyncService();
  final salt = List<int>.generate(16, (i) => i); // fixed salt for determinism

  group('pairing code', () {
    test('is 64 chars over the safe alphabet', () {
      const alphabet = '23456789ABCDEFGHJKMNPQRSTUVWXYZ';
      for (var i = 0; i < 20; i++) {
        final code = service.generatePairingCode();
        expect(code.length, 64);
        for (final ch in code.split('')) {
          expect(alphabet.contains(ch), isTrue, reason: 'bad char "$ch"');
        }
      }
    });

    test('is different each time', () {
      final a = service.generatePairingCode();
      final b = service.generatePairingCode();
      expect(a, isNot(equals(b)));
    });

    test('normalizeCode strips case and separators', () {
      expect(P2PSyncService.normalizeCode('abcd-2345 hjkm'), 'ABCD2345HJKM');
      // Ambiguous chars (0/O/1/I/L) are not in the alphabet, so they drop out.
      expect(P2PSyncService.normalizeCode('OIL01'), '');
    });

    test('grouped display normalizes back to the raw code', () {
      final code = service.generatePairingCode();
      final grouped = P2PSyncService.groupCode(code);
      expect(grouped.contains('-'), isTrue);
      expect(P2PSyncService.normalizeCode(grouped), code);
    });
  });

  group('encrypt / decrypt', () {
    test('round-trips arbitrary text with the right code', () async {
      const code = 'RIGHTCODE2345';
      const message = 'HELLO_SYNC · unicode ✓ · {"k":"v"}';
      final enc = await service.debugEncrypt(message, code, salt);
      // Ciphertext is a single base64 line, not the plaintext.
      expect(enc.contains('\n'), isFalse);
      expect(enc, isNot(contains('HELLO_SYNC')));
      final dec = await service.debugDecrypt(enc, code, salt);
      expect(dec, message);
    });

    test('a wrong code fails to decrypt (authentication guarantee)', () async {
      final enc = await service.debugEncrypt(
        'ACCEPT_SYNC',
        'CODEAAAA2345',
        salt,
      );
      expect(
        () => service.debugDecrypt(enc, 'CODEBBBB2345', salt),
        throwsA(anything),
      );
    });

    test('the same code with a different salt fails to decrypt', () async {
      const code = 'SAMECODE2345';
      final enc = await service.debugEncrypt('payload', code, salt);
      final otherSalt = List<int>.generate(16, (i) => i + 100);
      expect(
        () => service.debugDecrypt(enc, code, otherSalt),
        throwsA(anything),
      );
    });

    test('round-trips a JSON payload unchanged', () async {
      const code = 'JSONCODE2345';
      final payload = jsonEncode({
        'tables': {
          'contacts': [
            {'id': 1, 'first_name': 'Alice'},
          ],
        },
      });
      final enc = await service.debugEncrypt(payload, code, salt);
      final dec = await service.debugDecrypt(enc, code, salt);
      expect(jsonDecode(dec), jsonDecode(payload));
    });
  });

  group('QR pairing URI', () {
    test('build → parse round-trips ip/port/code', () {
      final uri = P2PSyncService.buildSyncUri(
        ip: '192.168.1.42',
        port: 51234,
        code: 'ABCD2345HJKM',
      );
      final parsed = P2PSyncService.parseSyncUri(uri);
      expect(parsed, isNotNull);
      expect(parsed!.ip, '192.168.1.42');
      expect(parsed.port, 51234);
      expect(parsed.code, 'ABCD2345HJKM');
    });

    test('rejects a foreign scheme', () {
      expect(
        P2PSyncService.parseSyncUri(
          'https://sync?v=1&ip=1.2.3.4&port=5&code=X',
        ),
        isNull,
      );
    });

    test('rejects a wrong version', () {
      expect(
        P2PSyncService.parseSyncUri(
          'contactspheresync://sync?v=9&ip=1.2.3.4&port=5&code=X',
        ),
        isNull,
      );
    });

    test('rejects a bad or absent port', () {
      expect(
        P2PSyncService.parseSyncUri(
          'contactspheresync://sync?v=1&ip=1.2.3.4&code=X',
        ),
        isNull,
      );
      expect(
        P2PSyncService.parseSyncUri(
          'contactspheresync://sync?v=1&ip=1.2.3.4&port=0&code=X',
        ),
        isNull,
      );
      expect(
        P2PSyncService.parseSyncUri(
          'contactspheresync://sync?v=1&ip=1.2.3.4&port=99999&code=X',
        ),
        isNull,
      );
    });

    test('rejects a missing code and plain garbage', () {
      expect(
        P2PSyncService.parseSyncUri(
          'contactspheresync://sync?v=1&ip=1.2.3.4&port=5',
        ),
        isNull,
      );
      expect(P2PSyncService.parseSyncUri('not a uri at all'), isNull);
    });
  });
}
