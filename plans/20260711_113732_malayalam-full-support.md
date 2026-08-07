# Handle Malayalam properly alongside English

**Status:** completed

## What the user asked for

"The app should handle Malayalam properly along with English." After scoping, the
user wants four things fixed:

1. **Avatar initials** — Malayalam names show broken glyphs.
2. **Sorting order** — Malayalam names should sort sensibly, not clumped after Z.
3. **Group by letter** — add alphabetical section headers (group contacts under
   their initial letter) that work for both scripts. No fast-scroll jump bar.
4. **Input/display review** — make sure Malayalam entry, editing, and display
   round-trip correctly everywhere.

Search already works: `lib/utils/malayalam_transliterator.dart` transliterates
Malayalam → "Manglish" and `searchKey()` normalizes both the stored `name_translit`
column and the query, so English-script search matches Malayalam names. We keep that
as-is and build on it.

## The issues (current behaviour)

### 1. Avatar initials break on Malayalam
Three call sites take `firstName[0]`:
- `lib/screens/contact_list_screen.dart:1257-1259`
- `lib/screens/dialer_screen.dart:718-719`
- `lib/widgets/relationship_editor.dart:321`

`firstName[0]` returns the first **UTF-16 code unit**, not the first letter. A
Malayalam letter is often several code units (base consonant + vowel sign / virama),
so `[0]` yields a partial, broken glyph. `.toUpperCase()` is a harmless no-op for
Malayalam.

### 2. Sorting is code-point based, not linguistic
`getContactSummaries` (`lib/repositories/contact_repository.dart:774-777`) orders by
`first_name COLLATE NOCASE ASC`. SQLite `NOCASE` only case-folds ASCII A–Z. Malayalam
code points (U+0D00+) all sort **after** every ASCII letter, so every Malayalam name
clumps at the bottom of the list and is ordered by raw code point, not by sound.

### 3. No letter grouping / section headers
`_buildList` (`lib/screens/contact_list_screen.dart:1097-1146`) is a flat, DB-paged
`ListView.builder`. Contacts are not grouped under letter headers, so there is no
visual "A / B / C …" structure in the list.

### 4. Input/display
Malayalam text entry works natively in Flutter `TextField`s, and `name_translit`
already regenerates on insert/update. This item is mostly verification plus any small
fixes the review turns up (e.g. other spots that index a string by `[0]`).

## The fix

### A. Shared romanized helpers (foundation for 1, 2, 3)
Add two small functions to `lib/utils/malayalam_transliterator.dart`:

- `String initialFor(String name)` — returns the first **grapheme cluster** of the
  name, uppercased, or `'?'` when empty. Uses `String.characters.first` (the
  `characters` package, already a transitive Flutter dependency; add it explicitly to
  `pubspec.yaml` under dependencies). This gives a correct single letter for both
  English and Malayalam (e.g. `അ`, not a broken half-glyph).

- `String sortRoman(String name)` — `transliterateMalayalam(name).toLowerCase().trim()`.
  This is a **lighter** key than `searchKey()` (no th→t / doubled-letter collapsing),
  so ordering stays closer to true spelling while still romanizing Malayalam. Latin
  names pass through unchanged, so English and Malayalam interleave under the same
  Latin alphabet (e.g. `അനു` → `anu` sorts next to `Anu`/`Ajay`).

### B. Avatar initials (item 1)
Replace the three `firstName[0].toUpperCase()` sites with `initialFor(contact.firstName)`.
Grep for any other `[0]`-on-name usage during the review and fix the same way.

Files: `lib/screens/contact_list_screen.dart`, `lib/screens/dialer_screen.dart`,
`lib/widgets/relationship_editor.dart`.

### C. Sorting (item 2)
Store romanized sort keys in the DB so paging + ordering stay in SQL:

- Add two columns to the `contacts` table: `sort_first TEXT`, `sort_last TEXT`
  (`lib/database/database_helper.dart`, schema near line 92 where `name_translit` is).
- Add a **v16 → v17 migration**: `ALTER TABLE contacts ADD COLUMN sort_first`,
  `ADD COLUMN sort_last`, then backfill every row (`sortRoman(first_name)` /
  `sortRoman(last_name)`), mirroring the existing `name_translit` backfill
  (`database_helper.dart:404-489`). Bump `_dbVersion` 16 → 17.
- Keep the keys current in `ContactRepository.insertContact` / `updateContact`
  (alongside the existing `_nameSearchKey` write, around lines 356 / 383).
