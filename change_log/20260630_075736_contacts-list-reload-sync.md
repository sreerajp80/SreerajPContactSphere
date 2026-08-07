# Change log: Stop the Contacts list reloading on every screen return

Implements [plans/20260630_074554_contacts-list-reload-sync.md](../plans/20260630_074554_contacts-list-reload-sync.md).

## Problem

Returning to the Contacts screen — even from the read-only contact-detail screen —
replaced the list with a full-screen spinner and re-ran a full device address-book sync
(`syncFromDevice` write loop) followed by two device reads, making the app feel like it
"loads every time" although nothing had changed.

## Changes

### `lib/services/contact_sync_service.dart`
- Added a persisted "initial sync completed" flag (`shared_preferences` key
  `contacts_initial_sync_done`):
  - New `hasCompletedInitialSync()` getter (false on absence/error).
  - `syncFromDevice()` now sets the flag via a new private `_markInitialSyncDone()` after a
    successful run. The no-permission early return still does **not** set it, so the first
    real sync after a permission grant runs foreground.
- Added an optional `bool fetchDevice = true` parameter to `mergedContacts(...)`. When
  `false`, the device book fetch is skipped and only app DB rows are returned (cheap
  local-only read). Default preserves prior behaviour.

### `lib/screens/contact_list_screen.dart`
- Replaced the single always-syncing-and-spinning `_loadContacts()` with three paths:
  - `_firstLoad()` (from `initState`): if the initial sync is already done, show local
    contacts immediately (no spinner) and run `_backgroundSync()`; otherwise do the
    one-time foreground sync with the spinner.
  - `_reload()`: cheap local-only DB read (`fetchDevice: false`) + interaction enrichment,
    no spinner, no device sync. Used on read-only returns and after mutations (which
    already two-way sync inside the service).
  - `_backgroundSync()`: fire-and-forget `syncFromDevice()` then a silent full merge
    refresh; no spinner.
  - Extracted `_loadLastInteractions()` / `_loadRecentCounts()` helpers for the
    best-effort enrichment shared by the read paths.
- Re-pointed all former `_loadContacts()` call sites (toggle secret, add, open/adopt,
  delete, import, duplicates, relationships, `onCallReconciled`, detail return) to
  `_reload()`.

### `docs/known-gaps.md`
- Updated the device-sync note: the list now shows local contacts immediately and syncs in
  the background after the initial sync; only first run blocks; read-only navigation does a
  local-only re-read.

## Verification
- `flutter analyze` on both changed files — no issues.
- `flutter test` — all 21 tests pass, including `contact_sync_service_test.dart` (the
  no-permission `syncFromDevice` still returns 0 and does not set the completed flag).
