# Suppress the incoming-call heads-up banner while the in-call screen is visible

Implements [plans/20260703_180016_no-heads-up-over-incall-ui.md](../plans/20260703_180016_no-heads-up-over-incall-ui.md).

## Problem

With the phone unlocked and the app's own incoming-call screen already in the foreground,
the ringing notification (HIGH-importance channel + full-screen intent) still popped as a
heads-up banner over the in-call UI. It should only sit in the status bar in that case.

## Changes

- **`android/.../MainActivity.kt`** — new `onResume()`/`onPause()` overrides report the
  activity's visibility via `CallRegistry.setInCallUiVisible(...)`.

- **`android/.../CallRegistry.kt`**
  - New `uiVisible` flag with `setInCallUiVisible()` / `isInCallUiVisible()`.
  - New `RingController.onUiVisibilityChanged()`; invoked when visibility flips while
    `ringing` so the service re-posts the ringing notification in the right shape.

- **`android/.../ContactSphereInCallService.kt`**
  - New notification channel `incoming_calls_quiet` ("Incoming calls (app open)",
    `IMPORTANCE_LOW`, silent) — a separate channel because importance is immutable after
    creation.
  - `buildCallStyleNotification()` and `buildLegacyNotification()`: when the ringing shape
    is built while `CallRegistry.isInCallUiVisible()`, it goes on the quiet channel with
    **no** `setFullScreenIntent` (and `PRIORITY_DEFAULT` pre-O), so it can't heads-up.
    When the UI is not visible, behavior is unchanged (HIGH channel + full-screen intent).
  - Implemented `onUiVisibilityChanged()`: while still ringing, rebuilds and re-posts the
    notification on the same ID, so it demotes in place when the UI comes up and promotes
    back to heads-up if the user leaves mid-ring.
  - Class doc updated to describe the demotion.

Ongoing-call notification path and all Dart code untouched.

## Verification

- `gradlew :app:compileDevDebugKotlin` passes.
- Manual (on device): incoming call with the app foregrounded should show only the
  full-screen in-call UI with a silent shade entry; calls arriving from another app /
  home keep the heads-up banner; locked-screen calls keep the full-screen intent; leaving
  the in-call screen mid-ring brings the banner back.
