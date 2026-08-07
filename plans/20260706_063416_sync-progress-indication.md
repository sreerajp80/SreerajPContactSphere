# Plan: Progress indication while syncing device contacts

**Status:** completed

## The issue

When the app pulls the device address book into its own store, the user gets no
progress feedback:

- The manual "Sync device contacts" card in Contacts settings shows only an
  endless spinner. On a big address book the user cannot tell if it is working
  or stuck.
- The first-run sync and the background sync on the contact list screen show
  nothing at all while they run.
- The sync service (`ContactSyncService`) only fires an event when the whole
  sync is *finished* (`onSyncCompleted`). It never reports how far along it is,
  so no screen can show progress even if it wanted to.

## Files to change

1. `lib/services/contact_sync_service.dart`
2. `lib/screens/contacts_settings_screen.dart`
3. `lib/screens/contact_list_screen.dart`
4. `test/contact_sync_service_test.dart` (add coverage for the new progress events)

## The fix

### 1. Service: report progress (`contact_sync_service.dart`)

- Add a small `SyncProgress` class in this file:
  - `phase` — `fetching` (reading the device book, total not yet known) or
    `merging` (saving into the app DB).
  - `processed` and `total` — counts for the merging phase.
- Add to `ContactSyncService`:
  - a broadcast `StreamController<SyncProgress?>` and a public
    `Stream<SyncProgress?> get onSyncProgress`;
  - a `SyncProgress? get currentProgress` field so a screen that opens
    mid-sync can show the current state right away. `null` means "not syncing".
- Emit events:
  - `syncFromDevice()` emits `fetching` before the device fetch;
  - `syncDeviceContacts()` emits `merging (0 of N)` when it starts, then an
    update every 10 contacts (to avoid flooding the UI) and one final update;
  - `null` is emitted when the sync ends — on success **and** on every early
    return / error path, so the UI can never get stuck showing progress.

### 2. Settings card: real progress (`contacts_settings_screen.dart`)

- `_SyncDeviceContactsCard` subscribes to `onSyncProgress` while syncing.
- The spinner becomes determinate (`CircularProgressIndicator(value: …)`) once
  the total is known, and the card's subtitle shows live text such as
  "Syncing 120 of 500…" (or "Reading device contacts…" during the fetch phase).
- Existing behavior stays: taps ignored while syncing, outcome snackbar at the end.

### 3. Contact list: sync banner (`contact_list_screen.dart`)

- The screen subscribes to `onSyncProgress` in `initState` (next to the
  existing `onSyncCompleted` listener) and keeps a `SyncProgress?` field.
- While a sync runs (first-run sync, background sync, or a manual sync started
  from settings), a slim banner shows above the list: a `LinearProgressIndicator`
  (indeterminate during fetch, determinate during merge) plus a short label
  like "Syncing contacts… 120 of 500". It disappears when the sync ends.

### 4. Tests (`contact_sync_service_test.dart`)

- Add a test that `syncDeviceContacts` emits merging progress events ending in
  a final full-count event followed by `null`.

## Out of scope

- No change to how the sync itself works (dedup/merge rules untouched).
- No progress for the device-*write* direction (saving one contact is quick).
