# Per-contact ringtone

**Status:** completed

**Decision:** Option **A** (no live preview, no new dependency).

## Issue

There is no per-contact ringtone. Ringtones exist only at the **group** level:
`groups.ringtone_path` ([database_helper.dart:109](../lib/database/database_helper.dart#L109))
and `GroupRepository.createGroup(name, {ringtonePath})`
([group_repository.dart:25](../lib/repositories/group_repository.dart#L25)) — and even that is
schema-only with no UI. The `flutter_ringtone_player` package is declared in `pubspec.yaml` but
unused in `lib/`.

The request: let each contact have its own ringtone, picked in the add/edit screen and shown on
the contact detail screen.

## Honest limitation (important)

This app is **not** the Android default dialer (see
[docs/known-gaps.md](../docs/known-gaps.md) — call recording / default-dialer notes). A
non-default-dialer app cannot make the OS actually ring a custom per-contact tone for a real
incoming call. So, exactly like the existing group `ringtone_path`, this feature **stores and
displays a per-contact ringtone selection** (the app's own metadata); it does not reprogram the
system telephony ringer. This matches what the codebase already does at group level and is the
realistic scope. This will be documented in `known-gaps.md`.

`flutter_ringtone_player` (v4) can only play the Android **system default** sounds or app-bundled
assets — it cannot play an arbitrary picked file/URI — so it is not usable to preview a
user-picked tone. Preview therefore needs either (a) no playback, or (b) a new audio dependency.
See the open decision below.

## Plan

Mirror the existing `photo_path` pattern end-to-end (column → model → picker → display), using
`file_selector` for the audio file picker (already a dependency, already used in
[export_import_service.dart](../lib/services/export_import_service.dart)).

### Files to change

1. **`lib/database/database_helper.dart`**
   - Add `ringtone_path TEXT` and `ringtone_label TEXT` columns to the `contacts` `CREATE TABLE`.
   - Bump DB `version` 3 → 4.
   - In `_onUpgrade`, add an `if (oldVersion < 4)` block that `ALTER TABLE contacts ADD COLUMN`
     for both new columns (two `ALTER`s; SQLite allows one column per statement).

2. **`lib/models/contact.dart`**
   - Add fields `String? ringtonePath;` and `String? ringtoneLabel;` (constructor params,
     `toMap`, `fromMap`).

3. **`lib/screens/add_edit_contact_screen.dart`**
   - Add `import 'package:file_selector/file_selector.dart';`.
   - State: `String? _ringtonePath;`, `String? _ringtoneLabel;`, initialised from
     `widget.contact`.
   - New `_pickRingtone()` using `openFile` with an audio `XTypeGroup`
     (extensions: mp3, m4a, aac, wav, ogg, flac, opus). On pick, store `file.path` and derive
     `_ringtoneLabel` from the file name (`p.basename`). On error, `_showMessage`.
   - New `_ringtoneSection()` styled with the screen's existing `_shell` / `_addButton` /
     `_squareButton` tokens: shows the chosen tone's name (or "None"), a button to pick/change,
     and a clear (X) button when one is set. Insert it in the `ListView` (e.g. right after
     `_personalSection()`).
   - In `_save()`, set `..ringtonePath = _ringtonePath` and `..ringtoneLabel = _ringtoneLabel`
     on the contact.
   - Add `import 'package:path/path.dart' as p;` for `basename`.

4. **`lib/screens/contact_detail_screen.dart`**
   - Add a `ListTile` (icon `Icons.music_note`) showing the ringtone label when
     `contact.ringtonePath != null`, placed near the groups/official rows.

5. **`docs/known-gaps.md`**
   - Update the ringtone/notes wording: per-contact ringtone is now stored + shown (UI added),
     but, like the group ringtone, it is metadata only — the OS ringer is not reprogrammed
     because the app is not the default dialer.

### Out of scope (not changed)

- CSV export/import (`export_import_service.dart`) — ringtone file paths are device-local and not
  portable, so they are intentionally left out of the CSV columns.
- Group-level ringtone UI — unchanged; still schema-only.
- Actually driving the system ringer for incoming calls — not possible without the default-dialer
  role (documented).

## Open decision (please choose at approval)

**Ringtone preview playback:**
- **A (recommended): no live preview.** Store + display the selection only. No new dependency.
  Honest about the fact the tone is metadata. Smallest change.
- **B: add `audioplayers` dependency** to play the picked file when the user taps a preview/play
  button in the picker section (and stop on dispose). Adds a dependency + `flutter pub get`.

I will implement **A** unless you pick **B**.

## Verification

- `flutter analyze` clean.
- `flutter test` passes (existing suite; DB opens at v4 / migrates from v3).
- Manual: add/edit a contact → pick a ringtone → save → reopen edit (shows the name) and the
  contact detail screen (shows the row); clear works.
