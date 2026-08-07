import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_contacts_dialer/services/telecom_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TelecomService DTMF tones', () {
    final calls = <MethodCall>[];

    setUp(() {
      calls.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(TelecomService.methodChannel, (call) async {
            calls.add(call);
            return null;
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(TelecomService.methodChannel, null);
    });

    test('playDtmf forwards digit and stopDtmf clears tone', () async {
      final telecom = TelecomService();
      await telecom.playDtmf('9');
      await telecom.stopDtmf();

      expect(calls.map((c) => c.method), ['playDtmf', 'stopDtmf']);
      expect(calls.first.arguments, {'digit': '9'});
    });
  });
}
