# Blood group: pick from a list instead of typing

**Status:** completed

## The issue

Blood group is typed by hand in three places:

1. Contact editor — [lib/screens/add_edit_contact_screen.dart](../lib/screens/add_edit_contact_screen.dart)
   line ~1326, a plain text field with hint `e.g. O+`.
2. The **Me** (Self) record — same screen, same field.
3. Emergency info — [lib/screens/emergency_info_screen.dart](../lib/screens/emergency_info_screen.dart)
   line ~275, a plain text field with hint `e.g. B+`.

A blood group can only be one of eight known values. Free typing lets people enter
`O+ve`, `o positive`, `0+`, `O +`, `AB Positive` and so on. That causes real problems:

- The emergency lock-screen card may show a messy or wrong value when it matters most.
- The same person can look different across the contact record and the emergency card.
- Any future "find O- donors" search will miss records because the text does not match.
- A typo like `0+` (zero) or `B-` typed instead of `B+` is silent — nothing warns the user.

## The fix

Add one shared list of the eight standard groups and use a picker everywhere.

**Standard values (display form):** `A+`, `A-`, `B+`, `B-`, `AB+`, `AB-`, `O+`, `O-`

### 1. New file: `lib/core/constants/blood_groups.dart`

- `const List<String> kBloodGroups` — the eight values above, in the order shown.
- `String? normalizeBloodGroup(String? raw)` — cleans an existing/typed value into one
  of the eight, or returns `null` when it cannot be understood. It will:
  - trim, uppercase, drop spaces, dots and hyphens used as separators,
  - map `POSITIVE` / `POS` / `+VE` / `P` to `+`, and `NEGATIVE` / `NEG` / `-VE` / `N` to `-`,
  - map a leading `0` (zero) to the letter `O`,
  - accept `A`, `B`, `AB`, `O` with a sign; reject anything else.

### 2. Contact editor — `lib/screens/add_edit_contact_screen.dart`

- Replace the `_bloodGroup` `TextEditingController` with a `String _bloodGroup = ''`
  plus a `bool _bloodMenuOpen = false`, mirroring how gender works today.
- Replace the `_inputField(caption: 'Blood group', ...)` call with a new
  `_bloodGroupField()` built from the existing `_menuButton` + `_chipWrap` + `_chip`
  helpers, so it looks and behaves exactly like the gender picker.
- The chip list is the eight groups, plus a "Clear" chip to set it back to empty
  (blood group is optional). **No "Custom" chip** — the whole point is to close off
  free text.
- On load, run the stored value through `normalizeBloodGroup`. If an old record holds
  something unrecognised, keep it selected and show it as an extra chip marked as-is,
  so editing the contact never silently deletes existing data.
- On save, store the selected value (or `null` when empty) — no change to the model,
  the DB column, backup, or sync formats.

### 3. Emergency info — `lib/screens/emergency_info_screen.dart`

- Replace `_bloodCtrl` with a `String? _blood` value.
- Add a `_bloodGroupField()` that renders a `DropdownButtonFormField<String>` styled
  with the same `OutlineInputBorder` used by `_field`, with the label
  `EmergencyInfo.labelBloodGroup`, a "Not set" empty entry, and the eight values;
  keep the existing "Show on lock screen" `_showRow` under it.
- On load, normalise the stored value; keep an unrecognised old value as an extra
  dropdown entry rather than dropping it.
- `_save()` writes the selected value; the preview card keeps working unchanged.

### 4. One-time clean-up of existing data — **not** included

Existing typed values stay as they are in the DB. They get tidied only when the user
next opens and saves that record. No migration, so nothing can be lost.

## Files to change

- `lib/core/constants/blood_groups.dart` — **new**
- `lib/screens/add_edit_contact_screen.dart` — picker instead of text field
- `lib/screens/emergency_info_screen.dart` — dropdown instead of text field
- `test/blood_group_test.dart` — **new**, unit tests for `normalizeBloodGroup`
  (`o positive` → `O+`, `0-` → `O-`, `AB+ve` → `AB+`, `xyz` → `null`, `''` → `null`)

## Not changed

- `Contact.bloodGroup` / `EmergencyInfo.bloodGroup` stay `String?`.
- DB schema, backup/restore, P2P sync bundle, device-contact sync — all untouched.
- The lock-screen Kotlin card — it just displays the stored string.

## How to check it works

1. `flutter analyze` and `flutter test` pass.
2. Add a contact → Blood group shows a picker; picking `O-` saves and shows `O-`.
3. Edit the **Me** record → same picker.
4. Settings → Emergency info → Blood group is a dropdown; save, then check the
   lock-screen card shows the picked value.
5. Open an old contact that had `O+ve` typed → the value is still shown and can be
   changed to a standard one.
