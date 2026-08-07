# Recents: show call duration + add Settings entry point

**Status:** completed

## Issues

### 1. Call duration not shown in Recents (for outgoing calls placed as default dialer)
The Recents rows show time and SIM but no duration. The display code in
`lib/screens/call_history_screen.dart` (`_callCard`) already appends the duration to the
subtitle *when it is present* (`if (call.duration != null && call.duration! > 0)`), so this is
not a rendering bug — the stored `duration` is null.

Root cause: outgoing calls are logged provisionally (duration unknown) by
`CallService.placeCall`, and their real duration is back-filled by `CallService.reconcile()`.
Reconciliation is triggered **only** by `CallLifecycleMixin.didChangeAppLifecycleState` on the
`resumed` lifecycle event — i.e. it assumes placing a call backgrounds the app (system dialer)
and returning to the app resumes it.

When ContactSphere is the **default dialer** (the 2026-07-01 build-out), an outgoing call is
shown by the app's *own* `InCallScreen`, pushed as a route from `main.dart` `_onCall`. The app is
never backgrounded, so `AppLifecycleState.resumed` never fires, so `reconcile()` never runs and
the duration (and call-type) is never back-filled. The SIM label still appears because it is
written at placement time, not at reconcile. `CallEventLogger` deliberately handles only
incoming/missed calls, so nothing else reconciles the outgoing ones.

Side effect of the same gap: the post-call feedback sheet also never shows when default-dialer,
because it is gated behind the same resume-triggered `_handleResume()`.

Fix: drive reconciliation off the Telecom **call-event stream** (which fires whether or not the
app backgrounds) in addition to the existing app-resume trigger. When a call the mixin is
tracking (`_pendingCall != null`) ends, run the same reconcile path. On non-default-dialer /
non-Android hosts the stream is empty, so the existing resume path continues to work unchanged.

### 2. No way to reach Settings from Recents
Settings is currently only reachable from the Contacts screen's overflow menu. The Recents
screen header (`_header`) has only a "Clear history" action (and only when the list is
non-empty). Add a Settings entry point here.

## Files to change

1. `lib/widgets/call_lifecycle_mixin.dart`
   - Import `dart:async` and `../services/telecom_service.dart` and `../models/call_state.dart`.
   - Add a `TelecomService _telecom` field and a `StreamSubscription<CallState>? _callSub`.
   - In `initState`, subscribe: `_callSub = _telecom.callEvents.listen(_onCallEvent)`.
   - In `dispose`, cancel `_callSub`.
   - Track that a tracked call actually went ongoing (`bool _sawOngoing`), then on an end event
     (`phase == CallPhase.disconnected`, or `!hasCall` after having seen an ongoing call) with
     `_pendingCall != null`, invoke the reconcile path (currently `_handleResume`). Reset the flag.
   - Rename `_handleResume()` to `_reconcilePendingCall()` (behaviour unchanged) and call it from
     both `didChangeAppLifecycleState` and `_onCallEvent`. The existing `_reconciling` /
     `_pendingCall == null` guards already make double-invocation safe (resume + call-event).
   - No change to `reconcile()` semantics: it still polls the *device* call log for the real
     duration/type, so READ_CALL_LOG is still required (already requested).

2. `lib/screens/call_history_screen.dart`
   - Import `settings_screen.dart`.
   - In `_header`, add a Settings `IconButton` (`Icons.settings_outlined`) that pushes
     `SettingsScreen` via `MaterialPageRoute`. Shown always (not gated on `_calls.isNotEmpty`),
     placed before the existing "Clear history" button.

## Out of scope / notes
- No DB schema change. No native change.
- This does not add duration for *incoming* calls beyond what `CallEventLogger` already logs.
- If the device call log can't be read (permission denied) the duration still won't appear —
  that's a permission state, not addressed here.

## Verification
- `flutter analyze` clean.
- `flutter test` (existing widget smoke test) passes.
- Manual (device, default dialer): place an outgoing call, hang up; the Recents row now shows the
  duration and the post-call feedback sheet appears. Tapping the new gear on Recents opens Settings.
