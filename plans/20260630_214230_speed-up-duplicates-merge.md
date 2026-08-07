# Speed up duplicate detection & merge

**Status:** completed

## Issue

Opening the "Find Duplicates" screen and merging are slow.

Root causes (in `lib/repositories/contact_repository.dart`):

1. **`findDuplicates()` fully hydrates every duplicate (dominant cost).**
   After the SQL returns the duplicate rows, it calls `_hydrate(...)` on each
   one. `_hydrate` fires **8 separate queries per contact** (phones, emails,
   addresses, social links, groups, tags, official details, relationships). With
   a few hundred duplicates that is well over a thousand round-trips — yet
   `duplicates_screen.dart` only renders `c.fullName` and the **first phone
   number**. All the child-table loading is wasted work.

2. **The detection query has no supporting indexes.**
   - The name branch (`c2.first_name = c1.first_name AND IFNULL(c2.last_name…)`)
     scans `contacts` for every contact → ~O(n²).
   - The phone branch (`phone_numbers p1 JOIN p2 ON p1.number = p2.number`) has
     **no index on `phone_numbers.number`**, so it self-joins via full scans.

3. **Post-merge reload re-pays cost #1.** `mergeContacts` itself is one small
   transaction (fast), but `duplicates_screen._mergeSelected` then calls
   `_load()`, which re-runs the slow `findDuplicates`. Fixing #1 fixes this too.

## Fix

1. **Make `findDuplicates()` return slim summaries (no per-row hydration).**
   Reuse the existing `_summarySelect` projection + `_summaryFromRow` mapper
   (already used by the paged list) so each duplicate carries name parts + the
   primary phone in a **single query** — exactly what the screen displays. Wrap
   the existing EXISTS conditions in a `WHERE` against `_summarySelect`. This
   removes the 8-queries-per-contact cost entirely.

2. **Add indexes the detection query can use** (in `database_helper.dart`):
   - `idx_phone_numbers_number` on `phone_numbers(number)` — speeds the phone
     self-join (and helps `findContactIdByNormalizedPhone` / dialer matching).
   - `idx_contacts_name` on `contacts(first_name, last_name)` — speeds the name
     duplicate branch.
   Add to the `_onCreate` index list **and** as a v6→v7 migration so existing
   installs get them. Bump schema version 6 → 7.

3. No change needed to `mergeContacts` logic — it already runs in one
   transaction. It benefits automatically from the faster reload via #1.

## Files to change

- `lib/repositories/contact_repository.dart`
  - Rewrite `findDuplicates()` to select via `_summarySelect` + `_summaryFromRow`
    (slim, single query, no `_hydrate`).
- `lib/database/database_helper.dart`
  - Add the two indexes to the `_onCreate` index list.
  - Bump `_version` 6 → 7 and add a v6→v7 migration creating the two indexes.
- `test/contact_sync_service_test.dart`
  - Add/adjust a test asserting `findDuplicates` still groups by shared
    name/phone and returns the primary phone in the summary.

## Verification

- `flutter analyze` — no new issues.
- `flutter test` — all tests pass.
- Manual: open Find Duplicates on a large book; confirm it lists the same
  duplicates noticeably faster, and merge + auto-reload is snappy.

## Notes

- Behaviour is unchanged: same duplicates detected, same merge semantics. This
  is purely a performance change (fewer queries + indexes).
- `_summaryFromRow` already returns name parts and the primary phone, which is
  all `duplicates_screen.dart` reads, so no UI change is required.
