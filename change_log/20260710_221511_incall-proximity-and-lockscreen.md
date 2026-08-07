# Change log — In-call proximity blanking + lock-screen exposure fix

Implements plan
[plans/20260710_220925_incall-proximity-and-lockscreen.md](../plans/20260710_220925_incall-proximity-and-lockscreen.md).

## What was changed

### 1. `android/app/src/main/AndroidManifest.xml`
- Added `<uses-permission android:name="android.permission.WAKE_LOCK"/>` (with a
  comment) so the app can hold the proximity screen-off wake lock.

### 2. `android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt`
- Added imports `android.app.KeyguardManager` and `android.os.PowerManager`.
- Added fields:
  - `proximityWakeLock: PowerManager.WakeLock?` — the proximity lock (lazy).
  - `hadCall: Boolean` — edge detection for the no-call → call transition.
  - `callArrivedOverKeyguard: Boolean` — whether the current call first appeared
    while the keyguard was locked.
- **Issue 1 (ear/cheek touches):** new `applyProximityLock(active)` helper. It
  lazily creates a `PROXIMITY_SCREEN_OFF_WAKE_LOCK` (only when the device
  supports the level), acquires it when active, and releases it (default release,
  so the screen returns) otherwise. `onCallChanged` now reads `state` and
  `speaker` from the snapshot and holds the lock only while the call is
  connected on the earpiece (`state` is `active`/`holding` and not on speaker).
  The lock is also released in `onDestroy`.
- **Issue 2 (lock-screen exposure):** new `isKeyguardLocked()` helper. When a
  call appears `onCallChanged` records whether the keyguard was locked; when the
  call ends, if it had been showing over a locked keyguard and the keyguard is
  still locked, it calls `moveTaskToBack(true)` so the lock screen reasserts
  instead of leaving the app drawn over it. The unlocked/in-use case is
  unchanged.

No Dart code changed.

## Verification done
- `./gradlew :app:compileDevDebugKotlin` compiles cleanly (exit 0).

## Verification still needed (physical device — cannot be done here)
1. During a connected call, cover the top proximity sensor / hold to the ear: the
   screen should go dark and stop responding to touch; move away → screen
   returns. On speaker the screen should stay on. While ringing the screen stays
   on so the call can be answered.
2. Lock the phone, receive and answer a call, then end it: the phone should
   return to the lock screen (PIN required), not the app home screen.
3. With the phone unlocked and the app open, receive/end a call: the app stays in
   front as before.
