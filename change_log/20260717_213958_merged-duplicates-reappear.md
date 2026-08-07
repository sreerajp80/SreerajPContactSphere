# Change log — merging duplicates now applies to the phone and stops reappearing

Implements plan
[plans/20260717_205448_merged-duplicates-reappear.md](../plans/20260717_205448_merged-duplicates-reappear.md).

## Problem

Duplicate contact sets that shared one phone number but had slightly different
names (e.g. "Dr. [name]" vs "Dr [name]" — a stray full stop) kept coming back after
merging, even after several merges on different days. A merge was app-only: it
deleted the duplicate rows from the app DB but left the duplicate contacts in the
phone book. The next device→app sync re-read them, and its name-based "heal wrong
absorption" rule (meant to undo *automatic* same-number merges of different
people) re-created the duplicates because the names differed.

## What changed

### 1. Merge now propagates to the phone book

- `lib/screens/duplicates_screen.dart`: the Find-duplicates screen now calls
  `ContactSyncService.mergeContacts(...)` (instead of
  `ContactRepository.mergeContacts(...)`) for both single-set and merge-all.
- `lib/services/contact_sync_service.dart`: new
  `mergeContacts(primaryId, duplicateIds)` — captures the duplicates' device
  links, runs the app-side merge, then (when the contacts permission is granted)
  deletes each duplicate's device contact from the phone and writes the survivor
  back so the phone reflects the merged fields. Secret / Self survivors stay
  app-only. Device work is best-effort; the app-side merge always happens.

### 2. App-side safety net so a user merge is never re-split

- `lib/database/database_helper.dart`: added `user_confirmed INTEGER NOT NULL
  DEFAULT 0` to `merged_device_ids`; bumped DB version 18 → 19; added a v18→19
  migration (`_ensureMergedConfirmedColumn`) guarded by a `PRAGMA table_info`
  existence check so it self-heals a dev DB that was version-bumped early.
- `lib/repositories/contact_repository.dart`:
  - `mergeContacts` records absorbed device ids with `user_confirmed = 1` (and
    promotes any re-pointed merge rows to confirmed).
  - `recordMergedDeviceId` (the automatic path) writes `user_confirmed = 0`.
  - Added `confirmedMergedDeviceIds()` and `deviceIdsForContacts(ids)`.
- `lib/services/contact_sync_service.dart`: `_mergeDeviceContacts` loads the
  confirmed set and only heals (re-splits) when `absorbed && !confirmed &&
  !sameName`. A confirmed duplicate is kept in place with the survivor's own
  name/link untouched (skips the field refresh, so the kept name no longer flips
  on each sync).

## Tests

- `flutter analyze` on the four changed files: no issues.
- `flutter test test/contact_sync_service_test.dart`: all pass, including a new
  case — a user-confirmed absorbed device contact with a different name is
  refreshed in place (no new row) and the kept name is preserved, while the
  existing "heal a wrongly absorbed device contact" (automatic, unconfirmed) case
  still re-splits.

## Follow-up fix (device merge error: "no such column: user_confirmed")

On-device testing hit `DatabaseException(no such column: user_confirmed)`. Two
causes, both fixed:

1. The DB version bump (18 → 19) had only been applied to the plaintext open
   path; the **encrypted (SQLCipher)** path — the one Android actually uses —
   still opened at version 18, so the v18→19 migration never ran. Set the
   encrypted open to version 19 as well.
2. Hardening for the project's known "dev version-bump before migration" gotcha:
   added an `onOpen` hook (`_onOpen`) that self-heals the `user_confirmed` column
   via a PRAGMA existence check on every open. This runs one lightweight
   `PRAGMA table_info` per open and only performs the `ALTER TABLE` if the column
   is genuinely missing — so it is not a full migration each time.

## Note for the user

Sets merged **before** this update still have their old phone copies and their
`merged_device_ids` rows marked unconfirmed. Merge each affected set **once more**
after installing this build: that deletes the phone copies and marks the merge
confirmed, after which they stay merged for good.
