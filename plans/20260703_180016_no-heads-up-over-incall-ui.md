# Suppress the incoming-call heads-up banner while our own in-call screen is visible

**Status:** completed

## Issue

When a call comes in while the app's own incoming-call screen is already showing in the
foreground, a heads-up notification banner (caller name + Answer/Decline) still pops over
the top of it. The notification should only sit quietly in the status bar in that case; the
banner is only useful when the user is *not* looking at our in-call UI.

### Root cause

`ContactSphereInCallService.startRinging()` always posts the ringing notification the same
way, regardless of whether the in-call UI is visible:

- It is posted on the `incoming_calls` channel created with `IMPORTANCE_HIGH`
  (`ContactSphereInCallService.kt` — `createChannel()`), and
- it always carries `setFullScreenIntent(contentPi, true)`
  (`buildCallStyleNotification()` / `buildLegacyNotification()`).

Android's rule for a high-importance notification with a full-screen intent: if the screen
is off/locked it launches the activity full screen; if the device is unlocked and in use it
shows a **heads-up banner** instead. Since `onCallAdded()` also calls `launchInCallUi()`
(bringing `MainActivity` with the Flutter in-call screen to the front), the unlocked
in-foreground case ends up with both: our full-screen UI *and* the heads-up banner over it.
Nothing in the pipeline knows whether `MainActivity` is currently visible.

## Fix plan

Track `MainActivity` visibility and post a *quiet* ringing notification (low-importance
channel, no full-screen intent) whenever the in-call UI is in the foreground; keep the
current high-importance + full-screen-intent shape when it is not (locked screen, other
app, home screen). Re-post whichever shape is correct when visibility changes mid-ring, so:

- ringing starts while our UI is up → silent status-bar entry only (the reported bug);
- ringing starts while the user is in another app → heads-up banner (unchanged, desired);
- user taps the banner / full-screen intent fires and our UI comes up → the heads-up is
  demoted to a quiet status-bar entry;
- user leaves our UI (Home/app switch) while it is still ringing → promoted back to a
  heads-up so the call remains answerable.

## Files to change

1. **`android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt`**
   - Override `onResume()` / `onPause()` to report visibility:
     `CallRegistry.setInCallUiVisible(true/false)`.

2. **`android/app/src/main/kotlin/in/sreerajp/contact_sphere/CallRegistry.kt`**
   - Add a `uiVisible` flag with `setInCallUiVisible(visible: Boolean)` /
     `isInCallUiVisible()`.
   - When the flag changes *while ringing*, call a new
     `RingController.onUiVisibilityChanged()` so the service re-posts the ringing
     notification in the right shape.

3. **`android/app/src/main/kotlin/in/sreerajp/contact_sphere/ContactSphereInCallService.kt`**
   - Create a third channel `incoming_calls_quiet` ("Incoming calls (app open)") with
     `IMPORTANCE_LOW`, silent, no vibration — channels are immutable once created, so the
     existing HIGH channel can't be reused for the quiet shape.
   - In `buildCallStyleNotification()` / `buildLegacyNotification()` (ringing shape only):
     when `CallRegistry.isInCallUiVisible()` is true, use the quiet channel and **skip**
     `setFullScreenIntent(...)` (and use non-high priority on pre-O); otherwise keep the
     current behavior.
   - Implement `onUiVisibilityChanged()`: if still ringing (`hasCall && !showingOngoing`),
     rebuild + re-post the notification (same notification id, so it swaps in place —
     the same pattern already used for the incoming→ongoing swap).

No Dart/Flutter changes needed; the ongoing-call notification path is untouched.

## Verification

- In-app + unlocked: receive a call with the app in the foreground → in-call screen shows,
  no banner, quiet entry present in the notification shade.
- Other app + unlocked: receive a call → heads-up banner with Answer/Decline (unchanged).
- Locked/screen off: receive a call → full-screen incoming UI over the lock screen
  (unchanged).
- While ringing, press Home from the in-call screen → banner appears; return to the app →
  banner retracts to the shade.
- Answer flow still swaps to the ongoing-call notification; ending the call clears it.
