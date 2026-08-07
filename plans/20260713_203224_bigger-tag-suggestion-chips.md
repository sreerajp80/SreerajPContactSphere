# Plan: Make tag suggestion chips bigger / easier to tap

**Status:** completed

## Issue

On the Add/Edit contact screen, the tag suggestion chips (`_DashedChip`) shown
while typing a tag are small, so the tap target is hard to hit (see user
screenshot).

## Files to change

1. `lib/screens/add_edit_contact_screen.dart`
   - At the tag-suggestion `_DashedChip` (around line 1786), pass a larger
     `padding` and increase the suggestion text `fontSize`, so the chip and its
     tap target are bigger.

## Fix details

- Change only the tag-suggestion chip:
  - `padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11)`
    (up from the shared default of h12/v7).
  - Text `fontSize: 14` (up from 12).
- Do **not** change the shared `_DashedChip` default padding, so other uses of
  the chip (group suggestions, etc.) are unaffected.
- Bump the `Wrap` `spacing`/`runSpacing` from 7 to 8 for a touch more breathing
  room between the now-larger chips.

## Testing

- `flutter analyze` on the changed file.
- Manual: tag suggestions are visibly larger and easier to tap; other dashed
  chips unchanged.
