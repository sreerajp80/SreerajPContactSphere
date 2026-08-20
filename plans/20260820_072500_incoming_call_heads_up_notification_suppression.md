# Suppress Incoming Call Notification Banner Above Full-Screen Caller Screen

**Status:** completed

## Issue

When an incoming call arrives, the full-screen incoming call UI is displayed, but an Android heads-up notification (HUN) banner (caller name + Answer/Decline buttons) is also displayed right on top of the caller screen, covering the top section of the screen (see user screenshot).

The notification banner should only appear as a heads-up popup if the caller screen is hidden, behind another app, or minimized (e.g. user pressed Home or switched apps while ringing). While the caller screen is in the foreground, the incoming call notification should only exist quietly in the status bar / notification shade to satisfy the foreground service requirement without obstructing the UI.

## Root Cause

1. In `ContactSphereInCallService.onCallAdded(call)`:
   - `CallRegistry.onCallAdded(call)` triggers `startRinging(call, ...)`.
   - `startRinging()` builds and posts the initial ringing notification before `MainActivity` has resumed.
   - At that instant, `CallRegistry.isInCallUiVisible()` is `false`.
   - Consequently, `buildCallNotification()` selects `CHANNEL_ID` (`IMPORTANCE_HIGH`) and sets `builder.setFullScreenIntent(...)`.
   - Android's NotificationManager immediately triggers a Heads-Up Notification (HUN) banner overlay.
   - Concurrently, `launchInCallUi()` launches `MainActivity` to display the full-screen caller screen.
   - Even when `MainActivity.onResume()` fires and calls `CallRegistry.setInCallUiVisible(true)`, Android SystemUI does not immediately dismiss an already-popped heads-up banner window overlay, leaving it hovering over the full-screen caller UI for its full timeout duration.

## Proposed Fix

1. **Initial Ringing State on `onCallAdded`**:
   - Since `onCallAdded()` immediately invokes `launchInCallUi()` to present the full-screen caller screen, the initial ringing notification posted by `startRinging()` should be posted directly on `QUIET_INCOMING_CHANNEL_ID` (`IMPORTANCE_LOW`, silent, no heads-up banner).
   - This satisfies Android's `phoneCall` foreground service requirement while preventing the system from posting a heads-up banner over the caller screen.

2. **When Caller Screen is Minimized / Sent to Background (`uiVisible == false`)**:
   - When the user leaves `MainActivity` (e.g. presses Home or switches apps while the phone is ringing), `MainActivity.onPause()` sets `CallRegistry.setInCallUiVisible(false)`.
   - `CallRegistry` notifies `RingController.onUiVisibilityChanged()`.
   - `ContactSphereInCallService.onUiVisibilityChanged()` sees `!isInCallUiVisible()` and rebuilds/re-posts the ringing notification on `CHANNEL_ID` (`IMPORTANCE_HIGH` with Answer / Decline buttons).
   - Android immediately displays the Heads-Up notification banner over the user's current app / home screen so the call can be answered or declined.

3. **When Caller Screen Returns to Foreground (`uiVisible == true`)**:
   - When the user taps the heads-up banner or switches back to ContactSphere, `MainActivity.onResume()` sets `CallRegistry.setInCallUiVisible(true)`.
   - `ContactSphereInCallService.onUiVisibilityChanged()` detects `isInCallUiVisible()` is true and demotes the notification back to `QUIET_INCOMING_CHANNEL_ID`.
   - If a heads-up notification was active on `CHANNEL_ID`, cancel/repost it cleanly so any lingering heads-up banner window is immediately dismissed.

4. **Window Lock/Wake flags in `MainActivity`**:
   - In `MainActivity.onCreate()` and `onNewIntent()`, ensure `applyShowWhenLocked(true)` is applied immediately when handling `ACTION_SHOW_IN_CALL` so incoming calls show over lock screen without delay.

## Files to Change

1. **`android/app/src/main/kotlin/in/sreerajp/contact_sphere/ContactSphereInCallService.kt`**
   - In `startRinging()`, post the ringing notification on `QUIET_INCOMING_CHANNEL_ID` so no heads-up banner is spawned when launching the full-screen in-call UI.
   - In `onUiVisibilityChanged()`, when switching from hidden (`uiVisible == false`) to visible (`uiVisible == true`), cleanly re-post on `QUIET_INCOMING_CHANNEL_ID` (and cancel the heads-up notification if needed).
   - In `buildCallNotification()`, ensure channel selection aligns with `uiVisible` state.

2. **`android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt`**
   - Ensure `ACTION_SHOW_IN_CALL` in `onCreate` / `onNewIntent` immediately invokes `applyShowWhenLocked(true)` so the activity displays over lock screen immediately on launch.

## Verification

1. **Incoming Call (App in Background / Phone Unlocked)**:
   - Simulate an incoming call.
   - Verify `MainActivity` / `IncomingCallScreen` launches full screen.
   - Verify **NO** heads-up notification banner appears over the caller screen.
   - Verify the quiet notification exists in the notification shade.

2. **Incoming Call (Phone Locked / Screen Off)**:
   - Simulate incoming call while device is locked.
   - Verify full-screen incoming call UI turns on screen and displays over lock screen cleanly with no banner covering it.

3. **Minimizing While Ringing**:
   - While incoming call is ringing on full screen, press Home / switch to another app.
   - Verify heads-up notification banner with Answer/Decline immediately pops up over the home screen/app.
   - Tap the banner or re-open the app -> verify full-screen caller screen is restored and the banner is dismissed.

4. **Run static analysis & tests**:
   - Run `flutter analyze` to ensure 0 errors/warnings.
