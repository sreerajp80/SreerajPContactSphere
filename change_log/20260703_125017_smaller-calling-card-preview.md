# Change log: Smaller calling-card preview

Implements plan `plans/20260703_125017_smaller-calling-card-preview.md`.

## What changed

The calling-card preview (a representation of the full-screen in-call backdrop) was
shrunk from full column width to a small, phone-shaped thumbnail in the two editing/
viewing surfaces. The in-call screen is unchanged and still renders the card full-screen.

### `lib/screens/add_edit_contact_screen.dart` — `_cardPhotoSection()`
- Wrapped the existing `AspectRatio(9/16)` picker in a `SizedBox(width: 150)`, so it now
  shows as a ~150×267 left-aligned thumbnail instead of a full-width, phone-height card.
- Behaviour unchanged: tap opens `_pickCardPhoto`, "×" clears the image, placeholder
  text/caption retained.

### `lib/screens/contact_detail_screen.dart` — `_buildCallingCard()`
- Replaced the full-width `Image.file(width: double.infinity)` with a
  `SizedBox(width: 150)` + `AspectRatio(9/16)` + `BoxFit.cover` thumbnail, matching the
  add/edit preview.
- "Calling card" label and tap-to-open zoomable full-screen viewer
  (`_openImageFullScreen`) retained — the full-size image is still viewable on tap.

### Unchanged
- `lib/screens/in_call_screen.dart` — still full-bleed / phone size.
- No database, model, or stored-image changes.

## Verification
- `flutter analyze lib/screens/add_edit_contact_screen.dart lib/screens/contact_detail_screen.dart`
  → "No issues found!"
