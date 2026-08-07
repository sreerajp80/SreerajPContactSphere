# Change log — Ringtone preview playback (in-app)

Implements [plans/20260630_073855_ringtone-preview-playback.md](../plans/20260630_073855_ringtone-preview-playback.md).

Adds an in-app **preview** (play/stop) of the per-contact ringtone file. Still preview-only — the
OS incoming-call ringer is not reprogrammed (the app is not the default dialer).

## What changed

- **`pubspec.yaml`**
  - Added `audioplayers: ^6.1.0`. `flutter pub get` resolved it cleanly (no constraint conflicts).

- **`lib/screens/add_edit_contact_screen.dart`**
  - Imported `dart:async` and `package:audioplayers/audioplayers.dart`.
  - Added preview state: `AudioPlayer _ringtonePreview`, `bool _previewPlaying`, and an
    `onPlayerComplete` subscription (`_previewCompleteSub`) that resets the flag, wired in
    `initState`.
  - New `_toggleRingtonePreview()` (play via `DeviceFileSource` / stop, try/catch → SnackBar) and
    `_stopPreview()` helper.
  - `_pickRingtone()` and `_clearRingtone()` now stop any running preview first (so a
    replaced/cleared tone doesn't keep playing); `_clearRingtone` became `Future<void>`.
  - `_ringtoneSection()` gained a play/stop `_squareButton` (between the name shell and the clear X),
    shown only when a tone is set.
  - `dispose()` cancels the subscription and disposes the player.

- **`lib/screens/contact_detail_screen.dart`**
  - Imported `dart:async` and `package:audioplayers/audioplayers.dart`.
  - Added the same preview state + `onPlayerComplete` subscription in `initState`.
  - New `dispose()` (cancels subscription, disposes player, chains `super.dispose()` — which runs
    `CallLifecycleMixin.dispose` to remove the lifecycle observer).
  - New `_toggleRingtonePreview(String path)` (play/stop, mounted-guarded SnackBar on error).
  - The ringtone `ListTile` gained a trailing play/stop `IconButton`.

- **`docs/known-gaps.md`**
  - Updated the "Partially integrated → Per-contact ringtone" entry to note the in-app preview via
    `audioplayers`, still preview-only.

## Not changed (per plan)

- Actual incoming-call ringing (needs default-dialer role).
- CSV export/import and device-contacts sync — ringtone remains app-only / device-local.

## Verification

- `flutter pub get` — Got dependencies.
- `flutter analyze` — No issues found.
- `flutter test` — all 21 tests pass (screens with the audio player aren't built in tests, so no
  audio platform channel is exercised).
