// lib/models/call_state.dart

/// The Telecom call lifecycle, mirroring the native `Call.STATE_*` names that
/// [CallRegistry] emits over the platform channel.
enum CallPhase {
  none,
  connecting,
  dialing,
  ringing,
  active,
  holding,
  disconnecting,
  disconnected,
  selecting,
  unknown;

  static CallPhase fromName(String? name) {
    switch (name) {
      case 'connecting':
        return CallPhase.connecting;
      case 'dialing':
        return CallPhase.dialing;
      case 'ringing':
        return CallPhase.ringing;
      case 'active':
        return CallPhase.active;
      case 'holding':
        return CallPhase.holding;
      case 'disconnecting':
        return CallPhase.disconnecting;
      case 'disconnected':
        return CallPhase.disconnected;
      case 'selecting':
        return CallPhase.selecting;
      case null:
        return CallPhase.none;
      default:
        return CallPhase.unknown;
    }
  }

  /// A call the user is actively engaged with (has a live in-call screen).
  bool get isOngoing =>
      this == CallPhase.connecting ||
      this == CallPhase.dialing ||
      this == CallPhase.ringing ||
      this == CallPhase.active ||
      this == CallPhase.holding;

  /// An incoming call awaiting answer/reject.
  bool get isIncoming => this == CallPhase.ringing;
}

/// Whether a call is incoming or outgoing, as reported by the native bridge
/// (`Call.Details.getCallDirection` on API 29+, else a ringing-based heuristic).
enum CallDirection {
  incoming,
  outgoing,
  unknown;

  static CallDirection fromName(String? name) {
    switch (name) {
      case 'incoming':
        return CallDirection.incoming;
      case 'outgoing':
        return CallDirection.outgoing;
      default:
        return CallDirection.unknown;
    }
  }
}

/// Immutable snapshot of the active call as reported by the native Telecom
/// bridge. A null snapshot on the channel maps to [CallState.none].
class CallState {
  final String? number;
  final CallPhase phase;
  final bool muted;
  final bool speaker;
  final bool canHold;

  /// Epoch millis when the call connected, or 0 before it does. Drives the
  /// in-call duration timer.
  final int connectTimeMillis;

  /// Epoch millis when the call was created — for an incoming call, when it
  /// started ringing — or 0 when the platform doesn't report one. This is the
  /// instant the device call log stamps the call with, so [CallEventLogger]
  /// dates a missed call by it instead of by "now" (the ring *end*), keeping
  /// the app's row and the device's row on the same moment.
  final int creationTimeMillis;

  /// The `PhoneAccountHandle` id (SIM) the call is on — matches the device call
  /// log's PHONE_ACCOUNT_ID. Null when unknown/unavailable.
  final String? phoneAccountId;

  /// Incoming vs outgoing. Lets [CallEventLogger] log incoming/missed calls
  /// without double-logging the outgoing calls the app places itself.
  final CallDirection direction;

  /// Stable id the native bridge assigns per physical call (0 when there's no
  /// call). Lets [CallEventLogger] write exactly one Recents row per call even
  /// if the call flaps through more than one end cycle.
  final int callId;

  /// The primary call is a merged conference (multiple parties on one line).
  final bool isConference;

  /// A second call can be dialed now ("Add call"): a call is up and none is
  /// ringing/dialing/connecting. Drives the Add-call button's visibility.
  final bool canAddCall;

  /// The two calls can be conferenced together ("Merge"). Only true when the
  /// carrier/network reports conference support, so the button hides otherwise.
  final bool canMerge;

  /// The foreground and background calls can be swapped ("Swap"): either a
  /// conference swap, or two independent calls to toggle between.
  final bool canSwap;

  /// DTMF touch-tones can be sent right now (the primary call is connected).
  final bool canDtmf;

  /// The background/held call's number, or null when there's only one call.
  /// Drives the "on hold" banner.
  final String? heldNumber;

  /// The background/held call's phase (typically [CallPhase.holding]).
  final CallPhase heldPhase;

  /// The network's STIR/SHAKEN caller-number verification for an incoming
  /// call: 'passed' | 'failed' | 'not_verified', or null when the platform /
  /// carrier doesn't report one (pre-API-30, outgoing, unsupported network).
  /// 'failed' means the network says the caller ID may be spoofed.
  final String? verificationStatus;

  /// Why the call ended, in the `AppCallOutcome` vocabulary — 'answered',
  /// 'no_answer', 'busy', 'declined', 'cancelled' or 'failed'. Null while the
  /// call is still running, and whenever Telecom's reason isn't one we map.
  ///
  /// This is the only source that can say *why* an outgoing call didn't
  /// connect: the device call log records duration but never a reason.
  final String? outcome;

  const CallState({
    required this.number,
    required this.phase,
    required this.muted,
    required this.speaker,
    required this.canHold,
    required this.connectTimeMillis,
    this.creationTimeMillis = 0,
    this.phoneAccountId,
    this.direction = CallDirection.unknown,
    this.callId = 0,
    this.isConference = false,
    this.canAddCall = false,
    this.canMerge = false,
    this.canSwap = false,
    this.canDtmf = false,
    this.heldNumber,
    this.heldPhase = CallPhase.none,
    this.verificationStatus,
    this.outcome,
  });

  /// No active call.
  static const CallState none = CallState(
    number: null,
    phase: CallPhase.none,
    muted: false,
    speaker: false,
    canHold: false,
    connectTimeMillis: 0,
  );

  bool get hasCall => phase != CallPhase.none;

  factory CallState.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) return CallState.none;
    return CallState(
      number: map['number'] as String?,
      phase: CallPhase.fromName(map['state'] as String?),
      muted: map['muted'] as bool? ?? false,
      speaker: map['speaker'] as bool? ?? false,
      canHold: map['canHold'] as bool? ?? false,
      connectTimeMillis: (map['connectTimeMillis'] as num?)?.toInt() ?? 0,
      creationTimeMillis: (map['creationTimeMillis'] as num?)?.toInt() ?? 0,
      phoneAccountId: map['phoneAccountId'] as String?,
      direction: CallDirection.fromName(map['direction'] as String?),
      callId: (map['callId'] as num?)?.toInt() ?? 0,
      isConference: map['isConference'] as bool? ?? false,
      canAddCall: map['canAddCall'] as bool? ?? false,
      canMerge: map['canMerge'] as bool? ?? false,
      canSwap: map['canSwap'] as bool? ?? false,
      canDtmf: map['canDtmf'] as bool? ?? false,
      heldNumber: map['heldNumber'] as String?,
      heldPhase: CallPhase.fromName(map['heldState'] as String?),
      verificationStatus: map['verificationStatus'] as String?,
      outcome: map['outcome'] as String?,
    );
  }
}
