# Fix: contacts list is empty on first launch until app restart

Implements [plans/20260705_223256_first-launch-empty-contacts.md](../plans/20260705_223256_first-launch-empty-contacts.md).

## Problem

On the very first launch, the contact list rendered before the user answered
the contacts-permission dialog, so its first read (and its own sync attempt)
found nothing. When the user then granted the permission, the startup sync in
`main.dart` filled the database — but nothing told the already-rendered list
to refresh, so it stayed on "No contacts yet" until the app was restarted.

## Changes

### `lib/services/contact_sync_service.dart`

- Added a broadcast stream `onSyncCompleted` (backed by a never-closed
  `StreamController<int>` — the service is an app-lifetime singleton).
- `syncFromDevice()` now fires that stream with the changed-row count after a
  successful pull. Early no-op returns (permission absent, fetch failed) do
  not fire it.

### `lib/screens/contact_list_screen.dart`

- Subscribes to `onSyncCompleted` in `initState` and runs the existing cheap
  local `_reload()` when a sync lands (guarded by `mounted`); cancels the
  subscription in `dispose`.
- `_backgroundSync()` no longer calls `_reload()` itself — the stream listener
  now does that, avoiding a double reload.

## Verification

- `flutter analyze`: no issues found.
- `flutter test`: all 109 tests passed.
- Manual check still recommended on a device: uninstall (or clear app data),
  launch, grant the permission — contacts should appear without a restart.
