# Change log — Refresh the contacts list after a Restore

Implements plan
[plans/20260711_080253_refresh-contacts-after-restore.md](../plans/20260711_080253_refresh-contacts-after-restore.md).

## The problem

After restoring a backup, the Contacts tab kept showing the "No contacts yet"
empty state even though the data was restored. Tapping Favorites → All revealed
the contacts, because that path re-queries the database.

Cause: `ContactListScreen` re-reads the DB only on a device-sync completion, a
sort/hide settings change, or returning from a screen that calls `_reload()`. The
restore flow ends with `navigator.popUntil((route) => route.isFirst)`, landing
back on the already-mounted Contacts list without any of those triggers (the
`'settings'` menu case it was opened through is the one case that doesn't reload
on return). So the list kept its stale launch-time snapshot. This is a pure
UI-refresh bug, unrelated to the separate encryption/key-loss issue.

## What changed

- **`lib/services/contact_sync_service.dart`** — added `notifyLocalDataChanged()`,
  which emits on the existing `_syncCompleted` broadcast. Screens that already
  listen to `onSyncCompleted` (the Contacts list) refresh their local reads. No
  new wiring or stream was introduced.
- **`lib/screens/backup/backup_restore_screen.dart`** — imported
  `ContactSyncService` and, in `_startRestore`, call
  `ContactSyncService().notifyLocalDataChanged()` right after a successful
  `restoreBackup(...)` + `settings.load()`, before popping back home. The
  Contacts list's existing listener then re-queries and shows the restored
  contacts immediately.

Dialer and Recents were not touched: `HomeShell` already reloads them via their
`GlobalKey` when their tab is selected, so restored call logs and favorites show
when those tabs are opened.

## Verification

- `flutter analyze lib/services/contact_sync_service.dart
  lib/screens/backup/backup_restore_screen.dart` — no issues.
- `flutter build apk --release` — the prod release APK built successfully
  (`build/app/outputs/apk/prod/release/app-prod-release.apk`).
- On-device verification (restore → Contacts refreshes without the Favorites→All
  toggle) is being done by the user: the freshly built APK had versionCode 1 and
  the device (installed versionCode 2001, non-debuggable) refused the downgrade,
  so an in-place update needs a build made with `--flavor prod
  --build-number 2002` (or higher) to preserve the just-restored data.

## Not addressed here (still open)

The underlying SQLCipher / Android-Keystore key-loss that blanked the database on
the Motorola (DB encrypted with a key the Keystore later lost, then silently
re-minted by `DbKey.getOrCreate`). That is tracked separately as the pending
fix-direction decision (#1 loud-fail / #2 passphrase-derived key / #3 drop
SQLCipher).
