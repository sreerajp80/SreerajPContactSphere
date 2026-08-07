# Lock-screen in-call: easy disconnect

**Status:** completed

## The issue

When a call is active and the phone is at the ear, the proximity sensor blanks the
screen. When the user wakes the phone at the lock screen to disconnect:

1. The persistent call icon shows in the status bar, but pulling down the notification
   shade shows **nothing** — no Hang Up control.
2. The user lands on the lock screen, not the in-call screen, so they must open the app
   to disconnect.

### Root cause

- **Shade shows nothing:** the active-call notification is a CallStyle "ongoing call"
  notification (it has a Hang Up action), but it is posted on the `ongoing_call` channel
  which is `IMPORTANCE_LOW`
  (`ContactSphereInCallService.kt` `createChannel()`, ~line 590-603). Android treats
  `IMPORTANCE_LOW` as **silent**, and lock screens hide silent notifications by default.
  So the Hang Up control never appears in the lock-screen shade. LOW was chosen so the
  ongoing notification never peeks as a heads-up over our own in-call screen.
- **Lands on lock screen, not call UI:** the in-call UI (`MainActivity`) is marked
  `setShowWhenLocked(true)` while a call is present, but a plain power-button wake shows
  the keyguard rather than re-presenting the over-keyguard activity. Nothing re-launches
  the in-call UI when the screen turns back on.

User chose **Both** fixes.

## Files to change

1. `android/app/src/main/kotlin/in/sreerajp/contact_sphere/ContactSphereInCallService.kt`
   - Fix A (notification visible on lock screen).
   - Fix B (re-show in-call UI on screen-on) — screen-on receiver lives here since the
     service owns the call lifecycle and already has `launchInCallUi()`.

## The plan

### Fix A — make the ongoing-call notification show its Hang Up on the lock screen

- Replace the `IMPORTANCE_LOW` ongoing channel with a new channel id
  (e.g. `ongoing_call_v2`) at `IMPORTANCE_DEFAULT`. (Channel importance is immutable once
  created, so a new id is required — same pattern already used for the quiet incoming
  channel.) Set `lockscreenVisibility = Notification.VISIBILITY_PUBLIC` and keep
  `setSound(null,null)` / `enableVibration(false)` so it stays quiet.
- `IMPORTANCE_DEFAULT` makes the notification non-silent, so the lock screen shows it and
  its Hang Up button. A CallStyle **ongoing** notification renders as a persistent ongoing
  notification, not a heads-up popup, so it should not banner over our own in-call screen.
  This is the main thing to confirm on-device (see Verification).
- Update the `ONGOING_CHANNEL_ID` constant / channel-creation block accordingly.

### Fix B — re-show the in-call screen when the screen turns on during an active call

- Register a runtime `BroadcastReceiver` for `Intent.ACTION_SCREEN_ON` (SCREEN_ON cannot
  be declared in the manifest on modern Android, so register/unregister in code).
- Register it when a call becomes active (call connected) and unregister when the call
  ends / service tears down, to avoid leaks and needless wakeful work.
- On `ACTION_SCREEN_ON`, if a call is still present and the in-call UI is not already
  visible (`CallRegistry.isInCallUiVisible()` is false), call the existing
  `launchInCallUi()` so `MainActivity` comes over the keyguard with the End Call button.
  Guard against double-launch when the UI is already front.

## Risks / notes

- Fix A: small chance `IMPORTANCE_DEFAULT` produces a brief heads-up on some OEM skins.
  If observed, fall back to keeping the channel LOW but rely on Fix B as the primary path,
  or explore posting the ongoing notification with an explicit no-heads-up behavior.
- Fix B: launching an activity from the background is allowed here because we are the
  default dialer with an active call (foreground-service + CATEGORY_CALL), the same path
  already used by `launchInCallUi()` for incoming calls.
- No Dart/Flutter changes expected; both fixes are in the Android native layer.

## Verification

- Build and install on the moto g54.
- Place/answer a call, put phone to ear (screen blanks), move away / press power:
  - Confirm the in-call screen appears over the lock screen with End Call (Fix B).
  - Pull down the shade and confirm the ongoing-call notification with Hang Up is visible
    and expandable (Fix A).
- Confirm no heads-up banner covers the in-call screen during a normal in-app call
  (regression check for the reason LOW was originally chosen).
