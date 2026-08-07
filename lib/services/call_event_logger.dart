// lib/services/call_event_logger.dart
import 'dart:async';

import 'package:smart_contacts_dialer/core/utils/call_log_write_lock.dart';
import 'package:smart_contacts_dialer/models/call_state.dart';
import 'package:smart_contacts_dialer/repositories/call_log_repository.dart';
import 'package:smart_contacts_dialer/repositories/contact_repository.dart';
import 'package:smart_contacts_dialer/repositories/interaction_repository.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/state/call_log_events.dart';
import 'package:smart_contacts_dialer/services/relationship_scoring_service.dart';
import 'package:smart_contacts_dialer/services/sim_service.dart';
import 'package:smart_contacts_dialer/services/telecom_service.dart';
import 'package:smart_contacts_dialer/utils/call_type_mapper.dart';

/// Logs **incoming and missed** calls into `call_logs` so they show up in
/// Recents with their SIM and duration.
///
/// Outgoing calls the app places are already logged (provisionally + reconciled)
/// by [CallService] via [CallLifecycleMixin]; this logger deliberately handles
/// only the *incoming* direction so those aren't double-logged. It works only
/// while ContactSphere is the default phone app (the in-call service is what
/// surfaces incoming calls); otherwise the event stream is empty and it no-ops.
///
/// Lifecycle: [start] once at app launch (see `main.dart`). It watches
/// [TelecomService.callEvents], accumulates the current call's number / SIM /
/// direction / connect-time across snapshots, and on call end logs a single row.
class CallEventLogger {
  CallEventLogger({
    TelecomService? telecom,
    InteractionRepository? interactions,
    ContactRepository? contacts,
    RelationshipScoringService? scoring,
    SimService? sims,
    CallLogRepository? callLogs,
  }) : _telecom = telecom ?? TelecomService(),
       _interactions = interactions ?? InteractionRepository(),
       _contacts = contacts ?? ContactRepository(),
       _scoring = scoring ?? RelationshipScoringService(),
       _sims = sims ?? SimService(),
       _callLogs = callLogs ?? CallLogRepository();

  final TelecomService _telecom;
  final InteractionRepository _interactions;
  final ContactRepository _contacts;
  final CallLogRepository _callLogs;
  final RelationshipScoringService _scoring;
  final SimService _sims;

  StreamSubscription<CallState>? _sub;

  // ---- Accumulated state for the call currently in progress ----
  bool _hadCall = false;
  String? _number;
  String? _phoneAccountId;
  CallDirection _direction = CallDirection.unknown;
  int _connectTimeMillis = 0;

  /// Epoch millis when the call was created — for an incoming call, when it
  /// started ringing. This is the moment the device call log stamps the call
  /// with, so using it keeps the app's row and the device's row describing the
  /// same instant. 0 when the platform didn't report one.
  int _creationTimeMillis = 0;
  bool _wasActive = false;

  /// Id of the call currently being accumulated (from the native snapshot), and
  /// the id of the last call we wrote a row for. Together these guarantee a
  /// single Recents row per physical call even if it flaps through end cycles.
  int? _callId;
  int? _lastLoggedId;

  /// Begins observing call events. Safe to call more than once (no-op if already
  /// started) and safe off Android (the stream is empty there). Also drains any
  /// calls the screening service blocked while the app was down into Recents.
  void start() {
    _sub ??= _telecom.callEvents.listen(_onEvent);
    unawaited(drainBlockedCalls());
    unawaited(drainCallWaitingCalls());
    unawaited(drainOutgoingOutcomes());
  }

