# Plan — Make the ringtone preview actually audible (ring stream + contact profile migration)

**Status:** completed

Follow-up to [plans/20260703_171128_ringtone-preview-no-sound.md](../plans/20260703_171128_ringtone-preview-no-sound.md)
(implemented earlier today). The user still hears nothing when previewing from the ringtone
settings screen or from a contact's profile.

## Diagnosis

Two independent causes found by code inspection (the Kotlin from the earlier fix compiles
cleanly — verified with `gradlew :app:compileDebugKotlin` — so this is not a stale-build issue):

1. **Contact profile was never migrated.** The earlier SAF fix updated
   `ringtone_settings_screen.dart` and `add_edit_contact_screen.dart`, but
   `contact_detail_screen.dart` (`_toggleRingtonePreview`, line ~63) still plays **every**
   tone through `audioplayers`' `DeviceFileSource`. All tones picked since the SAF fix are
   `content://` URIs, which `audioplayers` cannot open — and its `play()` fails silently.
   The contact-profile preview therefore can never make a sound for a current tone.

2. **Every preview plays on the wrong audio stream.** The native preview player
   (`MainActivity.previewRingtone`) uses `USAGE_MEDIA`, and `audioplayers` also plays on the
   media/music stream. The actual incoming-call ringer (`IncomingCallRinger`) plays with
   `USAGE_NOTIFICATION_RINGTONE` on the **ring** stream. On a device whose *media* volume is
   low or 0 (typical for a phone used mainly for calls), every preview in the app is
   inaudible while real calls ring fine — which matches the symptom persisting across
   previous fixes: playback "works", it just can't be heard. Nothing tells the user the
   stream is muted, so silence looks like a bug.

## Files to change

- `android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt`
- `lib/services/telecom_service.dart`
- `lib/screens/ringtone_settings_screen.dart`
- `lib/screens/add_edit_contact_screen.dart`
- `lib/screens/contact_detail_screen.dart`
- `pubspec.yaml` (dependency removal, see step 5)
- `docs/known-gaps.md` / `docs/dependencies.md` (drop the audioplayers notes)

## Fix

1. **MainActivity.kt — preview on the ring stream, faithful to a real call.**
   - `previewRingtone`: switch the `AudioAttributes` from `USAGE_MEDIA` to
     `USAGE_NOTIFICATION_RINGTONE` (same as `IncomingCallRinger`), and apply the same
     user ringtone-volume-percent scale from the native `contact_sphere_ringer` prefs, so
     the preview sounds exactly like the phone will ring.
   - Change the return value from `Boolean` to a status `String`:
     - `"playing"` — playback started and should be audible;
     - `"muted"` — playback started but won't be heard: ringer mode is silent/vibrate,
       ring-stream volume is 0, or the app's ringtone volume preference is 0;
     - `"missing"` — the source can't be opened (deleted/moved backing file).

2. **telecom_service.dart** — `previewRingtone` returns a small
   `enum RingtonePreviewStatus { playing, muted, missing }` mapped from the string
   (`missing` off-Android / on error).

3. **ringtone_settings_screen.dart + add_edit_contact_screen.dart**
   - `missing` → existing revert-to-default flow (unchanged).
   - `muted` → tone keeps "playing" state, plus a snackbar: *"Ring volume is muted —
     turn it up to hear the preview."*
   - Route legacy plain-file paths through the native preview too (it already wraps them
     in `file://`), so every preview uses the ring stream; remove the in-screen
     `AudioPlayer` instances and the `existsSync` guard (native `missing` covers it).

4. **contact_detail_screen.dart — migrate to the native preview.**
   - `_toggleRingtonePreview` plays/stops via `TelecomService.previewRingtone` /
     `stopRingtonePreview` with the same status handling; `missing` → snackbar advising to
     pick a new tone in Edit (no DB write from the view screen — the repository has no
     targeted ringtone setter and auto-clearing from a read screen is a surprising side
     effect).
   - Stop the native preview in `dispose`; remove the `AudioPlayer`/subscription state.

5. **Drop `audioplayers`.** After steps 3–4 the three screens were its only consumers
   (the only other mention is a doc comment). Remove it from `pubspec.yaml` and the doc
   references. Bonus: `:audioplayers_android` is the module that trips the JDK-24 Gradle
   configuration failure, so direct `gradlew` runs get more robust too.

## Verification

- `flutter analyze` (changed files clean) and `flutter test`.
- `android/gradlew :app:compileDebugKotlin` (toolchain confirmed working via the
  `org.gradle.java.home` pin).
- Device checklist — **needs a full `flutter run` / reinstall (native code changed; hot
  reload will not load the Kotlin)**:
  1. Settings → SIM ringtone preview: audible with ring volume up, even with media volume 0.
  2. Contact profile preview: audible for a `content://` tone.
  3. With ringer on vibrate or ring volume 0: preview shows the "ring volume is muted" hint.
  4. Deleted backing file: reverts (settings/edit) or advises re-pick (profile).
