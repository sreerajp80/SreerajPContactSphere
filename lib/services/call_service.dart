// lib/services/call_service.dart
import 'package:call_log/call_log.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

import 'package:smart_contacts_dialer/models/sim_account.dart';
import 'package:smart_contacts_dialer/repositories/contact_repository.dart';
import 'package:smart_contacts_dialer/repositories/interaction_repository.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/services/ephemeral_contact_service.dart';
import 'package:smart_contacts_dialer/services/permission_service.dart';
import 'package:smart_contacts_dialer/services/relationship_scoring_service.dart';
import 'package:smart_contacts_dialer/services/telecom_service.dart';
import 'package:smart_contacts_dialer/state/call_log_events.dart';
import 'package:smart_contacts_dialer/utils/call_type_mapper.dart';

/// A call placed through [CallService] but not yet reconciled against the
/// device call log (which only has the duration/outcome once the call ends).
///
/// Carries the ids of the provisional `call_logs`/`interactions` rows so the
/// post-call feedback flow can attach sentiment/intent/notes to them.
class PendingCall {
  final String number;
  final DateTime placedAt;

  /// Linked contact, or null when an unknown number was dialed.
  final int? contactId;

  final int callLogId;

  /// Null when the call wasn't linked to a contact (no interaction row).
  final int? interactionId;

  /// Null until reconciled, then holds the duration in seconds.
  int? reconciledDuration;

  PendingCall({
    required this.number,
    required this.placedAt,
    required this.contactId,
    required this.callLogId,
    required this.interactionId,
    this.reconciledDuration,
  });
}

/// Centralises the place-a-call lifecycle that used to live inline in
/// `contact_detail_screen.dart` (and was partly duplicated in the list's
/// quick-call): place the call, log provisional rows, then — once the app
/// resumes — reconcile the real duration/type from the device call log and
/// re-score the relationship.
///
/// UI-free on purpose: screens drive it (typically via `CallLifecycleMixin`)
/// and own showing the feedback sheet.
class CallService {
  final InteractionRepository _interactions;
  final RelationshipScoringService _scoring;
  final ContactRepository _contacts;
  final PermissionService _permissions;
  final TelecomService _telecom;

  CallService({
    InteractionRepository? interactions,
    RelationshipScoringService? scoring,
    ContactRepository? contacts,
    PermissionService? permissions,
    TelecomService? telecom,
  }) : _interactions = interactions ?? InteractionRepository(),
       _scoring = scoring ?? RelationshipScoringService(),
       _contacts = contacts ?? ContactRepository(),
       _permissions = permissions ?? PermissionService(),
       _telecom = telecom ?? TelecomService();

  /// Places a call to [number] and logs provisional rows so it can be
  /// reconciled later. When [contactId] is omitted the number is resolved
  /// against the contacts table (so dialing a known number still links the
  /// call); an unresolved number is logged without a contact link.
  ///
  /// Returns a [PendingCall] to reconcile on resume, or null if the call
  /// couldn't be placed (permission denied / dialer error) or no provisional
  /// row could be written. Logging failures never surface as call failures.
  Future<PendingCall?> placeCall({
    int? contactId,
    required String number,
    SimAccount? sim,
  }) async {
    final granted = await _permissions.ensureCallPhone();
    if (!granted) {
      throw const CallPermissionDeniedException();
    }

    final placedAt = DateTime.now();
    // When we're the default phone app, route through TelecomManager so the
    // call surfaces in our own in-call UI (and, when a SIM was chosen, over that
    // SIM). Returns false (and we fall back to the direct caller) when we're not
    // default, off-device, or it was refused.
    final placedViaTelecom = await _telecom.placeCall(number, sim: sim);
    if (!placedViaTelecom) {
      await FlutterPhoneDirectCaller.callNumber(number);
    }

    // Resolve an unknown number to a contact when one matches, so logging links
    // the call (and scoring can run).
    int? resolvedContactId = contactId;
    if (resolvedContactId == null) {
      try {
        resolvedContactId = await _resolveContactId(number);
      } catch (_) {
        // Resolution is best-effort; fall back to an unlinked call.
      }
    }

    try {
      final callLogId = await _interactions.logCall(
        contactId: resolvedContactId,
        phoneNumber: number,
        simId: sim?.phoneAccountId,
        simLabel: sim?.displayLabel,
      );
      int? interactionId;
      if (resolvedContactId != null) {
        interactionId = await _interactions.logInteraction(
          contactId: resolvedContactId,
        );
      }
      // Tell any open history view straight away, so a call placed from Recents
      // shows up under the user immediately instead of only once it ends and
      // reconciliation finishes. The row is provisional (no duration yet);
      // reconcile() fills it in and notifies again.
      CallLogEvents.instance.notifyCallLogged();
      return PendingCall(
        number: number,
        placedAt: placedAt,
        contactId: resolvedContactId,
        callLogId: callLogId,
        interactionId: interactionId,
      );
    } catch (_) {
      // Couldn't write the provisional rows; nothing to reconcile later.
      return null;
    }
  }

