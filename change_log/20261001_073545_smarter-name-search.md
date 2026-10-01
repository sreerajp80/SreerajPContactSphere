# Change log: Smarter name search (English ↔ Malayalam, similar names)

**Plan:** [plans/20261001_073545_smarter-name-search.md](../plans/20261001_073545_smarter-name-search.md)

## What changed

When you type English words in contact search, the results now include more names that
are close to what you typed, whether they are saved in English or in Malayalam.

### 1. Letter rules (`lib/utils/malayalam_transliterator.dart`)

The hidden English search key made from a Malayalam name now follows how people type:

- ന്റ → `nt` (ആന്റണി is found by "Antony"). The older ൻറ spelling is handled too.
- റ്റ → `tt` (മറ്റത്തിൽ is found by "Mattathil").
- ങ്ങ → `ng`.
- ൃ → `ri` (കൃഷ്ണൻ is found by "Krishnan").
- `f` and `ph` give the same key (ഫാത്തിമ is found by "Fathima").

The sound-only code (`phoneticCode`) uses the same conversion, so it gets these fixes too.

### 2. Spaces do not matter

New `compactKeyMatches`: the typed key and the name key are compared with spaces removed.
"sree raj" finds ശ്രീരാജ്, and "sreerajp" finds "Sreeraj P". It needs at least 3 letters.

### 3. Similar names

New `editDistance` and `similarNameDistance`. A name is "similar" when each typed word is
close to the start of some word in the name:

- Allowed mistakes: 0 for words up to 4 letters, 1 for 5–7 letters, 2 for 8 or more.
- The first letter must match.

For example, "Vijayam" finds വിജയൻ, and "Rmaesh" finds "Ramesh Kumar".

### 4. Search results order (`lib/repositories/contact_repository.dart`)

`searchContactSummaries` keeps its existing SQL search as the first group of results. A
new `_searchSimilarNames` step then adds contacts that match with spaces ignored, and
after them similar names, closest first. Secret contacts and the favourites filter work as
before. `nameMatches`, used by the in-memory contact pickers, uses the same new rules.

### 5. Docs

`docs/architecture.md`: a short section on how name search works and how results are ranked.

## Differences from the plan

- **No middle-of-word matching.** The plan said "raj" should find ശ്രീരാജ്. But this kind of
  match is what made "Ale" find "City Time Gallery", which an earlier change
  (`change_log/20260730_181113_search-malayalam-english-fixes.md`) fixed on purpose. So
  space-free matching still starts at the beginning of a word.
- **Stricter "similar" rules.** The plan allowed 1 mistake from 4 letters. With that, "Binu"
  found "Vinu", and an existing test forbids that. Now 1 mistake is allowed from 5 letters,
  and the first letter must match.
- **No database version bump.** The app already rebuilds out-of-date search keys when it
  opens (`_onOpen` → `staleContactSearchKeyCount` → `rebuildContactSearchKeys`). Saved
  contacts get the new keys the next time the app starts, so a v31 migration was not needed.
  The database stays at version 30.

## Tests

- `test/malayalam_transliterator_test.dart`: new groups for the letter rules,
  `editDistance`, `compactKeyMatches`, `similarNameDistance`, and `nameMatches`.
- `test/contact_search_malayalam_test.dart`: new repository tests (in-memory SQLite) for the
  letter rules, spaces, similar names ranked below the exact match, and short names
  staying apart.
- `flutter analyze`: no issues.
