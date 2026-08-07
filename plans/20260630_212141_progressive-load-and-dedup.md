# Progressive contact loading + auto-merge duplicates

**Status:** completed

## Problem

Loading the device address book (≈564 contacts) into the list is slow, nothing
appears until it's all done, and most contacts show up duplicated.

### Why it's slow (root causes, with refs)
1. **Everything-at-once fetch incl. full photos.**
   `DeviceContactService.fetchDeviceContacts()` calls
   `getAll(properties: ContactProperties.all)` — every field *plus full-size
   photo bytes* for all contacts over the platform channel in one shot
   ([device_contact_service.dart:58-74](../lib/services/device_contact_service.dart#L58-L74)).
2. **A disk write per contact while building the list.** `_toApp` awaits
   `_persistPhoto`, writing a JPEG per photo'd contact
   ([device_contact_service.dart:370](../lib/services/device_contact_service.dart#L370)).
3. **~564 × several DB round-trips in sync.** `syncFromDevice` loops contacts
   doing a `getContactByDeviceId` query + an insert/update, each in its own
   transaction ([contact_sync_service.dart:114-138](../lib/services/contact_sync_service.dart#L114-L138)).
4. **The work is done twice per launch.** `_backgroundSync` calls
   `syncFromDevice()` (full device fetch + photo writes) **and then**
   `mergedContacts(fetchDevice: true)` (another full device fetch + photo writes)
   ([contact_list_screen.dart:104-128](../lib/screens/contact_list_screen.dart#L104-L128)).
5. **Heavy local read.** `getAllContacts` hydrates all 8 child tables per contact
   even though the list card only needs name, primary phone, photo, score
   ([contact_repository.dart:245-259](../lib/repositories/contact_repository.dart#L245-L259)).

### Why duplicates
`device_id` is persisted + indexed and re-imports link by it, so the pipeline
doesn't multiply a contact. The exact dupes (same name **and** number, both
real app rows) come from **the device book holding duplicate entries** (contacts
synced under multiple accounts that Android never auto-linked). Each distinct
device contact has its own id → its own app row. The existing "Find Duplicates"
merge is manual and not applied on import.

## Chosen approach (confirmed with user)
- **Loading:** "Both" — slim names-first render + paged DB reads + lazy photos.
- **Duplicates:** auto-merge on import (by normalized phone, falling back to name
  only when there is no phone), durably, so absorbed device contacts don't
  re-import on the next sync.

## Files to change
1. **lib/database/database_helper.dart** — DB **v6**: add a `merged_device_ids`
   table `(contact_id INTEGER, device_id TEXT)` + indexes, and a v5→v6 migration.
   This records every device_id absorbed into a contact so auto-merge survives
   future syncs.
2. **lib/repositories/contact_repository.dart**
   - Add `getContactSummaries({includeSecret, limit, offset})`: one slim query
     returning only id, name parts, photo_path, relationship_score, device_id,
     the primary phone (correlated subquery), and first group name — no per-row
     child-table hydration. Returns lightweight `Contact`s for the list.
   - Add `countContacts({includeSecret})` for paging.
   - Add `findContactIdByNormalizedPhone(String number, {excludeId})` to detect a
     dup against existing rows (digit-normalized LIKE, reusing `normalizeDigits`).
   - Add `recordMergedDeviceId(contactId, deviceId)` and make
     `getContactByDeviceId` also consult `merged_device_ids`.
   - Make `mergeContacts` move the duplicates' `device_id`s into
     `merged_device_ids` (pointing at the primary) before deleting the dup rows,
     so they won't be re-imported.
3. **lib/services/device_contact_service.dart**
   - Add `withPhotos` (default false) to `fetchDeviceContacts`/`_toApp`; skip the
     `getAll` photo payload and the per-contact `_persistPhoto` on the fast path.
   - Add `persistPhotoFor(Contact)` to fetch+persist a single contact's photo on
     demand (used by the background pass / lazy photo loader).
4. **lib/services/contact_sync_service.dart**
   - `mergedContacts`: fetch device contacts **without photos** (fast path).
   - `syncFromDevice`: (a) load existing device_id→row links in **one** query;
     (b) for each device contact not already linked, auto-merge into an existing
     contact when its normalized phone matches (record the device_id in
     `merged_device_ids`) instead of inserting a duplicate; otherwise insert;
     (c) wrap the writes in a **single transaction** (or bounded chunks);
     (d) persist photos in this background pass, off the critical path.
5. **lib/screens/contact_list_screen.dart**
   - First paint: load page 1 of `getContactSummaries` (e.g. 60 rows) and render
     immediately; append further pages after first frame / on scroll
     (ScrollController near-end trigger).
   - Replace the full-hydration read with the slim summaries for the list; detail
     screen still does the full `getContactById` load on open (unchanged).
   - `_backgroundSync`: call `syncFromDevice()` once, then a **local-only**
     (`fetchDevice: false`) refresh — removing the second device scan.
   - Lazy photos: cards read `photoPath` if present (filled in by the background
     sync); no disk work on the render path.
6. **test/contact_sync_service_test.dart** (+ possibly a new repo test) — update
   for batched sync, auto-merge-on-import, and `merged_device_ids` skip-on-reimport.

## Behavioural notes / trade-offs
- Auto-merge keys on **normalized phone** (strong signal; matches the screenshot
  case). Name-only is used only when a contact has no phone, to avoid collapsing
  distinct people who share a name. This is conservative by design.
- Device-only contacts on the very first run show a letter avatar until the
  background sync persists their photo, then a silent refresh fills them in.
- No change to the secret-contact rules or the two-way save/delete semantics.

## Out of scope
- Reworking detail-screen hydration, the dialer, or the relationship sphere.
- Scheduling/notifications, QR/BLE, and other known-gaps items.

## Validation
- `flutter analyze` clean; `flutter test` green (including updated sync tests).
- Manual: cold start shows the list near-instantly and fills in; duplicates from
  the device collapse to single rows and stay collapsed across relaunches.
