# Change log: Lock-screen in-call easy disconnect

Implements plan `plans/20260714_084905_lockscreen-incall-disconnect.md`.

## What changed

All changes are in
`android/app/src/main/kotlin/in/sreerajp/contact_sphere/ContactSphereInCallService.kt`.
No Dart/Flutter changes.

### Fix A — ongoing-call notification now shows in the lock-screen shade

- Raised the active-call notification channel from `IMPORTANCE_LOW` to
  `IMPORTANCE_DEFAULT` and set `lockscreenVisibility = Notification.VISIBILITY_PUBLIC`.
  LOW made the notification "silent", which lock screens hide by default, so its Hang Up
  button never appeared when the shade was pulled down. It stays sound/vibration free.
- Because channel importance is immutable once created, the channel id was changed from
  `ongoing_call` to `ongoing_call_v2` so the new importance takes effect on existing
  installs.
- Updated the now-stale comment in `onUiVisibilityChanged()` that referred to the ongoing
  notification living on a low-importance channel.

### Fix B — in-call screen re-shows when the screen turns on during a call

- Added a runtime `BroadcastReceiver` for `Intent.ACTION_SCREEN_ON`
  (`registerScreenOnReceiver()` / `unregisterScreenOnReceiver()`, field `screenOnReceiver`).
- Registered when a call becomes present (`startRinging`, `showOngoingCall`; guarded so it
  registers once) and unregistered in `onCallEnded` (with a double-unregister guard).
- On screen-on, if a call is still present and the in-call UI isn't already visible
  (`CallRegistry.isInCallUiVisible()`), it calls the existing `launchInCallUi()` so
  `MainActivity` comes over the keyguard with the End Call button — instead of the user
  landing on the bare lock screen.
- Added imports: `android.content.BroadcastReceiver`, `android.content.IntentFilter`.

## Verification done

- `./gradlew :app:compileDevDebugKotlin` compiles cleanly (only unrelated JVM native-access
  warnings).

## Verification still needed on device (moto g54)

- During an earpiece call, blank the screen (proximity) then wake it: confirm the in-call
  screen appears over the lock screen with End Call (Fix B).
- Pull down the lock-screen shade mid-call: confirm the ongoing notification with Hang Up
  is visible and expandable (Fix A).
- Regression: confirm no heads-up banner covers the in-call screen during a normal in-app
  call (the reason LOW was originally chosen). If a banner appears on this OEM skin, fall
  back to LOW and rely on Fix B.
