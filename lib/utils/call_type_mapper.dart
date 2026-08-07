// lib/utils/call_type_mapper.dart
//
// One place that turns the `call_log` package's [CallType] into the string the
// app stores in `call_logs.call_type`.
//
// This used to be duplicated in CallService (reconciling a call the app placed)
// and CallLogImportService (importing the device log), and the two copies
// disagreed: one stored a blocked call as 'missed', the other as 'blocked'. Both
// also dropped the Wi-Fi calling types into the `outgoing` fallback, so an
// incoming Wi-Fi call showed in Recents with an outgoing arrow. Sharing one
// mapper means a call reads the same however it was recorded.

import 'package:call_log/call_log.dart';

/// The stored `call_type` values Recents knows how to render
/// (see `CallHistoryScreenState._typeIcon`).
class AppCallType {
  static const String incoming = 'incoming';
  static const String outgoing = 'outgoing';
  static const String missed = 'missed';
  static const String blocked = 'blocked';
}

/// The stored `call_logs.call_outcome` values — **what happened** on the call,
/// as opposed to [AppCallType] which says **which way it went**.
///
/// `call_type` conflates the two: 'missed' and 'blocked' both imply "not
/// answered", while 'outgoing' says nothing at all, which is why an outgoing
/// call that rang out used to look identical to one that was picked up.
///
/// A null outcome means "not known" — every row written before this column
/// existed, and rows imported from the device log where nothing settles it.
/// Recents shows nothing rather than guessing when the outcome is null.
class AppCallOutcome {
  /// The call reached `Call.STATE_ACTIVE` — someone actually talked.
  static const String answered = 'answered';

  /// Rang out without ever connecting.
  static const String noAnswer = 'no_answer';

  /// The other side was on another call.
  static const String busy = 'busy';

  /// The other side actively rejected it.
  static const String declined = 'declined';

  /// The user hung up before it rang out.
  static const String cancelled = 'cancelled';

  /// Network or system error — says nothing about the other party.
  static const String failed = 'failed';

  static const Set<String> all = {
    answered,
    noAnswer,
    busy,
    declined,
    cancelled,
    failed,
  };
}

/// The outcome implied by a call having connected or not.
///
/// This is the **weakest** source and is only for rows where nothing better is
/// available (chiefly the device call log, which reports duration and nothing
/// else about why a call ended). Some devices round a very short answered call
/// down to 0 seconds, so a `no_answer` from here must only ever fill a gap —
/// never overwrite an outcome the app observed live via `wasActive`.
///
/// Returns null for a null duration, which means "not reconciled yet", not
/// "nobody answered".
String? outcomeFromDuration(int? duration) {
  if (duration == null) return null;
  return duration > 0 ? AppCallOutcome.answered : AppCallOutcome.noAnswer;
}

/// The outcome a device call-log entry implies, using its type where that is
/// more specific than the duration alone.
///
/// The device log does distinguish a rejected inbound call, which duration
/// cannot. Everything else falls back to [outcomeFromDuration].
String? mapDeviceCallOutcome(CallType? type, int? duration) {
  switch (type) {
    case CallType.rejected:
      return AppCallOutcome.declined;
    case CallType.missed:
      return AppCallOutcome.noAnswer;
    case CallType.voiceMail:
      // Reached the mailbox: the person never picked up.
      return AppCallOutcome.noAnswer;
    default:
      return outcomeFromDuration(duration);
  }
}

/// A stored outcome string, or null if it isn't one we recognise.
///
/// Guards the values arriving from the native side, so an unexpected string
/// shows as "unknown" instead of reaching the UI as a label nobody wrote.
String? normalizeCallOutcome(String? outcome) =>
    outcome != null && AppCallOutcome.all.contains(outcome) ? outcome : null;

/// How an outcome reads in Recents. Null when nothing should be shown:
/// [AppCallOutcome.answered] is covered by the duration already on the row, and
/// an unknown outcome must not invent text.
///
/// [callType] (an [AppCallType] value) is what the same outcome is *called* from
/// each side: a call that rang out unanswered is "No answer" when we placed it,
/// but "Missed" when it came in — the stored outcome is the same fact either
/// way. Omit it and the outgoing wording is used, as it always was.
String? callOutcomeLabel(String? outcome, [String? callType]) {
  final inbound =
      callType == AppCallType.incoming || callType == AppCallType.missed;
  switch (outcome) {
    case AppCallOutcome.noAnswer:
      return inbound ? 'Missed' : 'No answer';
    case AppCallOutcome.busy:
      return 'Busy';
    case AppCallOutcome.declined:
      return 'Declined';
    case AppCallOutcome.cancelled:
      return 'Cancelled';
    case AppCallOutcome.failed:
      return 'Failed';
    default:
      return null;
  }
}

/// Whether an outgoing call got through. Drives which of the two outgoing icons
/// Recents draws: a null (unknown) outcome keeps the plain outgoing arrow, so
/// old and imported rows look exactly as they did before this column existed.
bool outgoingDidNotConnect(String? outcome) =>
    outcome != null && outcome != AppCallOutcome.answered;

/// Maps a device call-log entry type to the app's stored `call_type`.
///
/// - Wi-Fi calls carry their own types and are folded into plain in/out.
/// - A rejected call is stored as `missed`: from the user's side it is a call
///   that came in and was not talked on, which is how Recents reads `missed`.
/// - A voicemail entry is an incoming call that reached the mailbox.
/// - `unknown`/null keeps the historical `outgoing` fallback.
String mapDeviceCallType(CallType? type) {
  switch (type) {
    case CallType.incoming:
    case CallType.answeredExternally:
    case CallType.wifiIncoming:
    case CallType.voiceMail:
      return AppCallType.incoming;
    case CallType.missed:
    case CallType.rejected:
      return AppCallType.missed;
    case CallType.blocked:
      return AppCallType.blocked;
    case CallType.outgoing:
    case CallType.wifiOutgoing:
    case CallType.unknown:
    case null:
      return AppCallType.outgoing;
  }
}
