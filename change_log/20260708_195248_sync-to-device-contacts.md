# Change log: Sync to device contacts

Implements plan
[plans/20260708_194503_sync-to-device-contacts.md](../plans/20260708_194503_sync-to-device-contacts.md).

## What changed

Added a second sync action under **Settings → Contacts** so the two directions
are clear and both are available:

1. **Sync from device contacts** (renamed) — was "Sync device contacts". Wording
   only; it still pulls the phone's address book into the app.
2. **Sync to device contacts** (new) — pushes the app's contacts into the
   phone's device (local) contacts. A device contact that matches an app contact
   by phone number (checked first) or by full name is **overwritten** instead of
   duplicated. Secret and Self contacts stay app-only and are not pushed.

## Files changed

- `lib/services/contact_sync_service.dart`
  - Added `SyncToDeviceResult` (created / updated / total counts).
  - Added `syncToDevice({onProgress})`: loads non-secret, non-self app contacts;
    reads the device book once and builds phone→id and name→id conflict indexes;
    for each app contact overwrites the linked/matched device contact (via the
    existing `DeviceContactService.upsertDeviceContact`) or creates a new one,
    then stores the resulting `device_id` back on the app row. Reports progress
    and returns the created/updated counts. No-op (zeros) without permission.
  - Added the private `_matchDeviceId` helper (phone-then-name conflict lookup).

- `lib/screens/contacts_settings_screen.dart`
  - Renamed the existing card title to "Sync from device contacts".
  - Added `_SyncToDeviceCard` (stateful) below it: prompts for the contacts
    permission, shows a live "x of y" spinner while pushing, and reports the
    result in a snackbar. Uses `Icons.upload_outlined` to distinguish it from the
    pull card's `Icons.sync_outlined`.

- `test/contact_sync_service_test.dart`
  - Added a host-side test: `syncToDevice` is a no-op without device permission
    (returns zero counts and leaves app rows unchanged/unlinked).

## Verification

- `flutter analyze` on the three touched files: no issues.
- `flutter test test/contact_sync_service_test.dart`: all 18 tests pass.
- The name/phone conflict overwrite and the real device writes are platform-bound
  (inert on the host VM) and are to be verified manually on a device, consistent
  with how the pull path is tested.

## Notes / out of scope

- This is a push, not a full mirror: app contacts deleted in the app are not
  removed from the device.
- Conflict rule as approved: phone-number match wins; if no number matches, a
  full-name match also counts as a conflict.
