# Change log — Per-group ringtone

Implements [plans/20260705_195809_per-group-ringtone.md](../plans/20260705_195809_per-group-ringtone.md).

The `groups.ringtone_path` column was schema-only; now a group tone actually plays. The
precedence is: **contact tone > group tone > SIM tone > system default**. The group tone rides
inside the existing contact tier of the native ringtone mirror, so **no Kotlin/native code
changed**.

## What changed

- **`lib/database/database_helper.dart`**
  - Added `ringtone_label TEXT` to the `groups` CREATE TABLE.
  - Bumped DB version 13 → 14; v13→v14 `_onUpgrade` block adds the column with
    `ALTER TABLE groups ADD COLUMN ringtone_label TEXT`.

- **`lib/models/group.dart`**
  - Added `ringtoneLabel` field + `toMap` / `fromMap` mappings (`ringtone_label`).

- **`lib/repositories/group_repository.dart`**
  - New `setGroupRingtone(id, {path, label})` — sets or clears both columns.
  - New `groupRingtoneForContact(contactId)` — the deterministic group tone for a contact
    (first toned group by name ASC, then id ASC), matching the mirror SQL's pick.
  - `setGroupRingtone`, `deleteGroup`, `addContactToGroup`, and `removeContactFromGroup` now
    call `ContactRepository().pushRingtoneMirror()` (debounced) since each can change a
    member's effective tone.

- **`lib/repositories/contact_repository.dart`**
  - `ringtoneMirrorEntries()` now maps each number to the contact's *effective* tone: their
    own `ringtone_path`, else the first toned group's tone via a correlated subquery
    (same name/id ordering as `groupRingtoneForContact`). Keying (trailing 7 digits) and
    collision behaviour unchanged. (The file's two intentional NUL bytes are untouched.)

- **`lib/screens/in_call_screen.dart`**
  - The late in-call correction now falls back to `groupRingtoneForContact` when the matched
    contact has no tone of their own, pushing it with `source: 'contact'` (same tier, so it
    still beats a racing SIM push).

- **`lib/screens/groups_screen.dart`**
  - Tile subtitle shows the tone when set (`N contact(s) · <label>`).
  - The trailing delete icon became a ⋮ `PopupMenuButton`: **Ringtone…**, **Clear ringtone**
    (only when set), **Delete**.
  - **Ringtone…** opens the same two-source bottom sheet as the contact editor: phone
    ringtones (system picker, `TelecomService.pickRingtone`) or an audio file
    (`TelecomService.pickAudioDocument`, persistable content URI). No new dependencies —
    `file_selector` was not needed here.

- **`docs/known-gaps.md`**
  - The "group ringtone is schema-only" notes replaced with the shipped behaviour.

- **`test/group_ringtone_test.dart`** (new, sqflite ffi)
  - v13→v14 migration keeps group rows and adds a null `ringtone_label`.
  - Mirror map: own tone wins; group tone fills in; multi-group pick is deterministic
    (name, then id); toneless groups are skipped; contacts with no tone anywhere are absent.
  - `groupRingtoneForContact` matches the mirror pick; `setGroupRingtone` stores and clears.

## Verification

- `flutter analyze` — No issues found.
- `flutter test` — all 89 tests pass (48 before this suite, 9 new, plus the rest).
- On-device check still to do by hand: a group member without their own tone should ring the
  group tone from the first note; a member with their own tone keeps it; SIM tone still
  applies to callers with no contact/group tone.
