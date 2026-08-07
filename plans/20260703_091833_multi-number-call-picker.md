# Multi-number call picker (single combined sheet)

**Status:** completed

## The issue

A contact can have multiple phone numbers (e.g. [name] has a JIO number and a BSNL
number), but tapping **Call** on the contact list always dials
`contact.phoneNumbers.first.number` — [contact_list_screen.dart:329](../lib/screens/contact_list_screen.dart#L329).
There is no way to choose the other number from the list.

Naively adding a "which number?" sheet would stack **two** bottom sheets when the
SIM chooser is also on (number sheet → SIM sheet → dial), which the user
explicitly wants to avoid: "Too many selection windows will disturb the user."

## Design goal

At most **one** sheet per call, shown **only when there is a real choice**:

| Numbers | SIM ask on & 2+ SIMs | Result |
|---|---|---|
| 1 | no  | Dials immediately — no sheet |
| 1 | yes | Existing SIM sheet only (unchanged) |
| 2+ | no  | Number-only sheet |
| 2+ | yes | **One combined sheet**: number section + SIM section + one Call button |

Single-number contacts and users without the SIM prompt see **zero** new friction.

## Decisions taken (adjustable)

- **Combined sheet layout:** one sheet with a "number" section (selectable rows
  showing number + label like JIO/BSNL, default = primary) and, only when the SIM
  choice is also ambiguous, a "SIM" section, plus a single **Call** button at the
  bottom. Mirrors the visual style of the existing `sim_picker_sheet.dart`.
- **Long-press Call:** left **unchanged** (still Delete, [contact_list_screen.dart:709/872](../lib/screens/contact_list_screen.dart#L709)).
  The per-number call buttons already on the detail screen
  ([contact_detail_screen.dart:300](../lib/screens/contact_detail_screen.dart#L300))
  remain the "call that specific number" path.
- **Primary default:** single-tap Call uses the contact's `isPrimary` number
  (falling back to `.first`), so the everyday one-number case never prompts.

## Files to change

1. **`lib/widgets/call_options_sheet.dart`** — NEW. A single bottom sheet
   `showCallOptionsSheet(context, {required List<PhoneNumber> numbers, List<SimAccount> sims})`
   returning a small result `CallChoice { PhoneNumber number; SimAccount? sim }`,
   or `null` if dismissed (→ abort the call). Renders the number section always
   and the SIM section only when `sims.length > 1`. Styled like
   [sim_picker_sheet.dart](../lib/widgets/sim_picker_sheet.dart).

2. **`lib/widgets/call_lifecycle_mixin.dart`** — `startCall` gains an optional
   `List<PhoneNumber>? numbers`. New resolution order:
   - If `numbers != null && numbers.length > 1`: show `showCallOptionsSheet`
     (folds in SIM selection when `askSimBeforeCall && sims.length > 1`), giving
     **one** sheet. Dismissal → abort.
   - Else: keep the existing `_resolveSim()` path (SIM sheet or default SIM),
     dialing the single `number` passed in.
   Keeps the `_aborted` sentinel semantics. `placeCall` still receives a single
   resolved `number` + `sim`, so [call_service.dart](../lib/services/call_service.dart)
   is unchanged.

3. **`lib/screens/contact_list_screen.dart`** — `_quickCall` passes
   `numbers: contact.phoneNumbers` and a `number:` default of the primary number
   (`firstWhere(isPrimary, orElse: first)`). Empty-list guard stays.

4. **`lib/models/contact.dart`** *(if a `Contact` model holds `phoneNumbers`)* —
   optional convenience getter `PhoneNumber? get primaryPhone` to avoid repeating
   the firstWhere/orElse. Will confirm the file and add only if it reads cleanly;
   otherwise inline the resolution in `_quickCall`.

## Not changing

- `dialer_screen.dart`, `call_history_screen.dart`, `contact_detail_screen.dart`
  call `startCall` with a specific number and pass no `numbers` list — behaviour
  unchanged.
- `call_service.dart` / SIM placement / reconciliation — untouched.

## Verification

- `flutter analyze` clean for the changed files.
- `test/call_feature_test.dart` — check whether the `startCall` signature change
  needs a test update (the new param is optional, so existing calls should still
  compile); adjust if it references the mixin directly.
- Manual: single-number contact dials with no sheet; two-number contact with SIM
  prompt off shows one number sheet; with SIM prompt on shows one combined sheet;
  dismissing the sheet aborts the call.
