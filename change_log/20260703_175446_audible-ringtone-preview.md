# Change log — Audible ringtone preview (ring stream + contact profile migration)

Implements plan
[plans/20260703_174132_audible-ringtone-preview.md](../plans/20260703_174132_audible-ringtone-preview.md).

## Problem

Ringtone previews were inaudible even though playback started:

1. Every preview played on the **media** stream (`USAGE_MEDIA` in the native player;
   `audioplayers` likewise), while real calls ring on the **ring** stream. With media volume
   low/0 the preview was silent — confirmed by the user: raising media volume made it audible.
2. The contact profile screen was never migrated in the 2026-07-03 SAF fix — it still played
   every tone through `audioplayers`' `DeviceFileSource`, which can't open the `content://`
   URIs all current tones use, and fails silently.

## Changes

### Native

- **android/.../MainActivity.kt**
  - `previewRingtone` now plays with `USAGE_NOTIFICATION_RINGTONE` (ring stream — same
    attributes as `IncomingCallRinger`) and applies the in-app ringtone-volume-percent scale
    from the shared `contact_sphere_ringer` prefs, so a preview sounds exactly like an
    actual incoming call.
  - Return type changed `Boolean` → `String` status: `"playing"`, `"muted"` (started but
    inaudible: silent/vibrate mode, ring volume 0, or in-app volume 0), `"missing"` (source
    can't be opened). New `PREVIEW_*` constants; added `AudioManager` import.

### Dart

- **lib/services/telecom_service.dart**
  - New top-level `enum RingtonePreviewStatus { playing, muted, missing }`.
  - `previewRingtone` returns `Future<RingtonePreviewStatus>` (`missing` off-Android/on error).

- **lib/screens/ringtone_settings_screen.dart**, **lib/screens/add_edit_contact_screen.dart**
  - All previews (including legacy plain file paths) now go through the native player; the
    in-screen `AudioPlayer`, its complete-listener, and the `existsSync` guard are gone
    (native `missing` covers deleted files).
  - `muted` → snackbar *"Ring volume is muted — turn it up to hear the preview."*;
    `missing` → existing revert-to-default flow, unchanged.

- **lib/screens/contact_detail_screen.dart** (the unmigrated screen)
  - Preview now plays/stops via `TelecomService.previewRingtone`/`stopRingtonePreview` with
    the same status handling; `missing` shows *"pick a new one in Edit"* (no DB write from a
    read screen). `AudioPlayer`/subscription removed; native preview stopped in `dispose`.

- **pubspec.yaml** — removed `audioplayers` (those three screens were its only consumers).
  Bonus: `:audioplayers_android` was the module tripping the JDK-24 Gradle configuration
  failure on direct `gradlew` runs.

- **docs/known-gaps.md** — preview note updated to the native ring-stream player.

## Verification

- `flutter pub get` — resolved cleanly after the dependency removal.
- `flutter analyze` — No issues found.
- `gradlew :app:compileDebugKotlin` — BUILD SUCCESSFUL (with the `org.gradle.java.home`
  JBR-21 pin in `android/gradle.properties`).
- `flutter test` — 42 pass; 1 **pre-existing, unrelated** failure: `widget_test.dart`
  "renders the home shell" expects the Material `NavigationBar` that today's nav redesign
  replaced with a custom bar (`home_shell.dart`). Not touched by this change.
- Device testing requires a full `flutter run`/reinstall (Kotlin changed — hot reload won't
  load it): (1) preview from SIM settings / contact profile / add-edit is audible at ring
  volume even with media volume 0; (2) on vibrate/silent or ring volume 0 a "ring volume is
  muted" hint appears; (3) a deleted tone reverts (settings/edit) or advises re-pick (profile).
