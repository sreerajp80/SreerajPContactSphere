# Plan: Replace the "This is me" toggle with an "Add Me" entry in Settings → Contacts

**Status:** completed

## What the user wants

- Remove the "This is me" toggle from the Add/Edit contact screen.
- Add a **Contacts** settings group in Settings containing an **"Add Me"** button.
- "Add Me" opens the Add Contact screen in **self mode** — **without the Meetiversary field
  and without the Calling card section** — where the user fills in and saves their own details
  (marked as the Self contact).

## Current state (to change)

- Self is created/marked via a `_selfSection()` **toggle** in `add_edit_contact_screen.dart`.
- Meetiversary is already hidden when `_isSelf` is true (previous change).
- Settings (`settings_screen.dart`) is a flat list of `_SettingsCard`s with no sub-sections.
- The contact list has a **"My Profile"** overflow item (opens the Self detail if set, else
  creates in self mode). This stays.

## Design decisions (please confirm)

1. **New `ContactsSettingsScreen`** reached from a new **"Contacts"** card in Settings (matches
   "under Contacts Settings"). It hosts an **"Add Me"** card and leaves room for future
   contact-related settings. *(Alternative: drop a single "Add Me" card straight onto the
   Settings list without a sub-screen — say so if you prefer that.)*
2. **"Add Me" is idempotent** (Self is a singleton): on tap it opens the **existing** Self
   contact for editing if one exists, otherwise opens the Add screen in self mode to create it.
   This avoids creating a second "me".
3. **Self mode in Add/Edit** = `isSelf` true, with the **Meetiversary** field and the
   **Calling card** section hidden, and both persisted as null on save. Self mode is entered
   two ways: `initialIsSelf: true` (new), or editing a contact whose `isSelf` is already true.
4. **Removing the toggle** means an arbitrary existing contact can no longer be flipped
   to/from Self from the form. Self is created via "Add Me" (or the "My Profile" menu) and
   edited in place; to stop being Self, delete that contact. Acceptable per the request.

## Files to change

- **`lib/screens/add_edit_contact_screen.dart`**
  - Remove the `_selfSection()` widget from the build list (and delete the now-unused method).
  - Keep `_isSelf` initialized from `widget.contact?.isSelf ?? widget.initialIsSelf` (no runtime
    toggle).
  - Wrap the Calling card section (`_cardPhotoSection()` + its spacing) in `if (!_isSelf) ...[]`
    so it's hidden in self mode (Meetiversary already hidden).
  - In `_save()`: when `_isSelf`, persist `cardPhotoPath` as null (Meetiversary already nulled).
  - Top-bar title reflects self mode: "Add me" / "Edit me" when `_isSelf`, else the current
    "Add contact" / "Edit contact".

- **`lib/screens/settings_screen.dart`**
  - Add a **"Contacts"** `_SettingsCard` (icon e.g. `Icons.contacts_outlined`, subtitle
    "Your profile and contact options") routing to the new `ContactsSettingsScreen`. Placed
    near the top of the plain-card list.

- **`lib/screens/contacts_settings_screen.dart`** *(new)*
  - A `Scaffold` (AppBar "Contacts") with an **"Add Me"** card (reusing the settings-card
    style; icon e.g. `Icons.person_add_alt_1_outlined`, subtitle "Add or edit your own contact
    details").
  - On tap: `final self = await ContactSyncService().selfContact();` then push
    `AddEditContactScreen(contact: self)` if `self != null`, else
    `AddEditContactScreen(initialIsSelf: true)`.

- **`lib/screens/contact_list_screen.dart`** — unchanged (the "My Profile" item already routes
  correctly through the same self-mode create/edit paths).

## Verification

- `flutter analyze` clean; `flutter test` (existing suite) unchanged.
- Manual: Settings → Contacts → Add Me → the form opens in self mode (no Meetiversary, no
  Calling card) → save → the contact is pinned at the top with the "YOU" pill; tapping "Add Me"
  again re-opens the same record for editing.
