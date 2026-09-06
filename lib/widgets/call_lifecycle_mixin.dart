// lib/widgets/call_lifecycle_mixin.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_contacts_dialer/models/call_state.dart';
import 'package:smart_contacts_dialer/models/sim_account.dart';
import 'package:smart_contacts_dialer/repositories/interaction_repository.dart';
import 'package:smart_contacts_dialer/repositories/reminder_repository.dart';
import 'package:smart_contacts_dialer/services/call_log_import_service.dart';
import 'package:smart_contacts_dialer/services/call_service.dart';
import 'package:smart_contacts_dialer/services/relationship_scoring_service.dart';
import 'package:smart_contacts_dialer/services/sim_service.dart';
import 'package:smart_contacts_dialer/services/telecom_service.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/widgets/post_call_feedback_sheet.dart';
import 'package:smart_contacts_dialer/widgets/sim_picker_sheet.dart';
import 'package:smart_contacts_dialer/widgets/smart_redial_sheet.dart';


/// Shared "place a call → reconcile on resume → ask for feedback" behaviour for
/// any screen that can start a call (dialer, contact detail, contact list).
///
/// Mix it in alongside [WidgetsBindingObserver]; the mixin registers/unregisters
/// the observer itself:
///
/// ```dart
/// class _MyScreenState extends State<MyScreen>
///     with WidgetsBindingObserver, CallLifecycleMixin<MyScreen> { ... }
/// ```
///
/// Call [startCall] to place a call. When the app resumes, the mixin reconciles
/// the real duration/type, shows the post-call feedback sheet, persists the
/// feedback, re-scores the relationship, and then invokes [onCallReconciled] so
/// the screen can refresh.
mixin CallLifecycleMixin<T extends StatefulWidget>
    on State<T>, WidgetsBindingObserver {
  final CallService _callService = CallService();
  final InteractionRepository _interactionRepo = InteractionRepository();
  final ReminderRepository _reminderRepo = ReminderRepository();
  final RelationshipScoringService _scoring = RelationshipScoringService();
  final SimService _simService = SimService();
  final TelecomService _telecom = TelecomService();
  final CallLogImportService _callLogImport = CallLogImportService();

  /// Watches Telecom call events so a call ending can trigger reconciliation
  /// even when the app is never backgrounded — which is the case when
  /// ContactSphere is the default dialer and the call runs in our own in-call
  /// screen (no `resumed` lifecycle event ever fires). Empty stream off Android
  /// / when we're not the default dialer, so the resume path stays authoritative.
  StreamSubscription<CallState>? _callSub;

  /// Whether the currently-pending call was ever seen ongoing on the event
  /// stream, so a drop to "no call" is recognised as that call ending.
  bool _sawOngoing = false;

  /// Why the pending call ended, as the native bridge reported it on the
  /// disconnected event (see `AppCallOutcome`).
  ///
  /// Latched rather than read at reconcile time: the registry drops the call
  /// moments after it disconnects, and the very next event is an empty snapshot
  /// that knows nothing about it. Null when we never saw a reason — reconcile
  /// then falls back to whether the call lasted any time at all.
  String? _pendingOutcome;

  PendingCall? _pendingCall;
  String _pendingDisplayName = 'this contact';

  /// The SIM the pending call went out on (null = system default), so a Smart
  /// Redial scheduled from the unanswered-call sheet retries on the same SIM.
  String? _pendingSimId;

  /// How many resumes we've tried to reconcile the current pending call over.
  /// The sheet only fires once the call is confirmed ended (a completed
  /// call-log entry), so an early resume — a permission dialog dismissing, the
  /// dialer bouncing back — re-arms and waits for the real call-end resume.
  /// Bounded so we don't keep polling the call log forever if it never matches.
  int _reconcileAttempts = 0;
  static const int _maxReconcileAttempts = 6;

  /// Whether reconciliation is already running, so overlapping resume events
  /// (or the retry poll) don't drive it concurrently.
  bool _reconciling = false;

  /// Override to refresh the screen after a call has been reconciled and any
  /// feedback persisted. Default: no-op.
  void onCallReconciled() {}

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _callSub = _telecom.callEvents.listen(_onCallEvent);
  }

  @override
  void dispose() {
    _callSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _pendingCall != null) {
      _reconcilePendingCall();
    }
  }

  /// Reconciles the pending call when it ends on the Telecom event stream. This
  /// is the path that fires when the app is never backgrounded (default dialer,
  /// in-app in-call screen), so the resume-based trigger above never would.
  void _onCallEvent(CallState state) {
    if (_pendingCall == null) return;
    // Keep the last reason the bridge gave. It only ever arrives on the
    // disconnected event, which is gone by the time reconciliation runs.
    if (state.outcome != null) _pendingOutcome = state.outcome;
    if (state.phase.isOngoing) {
      _sawOngoing = true;
      return;
    }
    // The tracked call has ended: an explicit disconnected phase, or a drop to
    // "no call" after we'd seen it ongoing.
    final ended =
        state.phase == CallPhase.disconnected ||
        (!state.hasCall && _sawOngoing);
    if (ended) {
      _sawOngoing = false;
      _reconcilePendingCall();
    }
  }

  /// Places a call to [number] (optionally linked to [contactId]) and arms
  /// reconciliation for when the app resumes. [displayName] is shown on the
  /// feedback sheet. Shows a message if the call can't be placed; logging
  /// failures are swallowed so they never look like a call failure.
  Future<void> startCall({
    int? contactId,
    required String number,
    String displayName = 'this contact',
  }) async {
    try {
      // Resolve which SIM to use before dialing. Returns a sentinel to abort
      // when the user dismisses the SIM chooser. (The number to dial is decided
      // by the caller — e.g. the list's long-press number picker.)
      final sim = await _resolveSim(contactId);
      if (sim == _aborted) return;

      final pending = await _callService.placeCall(
        contactId: contactId,
        number: number,
        sim: sim,
      );
      _pendingCall = pending;
      _pendingDisplayName = displayName;
      _pendingSimId = sim?.phoneAccountId;
      _reconcileAttempts = 0;
      _sawOngoing = false;
      _pendingOutcome = null;
    } on CallPermissionDeniedException {
      _showMessage('Call permission denied');
    } catch (e) {
      _showMessage('Could not place call: $e');
    }
  }

  /// Sentinel returned by [_resolveSim] when the user cancels the SIM chooser,
  /// distinguishing "abort the call" from "use system default" (null).
  static const SimAccount _aborted = SimAccount(
    phoneAccountId: '__aborted__',
    componentName: '',
  );

  /// Decides which SIM to place the call on.
  ///
  /// The SIM the call would use on its own is [SimService.resolveForCall]: this
  /// contact's preferred SIM if it set one and that SIM is still in the phone,
  /// else the configured default, else null (system default).
  ///
  /// When "ask which SIM before each call" is on and there are 2+ SIMs the
  /// chooser is still shown — the user asked to confirm every call — but that
  /// resolved SIM is pre-selected in it, so honouring a contact's preference is
  /// one tap. Returns [_aborted] if the chooser was dismissed.
  Future<SimAccount?> _resolveSim(int? contactId) async {
    final settings = mounted ? context.read<AppSettings>() : null;
    if (settings == null) return null;

    final resolved = await _simService.resolveForCall(
      contactId: contactId,
      defaultSimId: settings.defaultSimId,
    );

    if (settings.askSimBeforeCall) {
      final sims = await _simService.list();
      if (sims.length > 1 && mounted) {
        final chosen = await showSimPickerSheet(
          context,
          sims: sims,
          preselectedId: resolved?.phoneAccountId,
          preselectedNote: 'Usual SIM for this call',
        );
        return chosen ?? _aborted;
      }
    }
    return resolved;
  }

  Future<void> _reconcilePendingCall() async {
    final pending = _pendingCall;
    if (pending == null || _reconciling) return;
    _reconciling = true;
    _pendingCall = null; // taken; re-armed below if the call hasn't ended yet
    _reconcileAttempts++;

    try {
      // Whether the user wants the feedback sheet at all. Read before any await
      // so we don't touch a possibly-unmounted context later.
      final feedbackEnabled =
          mounted && context.read<AppSettings>().postCallFeedbackEnabled;

      // reconcile() reports whether the device logged the call — which is what
      // "the call ended" means. It deliberately does *not* require a non-zero
      // duration: an unanswered or cancelled call is 0 seconds and still ended.
      final callEnded = await _callService.reconcile(
        pending,
        observedOutcome: _pendingOutcome,
      );

      if (!callEnded) {
        // This resume wasn't a completed call ending — likely a premature
        // bounce-back right after dialing. Re-arm so the real call-end resume
        // can catch it, up to a bounded number of attempts.
        if (_reconcileAttempts < _maxReconcileAttempts) {
          _pendingCall = pending;
        } else {
          // Out of attempts: the device never showed us the call within the
          // poll window. Pull it in through the device sync instead, so the row
          // still gets its real duration/direction rather than staying
          // provisional forever. Refreshes the screen through CallLogEvents.
          unawaited(_callLogImport.syncFromDevice(force: true));
        }
        return;
      }

      // Reconciled: this call's reason has been written, so it must not leak
      // onto the next one. (Left in place on the re-arm path above, which is
      // still waiting for this same call to end.)
      _pendingOutcome = null;

      // Refresh before the feedback sheet as well as after it — otherwise the
      // just-ended call sits behind the sheet still showing its placement-time
      // state, and only corrects itself once the sheet is dismissed.
      if (mounted) onCallReconciled();

      final smartRedialEnabled =
          mounted && context.read<AppSettings>().smartRedialEnabled;

      if (feedbackEnabled && mounted) {
        final feedback = await showPostCallFeedbackSheet(
          context,
          displayName: _pendingDisplayName,
          canRemind: pending.contactId != null,
        );
        if (feedback != null) {
          await _applyFeedback(pending, feedback);
        }
      }

      // If the call went unanswered or failed (0-second duration), offer Smart Redial & Reach Me
      final unanswered = (pending.reconciledDuration ?? 0) == 0;
      if (unanswered && smartRedialEnabled && mounted) {
        await showSmartRedialSheet(
          context,
          phoneNumber: pending.number,
          contactId: pending.contactId,
          displayName: _pendingDisplayName,
          simId: _pendingSimId,
        );
      }

      if (mounted) onCallReconciled();

    } finally {
      _reconciling = false;
    }
  }

  Future<void> _applyFeedback(
    PendingCall pending,
    PostCallFeedback feedback,
  ) async {
    try {
      if (feedback.hasFeedback) {
        await _interactionRepo.recordCallFeedback(
          callLogId: pending.callLogId,
          interactionId: pending.interactionId,
          tone: feedback.tone,
          intent: feedback.intent,
          notes: feedback.notes,
        );
      }
      if (feedback.hasFollowUp && pending.contactId != null) {
        await _reminderRepo.insert(
          contactId: pending.contactId!,
          reminderText: feedback.followUpText!,
          reminderTime: feedback.followUpTime,
        );
      }
      // Sentiment feeds the score, so re-run it after writing feedback.
      if (feedback.tone != null && pending.contactId != null) {
        await _scoring.calculateRelationshipScore(pending.contactId!);
      }
    } catch (_) {
      // Feedback is best-effort; the call itself is already logged.
    }
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
