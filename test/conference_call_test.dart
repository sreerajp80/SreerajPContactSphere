// Unit tests for the conference/multi-call additions: CallState parsing of the
// new snapshot fields, and TelecomService's new controls no-opping off Android
// (where the platform channels don't exist), matching the rest of the service.

import 'package:flutter/services.dart' show MethodCall;
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_contacts_dialer/models/call_state.dart';
import 'package:smart_contacts_dialer/services/telecom_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CallState.fromMap — conference/multi-call fields', () {
    test('parses the new capability + held-call fields', () {
      final state = CallState.fromMap(const {
        'number': '5550100',
        'state': 'active',
        'isConference': true,
        'canAddCall': true,
        'canMerge': true,
        'canSwap': true,
        'canDtmf': true,
        'heldNumber': '5550199',
        'heldState': 'holding',
      });

      expect(state.phase, CallPhase.active);
      expect(state.isConference, isTrue);
      expect(state.canAddCall, isTrue);
      expect(state.canMerge, isTrue);
      expect(state.canSwap, isTrue);
      expect(state.canDtmf, isTrue);
      expect(state.heldNumber, '5550199');
      expect(state.heldPhase, CallPhase.holding);
    });

    test('defaults the new fields when absent (single-call snapshot)', () {
      final state = CallState.fromMap(const {
        'number': '5550100',
        'state': 'active',
      });

      expect(state.isConference, isFalse);
      expect(state.canAddCall, isFalse);
      expect(state.canMerge, isFalse);
      expect(state.canSwap, isFalse);
      expect(state.canDtmf, isFalse);
      expect(state.heldNumber, isNull);
      expect(state.heldPhase, CallPhase.none);
    });

    test('CallState.none carries no held call', () {
      expect(CallState.none.heldNumber, isNull);
      expect(CallState.none.heldPhase, CallPhase.none);
      expect(CallState.none.canMerge, isFalse);
    });
  });

  group('TelecomService — new controls forward to the platform channel', () {
    // flutter_test reports the platform as Android, so the service's _supported
    // guard is satisfied and each call reaches the method channel. Assert the
    // method name (and DTMF digit) are forwarded verbatim to the native side.
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

    test(
      'playDtmf forwards the digit; stop/merge/swap forward by name',
      () async {
        final telecom = TelecomService();
        await telecom.playDtmf('5');
        await telecom.stopDtmf();
        await telecom.mergeCalls();
        await telecom.swapCalls();

        expect(calls.map((c) => c.method), [
          'playDtmf',
          'stopDtmf',
          'merge',
          'swap',
        ]);
        expect(calls.first.arguments, {'digit': '5'});
      },
    );
  });
}
