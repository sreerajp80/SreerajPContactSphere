# Refresh the contacts list after a Restore

**Status:** completed

## The issue

After restoring a backup, the Contacts tab still shows the old "No contacts yet"
empty state. The data IS restored — tapping **Favorites** then **All** makes the
contacts appear, because that path re-queries the database.

### Why it happens

- `HomeShell` keeps all three tabs (Contacts, Dialer, Recents) alive in an
  `IndexedStack`. Dialer and Recents reload when their tab is tapped
  (`_onSelect` → `reload()`), so they refresh after a restore as soon as you
  switch to them. Contacts does not — it is the landing tab, so no tab-switch
  fires for it.
- `ContactListScreen` only re-reads the DB on: a device sync completing
  (`onSyncCompleted` listener), a sort/hide settings change, or returning from a
  screen that explicitly calls `_reload()`.
- The restore flow ends with `navigator.popUntil((route) => route.isFirst)`,
  dropping straight back to the already-mounted Contacts list. The `'settings'`
  case in `_handleMenu` (the route the restore was opened through) is the one
  case that does NOT call `_reload()` on return. So nothing re-queries, and the
  list keeps its stale (empty) snapshot from launch.

This is purely a UI-refresh bug. It is unrelated to the encryption/key problem
diagnosed earlier (that is a separate, still-open decision).

## The fix

Make a successful restore announce that local data changed, and let the already
existing listener on the Contacts screen refresh itself.

1. **`lib/services/contact_sync_service.dart`** — add a small public method that
   emits on the existing broadcast the Contacts list already listens to:

   ```dart
   /// Signals that local contact data changed outside a device sync (e.g. a
   /// full backup restore). Screens listening to [onSyncCompleted] refresh.
   void notifyLocalDataChanged() => _syncCompleted.add(0);
   ```

   Reuses `_syncCompleted` so no new wiring is needed; `ContactListScreen`
   already maps this event to `_reload()`.

2. **`lib/screens/backup/backup_restore_screen.dart`** — in `_startRestore`,
   after `await _service.restoreBackup(...)` and `settings.load()`, call
   `ContactSyncService().notifyLocalDataChanged()` **before**
   `navigator.popUntil(...)`. The Contacts list's listener then re-reads the DB
   and shows the restored contacts. (Dialer and Recents already reload on tab
   selection, so restored call logs / favorites show when those tabs are opened.)

### Files to change

- `lib/services/contact_sync_service.dart` — add `notifyLocalDataChanged()`.
- `lib/screens/backup/backup_restore_screen.dart` — fire it on successful restore.

## Out of scope

- The SQLCipher / Keystore key-loss problem (why the DB went blank on the
  Motorola). That is the bigger, still-pending decision (fix #1 / #2 / #3) and is
  tracked separately.

## Verification

- `flutter analyze` on both changed files: expect no issues.
- On the connected device: restore a backup and confirm the Contacts list shows
  the contacts immediately, with no need to toggle Favorites → All. Capture a
  before/after via the running app.
