# Change log — Speed up duplicate detection & merge

Implements plan `plans/20260630_214230_speed-up-duplicates-merge.md`.

## Why
Opening the "Find Duplicates" screen and merging were slow. The dominant cost
was `findDuplicates()` fully hydrating every duplicate (8 queries per contact:
phones, emails, addresses, social links, groups, tags, official details,
relationships) while the screen only renders the name + first phone. The
detection query also lacked indexes for the phone self-join and the name branch.
Merging itself is one transaction (fast) but its post-merge reload re-paid the
hydration cost.

## What changed

### lib/repositories/contact_repository.dart
- Rewrote `findDuplicates()` to return slim summaries via the existing
  `_summarySelect` projection + `_summaryFromRow` mapper — a single query
  carrying name parts + primary phone (exactly what the screen renders), with no
  per-contact `_hydrate`. Detection logic (shared name OR shared phone number) is
  unchanged. Merge fidelity is unaffected: `mergeContacts` operates on ids at the
  DB level and re-points every child row regardless of what this read loads.

### lib/database/database_helper.dart
- Bumped schema version 6 → 7.
- Added two indexes (in `_createIndexes` and as a v6→v7 migration):
  - `idx_phone_numbers_number` on `phone_numbers(number)` — speeds the
    duplicate phone self-join (also helps `findContactIdByNormalizedPhone` and
    dialer match-as-you-type).
  - `idx_contacts_name` on `contacts(first_name, last_name)` — speeds the name
    duplicate branch.

### test/contact_sync_service_test.dart
- `findDuplicates` test: groups by shared name and by shared phone, excludes a
  loner, and confirms the slim summary still carries the primary phone.
- New merge test covering the asymmetric case (primary has only a phone, the
  duplicate has the email): the absorbed duplicate's child rows are re-pointed
  onto the primary — i.e. emails/addresses are preserved, not lost.

## Verification
- `flutter analyze` — no issues.
- `flutter test` — all 27 tests pass. (Device-plugin `MissingPluginException`
  lines on the host VM are the expected caught no-ops.)

## Notes
- Pure performance + correctness-coverage change; no UI changes and no change to
  which duplicates are detected or to merge semantics.
- Scalar fields on the `contacts` row (e.g. `middle_name`, `photo_path`) and
  `official_details` still follow "primary wins" on merge — unchanged, pre-
  existing behaviour. Smarter field-filling was deferred (would need its own plan).
