# Find Duplicates — redesign to grouped duplicate sets

**Status:** completed

## Context / what the design asks for

The new design lives in `sample/Duplicates Canvas.dc.html`. That canvas frames two phone
mockups (light + dark) but the actual screen is a `dc-import name="FindDuplicatesScreen"`
component that resolves to `./FindDuplicatesScreen.dc.html` at render time. **That component
file was not included in the `sample/` folder** — only the canvas wrapper and `support.js`
runtime are present. So there is no pixel-level HTML to port line-for-line the way
`add_edit_contact_screen.dart` was ported from `AddContactScreen.dc.html`.

What the canvas *does* specify (its on-canvas copy is an explicit functional + visual spec):

- **Title/subtitle:** "Find Duplicates" · "Grouped into duplicate sets · starred contact is
  kept · tap a row to include/exclude it from the merge · tap Merge to resolve a set."
- **Behavior:** duplicates are shown as **sets** (not one flat list). Within a set one
  contact is **starred = the one that is kept**; every other row can be **included/excluded**
  from the merge by tapping it; a **Merge** button **resolves that one set**.
- **Look:** "Matches the Add-contact screen: same Plus Jakarta type, token system, teal
  (light) / periwinkle (dark) accents, rounded cards." i.e. reuse the exact `_Tokens` design
  language already established in `add_edit_contact_screen.dart` (custom top bar, accent-dot
  section headers, rounded field/card surfaces, accent-soft chips, square icon buttons,
  gradient avatars) driven by the `AppColors` theme extension — no hardcoded palette.

I will implement to this spec, matching the existing Add-contact token system for the visuals.
(If you later drop the real `FindDuplicatesScreen.dc.html` into `sample/`, I can reconcile any
pixel differences.)

## Current behavior (what changes)

- `lib/screens/duplicates_screen.dart` is a plain `Scaffold` + `AppBar` + flat
  `CheckboxListTile` list with a single global "Merge" FAB. First-picked contact is kept;
  merging is across the whole flat list, so contacts from unrelated duplicate sets can be
  merged together by mistake.
- `ContactRepository.findDuplicates()` returns a flat `List<Contact>` of every contact that
  has *a* duplicate, with no grouping.

## Files to change

1. **`lib/repositories/contact_repository.dart`** — add `findDuplicateGroups()` returning
   `List<List<Contact>>` (each inner list = one duplicate set, size ≥ 2). Implementation:
   - Reuse the existing candidate condition (contacts sharing first+last name, or a phone
     number) to select candidate rows via `_summarySelect` (gives id, name parts, photo,
     score, primary phone).
   - Also load `(contact_id, number)` for all phones of those candidates.
   - **Union-find** the candidates into connected sets by two signals: same normalized
     name key (`first_name`+`last_name`, lower/trimmed) and any shared normalized phone
     digits. Emit only components of size ≥ 2, each sorted (kept-candidate first: highest
     `relationship_score`, tie-break lowest `id`), groups ordered by first member's name.
   - Keep the old `findDuplicates()` for now (still referenced by tests / other callers) —
     verify with a grep; remove only if unused. `mergeContacts()` is unchanged.

2. **`lib/screens/duplicates_screen.dart`** — full rewrite to the new design:
   - Add a private `_Tokens` resolver (same shape/source as the Add-contact screen: read
     `AppColors` + `ColorScheme`, derive accent/soft/field/border/text/sub/gradient). Kept
     local to the file to mirror the existing per-screen token pattern.
   - Custom top bar: circular back button + "Find Duplicates" title + a refresh circle
     button (replaces the AppBar action), matching `_circleIconButton`.
   - Intro subtitle line with the design's helper copy.
   - Body states: styled loading spinner, styled empty state ("No duplicates found"), and
     the set list.
   - **Per-set card** (rounded, `field`/`fieldBorder` surface): a header row
     ("Duplicate set" + a count badge), then one row per contact:
     - gradient avatar (or photo) with initials, name, primary phone / "No phone";
     - a **star** toggle marking the kept contact (exactly one per set; tapping another
       row's star moves "kept" there);
     - tapping the row body toggles **include/exclude** for the merge (excluded rows dimmed;
       the kept row is always included and cannot be excluded);
     - a per-set **Merge** button (accent-filled, `_squareButton`/pill style) enabled only
       when ≥ 1 non-kept row is included; shows the existing confirm dialog, then calls
       `mergeContacts(keptId, includedOtherIds)` and reloads.
   - State is held per set (which id is kept, which ids are excluded), keyed by contact id so
     it survives a rebuild within a load.

## Out of scope / non-goals

- No DB schema changes; `mergeContacts()` transaction logic is untouched.
- No change to how the screen is launched (`contact_list_screen.dart:360` still does
  `const DuplicatesScreen()` — constructor signature is preserved).

## Verification

- `flutter analyze` clean for the two changed files.
- Manual: open Find Duplicates from the contact list; confirm sets render, star moves the
  kept contact, row tap toggles include/exclude, per-set Merge merges only that set and the
  list refreshes; empty state shows when none remain.

## Change log

On completion, write `change_log/<ts>_find-duplicates-redesign.md` referencing this plan.