  /// Collects the calls the native call-screening service rejected (it never
  /// hands them to the in-call service, so [_onEvent] can't see them) and
  /// writes each as a 'blocked' Recents row at its original time. One-shot:
  /// the native side clears the journal on read, so re-calling is safe — the
  /// Recents screen also drains on load to pick up calls blocked while the
  /// app was already running.
  Future<void> drainBlockedCalls() async {
    try {
      final events = await _telecom.drainBlockedCallEvents();
      if (events.isEmpty) return;
      for (final event in events) {
        final contactId = await _resolveContactId(event.number);
        await CallLogWriteLock.run(
          () => _interactions.logCallIfNew(
            contactId: contactId,
            phoneNumber: event.number,
            callType: 'blocked',
            // Screened away before it ever rang, so nobody talked.
            callOutcome: AppCallOutcome.noAnswer,
            duration: 0,
            timestamp: event.when,
          ),
        );
      }
      CallLogEvents.instance.notifyCallLogged();
    } catch (_) {
      // Best-effort; a failed write loses at most this batch of rows (the
      // native journal was already cleared by the collect).
    }
  }

  /// Collects the call-waiting calls the native in-call service parked (incoming
  /// calls that ended while another call was live, so [_onEvent]'s snapshot —
  /// which only tracks the primary call — never saw them) and writes each as a
  /// Recents row at its original time, with its SIM: 'incoming' with the real
  /// duration when the call was answered, 'missed' with duration 0 otherwise.
  /// One-shot: the native side clears the journal on read, so re-calling is safe.
  Future<void> drainCallWaitingCalls() async {
    try {
      final events = await _telecom.drainCallWaitingEvents();
      if (events.isEmpty) return;
      for (final event in events) {
        final contactId = await _resolveContactId(event.number);
        final simLabel = await _sims.labelFor(event.phoneAccountId);
        await CallLogWriteLock.run(
          () => _interactions.logCallIfNew(
            contactId: contactId,
            phoneNumber: event.number,
            callType: event.wasActive ? 'incoming' : 'missed',
            callOutcome: event.wasActive
                ? AppCallOutcome.answered
                : AppCallOutcome.noAnswer,
            duration: event.wasActive ? event.durationSeconds : 0,
            timestamp: event.when,
            simId: event.phoneAccountId,
            simLabel: simLabel,
          ),
        );
      }
      CallLogEvents.instance.notifyCallLogged();
    } catch (_) {
      // Best-effort; a failed write loses at most this batch of rows (the
      // native journal was already cleared by the collect).
    }
  }

  /// Collects the outgoing-call outcomes the native in-call service parked and
  /// writes each onto the Recents row for that call.
  ///
  /// These are calls the app didn't place through [CallLifecycleMixin] — chiefly
  /// a Smart Redial retry, which is dialed natively and can fire with the app
  /// closed, so no screen was there to latch the reason from the event stream.
  /// Without this such a call could only ever fall back to the device log, which
  /// reports duration and nothing about *why* the call ended, so a busy line, a
  /// decline and a rang-out all read the same.
  ///
  /// Patch-only: it fills the outcome on a row that already exists and has none,
  /// and never inserts. Row creation for outgoing calls belongs to the
  /// device-log import, so this cannot produce a duplicate Recents entry.
  ///
  /// An event whose row doesn't exist yet is **kept for the next drain**, not
  /// dropped: the device sync that writes the row runs unawaited, so a drain
  /// triggered by app start or a Recents load routinely arrives first. The
  /// import then fires [CallLogEvents], Recents reloads, and this runs again
  /// with the row in place. See [_pendingOutcomes].
  ///
  /// One-shot on the native side: the journal clears on read.
  Future<void> drainOutgoingOutcomes() async {
    try {
      final drained = await _telecom.drainOutgoingOutcomeEvents();
      // Anything that arrived earlier and had no row yet gets another look.
      final events = [..._takePendingOutcomes(), ...drained];
      if (events.isEmpty) return;

      // One read covering every event in the batch.
      final since = events
          .map((e) => e.when)
          .reduce((a, b) => a.isBefore(b) ? a : b)
          .subtract(CallLogRepository.matchWindow);
      final stored = await _callLogs.storedCallsForMatching(since: since);

      var patched = false;
      for (final event in events) {
        final outcome = normalizeCallOutcome(event.outcome);
        if (outcome == null) continue;
        final match = CallLogRepository.findMatch(
          stored,
          CallLogRepository.matchKey(event.number),
          event.when.millisecondsSinceEpoch,
        );
        if (match == null) {
          // No row for this call yet — hold it for the next drain.
          _keepPendingOutcome(event);
          continue;
        }
        if (match.callOutcome != null) continue;
        final changed = await CallLogWriteLock.run(
          () => _interactions.backfillObservedOutcome(
            callLogId: match.id,
            callOutcome: outcome,
          ),
        );
        if (changed) patched = true;
      }
      if (patched) CallLogEvents.instance.notifyCallLogged();
    } catch (_) {
      // Best-effort; a failure costs at most the reason on these rows, never
      // the rows themselves.
    }
  }

