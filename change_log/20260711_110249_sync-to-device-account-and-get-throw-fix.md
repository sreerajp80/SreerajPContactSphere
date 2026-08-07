# Fix "Add app contacts to device" — get() throw + choosable destination account (incl. local)

Implements plan `plans/20260711_104954_sync-to-device-account-and-get-throw-fix.md`.

## Why

Tapping **Sync → "Add app contacts to device"** showed "Synced to device — 289 added or
updated" but **no contacts appeared on the phone** (Contact counts stayed Device: 0).

Diagnosis on the real device (moto, Android 16 / SDK 36) with adb + live logcat:

1. **Real bug:** every app contact carried a **stale `device_id`** (631, 632 …) from an
   earlier import; the phone book is now empty. `DeviceContactService.upsertDeviceContact`
   took the "update existing" branch and called `FlutterContacts.get(staleId)`, which in
   **flutter_contacts 2.1.0 THROWS** `Contact with ID X not found` (it does not return null,
   which the old code assumed). The throw was swallowed and the `create()` fallback never
   ran — so nothing was written, for all 289 contacts.
2. **False toast:** `syncToDevice` counted every attempt as `created`/`updated` regardless
   of success.
3. **Wrong destination:** the old "empty `Account` → local device account" trick worked on
   flutter_contacts 1.1.9 but is a **silent no-op on 2.1.0** (empty account is discarded and
   `create()` falls back to the user's default cloud account). The plugin cannot target the
   local ("Device") account at all. Verified via adb that direct provider inserts into both
   the local NULL account and the Google account persist on this device — Android 16 was not
   blocking or soft-deleting; the plugin simply wasn't writing.

## What changed

### `lib/services/device_contact_service.dart`
- **Fixed the `get()` throw:** the `FlutterContacts.get(existingId)` call is now wrapped in
  its own `try/catch`; a "not found" (or any failure) is treated as `existing == null`, so a
  stale link falls through and **recreates** the device contact.
- `upsertDeviceContact` now returns the device id **on success and `null` on failure** (was
  echoing the old id), so callers can count honestly. It takes an optional
  `WritableAccount target` picking where a *new* contact is created.
- **Account-routed create:** a real account → `FlutterContacts.create(..., account:)`
  (plugin); the local "Device" storage → a new native bridge. Updates/deletes still go
  through the plugin by id (unaffected by account).
- Added `writableAccounts()` — the local "Device" storage first, then the real accounts from
  `FlutterContacts.accounts.getAll()`.
- Added `_createLocalContact` + `_localPayload` + Android-type mappers building the compact
  payload the native writer consumes.

### `android/app/src/main/kotlin/in/sreerajp/contact_sphere/LocalContactWriter.kt` (new)
- Builds a `ContentProviderOperation` batch that inserts a RawContact with
  `ACCOUNT_TYPE = null, ACCOUNT_NAME = null` (the local account) plus name, phones, emails,
  postal addresses, organization, events, websites, and photo, then returns the new contact
  id. Runs off the platform thread.

### `android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt`
- Registered a new method channel `contact_sphere/contacts_local` with `createLocalContact`,
  delegating to `LocalContactWriter` on a worker thread.

### `lib/services/contact_sync_service.dart`
- `syncToDevice({target, onProgress})` and `mirrorToDevice({target})` accept and forward the
  chosen destination.
- **Honest counting:** `created`/`updated` are incremented only on a real success; failures
  are counted in the new `SyncToDeviceResult.failed`.
- `saveContact` keeps the previous `deviceId` when a device write fails (returns null), so a
  transient failure never unlinks a good contact.

### `lib/services/device_account.dart` (new)
- `WritableAccount` model: a local ("Device") target or a real `fc.Account`, with a friendly
  label and a stable `id` for remembering the last choice.

### `lib/screens/contact_sync_settings_screen.dart`
- Both app→device cards now show an **app-styled bottom-sheet account picker** (Device first,
  then real accounts), remember the choice in `SharedPreferences`, and pass it to the sync.
- Snackbars are honest: `"Saved to <account> — N added or updated (M failed)"`, etc. The
  shared card now stays silent on an empty message (picker cancelled).

## Notes / known gaps
- Social links are omitted on the **local** native write (no standard mimetype); they are
  preserved when writing to a real account through the plugin.
- Not downgrading flutter_contacts (2.1.0 APIs are used across the app).

## Verification
- `flutter analyze` — clean (full project).
- adb confirmed a local NULL-account provider insert persists (`deleted=0`) on the device.
- Full on-device build/install/sync testing is done by the user (native changes require a
  rebuild+reinstall; the release build updates in place and preserves the encrypted DB).
