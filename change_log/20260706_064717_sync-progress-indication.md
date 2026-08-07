# Change log: Progress indication while syncing device contacts

Implements plan: `plans/20260706_063416_sync-progress-indication.md`

## What changed

### `lib/services/contact_sync_service.dart`
- Added a `SyncPhase` enum (`fetching` / `merging`) and a small `SyncProgress`
  class (phase + processed/total counts).
- `ContactSyncService` gained a broadcast `onSyncProgress` stream and a
  `currentProgress` getter, so screens that open mid-sync can seed their UI
  right away.
- `syncFromDevice()` now reports the `fetching` phase before reading the
  device book, and clears progress (`null`) on the failed-fetch and error
  paths.
- The merge loop (moved into a private `_mergeDeviceContacts`, wrapped by
  `syncDeviceContacts`) reports "x of y" progress every 10 contacts plus a
  final full-count event. A `finally` block guarantees the terminal `null`
  even if the merge throws, so the UI can never get stuck showing progress.

### `lib/screens/contacts_settings_screen.dart`
- The "Sync device contacts" card now listens to `onSyncProgress`. The
  spinner becomes a determinate progress circle once the merge total is
  known, and the subtitle shows live text: "Reading device contacts…" then
  "Syncing 120 of 500…".
- The card also shows progress for syncs started elsewhere (e.g. the startup
  background sync) and ignores taps while any sync runs.

### `lib/screens/contact_list_screen.dart`
- The contact list subscribes to `onSyncProgress` and shows a slim banner
  above the list while a sync runs: a label plus a thin `LinearProgressIndicator`
  (indeterminate during the device fetch, determinate "x of y" during the
  merge). It covers the first-run sync, the background sync, and manual syncs.

### `test/contact_sync_service_test.dart`
- New test: `syncDeviceContacts` over 25 contacts emits merging progress
  starting at 0/25, ends with 25/25 followed by the terminal `null`, and
  leaves `currentProgress` cleared.

## Verification

- `flutter analyze` on the four changed files: no issues.
- `flutter test`: all 110 tests pass (including the new progress test).
