# Fix: merged duplicate contact kept reappearing

Implements `plans/20260805_061744_stable_id_for_merged_duplicates.md`.

## What was wrong

The app remembered "this phone contact was already merged" using Android's
internal contact ID. That ID is not permanent — Android reassigns it when it
re-links/re-splits a contact's raw entries (confirmed on the user's device:
this contact is backed by a local raw contact plus a WhatsApp-synced raw
contact, last re-linked 5 days before the report). When that happened, the
app's memory of "already merged" no longer matched, its fallback name check
also failed on a punctuation difference ("Dr." vs "Dr"), and it silently
re-added the contact as new.

## What changed

- **New table `confirmed_merge_phones`** (`lib/database/database_helper.dart`,
  DB version 25 → 26): records the phone number(s) involved in a
  user-confirmed merge, mapped to the surviving contact. Created via the
  project's usual `IF NOT EXISTS` + `_onOpen` self-heal pattern, same as the
  other `_ensure*` tables.
- **`ContactRepository.mergeContacts`** now also writes every phone number on
  the merged group into `confirmed_merge_phones`, pointing at the primary.
- **`ContactRepository`**: added `confirmedMergePhones()` (bulk read of the
  new table), and `recordMergedDeviceId(..., confirmed: )` gained a
  `confirmed` flag so a phone-number match can be recorded as a trusted,
  user-confirmed link (not just an automatic one).
- **`ContactSyncService._mergeDeviceContacts`**: before falling through to
  "brand-new contact," an unlinked device contact is now checked against
  `confirmed_merge_phones` by phone number. A match links it straight to the
  already-merged contact — no name check needed, since the user already
  confirmed these are the same person. This is what stops the duplicate from
  reappearing after Android reassigns the device ID.
- **Loosened the name-matching fallback** (`_nameKey` in
  `contact_sync_service.dart`): periods and commas are stripped before
  comparing, so "Dr." vs "Dr" no longer defeats an otherwise-identical name
  match.
- **`ContactRepository.deviceIdsForContacts`**: now also picks up device IDs a
  duplicate had already absorbed via `merged_device_ids` (not just its own
  primary link), so a repeat merge cleans up every native copy on the phone
  instead of leaving older absorbed ones behind.
- **`SyncBundleService._allManagedTables`**: added `confirmed_merge_phones`
  next to `merged_device_ids` — it's the same kind of device-local
  bookkeeping and must be wiped (not restored) on a full restore.

## Verification

- Confirmed the root cause directly on the user's connected device via
  read-only `adb shell content query` against the Android contacts provider
  (no changes made): the contact is one Android aggregate built from a local
  raw contact and a WhatsApp raw contact, last re-linked 2026-07-31.
- Added a regression test in `test/contact_sync_service_test.dart`:
  `syncDeviceContacts does not resurrect a confirmed merge after Android
  reassigns the absorbed device id` — merges two contacts, then simulates a
  sync where the absorbed contact comes back under a brand-new device ID with
  a punctuation-different name; asserts it is recognised and not re-added.
- Ran `flutter test test/contact_sync_service_test.dart` (20 tests, all pass)
  and `flutter test test/audit_log_test.dart` (13 tests, all pass — also
  exercises merge).
- Ran `flutter analyze` on the whole project: no issues.

## Not changed

- Duplicate detection itself ("Same name & number" grouping) — unchanged and
  working correctly.
- WhatsApp's own contact-sync behavior — out of the app's control; this fix
  makes the app tolerate the re-linking WhatsApp's sync triggers, rather than
  trying to stop it.
