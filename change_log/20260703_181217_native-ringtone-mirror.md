# Native ringtone mirror — correct tone from the first note

Implements [plans/20260703_175535_native-ringtone-mirror.md](../plans/20260703_175535_native-ringtone-mirror.md).

## Problem fixed

Incoming calls from a contact with a custom ringtone rang the default SIM tone
for ~1–3 seconds before audibly switching to the contact's tone, because the
native ringer started the default immediately while the Flutter side resolved
the caller and pushed the custom tone late.

## What changed

Ringtone data is now mirrored from Flutter into the native
`contact_sphere_ringer` SharedPreferences file (the pattern already used for
volume/vibrate), so `IncomingCallRinger` resolves the correct tone
**synchronously** at ring time: contact tone → per-SIM tone → system default.

### Android

- `IncomingCallRinger.kt`
  - `start()` now takes the caller number + phoneAccountId and resolves the
    tone from two mirrored JSON maps in prefs: `contact_ringtones` (keyed by
    the number's trailing 7 digits — the same slice
    `ContactRepository.findByFullNumber` prefilters on) and `sim_ringtones`
    (keyed by phoneAccountId). Unresolvable/unplayable tones fall back to the
    system default.
  - Tracks the currently playing URI; `setCustomTone` (the late Flutter push,
    kept as a stale-mirror safety net) no-ops when asked to play the tone
    already playing, so the normal case no longer restarts the ring.
  - New companion keys `KEY_CONTACT_TONES`, `KEY_SIM_TONES`, `MATCH_DIGITS`.
- `ContactSphereInCallService.kt` — `startRinging` passes the call's number and
  `accountHandle.id` into `ringer.start(...)`.
- `MainActivity.kt` — new `setRingtoneMirror` method-channel handler persisting
  the two maps as JSON strings into the ringer prefs file (null map leaves that
  key untouched).

### Flutter

- `lib/services/telecom_service.dart` — new `setRingtoneMirror({contactTones, simTones})`.
- `lib/repositories/contact_repository.dart`
  - `ringtoneMirrorEntries()` — `{trailing-7-digits: tone path}` for every
    number of every contact with a `ringtone_path`.
  - `pushRingtoneMirror()` — rebuilds and pushes the contact map; **debounced
    1 s via a static timer** (deviation from the plan's letter, same intent:
    a device sync updates hundreds of contacts in a loop and would otherwise
    push per write). Called after `insertContact` / `updateContact` /
    `deleteContact`.
- `lib/services/contact_sync_service.dart` — `syncFromDevice()` triggers one
  (debounced) mirror push for the whole sync.
- `lib/state/app_settings.dart`
  - `_mirrorSimRingtones()` pushes `{phoneAccountId: path}`; called from
    `setSimRingtone(...)` on every change.
  - `load()` pushes both maps once at startup so existing installs get a
    mirror without waiting for the next edit.

## Verification

- `flutter analyze` — no issues.
- `flutter build apk --debug --flavor dev` — Kotlin compiles, build succeeds.
- `flutter test` — 42 pass; the 1 failure (`widget_test.dart` "renders the home
  shell") is **pre-existing and unrelated**: it expects a Material
  `NavigationBar`, which `home_shell.dart` deliberately replaced with a custom
  bottom bar. Confirmed by re-running with this change's startup push disabled —
  identical failure.
- Manual on-device test still recommended: custom-tone contact rings their tone
  from the first note (warm + cold start); SIM tone rings when only a SIM tone
  is set; default otherwise; clearing a contact's tone reverts to default.