- Change `getContactSummaries` ordering to
  `sort_first COLLATE NOCASE ASC, c.id ASC` (and the last-name variant to
  `sort_last …, sort_first …, c.id ASC`). NOCASE is still fine — the keys are already
  romanized ASCII where Malayalam was involved.

Note: this is a pragmatic romanized collation, not full Unicode Malayalam collation.
It interleaves English and Malayalam under one A–Z order, which matches the "handle
both together" goal. True Malayalam dictionary collation is out of scope.

### D. Group by letter, with section headers (item 3)
Add a letter header row above each group of contacts that share an initial letter.
This works **incrementally with the existing paging** — no load-all needed. Because
the DB returns rows already sorted by the romanized sort key, the screen just tracks
the last letter it rendered and inserts a header row whenever the letter changes.

- Section letter for a contact = `initialFor(sortRoman(firstName))` (uppercased first
  grapheme of the romanized name, so the header matches the sort order). Names whose
  initial is a digit or symbol group under `#`.
- In `_buildList` (`contact_list_screen.dart:1097-1146`), keep the paged
  `ListView.builder`; when building each row, compare the current contact's section
  letter to the previous contact's. If different, render a small sticky-style header
  row (`_buildSectionHeader`) before the contact card.
- **Per-letter count in the header** (e.g. `A (12)`). Because `sort_first` is already
  romanized ASCII, the section letter is just `substr(upper(sort_first), 1, 1)` in SQL,
  so add a `ContactRepository.getSectionCounts()` that runs one grouped
  `COUNT(*) … GROUP BY that letter` query and returns a `Map<String,int>`. The screen
  loads this map once (and on refresh) and shows the count next to each header. This
  stays accurate even though contacts load page by page. Digit/symbol names count under
  `#`; the count query and the row logic use the same `#` bucket. Applies to the full
  unfiltered list; the search/favorites views can skip counts (or omit headers).
- The pinned "Self" card stays above all sections; the favorites view can skip headers
  (few items) or reuse the same logic — decide during implementation.
- No jump bar / fast-scroll index (per user's choice). Paging (`_hasMore`, trailing
  spinner) is unchanged.

Files: `lib/screens/contact_list_screen.dart`.

### E. Input/display review (item 4)
- Verify add/edit contact screen accepts and saves Malayalam (native Flutter — expected
  to already work), and that `name_translit` + new sort keys regenerate on edit.
- Grep `lib/` for other `[0]` / `substring(0, 1)` name-initial patterns and fix.
- Confirm Malayalam renders in list, detail, and dialer (Android system font covers
  Malayalam; if a specific screen forces a font that lacks it, note it — no bundled
  font is planned unless the review finds a gap).

## Files to change

- `lib/utils/malayalam_transliterator.dart` — add `initialFor`, `sortRoman`.
- `pubspec.yaml` — add `characters` dependency (explicit).
- `lib/database/database_helper.dart` — `sort_first` / `sort_last` columns, v17
  migration + backfill, bump `_dbVersion`.
- `lib/repositories/contact_repository.dart` — write sort keys on insert/update;
  order `getContactSummaries` by them; add `getSectionCounts()` for the per-letter
  header counts.
- `lib/screens/contact_list_screen.dart` — `initialFor` for avatar; letter section
  headers in the paged list.
- `lib/screens/dialer_screen.dart` — `initialFor` for avatar.
- `lib/widgets/relationship_editor.dart` — `initialFor` for avatar.
- `test/malayalam_transliterator_test.dart` — add cases for `initialFor` / `sortRoman`.

## Resolved decisions

- **Group by letter, no jump bar** — confirmed by the user.
- **Keep paging** — grouping is done incrementally as pages load, so paging stays.

## Open decision (please confirm during approval)

1. **Headers under Latin letters** (English + Malayalam interleaved under one A–Z set
   of headers) — recommended and assumed above. Alternative: group Malayalam names
   under Malayalam letter headers separately. I recommend the single Latin set for
   simplicity and because it keeps both scripts together in one ordered list.

## Testing

- `flutter analyze`
- `flutter test test/malayalam_transliterator_test.dart` (run alone — sqlite test
  crash caveat does not apply to this pure-Dart file).
- Manual on-device: add a Malayalam-named contact, confirm correct avatar letter,
  correct sort position among English names, and that the A–Z bar jumps to it.
