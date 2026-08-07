# Change log — Calling card photo

Implements plan [`plans/20260701_133051_calling-card-photo.md`](../plans/20260701_133051_calling-card-photo.md).

> **Correction (2026-07-03):** the "business/visiting card" framing described below is wrong.
> A "calling card" is a **full-screen portrait shown as the in-call backdrop**. The mechanics
> shipped here are correct; the concept/wording was later realigned — see
> [`change_log/20260703_123314_calling-card-concept-fix.md`](20260703_123314_calling-card-concept-fix.md).

## Summary

Contacts can now carry a second image — a **calling card** (a photo of the person's
business/visiting card) — independent of the profile photo. It can be set/removed on the
Add/Edit screen, is shown on the contact detail screen (tap to view full-screen), and — when
ContactSphere is the default dialer — fills the **in-call screen** as a Google Dialer-style
full-bleed caller backdrop. The calling card is **app-only**: it is stored only in the app's
SQLite DB and never synced to the device address book (which has no field for a second image).

## Files changed

- **`lib/models/contact.dart`** — new `String? cardPhotoPath` field, added to the constructor,
  `toMap()` (`card_photo_path`), and `fromMap()`.

- **`lib/database/database_helper.dart`** — schema `version` bumped **9 → 10**; `contacts` table
  gains `card_photo_path TEXT` in `_onCreate`; added a `v9 → v10` additive migration
  (`ALTER TABLE contacts ADD COLUMN card_photo_path TEXT`).

- **`lib/screens/add_edit_contact_screen.dart`**
  - New `_cardPhotoPath` state; initialized from `widget.contact?.cardPhotoPath`; assigned to
    `contact.cardPhotoPath` on save.
  - `_pickCardPhoto()` — a Camera/Gallery bottom-sheet chooser (business cards are usually
    photographed) using the existing `image_picker`.
  - `_persistCardPhoto()` — copies the picked image into `<appDocuments>/card_photos/` (so
    camera captures survive cache eviction), mirroring `DeviceContactService`'s photo handling;
    falls back to the original path on failure. Added `path_provider` import.
  - `_clearCardPhoto()` and a new `_cardPhotoSection()` — a card-shaped (business-card ratio)
    tappable thumbnail with a remove button / "Add calling card" placeholder, inserted after
    the Ringtone section.

- **`lib/screens/contact_detail_screen.dart`** — `_buildCallingCard()` renders the calling card
  (when set and the file exists) under a "Calling card" label after the name block;
  `_openImageFullScreen()` opens a zoomable (`InteractiveViewer`) full-screen viewer on tap.

- **`lib/screens/in_call_screen.dart`** — the existing caller lookup (`_resolveName`) now also
  loads the full `Contact` via `getContactById(match.contactId)` and resolves a backdrop image
  (`cardPhotoPath ?? photoPath`, existence-checked) into new `_resolvedImagePath` state. `build`
  now uses a `Stack`: full-bleed `Image.file` + a dark top/bottom scrim gradient for legibility,
  with the call UI on top; the caller-initial avatar is hidden when a backdrop image is shown.
  With no image it keeps the original brand-gradient background. Added `dart:io` import.

## Design decisions

- **App-only** (no `DeviceContactService` / `ContactSyncService` changes): the Android address
  book has no field for a second image, so the calling card lives only in SQLite — same
  treatment as tags, blood group, and the per-contact ringtone.
- **In-call backdrop priority:** calling card → profile photo → brand gradient.
- The contact-list slim summary query was intentionally left unchanged (the list card only
  needs the avatar).

## Verification

- `flutter analyze` → **No issues found**.
- Manual device testing (photo persistence across save/reopen, camera vs gallery, the v9→v10
  migration on an existing DB, and the in-call backdrop) to be performed on a connected device /
  default-dialer setup.
