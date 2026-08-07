# Change log — Calling card concept fix (in-call backdrop, not a business card)

Implements plan [`plans/20260703_123314_calling-card-concept-fix.md`](../plans/20260703_123314_calling-card-concept-fix.md).

## Summary

Realigned the "calling card" feature with its correct concept: a **full-screen portrait of
the person shown as the in-call backdrop**, not a photo of a business/visiting card. The
runtime mechanics were already correct (the in-call screen paints `cardPhotoPath` full-bleed);
this change fixes only the **Add/Edit presentation** and the **wording** in code comments and
docs. No schema, storage, sync, or in-call-rendering behavior changed.

Per the user's confirmed scope: portrait thumbnail, Camera + Gallery picker kept, and
comments/docs cleaned up too.

## Files changed

- **`lib/screens/add_edit_contact_screen.dart`** (`_cardPhotoSection` + related comments)
  - Thumbnail `aspectRatio` `1.6` (landscape) → `9 / 16` (portrait, mirroring the in-call
    backdrop); comment updated.
  - Placeholder icon `Icons.badge_outlined` → `Icons.wallpaper_outlined`.
  - Placeholder subtitle `'Photo of a business/visiting card'` →
    `'Photo shown full-screen during calls'`.
  - Doc/inline comments on `_pickCardPhoto`, the section insertion (`_isSelf` guard), and
    `_cardPhotoSection` reworded from "business/visiting card" to "in-call backdrop".

- **`lib/models/contact.dart`** — `cardPhotoPath` doc comment reworded from "photograph of
  their business/visiting card" to "full-screen portrait shown as the in-call backdrop"
  (still noting it is app-only).

- **`lib/database/database_helper.dart`** — v9→v10 migration comment reworded to
  "(full-screen in-call backdrop photo)".

- **`plans/20260701_133051_calling-card-photo.md`** and
  **`change_log/20260701_135940_calling-card-photo.md`** — prepended a dated "Correction"
  note pointing to this plan/change log, without rewriting their historical bodies.

## Deliberately unchanged

- In-call full-bleed rendering (`lib/screens/in_call_screen.dart`) — already correct.
- Internal identifiers `cardPhotoPath` / `card_photo_path` / the `card_photos/` storage dir
  (renaming would force a needless migration for no user-visible benefit).
- Device sync (still app-only), the Camera+Gallery picker behavior, the contact-list summary,
  and `contact_detail_screen.dart` rendering.

## Verification

- `flutter analyze` on the five touched files → **No issues found**.
- Manual (to confirm on device): the Add/Edit calling-card slot now shows a portrait thumbnail
  with a wallpaper icon and "Photo shown full-screen during calls"; picking (camera + gallery)
  and the in-call backdrop are unaffected.
