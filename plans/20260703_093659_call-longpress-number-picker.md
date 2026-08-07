# Move number choice to long-press; simple tap dials the default number

**Status:** completed

Supersedes the combined-sheet UX from
[20260703_091833_multi-number-call-picker.md](20260703_091833_multi-number-call-picker.md).

## The change requested

The combined number+SIM sheet is too heavy for a plain tap. New model:

- **Simple tap on Call** → dial the **default (primary) number** straight away,
  going through the existing SIM resolution (the normal compact SIM sheet appears
  only when "ask which SIM" is on and there are 2+ SIMs). No number sheet.
- **Long-press on Call** → show the contact's **numbers** to choose from, then the
  normal compact SIM sheet. Two lightweight steps, but only on an explicit
  long-press where the user has opted into choosing.

## Files to change

1. **`lib/widgets/number_picker_sheet.dart`** — NEW. A compact
   `showNumberPickerSheet(context, {displayName, numbers}) → PhoneNumber?`:
   tap-to-select rows (number + JIO/BSNL label), returns the chosen number or
   null if dismissed. Same card style as `sim_picker_sheet.dart`.

2. **`lib/widgets/call_options_sheet.dart`** — DELETE (the combined sheet is no
   longer used).

3. **`lib/widgets/call_lifecycle_mixin.dart`** — revert `startCall` to its
   original shape: drop the `numbers` param and `_resolveNumberAndSim`, and the
   `call_options_sheet` / `phone_number` imports. It resolves only the SIM again
   (`_resolveSim`) and dials the single `number` passed in.

4. **`lib/screens/contact_list_screen.dart`**:
   - `_quickCall` (simple tap) → dial `contact.phoneNumbers.first.number` (the
     summary already loads the primary as the only/first number). No full load.
   - New `_pickNumberAndCall` (long-press) → load full numbers via
     `_sync.phoneNumbersFor(id)`; if 0 → message; if 1 → dial it; if 2+ → show
     `showNumberPickerSheet`, then `startCall(number: chosen)` so the normal SIM
     step still runs. Falls back to the summary number when `id == null`.
   - `_QuickAction` gains an optional `onLongPress`; wire the Call button's
     `onLongPress: () => _pickNumberAndCall(contact)`.

## Kept from the previous fix

- `ContactRepository.getPhoneNumbers(int)` and
  `ContactSyncService.phoneNumbersFor(int)` stay — now used by the long-press path.

## Not changing

- Dialer, call-history, detail screens; `call_service.dart`; SIM placement.
- Row long-press (whole-card) still opens Delete; only the **Call button** gains
  a long-press.

## Verification

- `flutter analyze` on the changed files.
- `flutter test test/call_feature_test.dart`.
- Manual: simple tap dials the primary with no number sheet (SIM sheet only if
  enabled); long-press shows the number sheet, then the SIM sheet.
