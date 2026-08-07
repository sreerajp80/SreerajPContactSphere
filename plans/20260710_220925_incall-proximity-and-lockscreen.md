# In-call proximity blanking + lock-screen exposure fix

**Status:** completed

## The two issues

### Issue 1 — Ear/cheek touches open other screens during a call
When ContactSphere is the default phone app it draws its **own** in-call screen
(`InCallScreen`) instead of using the system in-call UI. A normal system dialer
relies on Android to turn the screen off when the phone is held to the ear
(the proximity sensor). ContactSphere never does this, so during a call the
touchscreen stays fully live. The user's ear/cheek then taps the on-screen
buttons (Mute, Speaker, Keypad, Add call, Block, even End/Answer), which is the
"lots of other screens open" symptom.

Confirmed: there is **no** proximity / wake-lock code anywhere in the project
(no code, no `WAKE_LOCK` permission, no plugin).

### Issue 2 — Answering from the lock screen appears to unlock the phone
`MainActivity.onCallChanged` calls `applyShowWhenLocked(snapshot != null)`, which
sets `setShowWhenLocked(true)` + `setTurnScreenOn(true)` on the **single** activity
that hosts the whole Flutter app. That correctly shows the in-call screen over the
keyguard. But when the call ends, the flag is cleared and the in-call route is
popped, revealing the **home/contacts screen still sitting on top of the lock
screen** — the user can see and touch the whole app without entering the PIN, so
it looks unlocked.

Note: the code does **not** call `KeyguardManager.requestDismissKeyguard`, so the
device is not truly unlocked (a secure keyguard is still there underneath). It is
an exposure problem: after the call, the app is left drawn over the lock screen.

## Files to change

1. `android/app/src/main/AndroidManifest.xml`
   - Add `<uses-permission android:name="android.permission.WAKE_LOCK"/>` (needed
     for the proximity wake lock).

2. `android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt`
   - **Proximity (Issue 1):** add a `PowerManager.PROXIMITY_SCREEN_OFF_WAKE_LOCK`.
     Acquire it while the call is connected on the earpiece; release it otherwise.
     - New field `proximityWakeLock: PowerManager.WakeLock?`.
     - New helper `applyProximityLock(active: Boolean)` that lazily creates the
       lock (only if `isWakeLockLevelSupported`), acquires when `active` and not
       already held, releases when not active. Uses the default release so the
       screen comes back on when the phone leaves the ear.
     - In `onCallChanged`, read `state` and `speaker` from the snapshot map and
       call `applyProximityLock(state in {"active","holding"} && !speaker)`. When
       speaker is on the sensor should not blank the screen; when there is no call
       the lock is released.
     - Release the lock in `onDestroy`.
   - **Lock screen (Issue 2):** when the call arrives, remember whether the
     keyguard was locked at that moment (`callArrivedOverKeyguard`). When the call
     ends, if it arrived over a locked keyguard **and** the keyguard is still
     locked, call `moveTaskToBack(true)` right after clearing `showWhenLocked`, so
     the app is sent behind the lock screen instead of being left exposed. If the
     user unlocked the device during the call, or the call started while unlocked,
     nothing changes (the app stays in front, as today).
     - New fields `hadCall: Boolean` (to detect the no-call → call transition) and
       `callArrivedOverKeyguard: Boolean`.
     - Use `KeyguardManager.isKeyguardLocked` (no extra permission needed).

No Dart changes are needed; the fix lives entirely in native Android where the
window flags and wake locks are owned.

## Why this approach

- The proximity wake lock is exactly the mechanism the stock in-call UI uses; it
  disables the touchscreen while the sensor is covered, which is the correct and
  minimal fix for Issue 1. Gating on `active/holding && !speaker` matches how
  standard dialers behave (screen stays on while ringing so the user can answer,
  and while on speaker).
- For Issue 2, sending the task to the back when the call ends over a still-locked
  keyguard makes the lock screen reassert, without splitting the app into a
  separate call-only activity (a much larger, riskier change). It also leaves the
  normal case (call taken while the phone was unlocked/in use) untouched.

## Testing (manual, on device)

1. Place/receive a call, hold the phone to the ear (or cover the top sensor):
   the screen should go dark and stop responding to touch; move it away and the
   screen returns. Turn on speaker: the screen should stay on.
2. Lock the phone, receive a call, answer it, then end the call: the phone should
   return to the **lock screen** (PIN required), not the app home screen.
3. With the phone unlocked and the app open, receive/end a call: the app should
   stay in front as before.
4. `flutter analyze` stays clean for Dart; build the app to confirm the Kotlin
   compiles.
