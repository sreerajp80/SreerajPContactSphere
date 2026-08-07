# Ringtone Settings (volume, vibration, per-SIM ringtone)

**Status:** completed

## Issue / goal

The app owns the incoming-call ringing experience (manifest declares
`IN_CALL_SERVICE_RINGING`, so `IncomingCallRinger` plays the tone and drives
vibration itself). Today there are **no user controls** for:

- **Ringtone volume** — the tone plays at whatever the OS ring-stream volume is; no in-app scaling.
- **Vibration on/off** — vibration is hardcoded, gated only by the device ringer mode (silent/vibrate/normal). The user can't disable it while keeping sound.
- **Per-SIM ringtone** — no way to give each SIM its own incoming tone.

Per-**contact** ringtone already exists (contact editor → `Contact.ringtonePath`,
applied in `in_call_screen.dart`) and works correctly; it will be left as-is and
merely referenced from the new screen.

We want a new **"Ringtone" settings screen** under the Settings hub that houses
volume, vibration, and per-SIM ringtone controls.

## Key constraint (why the design is shaped this way)

`ContactSphereInCallService.startRinging()` → `IncomingCallRinger.start()` runs
**natively the instant a call arrives**, frequently before the Flutter engine is
running (app killed / cold start). So volume and vibration preferences must be
**readable by native code at ring time**, not pushed live over the method channel.

**Approach:** Flutter remains the source of truth (via `AppSettings` /
`shared_preferences` for the UI), and mirrors the two ringer prefs into a small
**native `SharedPreferences` file** (`contact_sphere_ringer`) through a new
method-channel call. Native reads that file when it starts ringing. Native falls
back to sensible defaults (volume 100%, vibrate on) when a key/file is absent, so
a call received before the user ever opens the app still behaves correctly.

Per-SIM ringtone does **not** need this native mirror: the tone swap already
happens from Flutter (`setIncomingRingtone`) once the call/caller is resolved, so
it stays entirely on the Dart side and reuses the existing channel.

## Files to change

**Dart**
1. `lib/state/app_settings.dart` — add three persisted prefs + setters:
   - `ringtoneVolumePercent` (int 0–100, default 100)
   - `vibrateOnIncomingCall` (bool, default true)
   - `perSimRingtones` (map: phoneAccountId → {path, label}), persisted as JSON.
   - On `load()` and on every change of the first two, mirror them to native via a new `TelecomService.setRingerPrefs`.
2. `lib/services/telecom_service.dart` — add `setRingerPrefs({int volumePercent, bool vibrate})` (no-op off Android).
3. `lib/screens/settings_screen.dart` — add a **"Ringtone"** `_SettingsCard` (icon `Icons.notifications_active_outlined`) routing to the new screen; place it just below "SIM & calling".
4. `lib/screens/ringtone_settings_screen.dart` — **NEW**. Contains:
   - **Ringtone volume** card — a slider (0–100%) writing `setRingtoneVolumePercent`.
   - **Vibrate on incoming calls** card — a `SwitchListTile` writing `setVibrateOnIncomingCall`.
   - **Per-SIM ringtone** section — one row per SIM (from `SimService.list()`), each with pick / preview / clear, mirroring the contact-editor ringtone UI. Hidden with an explanatory note when no SIMs are detected (same pattern as `SimSettingsScreen`).
   - A short footnote linking the concept of **per-contact** ringtone to the contact editor (informational only).
   - Reuses `file_selector` (`openFile`) for picking and `audioplayers` (`AudioPlayer` + `DeviceFileSource`) for in-app preview, exactly as `add_edit_contact_screen.dart` does.
5. `lib/screens/in_call_screen.dart` — apply per-SIM ringtone with correct precedence (see below).

**Kotlin (native)**
6. `android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt` — handle a new `setRingerPrefs` method: write `volume` (int) and `vibrate` (bool) into the `contact_sphere_ringer` SharedPreferences file.
7. `android/app/src/main/kotlin/in/sreerajp/contact_sphere/IncomingCallRinger.kt` —
   - read `volume`/`vibrate` from `contact_sphere_ringer` (defaults 100 / true),
   - apply volume via `MediaPlayer.setVolume(v, v)` in `playUri` (so it covers both the default tone and any swapped-in custom/SIM/contact tone), where `v = volumePercent / 100f`,
   - skip `startVibration()` when the vibrate pref is false (silent/vibrate ringer-mode gating is unchanged and still respected).

## Behavior details

### Volume
- `MediaPlayer.setVolume(v, v)` scales the tone **within** the ring stream (0.0–1.0); it does not change the system ring volume. At 0% the ring is effectively muted (vibration, if enabled and ringer mode allows, still fires).

### Vibration
- New pref only *removes* vibration when the user turns it off; it never adds vibration beyond what the ringer mode permits. Effective vibration = `vibratePref && ringerMode != SILENT`.

### Per-SIM ringtone precedence (incoming call)
Final tone chosen as: **per-contact tone → per-SIM tone → native default**.
Implementation in `in_call_screen.dart`, reusing the existing `setIncomingRingtone` swap (last call wins):
- When a ringing call arrives and `CallState.phoneAccountId` is known, if a per-SIM tone is configured, call `setIncomingRingtone(simTone)` once (applies even for unknown callers).
- When the caller resolves to a contact **with** a custom tone, call `setIncomingRingtone(contactTone)` — overrides the SIM tone.
- If the caller resolves with no custom tone, leave the SIM tone playing (do not reset to default).
- Native still ignores the swap outside `RINGER_MODE_NORMAL`, unchanged.

## Testing / verification
- `flutter analyze` clean on changed Dart files.
- Manual on a device: set volume to ~30% and confirm a quieter ring; toggle vibration off and confirm sound-only ringing in normal mode; assign a per-SIM tone and confirm an incoming call on that SIM uses it, while a contact with its own tone still overrides it.
- Confirm defaults (100% / vibrate-on) apply on a fresh install with no saved prefs.

## Out of scope
- Changing the per-contact ringtone flow (already implemented).
- Group ringtones (`Group.ringtonePath` exists in the schema but is unused; not touched here).
- Any change to system ring volume or Do-Not-Disturb behavior.
