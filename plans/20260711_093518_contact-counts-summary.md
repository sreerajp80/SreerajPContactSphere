# Show device and app contact counts on the Contacts settings screen

**Status:** completed

## What the user asked

Show how many contacts exist on the device, and (from the follow-up) show the
app's own contact count too, on the **Contacts settings screen** (Settings →
Contacts).

## The issue / gap

There is no place in the app that shows how many contacts are on the phone or how
many the app stores. The user wants both, side by side, on the Contacts settings
screen.

## Background (constraints)

- `flutter_contacts` has **no count API** — the count is the length of a fetch.
  The app already does a **light** fetch (names/phones/emails, no photos) for its
  fast list, which is the cheap path. On a very large address book it is still
  not instant, so the counts load asynchronously with a spinner.
- App count is available cheaply from the DB via
  `ContactRepository.countContacts` (already wrapped by
  `ContactSyncService.contactCount`).

## Plan

### 1. Device count helper (service)

Add `Future<int?> deviceContactCount()` to
[device_contact_service.dart](../lib/services/device_contact_service.dart):
- Return `null` when the contacts permission is not granted (so the UI can show a
  hint instead of "0").
- Otherwise do a **light** `fetchDeviceContacts()` and return its length; return
  `null` on a failed fetch (never throw), matching the file's never-throw style.

### 2. Counts summary card (UI)

Add a `_ContactCountsCard` (stateful) at the **top** of
[contacts_settings_screen.dart](../lib/screens/contacts_settings_screen.dart),
above the "Add Me" card. It shows two figures side by side:

- **Device** — from `deviceContactCount()`; shows a spinner while loading, and a
  short "Grant contacts permission" hint (tappable to request) when the
  permission is missing.
- **App** — from `ContactSyncService().contactCount(includeSecret: true)` (counts
  every stored contact, including secret and Self, since this is a settings
  figure). 

Behaviour:
- Loads both counts once in `initState`.
- Listens to `ContactSyncService().onSyncCompleted` and reloads, so the numbers
  refresh right after any sync/mirror/restore changes them.
- Styled to match the existing cards on the screen (same `Card`, 48px accent
  icon, muted subtitle text).

No new strings are persisted; this is a read-only display.

## Files to change

- `lib/services/device_contact_service.dart` — add `deviceContactCount()`.
- `lib/screens/contacts_settings_screen.dart` — add `_ContactCountsCard` and
  place it at the top of the list.

## Out of scope

- No count on the Sync sub-screen or on individual sync-card subtitles (the user
  chose the Contacts settings screen).
- No live auto-refresh beyond the `onSyncCompleted` signal (e.g. it does not poll
  the device book for outside changes; reopening the screen re-reads).

## Testing

- `flutter analyze` clean on the two changed files.
- Manual: open Settings → Contacts; confirm both counts show, the spinner appears
  while loading, the permission hint shows when contacts access is denied, and
  the numbers update after running a sync.
