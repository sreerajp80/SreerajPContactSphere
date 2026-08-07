# Change log — Progressive contact loading + auto-merge duplicates

Implements plan `plans/20260630_212141_progressive-load-and-dedup.md`.

## Why
Loading ~564 device contacts was slow and blocked behind a spinner, and the list
showed many duplicates (device address book holds duplicate entries from
multi-account sync). Goal: fast, progressive loading and automatic de-duplication.

## What changed

### lib/database/database_helper.dart
- Bumped schema to **v6**.
- Added a `merged_device_ids(device_id PRIMARY KEY, contact_id)` table (+ FK
  index) recording every device `device_id` absorbed by the auto-merge dedup, so
  absorbed device contacts are recognised on future syncs instead of being
  re-imported. Added a v5→v6 migration and wired the table into `_onCreate`.

### lib/repositories/contact_repository.dart
- `getContactSummaries({includeSecret, limit, offset})` — a slim, paged read for
  the list (name parts, photo, score, device link, primary phone, first group)
  via correlated subqueries, skipping full child-table hydration. Shared
  `_summarySelect` projection + `_summaryFromRow` mapper.
- `searchContactSummaries(query, …)` — DB-backed slim search across name, any
  phone (digit-normalized), and any email, so search covers the whole book, not
  just loaded pages.
- `countContacts` and `averageRelationshipScore` — aggregates for the paged
  list's total count and health-hero average (exact regardless of paging).
- `deviceIdLinks()` and `phoneIndexNonSecret()` — one-query precomputed maps for
  the batched sync (device_id→id; normalized-phone→id, excluding secret rows).
- `findContactIdByNormalizedPhone(number, {excludeId})` and
  `recordMergedDeviceId(contactId, deviceId)` — the dedup primitives.
- `getContactByDeviceId` now also resolves via `merged_device_ids`.
- `mergeContacts` now preserves the duplicates' device links into
  `merged_device_ids` (re-pointing existing rows + capturing each dup's own
  `device_id`) before deleting them, so a merge survives the next sync.

### lib/services/device_contact_service.dart
- `fetchDeviceContacts({fullDetail = false})` — the default light fetch pulls
  only name/phone/email (`_lightProperties`), **no photos**, and skips the
  per-contact photo disk write (`_toApp(..., persistPhoto: false)`). `fullDetail`
  pulls `ContactProperties.all` + persists photos, used only by the background DB
  sync. This removes the dominant cost (full-res photos for all contacts +
  hundreds of synchronous file writes) from the display path.

### lib/services/contact_sync_service.dart
- Added `localSummaries`, `searchSummaries`, `contactCount`, `averageScore`
  delegates to the repository.
- `mergedContacts` now de-duplicates device-only entries by normalized phone (in
  addition to `device_id`), seeded from the app rows' numbers, so a device copy
  of an existing contact is suppressed.
- `syncFromDevice` rewritten: fetches full detail once; precomputes the
  device-link and phone-index maps (removing ~2 lookups per contact); for an
  unlinked device contact whose number matches an existing non-secret contact it
  **auto-merges** (records the device link) instead of inserting a duplicate;
  otherwise inserts. Added `_firstPhoneMatch` helper.

### lib/screens/contact_list_screen.dart
- Paged list: `ScrollController` + `_pageSize` (80); first page paints
  immediately, further pages append near the list end (`_loadMore`), with a
  trailing spinner while more remain (`_hasMore`).
- First-ever run now shows the device book quickly (light, no photos) via
  `_firstRunQuickShow`, then syncs in the background and refreshes from the
  de-duplicated store — no more blocking spinner on first run.
- `_backgroundSync` no longer does a second device fetch; it syncs then re-reads
  locally.
- Search is now DB-backed (`_runSearch` → `searchSummaries`) so it matches the
  whole book; `_applyFilter` removed.
- Health hero count/average now use the `_total` / `_avgScore` aggregates so they
  stay correct under paging.

### test/contact_sync_service_test.dart
- Added coverage for paged summaries + primary-phone selection, DB-backed search
  (name/phone/email), merge preserving device links (no re-import), and
  `findContactIdByNormalizedPhone`.

## Verification
- `flutter analyze` — no issues.
- `flutter test` — all 25 tests pass. (Device-plugin `MissingPluginException`
  lines on the host VM are the expected caught no-ops.)

## Notes / follow-ups
- Auto-merge keys on normalized phone (conservative). Contacts with no phone are
  not auto-merged by name; two entries with the same name but different numbers
  stay separate by design.
- Lazy photos: device-only contacts on first run show a letter avatar until the
  background sync persists their photo, after which a refresh fills them in.
- Background sync still writes per contact (its own transaction each). This is off
  the critical path; folding the writes into one transaction is a possible future
  optimization.
