# Ring for allowed callers while Do Not Disturb / Driving mode is on

**Status:** completed

## The issue

While driving with Android Auto, a call from an allowed caller shows on the car
display, but there is no ringtone in the car or on the phone.

What the phone's own logs showed for a real call (Android Auto connected, Google's
"Driving" Do Not Disturb mode active, calls allowed from "anyone"):

1. Do Not Disturb checked the caller and **allowed** the call
   (`matches_call_filter: result=true`, Telecom: `DND not suppressed`).
2. Telecom did **not** ring itself: `SKIP_RINGING (Dialer handles)`. Our app declares
   `IN_CALL_SERVICE_RINGING`, so ringing is our job.
3. Our incoming-call notification was posted and allowed through (it showed on the car).
4. When the Driving mode turned on, Android changed the ringer mode that apps see to
   **silent** (`set_ringer_mode_internal: i:normal->normal, e:normal->silent`). The
   phone's real ("internal") ringer mode stayed **normal**.

`IncomingCallRinger` reads `AudioManager.getRingerMode()`, which returns that
app-facing ("external") value. `RingerPolicy` sees `MODE_SILENT` and turns off both
sound and vibration. So any Do Not Disturb "Priority" mode silences **every** call in
our app, even callers that Do Not Disturb allows. The stock dialer rings for them.

When the car is parked, Driving mode is off, the ringer mode is normal, and our ringtone
plays in the car. So the ringtone already reaches the car. Only the silent decision is
wrong. The per-contact ringtone will play in the car once this is fixed.

## The fix

Only during Do Not Disturb "Priority" mode (`INTERRUPTION_FILTER_PRIORITY`):

1. Ask Android whether this caller may break through Do Not Disturb:
   `NotificationManager.matchesCallFilter(Uri)` with the caller's `tel:` number
   (public from Android 13 / API 33). This is the same check the system uses.
2. If the caller **is allowed**, use the phone's real ringer mode instead of the
   app-facing one. Read it from `Settings.Global.MODE_RINGER` ("mode_ringer"). This is
   where Android stores the real ringer mode. So if the user really set the phone to
   silent or vibrate, we still obey that.
3. If the caller is **not allowed**, or the check can't run (Android 12 or older, no
   number, an error), keep today's behaviour: use the app-facing mode, which stays
   silent. We never ring a caller that Do Not Disturb blocks.

No change outside Priority mode. "Total silence" and "Alarms only" still never ring.
Normal, vibrate and silent modes behave as before.

`RingerPolicy` stays pure (no Android imports). It gets the extra inputs and makes the
choice. `IncomingCallRinger` reads them from the platform. Each read fails safe, as
described in step 3.

Before writing the code, I'll check the exact permission rule for
`matchesCallFilter(Uri)` on the device. If our app (the default phone app) can't call
it, I'll stop and report back instead of guessing.

## Files to change

- `android/app/src/main/kotlin/in/sreerajp/contact_sphere/RingerPolicy.kt`: new inputs
  (`callerAllowedByDnd`, `internalRingerMode`) and the Priority-mode rule above.
- `android/app/src/main/kotlin/in/sreerajp/contact_sphere/IncomingCallRinger.kt`: read
  the real ringer mode and the caller check, then pass them to `RingerPolicy`.
- `android/app/src/test/kotlin/in/sreerajp/contact_sphere/RingerPolicyTest.kt`: new
  tests:
  - Priority + allowed caller + real mode normal: ring.
  - Priority + allowed caller + real mode vibrate: vibrate only.
  - Priority + allowed caller + real mode silent: silent.
  - Priority + caller not allowed: silent.
  - Priority + check unavailable: same as today.
  - Total silence / Alarms only: still silent.
- `docs/architecture.md`: one line on the Do Not Disturb Priority rule in the ringer
  section (only if a ringer section already exists).

## Testing

- `cd android && ./gradlew :app:testDevDebugUnitTest` (RingerPolicy tests).
- `flutter analyze`.
- On the phone, at the desk: turn the Driving mode on by hand, call from another phone,
  and confirm that it rings with the contact's ringtone. Also check the logs show the
  real ringer mode was used. Then test once in the car with Android Auto.

## Out of scope

- How the ring reaches the car. It already works when Do Not Disturb is off.
- Android 12 and older keep today's behaviour (they have no public caller check).
