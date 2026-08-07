# Change log — Per-contact ringtone

Implements [plans/20260629_221328_per-contact-ringtone.md](../plans/20260629_221328_per-contact-ringtone.md)
(Option A: store + display only, no live preview, no new dependency).

## What changed

- **`lib/database/database_helper.dart`**
  - Added `ringtone_path TEXT` and `ringtone_label TEXT` columns to the `contacts` table.
  - Bumped DB `version` 3 → 4; added a v3→v4 `_onUpgrade` block that `ALTER TABLE contacts ADD
    COLUMN` for both new columns.

- **`lib/models/contact.dart`**
  - Added `ringtonePath` / `ringtoneLabel` fields, constructor params, and `toMap` / `fromMap`
    mappings (`ringtone_path`, `ringtone_label`).

- **`lib/screens/add_edit_contact_screen.dart`**
  - New imports: `file_selector` and `path` (as `p`).
  - New state `_ringtonePath` / `_ringtoneLabel`, initialised from the edited contact.
  - New `_pickRingtone()` (audio `XTypeGroup`: mp3, m4a, aac, wav, ogg, flac, opus — label from
    `p.basename`) and `_clearRingtone()`.
  - New `_ringtoneSection()` styled with the screen's existing `_shell` / `_squareButton` tokens
    (shows the tone name or "None", tap to pick/change, X to clear), inserted after the Personal
    details section.
  - `_save()` now writes `ringtonePath` / `ringtoneLabel` onto the contact.

- **`lib/screens/contact_detail_screen.dart`**
  - Added a ringtone `ListTile` (icon `Icons.music_note`) shown when `contact.ringtonePath != null`.

- **`docs/known-gaps.md`**
  - Added a "Partially integrated" entry documenting that the per-contact ringtone is stored and
    displayed but is metadata only (OS ringer not reprogrammed — not the default dialer; no in-app
    preview because `flutter_ringtone_player` can't play arbitrary files).

## Not changed (per plan)

- CSV export/import — ringtone paths are device-local, intentionally excluded.
- Group-level ringtone UI — still schema-only.

## Verification

- `flutter analyze` — No issues found.
- `flutter test` — all 16 tests pass (DB migrates cleanly to v4).
