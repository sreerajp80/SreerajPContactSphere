# Change log: missed-call "Call back" foregrounds the app, "Dismiss" action, and leave-after-call

Implements plan `plans/20260711_171924_missed-call-callback-foreground-and-dismiss.md`.

## Problems fixed

1. **Tapping "Call back" didn't bring the app forward.** The action fired a *broadcast*
   that then called `startActivity` — a "notification trampoline", which Android 12+
   blocks. So the app never came to the front and the lock screen / shade stayed up.
2. **No way to dismiss the missed-call notification** without calling back.
3. **The app's own screen was left showing after an incoming call.** As the default
   dialer we launch our in-call UI for every call; when the call ended, `MainActivity`
   was left on the contacts/home screen even though the user never opened the app. Only
   a narrow keyguard-locked case sent it back.

## What changed (all native / Kotlin, plus docs)

### `PendingCallback.kt`
- Rewrote from a single `number` holder into a **token → number** store guarded by
  `SecureRandom`: `arm(number): Long` (returns a one-shot token), `take(token)` (returns
  the number iff the token matches), `drop(token)`. This is the trust anchor for the
  call-back now that it launches the exported `MainActivity` directly.

### `ContactSphereInCallService.kt`
- `callBackAction(...)` now builds a **`getActivity` PendingIntent** that launches
  `MainActivity` with `ACTION_TRUSTED_CALL_BACK` + `EXTRA_TOKEN` (from `PendingCallback.arm`)
  + `EXTRA_NOTIFICATION_ID`. Launching the activity directly is what makes the app
  reliably foreground. The number is **not** put in an extra — it's looked up by token.
- New `dismissAction(...)`: a cancel-only broadcast (`ACTION_DISMISS_MISSED`) added to the
  missed-call notification. Added `DISMISS_REQUEST_OFFSET` so its request code can't collide
  with the Call-back PendingIntent's.
- The missed-call notification now always shows **Dismiss**, and **Call back** when a
  number exists.

### `CallActionReceiver.kt`
- Removed the `ACTION_CALL_BACK` branch / `handleCallBack` (the call-back no longer goes
  through the receiver).
- Added `ACTION_DISMISS_MISSED`: cancels the notification and drops the armed token.
- Kept the in-call buttons (hang up / answer / decline / mute / speaker).

### `CallRegistry.kt`
- Added `callBroughtUiToFront`, captured in `onCallAdded` on the first call of a session
  (`calls` empty) as `!uiVisible` — i.e. our in-call UI was not already showing. Exposed
  via `didCallBringUiToFront()`.

### `MainActivity.kt`
- New `handleTrustedCallbackIntent(intent)` (called from `onCreate`/`onNewIntent`):
  validates `EXTRA_TOKEN` via `PendingCallback.take`, and only then parks the number as an
  auto-call, cancels the notification, and nudges Dart. Consumes the intent action so a
  replay can't reprocess it. A missing / stale token is ignored (no call).
- New `ensureUnlockedForCallback()`: for a call-back from the lock screen, show over the
  keyguard, turn the screen on, and `requestDismissKeyguard`, so the SIM picker is usable.
- **Issue 3:** in `onCallChanged`, on the call-end edge, `moveTaskToBack(true)` when
  `CallRegistry.didCallBringUiToFront()` — this generalizes and replaces the old
  keyguard-only return-to-back.
- Removed the now-dead `drainTrustedCallback`, `nudgeTrustedCallback`,
  `callArrivedOverKeyguard`, and the `isKeyguardLocked()` helper. Simplified
  `getPendingDial` (no longer drains the callback there). Added `NotificationManager`
  import and companion constants `ACTION_TRUSTED_CALL_BACK`, `EXTRA_TOKEN`,
  `EXTRA_NOTIFICATION_ID`.

### `AndroidManifest.xml`
- Updated the `ACTION_CALL` intent-filter and `CallActionReceiver` comments to describe the
  token-guarded `getActivity` call-back path and the cancel-only Dismiss.

### `docs/architecture.md`
- Documented the token-guarded `getActivity` call-back, the Dismiss action, and the
  "return to back after a call the app launched" behavior.

The Dart layer is unchanged — the `getPendingDial` → `{number, autoCall}` contract is the
same.

## Verification

- `./gradlew :app:compileDevDebugKotlin` — **BUILD SUCCESSFUL** (only pre-existing Gradle
  native-access warnings).
- `flutter analyze` — **No issues found**.

## Still to verify on device (moto g54)

- Miss a call → notification shows **Call back** + **Dismiss**.
  - Tap **Call back** (incl. from the lock screen) → app comes forward immediately; SIM
    picker / default-SIM call runs; call placed + logged; no need to clear the shade.
  - Tap **Dismiss** → notification clears, no call, no app launch.
- With the app not in the foreground: an incoming call (missed **or** answered) → after it
  ends, the app is **not** left on screen. A call dialed from inside the app stays on screen.
- Regression: an external `ACTION_CALL` `tel:` intent still only pre-fills the dialer
  (never auto-dials) — the token guard keeps the confused-deputy hole closed.
