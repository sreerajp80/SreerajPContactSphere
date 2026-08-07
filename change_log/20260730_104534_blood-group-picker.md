# Blood group is now picked, not typed

Implements [plans/20260730_104106_blood-group-picker.md](../plans/20260730_104106_blood-group-picker.md).

## Why

Blood group was a free text field in the contact editor, in the **Me** (Self) record
and in Emergency info. A blood group can only be one of eight values, so typing it
allowed `O+ve`, `o positive`, `0+`, `AB Positive` and plain typos — silent mistakes
that would show up on the emergency lock-screen card exactly when they matter.

## What changed

### New: `lib/core/constants/blood_groups.dart`

- `kBloodGroups` — the eight standard values: `A+ A- B+ B- AB+ AB- O+ O-`.
- `normalizeBloodGroup()` — cleans an old hand-typed value into one of the eight.
  It reads the spelled-out sign (`positive`, `neg`, `+ve`, `-ve`), ignores spaces
  and punctuation, and treats a zero as the letter `O` (`0-` → `O-`). It returns
  `null` when the text cannot be read as a blood group, including when there is no
  Rh sign at all.

### `lib/screens/add_edit_contact_screen.dart` (contact editor and the Me record)

- The `_bloodGroup` text controller is gone; the value is now a plain `String`
  with a `_bloodGroupField()` picker built from the screen's existing
  `_menuButton` + `_chipWrap` + `_chip` helpers, so it looks and behaves like the
  gender picker already on the same form.
- Chips are the eight groups plus a **Clear** chip (the field is optional). There is
  deliberately **no Custom chip** — free text was the problem.
- On open, a stored value is run through `normalizeBloodGroup`. If it cannot be
  cleaned up, the original text stays selected and appears as an extra chip, so
  editing a contact never quietly deletes data.

### `lib/screens/emergency_info_screen.dart`

- The `_bloodCtrl` text field is replaced by a `DropdownButtonFormField` with a
  "Not set" entry and the eight groups, styled with the same outlined border as the
  other fields. The per-field "Show on lock screen" toggle is unchanged.
- Same treatment for old values: unreadable text is kept and offered as an extra
  dropdown entry.

### New: `test/blood_group_test.dart`

Five tests covering the cleaner: standard values pass through, spelled-out signs,
zero-for-O, spacing and punctuation, and the cases that must return `null`.

## Not changed

- `Contact.bloodGroup` and `EmergencyInfo.bloodGroup` are still `String?`.
- DB schema, backup/restore, P2P sync bundle, device-contact sync and the native
  lock-screen card are all untouched.
- No migration of data already in the database. Existing odd values are shown as
  they are and get tidied only when the user next saves that record — nothing is
  rewritten behind their back.

## Checks run

- `flutter analyze lib test` — no issues.
- `flutter test test/blood_group_test.dart` — 5 passed.
- `flutter test test/emergency_info_test.dart` — 13 passed.
- Not run: on-device check of the two screens.
