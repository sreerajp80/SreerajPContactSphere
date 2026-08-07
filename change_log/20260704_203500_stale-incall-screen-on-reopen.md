# Fix: stale in-call screen flashed when reopening the app after a call ended in background

Implements [plans/20260704_202059_stale-incall-screen-on-reopen.md](../plans/20260704_202059_stale-incall-screen-on-reopen.md).

## Symptom

Call in progress → user switches to another app → other party disconnects → reopening
ContactSphere briefly showed the old calling screen before the normal UI appeared.
Affected outgoing and incoming calls alike (shared `_onCall` handler in `main.dart`).

## Root cause (confirmed live on a Moto G54 with logcat + screenshot bursts)

The call-end event *was* delivered and the route *was* popped while backgrounded — the
flash was stale pixels, from two sources:

1. Android replays the task snapshot (taken mid-call when the user left) as the starting
   window during reopen.
2. A backgrounded Flutter app renders no frames, so the route's exit transition started
   by the animated `popUntil` only played *after* resume, in front of the user.

## Changes

- `lib/main.dart`
  - `_SmartContactsAppState` now keeps a reference to the pushed in-call route
    (`_inCallRoute`).
  - In `_onCall`, when the call ends while the app is not `AppLifecycleState.resumed`,
    the route is removed with `Navigator.removeRoute` (instant, no exit transition)
    instead of the animated `popUntil`. Foreground behaviour is unchanged.
- `android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt`
  - `onCallChanged` now calls `setRecentsScreenshotEnabled(snapshot == null)` (API 33+),
    so the OS takes no task snapshot while a call is up and has nothing stale to replay
    on reopen. Re-enabled as soon as no call remains (normal Recents thumbnails return).

## Verification (on device)

- Repro re-run on the updated build (call → home → call ended while backgrounded →
  reopen with a screenshot burst): the first rendered frame after reopen is the normal
  Contacts screen; no calling-screen flash in any frame.
- Recents opened during an active call now shows a blank card for ContactSphere
  (no snapshot captured), confirming the native suppression works.
- `flutter analyze lib/main.dart`: no issues.
