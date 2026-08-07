# Merging duplicates must take effect on the phone too (and stop reappearing)

**Status:** completed

## The issue

Some contact sets can be merged from the Find-duplicates screen, yet they come
back as duplicates again after a sync — even after merging 3+ times on different
days. Other contacts merge cleanly and stay merged.

The affected sets all share **one phone number but have slightly different
names** (e.g. "Dr. [name-1]" vs "Dr [name-1]" — a stray full stop; or a short
nickname vs the same person's longer full name in Malayalam script).

### Root cause

Today a merge is **app-only**: `ContactRepository.mergeContacts` deletes the
duplicate rows from the app's own database but leaves all the duplicate contacts
in the **phone's** address book. On the next device→app sync those phone
contacts are read again. Because their names differ slightly from the surviving
contact, the sync's "heal wrong absorption" rule (meant to undo *automatic*
same-number merges of two different people) decides the merge was a mistake and
**re-creates the duplicate rows**. So the merge never sticks.

### What the user wants

A merge in the app must also merge the contacts **on the phone** — like every
other change. (Add/edit already writes through to the phone via
`saveContact`; delete already removes the phone contact via `deleteContact`.
Merge is the one mutation that does not propagate — this plan fixes that.)

## The fix

Make merge a two-sided operation and add an app-side safety net so a user merge
can never be silently undone.

### Part A — Merge propagates to the phone (the main fix)

Route the duplicates screen's merge through `ContactSyncService` instead of
calling the repository directly. The service will:

1. Look up the `device_id`s of the duplicate contacts **before** the merge
   deletes their rows.
2. Run the existing app-side merge (`_repo.mergeContacts`).
3. If the contacts permission is granted:
   - **Delete each duplicate contact from the phone** (skipping the survivor's
     own device contact). This removes the copies that were being re-imported.
   - **Update the survivor's phone contact** (`upsertDeviceContact`) so the
     phone reflects the merged fields, and store any new link back on the app
     row.
   - Secret / Self survivors keep their existing app-only rules (never pushed to
     the phone).

Deleting the phone copies is authoritative — if the contacts live in a Google
(or other) account, the deletion syncs up to that account, so they do not come
back from the cloud either.

### Part B — App-side safety net (so a user merge is never re-split)

Even with Part A, a device delete can fail (permission blip, or a copy the
account re-adds later). To guarantee a user's merge sticks, mark user merges as
confirmed and stop the name-based un-merge from touching them:

- Add a `user_confirmed` flag (INTEGER, default 0) to `merged_device_ids`.
- Automatic import-time merges keep it `0` (name-based healing still applies, so
  genuinely-different people who share a number still self-correct).
- A user merge writes `1`. The sync then treats those device contacts as true
  duplicates regardless of name: refresh in place, never re-create a row, and do
  not overwrite the survivor's name from a differently-named copy.

## Files to change

1. **`lib/screens/duplicates_screen.dart`**
   - `_mergeSet` / `_mergeAll`: call `ContactSyncService().mergeContacts(...)`
     instead of `_repository.mergeContacts(...)`.

2. **`lib/services/contact_sync_service.dart`**
   - Add `Future<void> mergeContacts(int primaryId, List<int> duplicateIds)`:
     capture the duplicates' `device_id`s, run `_repo.mergeContacts`, then delete
     the duplicate phone contacts and upsert the survivor to the phone (honouring
     secret/Self rules). No-op on the device side when permission is not granted
     — the app-side merge still happens.
   - In `_mergeDeviceContacts`: also load `confirmedMergedDeviceIds()`; heal only
     when `absorbed && !confirmed && !_sameName(...)`; for `absorbed && confirmed`
     treat as a true duplicate (keep the survivor's own link and name, no new
     row).

3. **`lib/repositories/contact_repository.dart`**
   - Add `Future<List<String>> deviceIdsForContacts(List<int> ids)` (the phone
     links to delete on merge).
   - `mergeContacts`: the `INSERT OR REPLACE INTO merged_device_ids` sets
     `user_confirmed = 1`.
   - `recordMergedDeviceId`: writes `user_confirmed = 0` (auto path, unchanged).
   - Add `Future<Set<String>> confirmedMergedDeviceIds()` (device_ids with
     `user_confirmed = 1`).

4. **`lib/database/database_helper.dart`**
   - Add `user_confirmed INTEGER NOT NULL DEFAULT 0` to the `merged_device_ids`
     CREATE TABLE.
   - Bump `version` 18 → 19 (both open sites).
   - Add a v18→19 `_onUpgrade` step adding the column, guarded by a
     `PRAGMA table_info(merged_device_ids)` existence check (self-heals a dev
     build that bumped the version but never ran the ALTER — a known gotcha in
     this project).

## Limitation (called out honestly)

Merges done **before** this fix left their `merged_device_ids` rows with
`user_confirmed = 0`, and the old duplicate phone contacts still exist. After the
update, merging each affected set **once more** will delete the phone copies and
mark the merge confirmed — after that they stay merged for good.

## Testing

- `flutter analyze` — no new errors.
- `flutter test test/contact_sync_service_test.dart` — existing tests pass; add
  a case: an absorbed device contact with `user_confirmed = 1` and a **different**
  name is refreshed in place (no new row), while `user_confirmed = 0` with a
  different name is still re-split.
- On device: merge one affected set → confirm the duplicate contacts are gone
  from the phone's contacts app, and do not reappear after a sync.
