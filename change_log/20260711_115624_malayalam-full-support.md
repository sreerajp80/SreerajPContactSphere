# Handle Malayalam properly alongside English

Implements plan `plans/20260711_113732_malayalam-full-support.md`.

## What changed

Search already matched Malayalam names from English-script queries (via
`name_translit`). This change fixes the remaining places that assumed English:
avatar/section initials, list sort order, and adds grouped letter headers with
per-letter counts.

### New shared helpers — `lib/utils/malayalam_transliterator.dart`
- `initialFor(name)` — first **grapheme cluster** of a name, upper-cased (`'?'`
  when empty). Fixes broken half-glyph initials for Malayalam (a letter is several
  UTF-16 units, so the old `name[0]` sliced it).
- `sortRoman(name)` — a lighter romanized key than `searchKey` (no th→t /
  doubled-letter collapsing), used for sorting so Malayalam and English interleave
  in one A–Z order instead of Malayalam clumping after `z`.
- `sectionLetterFor(name)` — the A–Z bucket (or `#` for digits/symbols/empty),
  derived from `sortRoman`.
- Added `characters` as an explicit dependency in `pubspec.yaml`.

### Sorting — DB + repository
- `lib/database/database_helper.dart`: added `sort_first` / `sort_last` columns to
  the `contacts` table; bumped DB version 16 → **18** with a migration that adds the
  columns and backfills every row from its current name. The add/backfill runs
  through `ensureSortColumns()`, which checks the **actual** columns via PRAGMA
  instead of trusting the version number. This self-heals a DB that was
  version-bumped during development before the migration existed — that state left
  the columns permanently missing, so `getContactSummaries` (which now orders by
  `sort_first`) threw and the list showed empty even though contacts existed
  (the dialer, which doesn't use the sort key, still listed them).
- `lib/repositories/contact_repository.dart`: writes `sort_first` / `sort_last` on
  every `insertContact` / `updateContact`; orders `getContactSummaries`,
  `searchContactSummaries`, and `getAllContacts` by the sort keys. Added
  `getSectionCounts()` — one grouped `COUNT(*)` keyed off the same romanized key,
  so headers can show the full group size even though the list pages in.

### Letter grouping — UI
- `lib/services/contact_sync_service.dart`: added `sectionCounts(...)` wrapper.
- `lib/screens/contact_list_screen.dart`: loads section counts on refresh; inserts
  an alphabetical header row (letter + `(count)`) whenever the section letter
  changes, in the browse and favorites views (not in ranked search results).
  Headers group English and Malayalam together under the same Latin letter. Paging
  is unchanged — headers are built incrementally as pages load.

### Avatar initials — use `initialFor` everywhere
Replaced `name[0].toUpperCase()` initial logic in:
`contact_list_screen.dart`, `dialer_screen.dart`, `widgets/relationship_editor.dart`,
`call_history_screen.dart`, `contact_detail_screen.dart`, `in_call_screen.dart`,
`relationship_screen.dart`, `relation_status_screen.dart`.

## Tests
- `test/malayalam_transliterator_test.dart`: added cases for `sortRoman`,
  `initialFor`, and `sectionLetterFor` (21 tests pass).
- `flutter analyze`: no issues.
- `test/db_sort_columns_test.dart`: new regression test — a contacts table with no
  sort columns self-heals (columns added + backfilled, romanized) and the call is
  idempotent.
- Ran `backup_service_test`, `contact_sync_service_test`, `contact_stem_search_test`,
  `db_sort_columns_test` (sqlite-backed, one file per run) — all pass against the
  v18 schema.

## Notes
- This is a pragmatic romanized collation, not full Unicode Malayalam collation; it
  interleaves both scripts under one A–Z order, matching the "handle both together"
  goal.
- Existing databases upgrade in place via the v16→v17 migration; fresh installs
  create the columns directly and populate them on first insert.