  /// Looks up the device call log for [pending]'s real duration/type/time,
  /// back-fills the provisional rows, then recomputes the relationship score
  /// for a linked contact. Best-effort: any failure leaves the provisional
  /// (null-duration) record intact.
  ///
  /// Returns true when the call was confirmed ended — i.e. the device wrote a
  /// call-log entry for it. **A zero-second call still counts.** A call that
  /// rang unanswered, was cancelled before connecting, or was rejected has
  /// duration 0, and treating that as "not ended yet" is what left those calls
  /// stuck as provisional rows that Recents never refreshed.
  ///
  /// [observedOutcome] is what the Telecom event stream saw when the call
  /// disconnected (see `AppCallOutcome`), and wins when present: it can tell
  /// busy from declined from rang-out, which the device call log cannot. Without
  /// it the outcome falls back to whether the call lasted any time at all.
  Future<bool> reconcile(PendingCall pending, {String? observedOutcome}) async {
    var ended = false;
    try {
      // Android can take a moment to write the call-log row after a call ends,
      // so poll with a growing delay rather than reading once. No permission
      // pre-check: the call_log plugin raises its own prompt, and the old check
      // (Permission.phone) didn't actually cover READ_CALL_LOG on Android 9+.
      CallLogEntry? match;
      for (var attempt = 0; attempt < _reconcileDelays.length; attempt++) {
        await Future<void>.delayed(_reconcileDelays[attempt]);
        final entries = await CallLog.query(
          dateFrom: pending.placedAt.millisecondsSinceEpoch,
        );
        final candidate = _bestMatch(entries, pending.number);
        if (candidate != null && candidate.duration != null) {
          match = candidate;
          break;
        }
      }
      if (match != null) {
        ended = true;
        pending.reconciledDuration = match.duration ?? 0;
        await _interactions.updateCallOutcome(
          callLogId: pending.callLogId,
          interactionId: pending.interactionId,
          duration: match.duration ?? 0,
          callType: mapDeviceCallType(match.callType),
          callOutcome:
              normalizeCallOutcome(observedOutcome) ??
              mapDeviceCallOutcome(match.callType, match.duration),
          timestamp: match.timestamp != null
              ? DateTime.fromMillisecondsSinceEpoch(
                  match.timestamp!,
                ).toIso8601String()
              : null,
          // Back-fill the SIM the call actually used — covers calls placed on
          // the system default (no SIM chosen up front). Null-safe: only
          // written when the device call log reported it.
          simId: match.phoneAccountId,
          simLabel: match.simDisplayName,
        );
      }
      if (pending.contactId != null) {
        await _scoring.calculateRelationshipScore(pending.contactId!);
      }
      await EphemeralContactService().onCallCompleted(
        contactId: pending.contactId,
        phoneNumber: pending.number,
      );
    } catch (_) {
      // Leave the provisional record as-is on any failure.
    }
    return ended;
  }

  /// How long [reconcile] waits before each look at the device call log —
  /// roughly 8 seconds in total, backing off as it goes. The old budget was
  /// four fixed 750 ms tries (~2.25 s), which the phone often hadn't finished
  /// writing the row within; the call then stayed provisional forever, because
  /// nothing re-armed reconciliation without another resume. The screen falls
  /// back to a device sync if even this misses.
  static const List<Duration> _reconcileDelays = <Duration>[
    Duration(milliseconds: 400),
    Duration(milliseconds: 600),
    Duration(milliseconds: 1000),
    Duration(milliseconds: 1500),
    Duration(milliseconds: 2000),
    Duration(milliseconds: 2500),
  ];

  Future<int?> _resolveContactId(String number) async {
    // Normalize both sides to E.164 under the user's Default country so a
    // national number links to the same number carrying a country code.
    final iso = await AppSettings.readDefaultCountryIso();
    final matches = await _contacts.findByFullNumber(number, defaultIso: iso);
    if (matches.isEmpty) return null;
    return matches.first.contactId;
  }

  /// Picks the call-log entry whose number best matches the dialed one,
  /// comparing on trailing digits to tolerate formatting differences.
  CallLogEntry? _bestMatch(Iterable<CallLogEntry> entries, String dialed) {
    final target = ContactRepository.normalizeDigits(dialed);
    if (target.isEmpty) return null;
    for (final entry in entries) {
      final n = ContactRepository.normalizeDigits(entry.number ?? '');
      if (n.isEmpty) continue;
      if (n.endsWith(target) || target.endsWith(n)) return entry;
    }
    return null;
  }

}

/// Thrown by [CallService.placeCall] when the CALL_PHONE permission is denied,
/// so the caller can show a message instead of silently failing.
class CallPermissionDeniedException implements Exception {
  const CallPermissionDeniedException();
  @override
  String toString() => 'Call permission denied';
}
