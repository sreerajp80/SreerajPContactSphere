# Honour "silence the ringtone" gestures and the power button

Implements plan
[plans/20260709_084351_silence-ringer-gesture-power-button.md](../plans/20260709_084351_silence-ringer-gesture-power-button.md).

## What was wrong

The incoming-call ringtone would not stop when the user pressed the power button
or used a device gesture (Motorola flip / shake / pick-up to silence). The app
declares `IN_CALL_SERVICE_RINGING`, so it plays the ringtone itself via
`IncomingCallRinger` rather than letting the platform ring. All of those
silence actions reach the app through the Telecom callback
`InCallService.onSilenceRinger()`, which `ContactSphereInCallService` did not
override — so the request was dropped and the app's own `MediaPlayer` and
vibration kept going.

## What changed

- `android/app/src/main/kotlin/in/sreerajp/contact_sphere/ContactSphereInCallService.kt`
  — added an `onSilenceRinger()` override. It calls `ringer?.stop()` (which stops
  the tone, abandons audio focus, and cancels vibration) and clears the ringer
  reference so a late `setCustomRingtone` push can't restart the sound. The call
  is left in its ringing state, so it can still be answered or declined.

No other files needed changes; `IncomingCallRinger.stop()` already stops sound
and vibration and is safe to call more than once.

## How to verify

On a device with ContactSphere as the default phone app, receive an incoming
call and:

- Press the power button → ringtone and vibration stop; the call stays on screen
  and can still be answered/declined.
- Use the flip / shake / pick-up-to-silence gesture → same result.
