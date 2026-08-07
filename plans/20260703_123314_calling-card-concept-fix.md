# Fix the "calling card" concept: it's the in-call full-screen backdrop, not a business card

**Status:** completed

## Issue

The **calling card** feature was built on a wrong concept. It was framed as *"a photo of
the person's business/visiting card"* — a landscape business-card image. The user clarifies
the real intent: a **calling card is a full portrait photo of the person that is displayed
as the full-screen background of the in-call screen** (a full-bleed caller-ID backdrop, like
Google Dialer / the user's reference screenshot titled *"ചിത്രവും കോളിംഗ് കാർഡും"* =
"Photo and Calling Card").

The **runtime mechanics are already correct** — `in_call_screen.dart` already paints
`cardPhotoPath` (falling back to `photoPath`) as a full-bleed `Image.file` background with a
scrim. What is wrong is only the **presentation/framing** in the Add/Edit UI and the
**wording** in code comments/docs, which still describe a business card:

- Add/Edit thumbnail is **landscape** (`aspectRatio: 1.6`, "roughly a business-card ratio"),
  but the backdrop is a **portrait** phone-screen image.
- Placeholder icon is `Icons.badge_outlined` (a business-card badge).
- Placeholder subtitle reads *"Photo of a business/visiting card"*.
- Doc comments in the model, DB, and Add/Edit screen say "business/visiting card".

No schema, storage, sync, or in-call-rendering behavior changes — this is a concept/UI/wording
realignment only.

### User-confirmed scope
- Thumbnail shape → **Portrait** (phone ratio), matching the in-call backdrop.
- Picker sources → **keep Gallery + Camera** (unchanged).
- Cleanup depth → **UI text + icon + ratio AND code comments/docs**.

## Files to change

1. **`lib/screens/add_edit_contact_screen.dart`** (`_cardPhotoSection`, ~L1253–1318, plus
   comments at L478, L922, L1253)
   - **L1262** `aspectRatio: 1.6` → a **portrait** ratio matching a phone screen,
     `aspectRatio: 9 / 16` (~0.56); update the trailing comment
     `// roughly a business-card ratio` → `// portrait — mirrors the full-screen in-call backdrop`.
   - **L1297** icon `Icons.badge_outlined` → `Icons.wallpaper_outlined` (conveys a full-screen
     backdrop image).
   - **L1309** subtitle `'Photo of a business/visiting card'` →
     `'Photo shown full-screen during calls'`.
   - **L478** doc comment `/// Picks the "calling card" image. A business card is usually
     photographed, so ...` → reword to explain it's the in-call backdrop photo, still offering
     Camera + Gallery (behavior unchanged).
   - **L922** comment `// The calling card (a business/visiting card) is irrelevant ...` →
     `// The calling card (the in-call full-screen backdrop) is irrelevant ...`.
   - **L1253** doc comment `... deliberately rectangular (a business card), not the circular
     avatar.` → `... deliberately a portrait rectangle (the in-call backdrop), not the circular
     avatar.`

2. **`lib/models/contact.dart`** (L20–22 doc comment)
   - Reword the `cardPhotoPath` doc from "business/visiting card, independent of [photoPath]"
     to describe it as the **full-screen portrait shown as the in-call background**, still noting
     it is app-only.

3. **`lib/database/database_helper.dart`** (L322 migration comment)
   - `// v9 -> v10: per-contact "calling card" image (business/visiting card photo).` →
     `// v9 -> v10: per-contact "calling card" image (full-screen in-call backdrop photo).`

4. **`lib/screens/contact_detail_screen.dart`** (`_buildCallingCard`, ~L359–390)
   - The label "Calling card" and natural-aspect rendering are fine; **no functional change**.
     (Optional, will do for consistency: the `///` doc line stays accurate — no "business card"
     wording present here, so left as-is.)

5. **Historical docs** — `plans/20260701_133051_calling-card-photo.md` and
   `change_log/20260701_135940_calling-card-photo.md`
   - These are historical records of what was built then. Rather than rewrite their bodies
     (which would falsify history), **prepend a short "Correction (2026-07-03)" note** at the
     top of each pointing to this plan and stating the corrected concept (calling card =
     in-call full-screen backdrop). This satisfies "fix the docs" without erasing history.

## Out of scope (explicitly unchanged)
- The in-call backdrop rendering in `in_call_screen.dart` (already correct).
- DB schema / column name `card_photo_path`, storage dir `card_photos/`, model field name
  `cardPhotoPath` (renaming would force another migration for no user benefit).
- Device sync (still app-only), the picker's Camera+Gallery behavior, the contact-list summary.
- `contact_detail_screen.dart` rendering behavior.

## Testing
- `flutter analyze` → stays clean (only string/comment/const-icon/ratio edits).
- Manual: open Add/Edit — the calling-card slot is now a **portrait** thumbnail with a
  wallpaper icon and "Photo shown full-screen during calls"; add one (camera + gallery both
  still work), save, reopen — persists. In-call screen still shows it full-bleed (unchanged).
