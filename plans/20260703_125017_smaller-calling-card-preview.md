# Smaller calling-card preview in Add/Edit and Contact profile

**Status:** completed

## Issue

The calling card is a full-screen (phone-sized) in-call backdrop photo. But in the
**Add/Edit contact** screen and the **Contact profile** screen it is currently rendered
at full column width:

- `add_edit_contact_screen.dart` — `_cardPhotoSection()` wraps the picker in an
  `AspectRatio(9/16)` at full width, producing a tall, phone-height rectangle that
  dominates the form.
- `contact_detail_screen.dart` — `_buildCallingCard()` shows the image with
  `width: double.infinity`, so it also spans the full width.

These two spots are only meant to be a *representation* of the calling card, not a
life-size preview. The user wants them shrunk to a smaller, proportionate (phone-shaped)
thumbnail. The **in-call screen must stay full phone size** (no change there).

## Files to change

1. `lib/screens/add_edit_contact_screen.dart` — `_cardPhotoSection()`
2. `lib/screens/contact_detail_screen.dart` — `_buildCallingCard()`

(`lib/screens/in_call_screen.dart` — **unchanged**; it stays full-bleed / phone size.)

## Plan for the fix

Keep the 9/16 portrait aspect ratio (so it still reads as a phone screen) but constrain
the width so the preview is a small card rather than full width.

### 1. Add/Edit screen — `_cardPhotoSection()`
- Wrap the existing `AspectRatio(9/16)` card in a `SizedBox(width: ~150)` (a small
  phone-shaped thumbnail ≈ 150 × 267), left-aligned within the section.
- Keep the placeholder text and remove ("×") button. Because the card is now narrow,
  slightly reduce the placeholder icon/text so it still fits comfortably; the
  "Photo shown full-screen during calls" caption stays.
- No behavioural change — tap still opens `_pickCardPhoto`, "×" still clears.

### 2. Contact profile — `_buildCallingCard()`
- Replace the full-width `Image.file(width: double.infinity)` with a fixed-size
  portrait thumbnail: a `SizedBox(width: ~150)` + `AspectRatio(9/16)` + `BoxFit.cover`,
  matching the add/edit preview so both screens look consistent.
- Keep the "Calling card" label and the tap-to-open zoomable full-screen viewer
  (`_openImageFullScreen`), which still shows the image at full size.

### Notes
- Exact width (~150 dp) chosen so the thumbnail is clearly a small representation while
  keeping the phone-screen proportions; can be tuned after a visual check.
- No database, model, or in-call changes. The stored image and its full-screen in-call
  rendering are untouched.

## Verification
- `flutter analyze` clean for the two edited files.
- Visual: Add/Edit screen shows a small phone-shaped calling-card picker; Contact
  profile shows a matching small thumbnail; tapping it still opens the full-screen viewer;
  the in-call screen still shows the card full-screen.
