// test/app_pin_service_test.dart
//
// Verifies AppPinService's PIN + recovery-code handling with an in-memory fake
// of the flutter_secure_storage platform channel (no device/Keystore needed).
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_contacts_dialer/services/app_pin_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final store = <String, String>{};

  setUp(() {
    store.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          final args = (call.arguments as Map?) ?? const {};
          final key = args['key'] as String?;
          switch (call.method) {
            case 'write':
              store[key!] = args['value'] as String;
              return null;
            case 'read':
              return store[key];
            case 'delete':
              store.remove(key);
              return null;
            case 'containsKey':
              return store.containsKey(key);
            case 'readAll':
              return Map<String, String>.from(store);
            case 'deleteAll':
              store.clear();
              return null;
            default:
              return null;
          }
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test(
    'setPin then verifyPin accepts the correct PIN, rejects others',
    () async {
      final service = AppPinService();
      expect(await service.hasPin(), isFalse);

      final code = await service.setPin('1234');
      expect(code, isNotEmpty);
      expect(await service.hasPin(), isTrue);

      expect(await service.verifyPin('1234'), isTrue);
      expect(await service.verifyPin('4321'), isFalse);
      expect(await service.verifyPin('12345'), isFalse);
    },
  );

  test('the raw PIN is never stored, only a hash', () async {
    await AppPinService().setPin('987654');
    expect(store.values, isNot(contains('987654')));
    // A salt and a hash exist for both the PIN and the recovery code.
    expect(store.length, greaterThanOrEqualTo(4));
  });

  test(
    'recovery code verifies case-insensitively and ignores spaces',
    () async {
      final service = AppPinService();
      final code = await service.setPin('0000');

      expect(await service.verifyRecoveryCode(code), isTrue);
      expect(await service.verifyRecoveryCode(code.toLowerCase()), isTrue);
      // Spaces inserted by a user copying the code by hand are ignored.
      final spaced = '${code.substring(0, 4)} ${code.substring(4)}';
      expect(await service.verifyRecoveryCode(spaced), isTrue);
      expect(await service.verifyRecoveryCode('WRONGCODE0'), isFalse);
    },
  );

  test('clearPin removes the PIN and recovery code', () async {
    final service = AppPinService();
    final code = await service.setPin('2468');

    await service.clearPin();
    expect(await service.hasPin(), isFalse);
    expect(await service.verifyPin('2468'), isFalse);
    expect(await service.verifyRecoveryCode(code), isFalse);
  });

  test('a new setPin issues a different recovery code', () async {
    final service = AppPinService();
    final first = await service.setPin('1111');
    final second = await service.setPin('2222');
    expect(first, isNot(equals(second)));
    // The old recovery code no longer works.
    expect(await service.verifyRecoveryCode(first), isFalse);
    expect(await service.verifyRecoveryCode(second), isTrue);
  });
}
