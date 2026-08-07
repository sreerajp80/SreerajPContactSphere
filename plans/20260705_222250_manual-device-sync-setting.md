# Settings → Contacts: manual "Sync device contacts" action

**Status:** completed

## The request

Give the user a way to manually sync the app with the phone's contacts, from
Settings → Contacts.

## Current state

- Settings → Contacts is `lib/screens/contacts_settings_screen.dart` — a
  `ListView` of action/switch cards (Add Me, Blocked numbers, secret-contact
  export controls).
- The sync already exists as `ContactSyncService.syncFromDevice()`: it pulls
  the device book into the app DB, links by `device_id`, dedups, and returns
  the number of rows inserted/updated. It is a silent no-op (returns 0) when
  the contacts permission is not granted — it does not prompt.
- `DeviceContactService.ensurePermission()` prompts for the contacts
  permission when needed.

Today the sync only runs automatically (app startup, list screen background
sync, on permission grant). There is no user-triggered sync.

## Files to change

1. `lib/screens/contacts_settings_screen.dart` — add the new card.

No service or DB changes needed.

## The plan

Add a **"Sync device contacts"** action card to `ContactsSettingsScreen`,
placed right after "Add Me" (it is the most contact-book-related action):

1. New private widget `_SyncDeviceContactsCard`, a small `StatefulWidget`
   (the rest of the screen stays stateless):
   - Same card style as the existing cards (48px icon tile, accent at 14%
     alpha, title + muted subtitle). Icon: `Icons.sync_outlined`.
   - Title: "Sync device contacts". Subtitle: "Pull the phone's address book
     into the app now".
2. On tap:
   - First call `DeviceContactService().ensurePermission()`. If denied, show
     a snackbar: "Contacts permission is needed to sync" and stop.
   - While syncing: disable the card and swap the icon for a small
     `CircularProgressIndicator` so a second tap can't start a parallel sync.
   - Run `ContactSyncService().syncFromDevice()` and show the result in a
     snackbar: "Contacts synced — N added or updated" (or "Contacts are
     already up to date" when N is 0). Errors show "Sync failed" (the service
     is defensive, but the tap handler still catches).
3. The contact list screen already re-reads from the DB on return/refresh, so
   no extra wiring is needed for it to pick up the synced rows.
4. Run `flutter analyze` and `flutter test`, then write the change log.

## Note — relation to the pending missing-contacts plan

`plans/20260705_222030_missing-contacts-in-list.md` (approval_pending) fixes
bugs in `syncFromDevice` itself (over-aggressive dedup, dropped nameless
contacts, failure handling). This manual-sync button simply triggers that same
sync, so:

- The two changes are independent; this one can be built first.
- But until that fix plan is also approved and implemented, a manual sync will
  still drop the same contacts the automatic sync drops.
