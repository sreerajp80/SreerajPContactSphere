# Plan: Make tag suggestion chips larger (second pass)

**Status:** completed

## Issue

The tag suggestion chips (dashed `+ tag`) on the Add/Edit contact screen are
still too small to tap comfortably, even after the previous bump to fontSize 14
/ padding h16 v11.

## Files to change

1. `lib/screens/add_edit_contact_screen.dart`
   - At the tag-suggestion `_DashedChip` (around line 1786), further increase the
     `padding` and the suggestion text `fontSize`.

## Fix details

- Text `fontSize: 16` (up from 14).
- `padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14)`
  (up from h16 / v11) — this raises the chip height and the tap target.
- Keep `Wrap` spacing at 8.
- Do **not** change the shared `_DashedChip` default padding, so other uses of
  the chip are unaffected.

## Note on the device build

Per prior notes in this project, `flutter run` can fail at the APK/install step
and leave the **old build** on the device, which would make earlier size changes
look like they had no effect. After this change, confirm the new build actually
installs before judging the size on-device.

## Testing

- `flutter analyze` on the changed file.
- Manual: suggestion chips are clearly larger and easy to tap.
