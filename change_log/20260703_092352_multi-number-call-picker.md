# Multi-number call picker (single combined sheet)

Implements [plans/20260703_091833_multi-number-call-picker.md](../plans/20260703_091833_multi-number-call-picker.md).

## Problem

Tapping **Call** on a contact-list row always dialed `phoneNumbers.first`, so a
contact with two numbers (e.g. [name]: JIO / BSNL) could never be called on the
second number from the list. A naive number chooser would stack on top of the
existing SIM chooser — two sheets in a row, which the user wanted to avoid.

## What changed

- **`lib/widgets/call_options_sheet.dart` (new)** — `showCallOptionsSheet(...)`, a
  single bottom sheet returning a `CallChoice { PhoneNumber number; SimAccount? sim }`
  (or null if dismissed). Always renders a selectable number section (primary
  pre-selected, showing the JIO/BSNL label); renders a SIM section **only** when
  more than one SIM is passed. One **Call** button confirms both choices. Styled
  to match `sim_picker_sheet.dart`.

- **`lib/widgets/call_lifecycle_mixin.dart`** — `startCall` gained an optional
  `List<PhoneNumber>? numbers`. When 2+ numbers are supplied, the new
  `_resolveNumberAndSim(...)` shows the combined sheet (folding in SIM selection
  when the per-call SIM chooser is on and there are 2+ SIMs) — so at most **one**
  sheet appears. Otherwise the existing `_resolveSim()` path runs unchanged and
  dials the single `number`. `CallService.placeCall` is untouched (still gets one
  resolved number + SIM).

- **`lib/screens/contact_list_screen.dart`** — `_quickCall` now uses
  `contact.primaryPhone` as the single-tap default and passes
  `numbers: contact.phoneNumbers` so multi-number contacts get the chooser.

- **`lib/models/contact.dart`** — added `PhoneNumber? get primaryPhone` (the
  `isPrimary` number, else first, else null).

## Behaviour matrix

| Numbers | SIM ask on & 2+ SIMs | Result |
|---|---|---|
| 1  | no  | Dials immediately — no sheet |
| 1  | yes | Existing SIM sheet only (unchanged) |
| 2+ | no  | One number-only sheet |
| 2+ | yes | One combined number + SIM sheet |

## Not changed

- `dialer_screen.dart`, `call_history_screen.dart`, `contact_detail_screen.dart`
  — they call `startCall` with a specific number and no `numbers` list, so their
  behaviour is unchanged. The detail screen's per-number call buttons remain the
  "call that exact number" path.
- Long-press on the list row is still Delete.
- `call_service.dart`, SIM placement, reconciliation — untouched.

## Verification

- `flutter analyze` on the four changed/added files: **No issues found**.
- `flutter test test/call_feature_test.dart`: **all passed** (signature change is
  backward-compatible — `numbers` is optional; no test references the mixin).
- Manual on-device check still recommended for the sheet interaction (single vs.
  combined sheet, dismiss-aborts-call), since the flow needs a real dialer/SIMs.
