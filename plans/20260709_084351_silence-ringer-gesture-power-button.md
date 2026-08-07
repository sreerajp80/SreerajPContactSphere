# Honour "silence the ringtone" gestures and the power button

**Status:** completed

## The issue

On the user's Android devices, the incoming-call ringtone does **not** stop when:

1. A device gesture asks to silence the ring — e.g. Motorola's "flip for
   silence", "pick up to silence", or "shake to silence".
2. The power button is pressed (many phones use a power-button press to silence
   the ringtone of an incoming call).

Why it happens: ContactSphere declares `IN_CALL_SERVICE_RINGING` in the manifest,
so the platform does **not** ring for us — [`IncomingCallRinger`](../android/app/src/main/kotlin/in/sreerajp/contact_sphere/IncomingCallRinger.kt)
plays the tone itself through a `MediaPlayer` and drives vibration. All of the
gestures and the power-button press funnel through the Telecom framework, which
tells the active in-call service to silence the ring by calling
`InCallService.onSilenceRinger()`. Our [`ContactSphereInCallService`](../android/app/src/main/kotlin/in/sreerajp/contact_sphere/ContactSphereInCallService.kt)
**never overrides that callback**, so the request is dropped and our own
`MediaPlayer`/vibration keep going. (Verified: `onSilenceRinger` is not
referenced anywhere in the project.)

`onSilenceRinger()` is the single correct hook — the power button, flip, shake,
and pick-up gestures all resolve to the same "silence the ringer" telecom
request, so handling it fixes both reported problems at once.

## The fix

Override `onSilenceRinger()` in `ContactSphereInCallService` to stop our own
ringtone and vibration, while leaving the call in its ringing state so the user
can still answer or decline it (this matches normal "silence the ringer"
behaviour — it hushes the alert, it does not reject the call).

Concretely, add to `ContactSphereInCallService`:

```kotlin
override fun onSilenceRinger() {
    super.onSilenceRinger()
    // The user asked the platform to silence the ringer — via the power button
    // or a flip / shake / pick-up-to-silence gesture. Because we own the ringing
    // experience (IN_CALL_SERVICE_RINGING) and play the tone ourselves, the
    // platform can't silence it for us; we must stop our own ringtone + vibration.
    // The call stays ringing so it can still be answered or declined.
    ringer?.stop()
    ringer = null
}
```

`IncomingCallRinger.stop()` already stops the `MediaPlayer`, abandons audio
focus, and cancels vibration, and is safe to call more than once. Setting
`ringer = null` mirrors what `stopRinging()` already does, and means a late
`setCustomRingtone` tone push after silencing correctly no-ops (the sound must
not come back once silenced).

## Files to change

- `android/app/src/main/kotlin/in/sreerajp/contact_sphere/ContactSphereInCallService.kt`
  — add the `onSilenceRinger()` override described above. (No other file needs
  to change; `IncomingCallRinger.stop()` already does the right thing.)

## How to verify

Build and install on a device, then with ContactSphere as the default phone app,
receive an incoming call and:

- Press the power button → the ringtone and vibration stop, the call stays on
  screen and can still be answered/declined.
- Use the device's flip / shake / pick-up-to-silence gesture → same result.

## Notes / risk

- Very small, additive change; no behaviour change to answering, declining, or
  the ongoing-call path.
- `onSilenceRinger()` is a standard `InCallService` callback available on all API
  levels this app targets, so no version guard is needed.