  /// Outcomes drained from the native journal that had no Recents row to land on
  /// yet, waiting for the device import to write it.
  ///
  /// Static because the class is constructed ad-hoc at each call site (see
  /// `CallHistoryScreen._load`) — an instance field would give each of those its
  /// own empty buffer and the retry would never happen. Process-lifetime only:
  /// an entry that doesn't find its row before the app closes is simply lost,
  /// and the row keeps the import's duration-based outcome.
  static final List<({String number, DateTime when, String outcome})>
  _pendingOutcomes = [];

  /// Cap on [_pendingOutcomes] (oldest dropped). Anything near this means the
  /// device import isn't running at all, in which case the reasons are moot.
  static const int _maxPendingOutcomes = 50;

  /// How long an unmatched outcome is worth retrying. Past this the call is
  /// old enough that the import has certainly either written its row or never
  /// will, so holding on to it only risks stamping a stale reason on a row that
  /// happens to match later.
  static const Duration _pendingOutcomeTtl = Duration(hours: 6);

  /// Empties the retry buffer, returning what is still worth retrying.
  List<({String number, DateTime when, String outcome})>
  _takePendingOutcomes() {
    final cutoff = DateTime.now().subtract(_pendingOutcomeTtl);
    final out = _pendingOutcomes
        .where((e) => e.when.isAfter(cutoff))
        .toList(growable: false);
    _pendingOutcomes.clear();
    return out;
  }

  void _keepPendingOutcome(
    ({String number, DateTime when, String outcome}) event,
  ) {
    _pendingOutcomes.add(event);
    if (_pendingOutcomes.length > _maxPendingOutcomes) {
      _pendingOutcomes.removeAt(0);
    }
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
  }

  void _onEvent(CallState state) {
    if (state.hasCall) {
      // A different physical call than the one we're tracking → start fresh so
      // its details don't bleed into the new call's row.
      if (_callId != null && state.callId != _callId) _reset();
      _callId = state.callId;
      _hadCall = true;
      if (state.number != null && state.number!.isNotEmpty) {
        _number = state.number;
      }
      if (state.phoneAccountId != null) _phoneAccountId = state.phoneAccountId;
      if (state.direction != CallDirection.unknown) {
        _direction = state.direction;
      }
      if (state.connectTimeMillis > _connectTimeMillis) {
        _connectTimeMillis = state.connectTimeMillis;
      }
      // Ring start: keep the earliest the platform reported for this call.
      if (state.creationTimeMillis > 0 &&
          (_creationTimeMillis == 0 ||
              state.creationTimeMillis < _creationTimeMillis)) {
        _creationTimeMillis = state.creationTimeMillis;
      }
      if (state.phase == CallPhase.active) _wasActive = true;
    }

    // A completed call: either we got the explicit disconnected phase, or the
    // snapshot dropped to "no call" after we'd been tracking one.
    final ended =
        _hadCall && (state.phase == CallPhase.disconnected || !state.hasCall);
    if (!ended) return;

    // Once no call remains, surface any call-waiting call the native side parked
    // during this session (a call that stopped being the primary before we saw it
    // end, so [_onEvent] itself could never log it) without waiting for the next
    // app start. One-shot and idempotent: the native journal clears on read.
    if (!state.hasCall) unawaited(drainCallWaitingCalls());

    final id = _callId;
    final number = _number;
    final direction = _direction;
    final wasActive = _wasActive;
    final connectTime = _connectTimeMillis;
    final creationTime = _creationTimeMillis;
    final phoneAccountId = _phoneAccountId;
    _reset();

    // Dedupe: never write more than one Recents row for the same physical call
    // (a call that flaps through disconnected → no-call ends more than once).
    if (id == null || id == _lastLoggedId) return;
    _lastLoggedId = id;

    // Only incoming/missed calls; outgoing are the mixin's responsibility.
    if (direction == CallDirection.incoming &&
        number != null &&
        number.isNotEmpty) {
      // Fire-and-forget; logging must never affect call handling.
      unawaited(
        _logIncoming(
          number: number,
          wasActive: wasActive,
          connectTimeMillis: connectTime,
          creationTimeMillis: creationTime,
          phoneAccountId: phoneAccountId,
        ),
      );
    }
  }

