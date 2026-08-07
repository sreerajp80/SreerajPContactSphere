# Sync app contacts into the device (local) account, and refresh the counts card

Implements plan `plans/20260711_100024_sync-to-device-local-account.md`.

## Problem

The "Contact counts" card showed **Device: 0** even after "Add app contacts to
device". Confirmed on the connected device with `adb`/ContactsContract: all 328
`raw_contacts` were `deleted=1` (soft-deleted), all in the synced `com.google`
account, so the visible `contacts` table was empty and the app read 0 correctly.

Cause: `DeviceContactService.upsertDeviceContact` created contacts with **no
account**. In `flutter_contacts` 2.1.0 the native `CreateImpl` replaces a null
account with the device **default account** (Google here). Contacts in that
synced account get reconciled away and end up soft-deleted.

The device's local account is `NULL`/`NULL` (`ungrouped_visible=1`). A raw
contact inserted there stays live/visible — verified by inserting and deleting
test rows via `adb`. Passing an account with empty `type`/`name` makes the
ContactsProvider store it as that local `NULL` account, so the fix stays within
the plugin's public API (no fork).

## Changes

- `lib/services/device_contact_service.dart`
  - Added `static const fc.Account _localAccount = fc.Account(id: '', name: '', type: '')`.
  - `upsertDeviceContact` now calls
    `FlutterContacts.create(_toDevice(c), account: _localAccount)` so newly
    created device contacts go to the local device account instead of the Google
    default. Updates of an already-linked contact are unchanged (they stay on
    their existing raw contact).

- `lib/services/contact_sync_service.dart`
  - `syncToDevice` now fires `_syncCompleted.add(created + updated)` at the end.
  - `mirrorToDevice` now fires `_syncCompleted.add(deleted)` unconditionally
    (previously only when `deleted > 0`), since the push half can create/overwrite
    device contacts even when nothing is deleted.
  - Both make the "Contact counts" card (and other `onSyncCompleted` listeners)
    refresh after an app→device sync without a manual tap.

## Notes

- Existing app rows carry stale `device_id`s from the earlier Google-account
  sync. On the next push, `FlutterContacts.get(oldId)` returns null for those
  soft-deleted contacts, so `upsertDeviceContact` falls through to `create()` and
  recreates them in the local account — self-healing, no migration code.
- The 328 pre-existing `deleted=1` rows are stale Google-account writes; the sync
  adapter purges them over time. No cleanup code added.

## Verification status

- `flutter analyze` on both changed files: **no issues**.
- Provider-level behavior (empty account -> live local `NULL` contact) verified
  on-device via `adb` insert/delete.
- **Full on-device UI run not completed here:** `flutter run` failed at the
  flavor/APK step (known build-flavor quirk), so the debug APK was never
  installed and the phone kept running the previous build. The debug APK
  (versionCode 1) cannot install over the installed release (2001) without an
  uninstall that would wipe app data. Per the user's decision, they will build
  and test through their normal flavored release workflow.
