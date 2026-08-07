# Fix: app did not show all phone contacts

Implements `plans/20260705_222030_missing-contacts-in-list.md`.

## What was wrong

Device contacts could go missing from the app's list four ways: (1) the sync
absorbed any device contact that shared a single phone number with an existing
contact, even when it was a different person; (2) contacts with no name were
dropped entirely; (3) a failed device fetch was treated as an empty book and
still marked the initial sync as done, so the app settled on a partial list;
(4) the list sort was case-sensitive and paging had no tiebreaker.

## Changes

### lib/services/contact_sync_service.dart
- `syncFromDevice` now absorbs a device contact into a number-match **only when
  the full name also matches** (case-insensitive, whitespace-collapsed).
  Different people sharing a number each get their own row.
- **Self-healing**: on every sync, links recorded in `merged_device_ids` are
  re-verified. A wrongly absorbed contact (shared number, different name) is
  unlinked and inserted as its own row, so installs affected by the old
  behavior recover on their next sync without a reinstall.
- A true absorbed duplicate no longer overwrites the host row's own
  `device_id` when refreshed (an old overwrite bug; a bogus self-link found in
  that state is cleared during healing).
- The device fetch failing (now `null`, see below) aborts the sync **without**
  marking the initial sync done, so the next launch retries the full pull.
- The merge loop was extracted into `syncDeviceContacts(List<Contact>)`
  (`@visibleForTesting`) so the DB-side rules are unit-testable.
- `mergedContacts` applies the same "same number AND same name" rule when
  hiding device-only entries in the first-run merged view.

### lib/services/device_contact_service.dart
- `fetchDeviceContacts` returns `List<Contact>?`: empty list = no permission /
  empty book, `null` = the fetch itself failed. Still never throws.
- `_toApp` no longer drops nameless contacts: it falls back to the first
  phone number, then the first email, as the display name (like the OS
  contacts app). Only a contact with no name, number, or email is skipped.
  This also benefits vCard/QR/BLE imports, which share `mapToApp`.

### lib/repositories/contact_repository.dart
- New `mergedDeviceIds()` (the absorbed-link set) and
  `removeMergedDeviceId(deviceId)` (the heal path's unlink).
- `getContactSummaries` and `searchContactSummaries` now order by
  `first_name COLLATE NOCASE, id` — lowercase/mixed-case names sort naturally
  and `LIMIT/OFFSET` paging is stable when first names repeat.

### Tests
- `test/contact_sync_service_test.dart`: five new tests — shared number with a
  different name stays a separate contact; same name + number is absorbed;
  a wrongly absorbed contact is healed; the initial-sync flag is set only by a
  completed sync; summaries sort case-insensitively. Added
  `SharedPreferences.setMockInitialValues` to the setup.
- `test/device_contact_service_test.dart` (new): nameless contact falls back
  to number, then email; a contact with nothing usable is dropped; named
  contacts keep their name.

## Verification

`flutter analyze`: no issues. `flutter test`: all 109 tests pass.
