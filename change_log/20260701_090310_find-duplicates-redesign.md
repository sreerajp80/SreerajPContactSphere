# Find Duplicates — redesign to grouped duplicate sets

Implements `plans/20260701_090310_find-duplicates-redesign.md`.

## What changed

### `lib/repositories/contact_repository.dart`
- Added `findDuplicateGroups()` → `Future<List<List<Contact>>>`. It selects the same
  duplicate candidates as `findDuplicates()` (contacts sharing a first+last name, or a phone
  number) via `_summarySelect`, then groups them into **connected sets** with a union-find:
  candidates are linked by a normalized name key (`first_name`+`last_name`, trimmed/lower)
  and by any shared phone digits (all candidate phones loaded in one `IN (...)` query), so
  membership is transitive. Only sets of size ≥ 2 are returned; within each set the "keep"
  candidate is placed first (highest `relationship_score`, ties broken by lowest `id`), and
  sets are ordered by their first member's name.
- `findDuplicates()` and `mergeContacts()` are unchanged (the old flat method is still used
  by `test/contact_sync_service_test.dart`).

### `lib/screens/duplicates_screen.dart` (full rewrite)
- Rebuilt on the Add-contact token system: a local `_Tokens.of(context)` resolver reading
  `AppColors` + `ColorScheme` (accent / accent-soft / field / border / text / sub / gradient),
  so it renders on-brand in Calm (light) and Midnight (dark) with no hardcoded palette.
- Custom top bar (circular back button + "Find Duplicates" title + refresh circle button)
  replacing the old `AppBar`; styled loading spinner and a styled empty state.
- Duplicates now render as **per-set cards**. Each card shows a "Duplicate set" header with a
  count badge and one row per contact (gradient avatar with initials or photo, name, primary
  phone). Exactly one row is **starred = kept**; tapping another row's star moves "kept".
  Tapping a non-kept row toggles **include/exclude** (excluded rows dim and are labelled).
  A per-set **Merge set** button (enabled only when ≥ 1 other row is included) confirms, then
  calls `mergeContacts(keptId, includedOtherIds)` and reloads — so a merge only ever affects
  that one set, not the whole list.
- The `DuplicatesScreen` constructor is unchanged, so the launch site
  (`contact_list_screen.dart:360`) needs no edit.

## Design note
The first pass was built from the canvas's textual spec because the real
`FindDuplicatesScreen.dc.html` component was missing from `sample/`. The user then added that
file, so the screen was **reconciled to the actual component**. Changes made in that pass:
- Repository `findDuplicateGroups()` now returns `List<DuplicateSet>` (contacts + a `reason`)
  instead of `List<List<Contact>>`, and computes a per-set reason from the linking signals
  ("Same phone number" / "Same name" / "Same name & number") via `_reasonFor(...)`.
- Screen rebuilt to match the component exactly: a **summary banner** ("{n} duplicate sets
  found" + "Review each set — the starred contact is kept."), **per-set cards** with a reason
  header + "{n} contacts" badge, contact rows with a rounded-square avatar, a **KEEP** badge
  on the kept row, and a right-hand **selection control** (filled circle = kept, filled square
  tick = merging, empty square = excluded); a **set footer** with a "Keeping 1 · merging N"
  note and a compact **Merge** button; and a sticky **"Merge all sets"** bottom bar showing the
  running "{total} to merge". The rescan button spins on load (`AnimatedRotation`).
- Interaction now follows the component: the kept contact is **fixed** to the best candidate
  (the mockup's keep-change handler is a no-op); tapping a non-kept row toggles include/exclude.
  (The earlier reconstruction let you tap a star to move "kept"; that was dropped to match.)

## Follow-up: richer row detail line (no perf regression)
The mockup's row subtitle shows a phone label, an email fallback, and a field count. Added
these while keeping `findDuplicateGroups()` at a fixed handful of **bulk** queries over the
candidate set only (no per-contact hydration — the slow path the earlier speed-up removed):
- `DuplicateSet` now also carries `details` (`Map<int,String>`, contactId → subtitle).
- The existing candidate-phones query was extended (`number, label`, ordered
  `is_primary DESC, id ASC`) to also yield each contact's **primary phone + label**; two more
  single grouped/scan queries over the same candidate ids give the **primary email**
  (no-phone fallback) and the **total field count** (phones+emails+addresses+socials via one
  `UNION ALL` COUNT). Net +2 bulk queries, all O(candidates); `mergeContacts()` untouched.
- New `ContactRepository._detailFor(...)` composes the line: `"<number> · <label|no label>"`,
  or `"<email> · no phone"` when there's no phone, or `"No phone"`, then `"· N field(s)"`.
- The screen reads `set.detailFor(contact)` instead of deriving from `phoneNumbers`.

## Verification
- `flutter analyze lib/screens/duplicates_screen.dart lib/repositories/contact_repository.dart`
  → No issues found.
- `flutter test test/contact_sync_service_test.dart` → all 11 tests pass (incl. the
  `findDuplicates` grouping test, unaffected).
