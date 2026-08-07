# Change log: Bigger tag suggestion chips

Implements plan `plans/20260713_203224_bigger-tag-suggestion-chips.md`.

## What changed

The tag suggestion chips on the Add/Edit contact screen were too small to tap
comfortably. They are now larger.

## Files changed

1. `lib/screens/add_edit_contact_screen.dart` (tag-suggestion `_DashedChip`)
   - Passed a larger `padding` (`horizontal: 16, vertical: 11`, up from the
     shared default `horizontal: 12, vertical: 7`).
   - Increased suggestion text `fontSize` from 12 to 14.
   - Bumped the `Wrap` `spacing`/`runSpacing` from 7 to 8.
   - The shared `_DashedChip` default padding was left unchanged, so other uses
     (group suggestions, etc.) are unaffected.

## Verification

- `flutter analyze` on the changed file: **No issues found.**
