# Change log: Larger tag suggestion chips (second pass)

Implements plan `plans/20260714_084317_larger-tag-suggestion-chips-again.md`.

## What changed

The tag suggestion chips on the Add/Edit contact screen were made larger again
so they are easier to tap.

## Files changed

1. `lib/screens/add_edit_contact_screen.dart` (tag-suggestion `_DashedChip`)
   - Suggestion text `fontSize` 14 -> 16.
   - Chip `padding` `horizontal: 16, vertical: 11` -> `horizontal: 18, vertical: 14`.
   - `Wrap` spacing left at 8; shared `_DashedChip` default unchanged.

## Verification

- `flutter analyze` on the changed file: **No issues found.**

## Note

Per prior project notes, `flutter run` can fail at the install step and leave the
old build on the device. Confirm the new build installs before judging the size
on-device.
