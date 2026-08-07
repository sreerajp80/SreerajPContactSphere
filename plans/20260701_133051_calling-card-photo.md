# Add a second "calling card" photo to contacts

**Status:** completed

> **Correction (2026-07-03):** the *concept* below is wrong. A "calling card" is **not** a
> photo of a business/visiting card — it is a **full-screen portrait of the person shown as
> the in-call backdrop**. The storage/DB/in-call mechanics built here are correct and retained;
> only the framing/wording was fixed. See
> [`plans/20260703_123314_calling-card-concept-fix.md`](20260703_123314_calling-card-concept-fix.md).

## Issue / feature request

Today a contact has exactly one image — the **profile photo** (`Contact.photoPath`,
`contacts.photo_path`), picked from the gallery on the Add/Edit screen and shown as the
avatar in the list, detail, and edit screens.

The user wants a contact to also carry a **calling card photo** (a photograph of the
person's business/visiting card) — a *second, independent* image alongside the profile
photo. This does not exist anywhere in the model, DB, or UI yet.

## Design decisions

- **Separate field, same storage strategy.** Mirror `photoPath`: store a file-path string
  in a new column, not a blob. New field `Contact.cardPhotoPath` → column
  `contacts.card_photo_path TEXT`.
- **App-only field (not synced to the device).** The app keeps contacts in two synced
  stores: its own SQLite DB (the full-featured one) and the phone's native address book
  (via `flutter_contacts`, two-way synced). The Android address book has a **fixed set of
  fields** — name, phones, emails, addresses, organization, events, and exactly **one**
  photo (the profile picture); there is **no field for a second "business card" image**.
  So — like `tags`, `gender`, `bloodGroup`, the per-contact ringtone, and the secret flag —
  the calling card can only live in the app's SQLite DB. Consequence: it shows inside
  ContactSphere but will **not** appear in the stock Contacts app or ride Google Contacts
  sync. This means **no changes** to `DeviceContactService` / `ContactSyncService`.
  (Forcing it onto a device contact — stuffing the image into Notes, or as a second
  raw-contact photo — is a fragile hack and is explicitly rejected.)
- **Camera + gallery source.** A business card is usually photographed, so the calling-card
  picker offers a small Camera/Gallery chooser (bottom sheet), unlike the profile picker
  (gallery only). Uses the already-present `image_picker`.
- **Persist the picked file into app storage.** `image_picker` camera captures land in a
  cache dir that Android can evict. To keep the calling card from vanishing, copy the picked
  file into `<appDocuments>/card_photos/<timestamp>.jpg` (same pattern
  `DeviceContactService._persistPhoto` already uses for `device_photos/`) and store that
  stable path. Uses the already-present `path_provider` + `path`.
  - *Note:* the existing profile photo's fragile cache path behavior is left unchanged —
    out of scope for this request.
- **List summary unchanged.** The contact-list card only shows the avatar, so
  `card_photo_path` is intentionally left out of the slim `_summarySelect` projection. Full
  detail/edit loads (`getContactById`, which reads the full row) pick it up automatically
  via `Contact.fromMap`.
- **Full-screen calling card during a call (Google Dialer style).** When a call is on the
  in-call screen, if the resolved contact has a calling card, render it **full-bleed** as
  the screen background (with a dark scrim/gradient overlay so the name, status, and call
  controls stay legible), instead of the current brand-gradient background. Today
  `in_call_screen.dart` only resolves the caller's *name* (`findByPhoneFragment`); it will
  be extended to also resolve the full `Contact` (name-match → `contactId` →
  `getContactById`) and read `cardPhotoPath`. When there's no calling card, the screen
  keeps its **existing gradient** background (unchanged behavior).
  - *Fallback (optional, will implement):* if no calling card but a profile photo exists,
    fall back to the profile photo full-bleed rather than the plain gradient — closer to
    Google Dialer. Calling card takes priority when both are present.

## Files to change

1. **`lib/models/contact.dart`**
   - Add field `String? cardPhotoPath;`.
   - Add `this.cardPhotoPath` to the constructor.
   - Add `'card_photo_path': cardPhotoPath` to `toMap()`.
   - Add `cardPhotoPath: map['card_photo_path']` to `fromMap()`.

2. **`lib/database/database_helper.dart`**
   - Bump `version: 9` → `version: 10`.
   - Add `card_photo_path TEXT` to the `contacts` table in `_onCreate`.
   - Add a `if (oldVersion < 10)` branch in `_onUpgrade`:
     `ALTER TABLE contacts ADD COLUMN card_photo_path TEXT`.

3. **`lib/screens/add_edit_contact_screen.dart`**
   - Add `_cardPhotoPath` state; initialize from `widget.contact?.cardPhotoPath` where the
     other fields are initialized.
   - Add `_pickCardPhoto()` — show a Camera/Gallery chooser, call `_picker.pickImage`,
     then copy the result into `<appDocuments>/card_photos/` and store the copied path.
     Add a `_clearCardPhoto()` to remove it.
   - Add a new "Calling card" section widget (a tappable rectangular card thumbnail —
     card-shaped, not the circular avatar — showing the image or an "Add calling card"
     placeholder, with a remove affordance when set). Insert it in the form's `Column`
     (e.g. just after the avatar header / name section).
   - On save, assign `contact.cardPhotoPath = _cardPhotoPath;` alongside the existing
     `contact.photoPath` assignment.

4. **`lib/screens/contact_detail_screen.dart`**
   - When `contact.cardPhotoPath` is set and the file exists, render a "Calling card"
     section showing the image (tappable to open a full-screen viewer). Placed among the
     detail sections (after the header/name block).

5. **`lib/screens/in_call_screen.dart`**
   - Extend the existing async caller resolution (`_resolveName`) to also load the full
     `Contact`: after `findByPhoneFragment` yields a match, take its `contactId` and call
     `ContactRepository.getContactById` to obtain `cardPhotoPath` (and `photoPath` for the
     fallback). Store the resolved image path in state and rebuild. Keep it best-effort
     (wrapped in try/catch, `mounted` guarded) exactly like the current name resolution.
   - In `build`, when a full-bleed image path is available and the file exists, replace the
     gradient `Container` background with a `Stack`: the `Image.file(...)` (`BoxFit.cover`,
     full screen) at the bottom, a dark scrim/gradient overlay above it for legibility, then
     the existing `SafeArea`/`Column` UI on top. With no image, keep the current gradient
     `Container` unchanged. Priority: calling card → profile photo → gradient.

## Out of scope (explicitly not changing)

- Device sync services (calling card is app-only).
- The contact-list slim summary query / list card rendering.
- Existing profile-photo behavior and its storage path.
- OCR / parsing of the card, QR, sharing — none of that; this is just an image.

## Testing

- `flutter analyze` stays clean.
- Manual: add a contact, set both a profile photo and a calling card (try camera + gallery),
  save, reopen in detail and edit — both images persist and display; removing the calling
  card clears it. Existing contacts (pre-migration) open fine with a null calling card.
- Confirm the v9→v10 migration runs on an existing DB without data loss.
- Manual (in-call): place/receive a call to a contact **with** a calling card — the in-call
  screen shows it full-screen with legible name/status/controls over a scrim. Then a contact
  with only a profile photo (falls back to the profile photo full-bleed), and an unknown
  number (keeps the plain gradient). Requires the app to be the default dialer.
