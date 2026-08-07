# Move sync into a Sync section + add destructive mirror + call-log import

**Status:** completed

## What the user asked

1. Move the two existing sync actions ("Sync from device contacts", "Sync to
   device contacts") out of the flat Contacts settings list into a dedicated
   **Sync** section under Contacts, and re-label them as four actions:
   - Add device contacts to app
   - Add app contacts to device
   - Add device contacts to app (destructive)
   - Add app contacts to device (destructive)
2. Add call-log options in the same Sync section.

## Decisions already made (from the user)

- **Destructive = mirror (delete extras).** The destructive action makes the
  target an exact copy of the source, deleting rows in the target that the
  source does not have.
- **Call log = import only (2 options).** Add "Add device call log to app" and a
  destructive "Replace app call log from device". No app-to-device direction,
  because Android owns the system call log and records calls automatically.

## Current state (what exists today)

- `ContactsSettingsScreen` shows a flat list of cards, including
  `_SyncDeviceContactsCard` (pull, merge-only) and `_SyncToDeviceCard`
  (push, merge-only). See
  [contacts_settings_screen.dart:51-53](../lib/screens/contacts_settings_screen.dart#L51-L53).
- `ContactSyncService.syncFromDevice()` merges device -> app (insert/update
  only, never deletes). `syncToDevice()` merges app -> device (insert/overwrite
  only, never deletes). See
  [contact_sync_service.dart:302](../lib/services/contact_sync_service.dart#L302)
  and [:343](../lib/services/contact_sync_service.dart#L343).
- App call history lives in the SQLite `call_logs` table, built forward from
  live call events ([call_event_logger.dart](../lib/services/call_event_logger.dart)).
  There is **no** bulk import of the phone's existing call log today. The app
  only *reads* the device call log to reconcile durations
  ([call_service.dart:146](../lib/services/call_service.dart#L146)).
- `CallLogRepository` reads/clears `call_logs`; `InteractionRepository.logCall`
  inserts a row. `DeviceContactService` exposes `fetchDeviceContacts`,
  `upsertDeviceContact`, `deleteDeviceContact`, `isGranted`.

## The issue / gap

- The four contact actions the user wants: two already exist (merge pull/push);
  the two **destructive** ones do **not** exist and must be built.
- The two call-log actions do **not** exist and must be built (a new device
  call-log import path).
- There is no "Sync" grouping in the UI yet.

## Plan

### 1. New Sync screen (UI grouping)

Create `lib/screens/contact_sync_settings_screen.dart` with a new
`ContactSyncSettingsScreen`. It lists the sync actions under two headers:

- **Contacts**
  - Add device contacts to app (merge; existing `syncFromDevice`)
  - Add app contacts to device (merge; existing `syncToDevice`)
  - Add device contacts to app (destructive) — new
  - Add app contacts to device (destructive) — new
- **Call log**
  - Add device call log to app (merge/import) — new
  - Add device call log to app (destructive / replace) — new

Each action is a card styled like the existing cards (reuse the same
`Card`/`InkWell`/48px icon pattern already in the codebase). Destructive cards
use a warning tint (e.g. error color) and always show a confirm dialog before
running. Progress + result snackbars mirror the existing sync cards.

Rationale for a sub-screen (not an inline section): six sync actions plus
confirm dialogs would crowd the flat Contacts list. A dedicated screen keeps it
tidy. (If you prefer an inline "Sync" header inside the existing Contacts
screen instead, say so and I will adjust.)

### 2. Wire it into Contacts settings

In [contacts_settings_screen.dart](../lib/screens/contacts_settings_screen.dart):
- **Remove** `_SyncDeviceContactsCard` and `_SyncToDeviceCard` from the list
  (and their class definitions), and instead add a single **"Sync"** card that
  navigates to `ContactSyncSettingsScreen`.
- Move the two existing sync card widgets into the new screen file (renamed
  titles: "Add device contacts to app" / "Add app contacts to device").

### 3. New destructive contact operations (service layer)

In [contact_sync_service.dart](../lib/services/contact_sync_service.dart) add:

- `Future<int> mirrorFromDevice()` — device -> app, delete extras.
  1. Run the normal `syncFromDevice()` merge first (imports/updates).
  2. Then delete app contacts that **came from the device but are gone from it**:
     app rows whose `deviceId` is set but whose id is no longer present in the
     current device book.
  3. **Never delete** app-only contacts: secret contacts, the Self contact, and
     any contact with no `deviceId` (app-created, never on the device). This is
     the safe reading of "mirror" — it keeps data the device never had.
  Returns a count of deletions (surface both added and removed in the snackbar).

- `Future<int> mirrorToDevice()` — app -> device, delete extras.
  1. Run the normal `syncToDevice()` push first (creates/overwrites).
  2. Then delete device contacts **not matched by any app contact**, so the
     device book becomes exactly the app's pushed set. Device-only contacts are
     removed.
  3. **Protect Self and secret contacts.** When building the "keep" set of
     device contacts, include not only the pushable (non-secret, non-self) app
     contacts but ALSO the Self contact and every secret contact, matched to the
     device by link (`deviceId`), phone, or name. This means a device contact
     that corresponds to a secret contact or to the Self contact is **never
     deleted** by this operation, even though those app contacts are not pushed.
  Returns a count of deletions.

Both are guarded by permission and are best-effort per row (a single failed
delete does not abort the run). Both fire `onSyncCompleted` so open screens
refresh.

Helper repository methods as needed on `ContactRepository` (e.g. list app
contacts that have a `deviceId`, for the "gone from device" diff) — reuse
existing `getAllContacts`/`deviceIdLinks` where possible to avoid new SQL.

### 4. New call-log import (service + repository)

- Add `Future<int> importFromDevice({bool replace = false})` to a new
  `lib/services/call_log_import_service.dart` (or extend an existing service).
  1. Ensure `READ_CALL_LOG` permission (reuse `PermissionService`/`CallLog`).
  2. If `replace`, clear `call_logs` first (`CallLogRepository.clearHistory`).
  3. Query the device call log via `CallLog.query()`.
  4. For each entry, resolve the contact by number (reuse the same
     `findByFullNumber` normalization the loggers use), map the call type, and
     insert a `call_logs` row via `InteractionRepository.logCall` (back-dated to
     the entry's real timestamp, with duration/SIM).
  5. In merge mode, dedupe against existing rows by (normalized number +
     timestamp) so re-running does not double-insert.
  Returns the number of rows imported. Fires `CallLogEvents` so Recents
  refreshes.

- Add a small helper on `CallLogRepository` to read existing (number,timestamp)
  keys for the dedupe, or do the check in the service.

### 5. Help article ("Contact Sync destructive")

Add a new help screen `lib/screens/help/contact_sync_help_screen.dart`
(`ContactSyncHelpScreen`), styled like the existing help articles
(`_Intro`/`_Section`/`_Bullet`/`_Footer`). Register it as a new topic card on
[help_home_screen.dart](../lib/screens/help/help_home_screen.dart) titled
"Contact Sync". It has a dedicated **"Destructive sync"** section that states:
- What each of the four contact actions does (merge vs. destructive/mirror).
- **Destructive device -> app never deletes your Self contact, your secret
  contacts, or any contact you created only in the app.** It only removes app
  contacts that came from the phone and are now gone from the phone.
- **Destructive app -> device never deletes device contacts that match your Self
  contact or a secret contact.** Other device contacts not in the app are
  removed.
- That destructive actions ask for confirmation first.

### 6. Confirmations & safety

- Every destructive action shows an `AlertDialog` spelling out exactly what will
  be deleted (e.g. "This will delete device contacts that are not in the app.")
  before running.
- Destructive contact mirror to device can remove many device rows; the dialog
  states the count is unknown up front and lets the user cancel.

## Files to change / add

**Change**
- `lib/screens/contacts_settings_screen.dart` — drop the two sync cards, add a
  "Sync" navigation card.
- `lib/services/contact_sync_service.dart` — add `mirrorFromDevice`,
  `mirrorToDevice`.
- `lib/repositories/contact_repository.dart` — small query helpers if needed.
- `lib/repositories/call_log_repository.dart` — dedupe-key helper if needed.
- `lib/screens/help/help_home_screen.dart` — add the "Contact Sync" topic card.

**Add**
- `lib/screens/contact_sync_settings_screen.dart` — the new Sync screen with all
  six action cards, progress, and confirm dialogs.
- `lib/services/call_log_import_service.dart` — device call-log import.
- `lib/screens/help/contact_sync_help_screen.dart` — the "Contact Sync" help
  article with the "Destructive sync" section.

## Out of scope

- App -> device call-log push (not appropriate; Android owns the system log).
- A separate "recent contacts" device store (there is none; Recents = the
  `call_logs` table).

## Testing

- `flutter analyze` clean on changed files.
- Manual: open Settings -> Contacts -> Sync; verify the four contact actions and
  two call-log actions, confirm dialogs, progress, and snackbars.
- Verify mirror-from-device does not delete secret/self/app-only contacts.
- Verify call-log import dedupes on re-run and that "replace" clears first.
