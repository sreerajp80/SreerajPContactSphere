// test/call_log_matching_test.dart
//
// The two pure pieces the device call-log sync rests on: how a device call type
// becomes the app's stored `call_type`, and how a device entry is recognised as
// a call Recents already has. Both are static/pure, so no database is involved.

import 'package:call_log/call_log.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_contacts_dialer/repositories/call_log_repository.dart';
import 'package:smart_contacts_dialer/utils/call_type_mapper.dart';

void main() {
  group('mapDeviceCallType', () {
    test('maps the plain directions', () {
      expect(mapDeviceCallType(CallType.incoming), AppCallType.incoming);
      expect(mapDeviceCallType(CallType.outgoing), AppCallType.outgoing);
      expect(mapDeviceCallType(CallType.missed), AppCallType.missed);
      expect(mapDeviceCallType(CallType.blocked), AppCallType.blocked);
    });

    test('folds Wi-Fi calls into the matching direction', () {
      // Regression: both mappers dropped these into the `outgoing` fallback, so
      // an incoming Wi-Fi call showed in Recents with an outgoing arrow and a
      // missed one never read as missed.
      expect(mapDeviceCallType(CallType.wifiIncoming), AppCallType.incoming);
      expect(mapDeviceCallType(CallType.wifiOutgoing), AppCallType.outgoing);
    });

    test('treats answered-externally and voicemail as incoming', () {
      expect(
        mapDeviceCallType(CallType.answeredExternally),
        AppCallType.incoming,
      );
      expect(mapDeviceCallType(CallType.voiceMail), AppCallType.incoming);
    });

    test('treats a rejected call as missed', () {
      expect(mapDeviceCallType(CallType.rejected), AppCallType.missed);
    });

    test('falls back to outgoing for unknown/absent types', () {
      expect(mapDeviceCallType(CallType.unknown), AppCallType.outgoing);
      expect(mapDeviceCallType(null), AppCallType.outgoing);
    });
  });

  group('CallLogRepository.matchKey', () {
    test('reduces a number to its last ten digits', () {
      expect(CallLogRepository.matchKey('+919876543210'), '9876543210');
      expect(CallLogRepository.matchKey('09876543210'), '9876543210');
      expect(CallLogRepository.matchKey('98765 43210'), '9876543210');
    });

    test('leaves short numbers whole', () {
      expect(CallLogRepository.matchKey('139'), '139');
    });

    test('is empty for empty string and uppercase for non-digit strings', () {
      expect(CallLogRepository.matchKey(''), '');
      expect(CallLogRepository.matchKey('Unknown'), 'UNKNOWN');
    });
  });

  group('CallLogRepository.findMatch', () {
    StoredCall stored(int id, String number, DateTime at) => StoredCall(
      id: id,
      matchKey: CallLogRepository.matchKey(number),
      epochMillis: at.millisecondsSinceEpoch,
      duration: null,
      callType: 'outgoing',
    );

    final base = DateTime(2026, 7, 19, 10);

    test('matches the same call logged seconds apart', () {
      // The app logs a call when it is *placed*; the device logs when it
      // actually started. An exact-timestamp key treated these as two calls and
      // the import inserted a twin of every call already in Recents.
      final calls = [stored(1, '+919876543210', base)];
      final match = CallLogRepository.findMatch(
        calls,
        CallLogRepository.matchKey('09876543210'),
        base.add(const Duration(seconds: 8)).millisecondsSinceEpoch,
      );
      expect(match?.id, 1);
    });

    test('does not match beyond the window', () {
      final calls = [stored(1, '+919876543210', base)];
      final match = CallLogRepository.findMatch(
        calls,
        CallLogRepository.matchKey('9876543210'),
        base
            .add(CallLogRepository.matchWindow + const Duration(seconds: 5))
            .millisecondsSinceEpoch,
      );
      expect(match, isNull);
    });

    test('does not match a different number at the same moment', () {
      final calls = [stored(1, '+919876543210', base)];
      final match = CallLogRepository.findMatch(
        calls,
        CallLogRepository.matchKey('+919000000001'),
        base.millisecondsSinceEpoch,
      );
      expect(match, isNull);
    });

    test('picks the closest call when two are inside the window', () {
      final calls = [
        stored(1, '+919876543210', base),
        stored(2, '+919876543210', base.add(const Duration(seconds: 60))),
      ];
      final match = CallLogRepository.findMatch(
        calls,
        CallLogRepository.matchKey('9876543210'),
        base.add(const Duration(seconds: 50)).millisecondsSinceEpoch,
      );
      expect(match?.id, 2);
    });

    test('never matches an empty key', () {
      final calls = [stored(1, '', base)];
      final match = CallLogRepository.findMatch(
        calls,
        '',
        base.millisecondsSinceEpoch,
      );
      expect(match, isNull);
    });
  });

  group('StoredCall.needsOutcome', () {
    test('is true while a call is still provisional', () {
      const provisional = StoredCall(
        id: 1,
        matchKey: '9876543210',
        epochMillis: 0,
        duration: null,
        callType: 'outgoing',
      );
      expect(provisional.needsOutcome, isTrue);
    });

    test('is true while the row has no recorded outcome', () {
      // A row stored before `call_outcome` existed. It has a duration, so the
      // old rule called it complete — but nothing on it says what happened, and
      // the device-log import is the only thing that will ever fill that in.
      const noOutcome = StoredCall(
        id: 1,
        matchKey: '9876543210',
        epochMillis: 0,
        duration: 0,
        callType: 'missed',
      );
      expect(noOutcome.needsOutcome, isTrue);
    });

    test('is false once both the duration and the outcome are known', () {
      // A call that rang unanswered is 0 seconds and is still a finished call.
      const unanswered = StoredCall(
        id: 1,
        matchKey: '9876543210',
        epochMillis: 0,
        duration: 0,
        callType: 'missed',
        callOutcome: 'no_answer',
      );
      expect(unanswered.needsOutcome, isFalse);
    });
  });
}
