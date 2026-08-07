# Move number choice to long-press; simple tap dials the default number

Implements [plans/20260703_093659_call-longpress-number-picker.md](../plans/20260703_093659_call-longpress-number-picker.md).
Supersedes the combined-sheet UX from
[change_log/20260703_092352_multi-number-call-picker.md](20260703_092352_multi-number-call-picker.md)
and [change_log/20260703_093401_multi-number-load-full-list.md](20260703_093401_multi-number-load-full-list.md).

## Why

The combined number+SIM sheet on a plain tap was too heavy. New model: a simple
tap dials the default number (with the normal SIM sheet only if enabled), and a
long-press on Call lets the user pick a number, then the normal compact SIM sheet.

## What changed

- **`lib/widgets/number_picker_sheet.dart` (new)** — `showNumberPickerSheet(...)`,
  a compact tap-to-select bottom sheet returning the chosen `PhoneNumber` (or null
  if dismissed). Shows number + JIO/BSNL label; styled like `sim_picker_sheet.dart`.

- **`lib/widgets/call_options_sheet.dart` (deleted)** — the combined sheet is no
  longer used.

- **`lib/widgets/call_lifecycle_mixin.dart`** — reverted `startCall` to its
  original shape: removed the `numbers` param, the `_resolveNumberAndSim` helper,
  and the `call_options_sheet` / `phone_number` imports. It resolves only the SIM
  (`_resolveSim`) and dials the `number` the caller supplies.

- **`lib/screens/contact_list_screen.dart`**:
  - `_quickCall` (simple tap) → dials `contact.phoneNumbers.first.number` (the
    summary's primary), no extra query.
  - New `_pickNumberAndCall` (long-press) → loads full numbers via
    `_sync.phoneNumbersFor(id)`; 0 → message, 1 → dial it, 2+ → `showNumberPickerSheet`
    then `startCall(number: chosen)` (so the normal SIM step still runs). Falls
    back to the summary number when `id == null`.
  - `_QuickAction` gained an optional `onLongPress` (wired into its `InkWell`);
    the Call button passes `onLongPress: () => _pickNumberAndCall(contact)`.
  - Added the `number_picker_sheet.dart` import.

## Kept

- `ContactRepository.getPhoneNumbers(int)` and `ContactSyncService.phoneNumbersFor(int)`
  from the previous change — now used by the long-press path.

## Not changed

- Dialer, call-history, detail screens; `call_service.dart`; SIM placement.
- Whole-row long-press still opens Delete; only the Call button gained a long-press.

## Verification

- `flutter analyze` on the three changed files: **No issues found**.
- `flutter test test/call_feature_test.dart`: **all passed**.
- Grep confirms no remaining references to `call_options_sheet` / `CallChoice`.
- Manual on-device check of tap vs. long-press still recommended.
