# Recents: show call duration + add Settings entry point

Implements `plans/20260701_220551_recents-duration-and-settings.md`.

## What changed

### 1. Outgoing-call duration now back-fills when we're the default dialer
`lib/widgets/call_lifecycle_mixin.dart`
- Reconciliation was triggered **only** by `AppLifecycleState.resumed`, which never fires when
  ContactSphere is the default dialer (the outgoing call runs in the app's own `InCallScreen`, an
  in-app route, so the app is never backgrounded). Result: `CallService.reconcile()` never ran and
  the provisional `call_logs` row kept a null `duration`/`outgoing` type — so Recents showed no
  duration. The post-call feedback sheet was suppressed for the same reason.
- Added a subscription to `TelecomService().callEvents` (`_callSub`, cancelled in `dispose`). When
  the tracked pending call ends on the stream (explicit `disconnected` phase, or a drop to "no
  call" after it was seen ongoing — tracked via `_sawOngoing`), the same reconcile path runs.
- Renamed `_handleResume()` → `_reconcilePendingCall()` (behaviour unchanged); it is now invoked
  from both `didChangeAppLifecycleState` (resume, non-default-dialer path) and `_onCallEvent`
  (call-end, default-dialer path). Existing `_reconciling` / `_pendingCall == null` guards keep
  the two triggers from racing. `_sawOngoing` is reset when a new call is armed in `startCall`.
- Off Android / when not the default dialer the event stream is empty, so behaviour is unchanged
  and the resume path remains authoritative. No change to `reconcile()` itself (still reads the
  device call log; READ_CALL_LOG still required).
- Added imports: `dart:async`, `../models/call_state.dart`, `../services/telecom_service.dart`.

### 2. Settings reachable from Recents
`lib/screens/call_history_screen.dart`
- Added a `Settings` (`Icons.settings_outlined`) `IconButton` to the header, always visible,
  before the existing "Clear history" action; it pushes `SettingsScreen`. Added the import and a
  small `_openSettings()` helper.

## Verification
- `flutter analyze` on both changed files: no issues.
- `flutter test`: all 27 tests pass (incl. the widget smoke test).
- Device manual check (default dialer) pending user confirmation: outgoing call → hang up → Recents
  shows duration and the feedback sheet appears; gear on Recents opens Settings.
