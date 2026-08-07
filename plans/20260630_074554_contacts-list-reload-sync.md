# Plan: Stop the Contacts list reloading (spinner + full device sync) on every screen return

**Status:** completed

## The issue

Every time the user returns to the Contacts screen — even from the **read-only**
contact-detail screen — the whole list is replaced by a full-screen spinner and the
entire device address book is re-synced. This makes it feel like the app "loads every
time" although nothing changed.

Root causes in [lib/screens/contact_list_screen.dart](../lib/screens/contact_list_screen.dart):

1. `_openContact` (and several other navigations) unconditionally call `_loadContacts()`
   after `Navigator.push` returns — including after a pure view of the detail screen
   (lines 150-155).
2. `_loadContacts()` always:
   - sets `_loading = true`, so `_buildList` shows `CircularProgressIndicator` and hides
     the existing list (line 53 / 499),
   - `await _sync.syncFromDevice()` — re-reads the **whole** device book and re-writes
     every row to SQLite (a write loop), then
   - `await _sync.mergedContacts()` — fetches the device book **again**.

So a read-only return pays: spinner + one full device write-sync + two device reads.

A startup/grant sync already exists (`unawaitedSyncFromDevice()` in
[lib/main.dart:25](../lib/main.dart#L25) and
[lib/screens/permissions_screen.dart:53](../lib/screens/permissions_screen.dart#L53)),
so the per-load device sync is largely redundant.

## Desired behaviour (confirmed with user)

- **First ever run (initial sync not yet completed):** foreground sync with the spinner,
  then mark initial sync as completed (persisted).
- **Subsequent app starts (initial sync completed):** show the locally-stored contacts
  immediately (no spinner), and run the device sync in the **background**, refreshing the
  list silently when it finishes.
- **Returning from the read-only detail screen (and other read-only screens):** a cheap
  **local DB-only** re-read — no device sync, no spinner.
- **Create / update / delete:** these already two-way sync to the device inside
  `ContactSyncService.saveContact`/`deleteContact`, so the list only needs a local DB
  re-read afterwards (no extra device pull, no spinner).

## Files to change

1. `lib/services/contact_sync_service.dart`
2. `lib/screens/contact_list_screen.dart`

## The fix

### 1. `contact_sync_service.dart`

- Add a persisted "initial sync completed" flag via `shared_preferences`
  (key e.g. `contacts_initial_sync_done`):
  - `Future<bool> hasCompletedInitialSync()` — reads the flag (false on error/absent).
  - In `syncFromDevice()`, after a successful run, set the flag to `true`.
    (Set it even when the granted device book is empty, so an empty book still counts as
    "initial sync done"; keep the no-permission early-return a no-op that does **not** set
    the flag, so the first real sync after a grant still runs foreground.)
- Add an optional `bool fetchDevice = true` parameter to `mergedContacts(...)`. When
  `false`, skip the device fetch and return the app DB rows only (used for the cheap
  re-read path). Default `true` preserves current behaviour for the sync paths.

### 2. `contact_list_screen.dart`

Replace the single `_loadContacts()` with clear, intention-revealing paths:

- `_reload()` — DB-only read: `_sync.mergedContacts(includeSecret:, fetchDevice:false)`
  plus the existing best-effort interaction enrichment, `setState` the lists. **No
  spinner, no device sync.** This is the cheap path.
- `_backgroundSync()` — fire-and-forget: `await _sync.syncFromDevice()` then, if still
  mounted, do a full `_reload()`-style refresh (with `fetchDevice:true` so any not-yet-
  adopted device-only contacts surface). No spinner.
- `initState` → `_firstLoad()`:
  - `if (await _sync.hasCompletedInitialSync())`: `_reload()` immediately (no spinner),
    then `_backgroundSync()`.
  - `else`: `setState(_loading=true)`, `await _sync.syncFromDevice()`, read, `_loading=false`
    (foreground first-run with spinner).
- Update the call sites:
  - `_openContact` detail branch (read-only return), `groups`, `relationships`, `export`
    → `_reload()` (cheap, no sync, no spinner).
  - `_addContact`, `_confirmDelete`, `import`, `duplicates`, `_toggleSecret`,
    `onCallReconciled`, and the adopt-device-only save branch → `_reload()` (the mutation
    already synced to the device inside the service; only a local refresh is needed).
  - Keep the genuine first-load spinner only in `_firstLoad`'s not-yet-synced branch.

### Notes / edge cases

- A device contact added **externally** while the app is open will appear after the next
  `_backgroundSync()` (startup) rather than instantly on a read-only return — acceptable
  under the agreed "sync on startup + on mutations" model.
- `docs/known-gaps.md` mentions the per-load `syncFromDevice`; update that note if it
  becomes stale.

## Testing

- `flutter analyze` — no new issues.
- `flutter test` — existing `contact_sync_service_test.dart` still passes; the
  no-permission `syncFromDevice` returns 0 and must **not** set the completed flag.
- Manual: first run shows spinner once; opening a contact and returning shows **no**
  spinner and no re-sync; relaunch shows contacts instantly with a silent background sync.