  /// Clears the per-call accumulation. Deliberately leaves [_lastLoggedId] intact
  /// — that's the cross-call dedupe guard.
  void _reset() {
    _hadCall = false;
    _callId = null;
    _number = null;
    _phoneAccountId = null;
    _direction = CallDirection.unknown;
    _connectTimeMillis = 0;
    _creationTimeMillis = 0;
    _wasActive = false;
  }

  Future<void> _logIncoming({
    required String number,
    required bool wasActive,
    required int connectTimeMillis,
    required int creationTimeMillis,
    required String? phoneAccountId,
  }) async {
    try {
      // Answered (ever active) → 'incoming'; never connected → 'missed'.
      final callType = wasActive ? 'incoming' : 'missed';
      // The same signal, recorded on its own axis so the outgoing side can
      // carry an outcome too (call_type has no room to say it there).
      final callOutcome = wasActive
          ? AppCallOutcome.answered
          : AppCallOutcome.noAnswer;
      final duration = (wasActive && connectTimeMillis > 0)
          ? ((DateTime.now().millisecondsSinceEpoch - connectTimeMillis) ~/
                    1000)
                .clamp(0, 359999)
          : 0;

      final simLabel = await _sims.labelFor(phoneAccountId);
      final contactId = await _resolveContactId(number);

      // Date the row the way the device call log dates the same call: at ring
      // start. Using "now" (the call *end*) drifts by the whole ring or talk
      // time, which pushes the two records apart and can put them outside the
      // 90-second match window — the row then survives as a second Recents
      // entry for one call. Connect time is the next best thing for an answered
      // call (seconds after ring start); a missed call with no reported
      // creation time falls back to now, as before.
      final timestamp = creationTimeMillis > 0
          ? DateTime.fromMillisecondsSinceEpoch(creationTimeMillis)
          : (wasActive && connectTimeMillis > 0)
          ? DateTime.fromMillisecondsSinceEpoch(connectTimeMillis)
          : null;

      // Deduped insert: the device-log import writes the same call from the
      // other side, and whichever lands second must find the first rather than
      // add a twin. See [InteractionRepository.logCallIfNew].
      await CallLogWriteLock.run(
        () => _interactions.logCallIfNew(
          contactId: contactId,
          phoneNumber: number,
          callType: callType,
          callOutcome: callOutcome,
          duration: duration,
          simId: phoneAccountId,
          simLabel: simLabel,
          timestamp: timestamp,
        ),
      );

      // The Recents row now exists — let any open call-history screen refresh.
      // Before the interaction/scoring writes: those don't affect Recents.
      CallLogEvents.instance.notifyCallLogged();

      // A connected incoming call is a real interaction — feed the score.
      if (contactId != null && callType == 'incoming') {
        await _interactions.logInteraction(
          contactId: contactId,
          duration: duration,
        );
        await _scoring.calculateRelationshipScore(contactId);
      }
    } catch (_) {
      // Best-effort; a logging failure must never surface anywhere.
    }
  }

  /// Resolves an incoming number to a contact by normalizing both sides to
  /// E.164 under the user's Default country, mirroring [CallService].
  Future<int?> _resolveContactId(String number) async {
    try {
      final iso = await AppSettings.readDefaultCountryIso();
      final matches = await _contacts.findByFullNumber(number, defaultIso: iso);
      if (matches.isEmpty) return null;
      return matches.first.contactId;
    } catch (_) {
      // Fall through to unlinked.
    }
    return null;
  }
}
