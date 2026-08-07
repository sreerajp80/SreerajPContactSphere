# Sync section, destructive mirror sync, and call-log import

Implements plan
[plans/20260711_092004_sync-section-and-call-log-import.md](../plans/20260711_092004_sync-section-and-call-log-import.md).

## What changed

Moved the two device-sync actions out of the flat Contacts settings list into a
new dedicated **Sync** screen, re-labelled them, and added four new actions: two
destructive "mirror" contact syncs and two call-log imports.

### New Sync screen

- **Added** `lib/screens/contact_sync_settings_screen.dart`
  (`ContactSyncSettingsScreen`). It groups six action cards under two headers:
  - **Contacts**
    - Add device contacts to app (merge — `syncFromDevice`)
    - Add app contacts to device (merge — `syncToDevice`)
    - Add device contacts to app (destructive — `mirrorFromDevice`)
    - Add app contacts to device (destructive — `mirrorToDevice`)
  - **Call log**
    - Add device call log to app (import, merge)
    - Add device call log to app (destructive — import, replace)
  - A reusable `_SyncActionCard` runs each action, shows a spinner while busy,
    reports the result in a snackbar, and (for destructive actions) shows a
    danger-styled confirm dialog first.
- **Changed** `lib/screens/contacts_settings_screen.dart`: removed the two old
  inline sync cards (`_SyncDeviceContactsCard`, `_SyncToDeviceCard`) and added a
  single **Sync** navigation card that opens the new screen. Dropped the now
  unused `dart:async` and `device_contact_service` imports.

### Destructive contact mirror (service)

- **Changed** `lib/services/contact_sync_service.dart`:
  - `mirrorFromDevice()` — runs the normal pull, then deletes app contacts whose
    `device_id` is gone from the phone. **Never** deletes the Self contact,
    secret contacts, or app-only contacts (no `device_id`).
  - `mirrorToDevice()` — runs the normal push, then deletes device contacts that
    no app contact matches (by link, phone, or name). The keep set is built from
    the whole app book **including Self and secret contacts**, so a device
    contact matching one of those is never deleted, even though those are never
    pushed.
  - Both fire `onSyncCompleted` when they delete anything.

### Call-log import (service + repository)

- **Added** `lib/services/call_log_import_service.dart`
  (`CallLogImportService.importFromDevice({replace})`). Reads Android's system
  call log via `CallLog.get()`, resolves each entry to a contact, and inserts a
  `call_logs` row (back-dated to the real time, with duration/SIM). Merge mode
  de-duplicates against existing rows by (normalized number + exact timestamp);
  `replace` clears the history first. Fires `CallLogEvents` so Recents refreshes.
  There is no app→device direction (Android owns the system call log).
- **Changed** `lib/repositories/call_log_repository.dart`: added
  `existingKeys()` and the static `importKey()` used for import de-duplication.

### Help

- **Added** `lib/screens/help/contact_sync_help_screen.dart`
  (`ContactSyncHelpScreen`) with a **Destructive sync** section spelling out what
  each action deletes and that Self / secret contacts are protected.
- **Changed** `lib/screens/help/help_home_screen.dart`: added a "Contact Sync"
  topic card linking to the new article.

## Notes / known limits

- Merge call-log import can leave a few near-duplicates when a call was already
  logged live (the live timestamp and the device-log timestamp can differ by a
  second or two). The destructive "replace" option gives a clean device-sourced
  history.
- The new merge cards show a simple spinner rather than the old live "x of y"
  progress bar; the underlying `syncFromDevice` progress stream is unchanged.

## Testing

- `flutter analyze` on all seven changed/added files: **No issues found.**
- Manual verification (Settings → Contacts → Sync) pending on device.
