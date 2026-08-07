# Ringtone preview playback (in-app)

**Status:** completed

## Issue

Per-contact ringtone is currently **store + display only** (see
[plans/20260629_221328_per-contact-ringtone.md](20260629_221328_per-contact-ringtone.md) and the
"Partially integrated" note in [docs/known-gaps.md](../docs/known-gaps.md)). There is no way to
actually *hear* the selected tone. `flutter_ringtone_player` can only play system-default sounds /
bundled assets, not an arbitrary picked file, so it can't preview a user-chosen ringtone.

This is the follow-up the previous change explicitly flagged: add an in-app **preview** (play/stop)
of the selected ringtone file. (It is still *preview only* — the OS telephony ringer is not
reprogrammed; the app is not the default dialer. This plan does not change that.)

## Approach

Add the `audioplayers` package and a play/stop control wherever a ringtone is shown:
- the Add/Edit ringtone section (preview the just-picked tone), and
- the contact detail ringtone row (preview the saved tone).

Each screen owns one `AudioPlayer`, plays the file via `DeviceFileSource(path)`, resets its
play state on completion, and stops/disposes the player when the widget is disposed (and, in the
editor, when the tone is cleared or replaced). All playback is wrapped in try/catch and surfaces a
SnackBar on failure (missing/unsupported file), consistent with the screens' existing error
handling.

### Files to change

1. **`pubspec.yaml`**
   - Add `audioplayers: ^6.1.0` to `dependencies`. Run `flutter pub get`.

2. **`lib/screens/add_edit_contact_screen.dart`**
   - Import `package:audioplayers/audioplayers.dart`.
   - State: `final AudioPlayer _ringtonePreview = AudioPlayer();`, `bool _previewPlaying = false;`,
     and a `StreamSubscription` on `onPlayerComplete` to reset `_previewPlaying`.
   - New `_toggleRingtonePreview()`: if playing → `stop()`; else `play(DeviceFileSource(path))`.
     try/catch → `_showMessage`.
   - `_clearRingtone()` and `_pickRingtone()`: stop the preview first (so a replaced/cleared tone
     doesn't keep playing) and reset `_previewPlaying`.
   - `_ringtoneSection()`: add a play/stop `_squareButton`
     (`Icons.play_arrow` / `Icons.stop`) between the name shell and the existing clear (X) button,
     shown only when `hasTone`.
   - `dispose()`: cancel the subscription and `_ringtonePreview.dispose()`.

3. **`lib/screens/contact_detail_screen.dart`**
   - Import `package:audioplayers/audioplayers.dart`.
   - State: `final AudioPlayer _ringtonePreview = AudioPlayer();`, `bool _previewPlaying = false;`,
     plus an `onPlayerComplete` subscription resetting the flag.
   - New `_toggleRingtonePreview(String path)` mirroring the editor (play/stop, try/catch →
     SnackBar).
   - The existing ringtone `ListTile` (currently at lines ~250-255): add a `trailing` IconButton
     (`Icons.play_arrow` / `Icons.stop`) wired to the toggle.
   - `dispose()`: this State has no `dispose` yet — add one that cancels the subscription, disposes
     the player, and calls `super.dispose()`. (The `CallLifecycleMixin` / `WidgetsBindingObserver`
     don't currently require a local `dispose`; confirm the mixin doesn't need a `super.dispose()`
     hook — if it does, chain it.)

4. **`docs/known-gaps.md`**
   - Update the "Partially integrated → Per-contact ringtone" entry: an in-app preview now exists
     (via `audioplayers`); it remains preview-only (OS ringer still not reprogrammed; not the
     default dialer).

### Out of scope (unchanged)

- Driving the actual incoming-call ringer (needs default-dialer role).
- Including ringtone in CSV export/import or device-contacts sync (device-local path; intentionally
  app-only, consistent with prior decisions).

## Risks / notes

- `audioplayers` v6 is the current major line; `flutter pub get` will resolve the exact patch. If
  resolution conflicts with existing deps, fall back to the latest compatible 6.x and note it.
- `file_selector` may hand back a cached copy path; `DeviceFileSource` plays a real file path, so
  this works best-effort. If a path is later invalid (file moved/deleted), playback throws and is
  caught → SnackBar.
- No new Android permission is needed for local-file playback.
- Tests don't build these screens (only `widget_test` renders the home shell), so no audio
  platform channel is exercised under `flutter test`.

## Verification

- `flutter pub get` succeeds.
- `flutter analyze` clean.
- `flutter test` passes (existing suite).
- Manual: pick a ringtone in Add/Edit → play/stop preview works, clearing/replacing stops it;
  save → open detail → play/stop on the ringtone row works; leaving the screen stops audio.
