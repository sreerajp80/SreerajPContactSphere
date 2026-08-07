# Fix: contacts list is empty on first launch until app restart

**Status:** completed

## The issue

On the very first launch, the contacts list stays empty even after the user
grants the contacts permission. Closing and re-opening the app makes the
contacts appear.

### Why it happens (a startup race)

Two things start at the same time after the first frame:

1. **The app root** ([lib/main.dart](../lib/main.dart) `_bootstrap`) asks for
   permissions and waits for the user's answer. Only after the user taps
   "Allow" does it start the device-book sync (`unawaitedSyncFromDevice`).
2. **The contact list screen** (`_firstLoad` → `_firstRunQuickShow` in
   [lib/screens/contact_list_screen.dart](../lib/screens/contact_list_screen.dart))
   immediately tries to read contacts. At that moment the permission dialog is
   still on screen, so `isGranted()` is false. Its quick read returns nothing,
   and its own `syncFromDevice()` call also no-ops for the same reason. The
   screen settles on "No contacts yet".

When the user finally taps "Allow", the bootstrap sync (step 1) runs and fills
the local database — but **nothing tells the contact list screen to reload**.
The screen only re-reads on user actions (open/close a contact, search, etc.)
or on the next app start. That is why a restart "fixes" it.

## The fix

Let the contact list react when a device sync finishes, instead of only
reading once at startup.

1. **`lib/services/contact_sync_service.dart`**
   - Add a broadcast stream to `ContactSyncService` (it is already a
     singleton), e.g. `Stream<int> get onSyncCompleted`.
   - Fire it at the end of a successful `syncFromDevice()` (after
     `syncDeviceContacts` finishes), carrying the number of changed rows.

2. **`lib/screens/contact_list_screen.dart`**
   - In `initState`, subscribe to `onSyncCompleted`; on an event, call the
     existing cheap local `_reload()` (guarded by `mounted`).
   - Cancel the subscription in `dispose`.
   - Simplify `_backgroundSync()` to just run the sync — the new stream now
     triggers the reload, so its manual `_reload()` call can go (avoids a
     double reload).

This fixes the reported first-run case (bootstrap sync completes after the
permission grant → stream fires → list reloads and shows contacts) and also
any future background sync that lands new contacts while the list is open.

## Files to change

- `lib/services/contact_sync_service.dart` — add the sync-completed broadcast
  stream and fire it after a successful device sync.
- `lib/screens/contact_list_screen.dart` — listen to the stream and reload;
  drop the now-duplicate manual reload in `_backgroundSync`.

## Testing

- `flutter analyze` (note: pre-existing errors are documented in
  docs/known-gaps.md).
- `flutter test`.
- Manual: uninstall the app (or clear its data), install, launch, grant the
  permission — contacts should appear without restarting.
