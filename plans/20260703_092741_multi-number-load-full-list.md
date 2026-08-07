# Load full numbers before the call chooser (fix: combined sheet never shows)

**Status:** completed

Follow-up to [20260703_091833_multi-number-call-picker.md](20260703_091833_multi-number-call-picker.md).

## The issue

The multi-number chooser never appears from the contact list — tapping Call on a
two-number contact ([name]) shows only the old SIM-only sheet.

Root cause: the list is populated with **slim summaries**. `_summarySelect`
([contact_repository.dart:556-561](../lib/repositories/contact_repository.dart#L556))
selects only the *primary* number per contact (a `LIMIT 1` subquery), and
`_summaryFromRow` ([:573](../lib/repositories/contact_repository.dart#L573)) builds
`phoneNumbers` with just that one entry (no label, no `isPrimary`). So in
`_quickCall`, `contact.phoneNumbers.length` is always 1, the `numbers.length > 1`
guard is false, and it falls through to the SIM-only path. The card showing a
single number has the same cause.

Loading the full list at call time is needed anyway: the combined sheet shows the
JIO/BSNL **labels**, which the summary doesn't carry.

## The fix

Load the contact's full phone numbers on demand when Call is tapped (one cheap
query per tap — not on every list row), then let `startCall` decide.

## Files to change

1. **`lib/repositories/contact_repository.dart`** — expose a public
   `Future<List<PhoneNumber>> getPhoneNumbers(int contactId)` that wraps the
   existing private `_getPhoneNumbers` ([:1077](../lib/repositories/contact_repository.dart#L1077)).

2. **`lib/services/contact_sync_service.dart`** — add a thin delegate
   `Future<List<PhoneNumber>> phoneNumbersFor(int contactId)` →
   `_repo.getPhoneNumbers(contactId)` (keeps the screen talking to the service,
   as it already does for reads).

3. **`lib/screens/contact_list_screen.dart`** — in `_quickCall`, when
   `contact.id != null`, load the full numbers via `_sync.phoneNumbersFor(id)`
   and pass that list (with the primary as the single-tap default). Fall back to
   the summary's single number when the load returns empty or `id` is null
   (device-only rows). Guard against the contact having no numbers as today.

## Not changing

- The slim `_summarySelect` stays slim — we do **not** load all numbers for every
  list row. The full load happens only on the Call tap.
- `call_options_sheet.dart` and the mixin's `startCall` logic from the previous
  plan are unchanged; they already do the right thing once given 2+ numbers.

## Verification

- `flutter analyze` on the three changed files.
- Manual: two-number contact → tapping Call now shows the combined number sheet
  (with JIO/BSNL labels), and the SIM section folds in when the SIM prompt is on;
  single-number contact still dials with no number sheet.
