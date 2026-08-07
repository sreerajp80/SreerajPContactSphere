# Change log: "Add Me" in Settings → Contacts (replaces the "This is me" toggle)

Implements [plans/20260703_121512_add-me-in-settings.md](../plans/20260703_121512_add-me-in-settings.md).

## What changed

The Self (phone owner) contact is now created/edited from **Settings → Contacts → Add Me**
instead of a toggle on the Add/Edit form. The self-mode form hides the Meetiversary field and
the Calling card section.

### `lib/screens/add_edit_contact_screen.dart`
- Removed the `_selfSection()` "This is me" toggle (widget and method).
- `_isSelf` is now set once from `widget.contact?.isSelf ?? widget.initialIsSelf` (no runtime
  toggle) and drives self mode.
- Calling card section (`_cardPhotoSection()` + spacing) is wrapped in `if (!_isSelf) ...[]`
  so it's hidden in self mode (Meetiversary was already hidden).
- `_save()`: in self mode, `cardPhotoPath` is persisted as null (Meetiversary already nulled).
- Top-bar title shows "Add me" / "Edit me" in self mode, else "Add contact" / "Edit contact".

### `lib/screens/contacts_settings_screen.dart` (new)
- `ContactsSettingsScreen` (AppBar "Contacts") with an **"Add Me"** card styled like the
  Settings hub cards.
- On tap: loads the existing Self via `ContactSyncService.selfContact()` and opens it for
  editing if present (Self is a singleton), otherwise opens
  `AddEditContactScreen(initialIsSelf: true)` to create it.

### `lib/screens/settings_screen.dart`
- Added a **"Contacts"** `_SettingsCard` (icon `contacts_outlined`, subtitle "Your profile and
  contact options") routing to `ContactsSettingsScreen`, placed after "Dialer top contacts".

### Unchanged
- The contact list's "My Profile" overflow item still works — it routes through the same
  self-mode create/edit paths.

## Verification
- `flutter analyze` — **clean** (no issues).
- `flutter test` — 42/43 pass; the single failure (`widget_test.dart` → "renders the home
  shell") is the same pre-existing, unrelated stale assertion (expects a Material
  `NavigationBar`, which the custom bottom bar in `home_shell.dart` doesn't use). No regression.

## Note
- Removing the toggle means an arbitrary existing contact can no longer be flipped to/from Self
  from the form; Self is created via "Add Me" (or the list's "My Profile") and edited in place.
