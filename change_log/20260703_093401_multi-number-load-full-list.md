# Load full numbers before the call chooser (fix: combined sheet never showed)

Implements [plans/20260703_092741_multi-number-load-full-list.md](../plans/20260703_092741_multi-number-load-full-list.md).
Follow-up to [change_log/20260703_092352_multi-number-call-picker.md](20260703_092352_multi-number-call-picker.md).

## Problem

The multi-number call chooser never appeared from the contact list — tapping Call
on a two-number contact showed only the old SIM-only sheet. The list is populated
with **slim summaries**: `_summarySelect`
([contact_repository.dart:556-561](../lib/repositories/contact_repository.dart#L556))
selects only the primary number per contact, so `_quickCall` always saw
`phoneNumbers.length == 1` and skipped the combined chooser. The summary also
carries no label, so the JIO/BSNL labels weren't available either.

## What changed

- **`lib/repositories/contact_repository.dart`** — added public
  `getPhoneNumbers(int contactId)` wrapping the existing private
  `_getPhoneNumbers`, to load a contact's full numbers (labels + `is_primary`) on
  demand.

- **`lib/services/contact_sync_service.dart`** — added `phoneNumbersFor(int)`
  delegating to `_repo.getPhoneNumbers`, plus the `phone_number.dart` import.

- **`lib/screens/contact_list_screen.dart`** — `_quickCall` now loads the full
  numbers via `_sync.phoneNumbersFor(contact.id!)` when Call is tapped, and passes
  that list to `startCall` (single-tap default = the `isPrimary` number, else
  first). Falls back to the summary's own single number when `id == null`
  (device-only rows) or the load throws/returns empty. Added the
  `phone_number.dart` import.

- **`lib/models/contact.dart`** — removed the `primaryPhone` getter added in the
  previous change; it's now unused (the primary is computed from the freshly
  loaded list inside `_quickCall`).

## Effect

A two-number contact now gets the combined chooser (with JIO/BSNL labels) on
Call, with the SIM section folding in when the SIM prompt is on. Single-number
contacts still dial with no number sheet. The list query stays slim — the full
numbers load only on the Call tap, not per row.

## Verification

- `flutter analyze` on all six touched files: **No issues found**.
- `flutter test test/call_feature_test.dart`: **all passed**.
- Manual on-device check of the tap-through still recommended.
