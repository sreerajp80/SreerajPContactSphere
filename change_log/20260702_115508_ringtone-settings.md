# Change log — Ringtone Settings (volume, vibration, per-SIM ringtone)

Implements [plans/20260702_112951_ringtone-settings.md](../plans/20260702_112951_ringtone-settings.md).

## Summary

Added a new **Ringtone** settings screen (Settings hub → "Ringtone") with three
controls for the incoming-call ringing experience the app owns:

- **Ringtone volume** (0–100% slider) — scales the tone within the ring stream.
- **Vibrate on incoming calls** (switch) — lets the user turn vibration off while
  keeping sound; the device ringer mode (silent) still overrides it.
- **Per-SIM ringtone** — a ringtone per SIM, with pick / preview / clear per row.

Per-contact ringtone (already implemented) is unchanged and now takes precedence
over the per-SIM ringtone. Incoming-tone precedence: **contact → per-SIM → native
default**.

## Why the native mirror

`IncomingCallRinger.start()` runs natively the instant a call arrives, often
before the Flutter engine is up (cold start). So volume/vibration are mirrored
from Flutter into a native `SharedPreferences` file (`contact_sphere_ringer`) that
the ringer reads synchronously at ring time; native falls back to defaults
(volume 100%, vibrate on) when a key is absent.

## Files changed

**Dart**
- `lib/state/app_settings.dart` — new `RingtoneRef` model; `ringtoneVolumePercent`
  (default 100), `vibrateOnIncomingCall` (default true), and `perSimRingtones`
  (JSON-persisted map) prefs with getters/setters; `ringtoneForSim(...)` and static
  `readSimRingtone(...)`; `_mirrorRingerPrefs()` pushes volume/vibrate to native on
  `load()` and on every change.
- `lib/services/telecom_service.dart` — added `setRingerPrefs({volumePercent, vibrate})`.
- `lib/screens/ringtone_settings_screen.dart` — **new** screen (volume slider,
  vibration switch, per-SIM ringtone list with a "no SIMs" note, per-contact
  precedence footnote). Reuses `file_selector` for picking and `audioplayers` for
  in-app preview.
- `lib/screens/settings_screen.dart` — new "Ringtone" card routing to the screen.
- `lib/screens/in_call_screen.dart` — `_resolveRingtone` / `_applySimRingtone` apply
  the per-SIM tone once per ringing call; a contact tone sets `_contactToneApplied`
  so it isn't clobbered by a later-resolving SIM tone.

**Kotlin**
- `android/.../IncomingCallRinger.kt` — reads `volume`/`vibrate` from the
  `contact_sphere_ringer` prefs file (defaults 100 / true); applies volume via
  `MediaPlayer.setVolume(v, v)` in `playUri`; skips vibration when disabled. Added
  companion constants for the prefs file/keys.
- `android/.../MainActivity.kt` — handles the `setRingerPrefs` method by writing
  the values into the `contact_sphere_ringer` prefs file.

## Verification

- `flutter analyze` on the five changed Dart files: **No issues found**. (Whole-project
  analyze still surfaces the pre-existing gaps documented in `docs/known-gaps.md`.)
- Manual device verification (volume scaling, vibration toggle, per-SIM tone with
  contact-tone override, fresh-install defaults) still to be performed on a device.

## Notes / out of scope

- System ring volume and Do-Not-Disturb behavior are untouched.
- `Group.ringtonePath` remains unused (not part of this change).
