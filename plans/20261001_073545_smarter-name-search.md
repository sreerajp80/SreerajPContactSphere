# Smarter name search (English ↔ Malayalam, similar names)

**Status:** in_progress

## The issue

The user types English words in search. The results should include contacts
whose names are **similar** to what was typed, whether the name was saved in
English or in Malayalam.

The app already does part of this. When a contact is saved, it stores two hidden
keys made from the name:

- `name_translit`: the name turned into simple English letters, with common
  spelling differences removed (for example ശ്രീരാജ് → `sriraj`).
- `name_phonetic`: a "sound only" code with the vowels removed (`Michael` and
  മൈക്കിൾ → `mkl`).

Search (`searchContactSummaries`) matches the typed text against these keys.
Reading the code shows these gaps:

1. **Some Malayalam letters turn into letters people do not type.**
   - ന്റ becomes `nr`, but people type `nt` (ആന്റണി → "anrani", typed "Antony").
   - റ്റ becomes `r`, but people type `tt` (മറ്റത്തിൽ, typed "Mattathil").
   - ൃ becomes `ru`, but people type `ri` (കൃഷ്ണൻ, typed "Krishnan").
   - ങ്ങ becomes `ngng`, but people type `ng`.
   - ഫ becomes `p`, but people type `f` ("Fathima" against ഫാത്തിമ).
2. **Spaces matter.** "sree raj" does not find ശ്രീരാജ്, and "sreerajp" does not
   find "Sreeraj P".
3. **Only the start of a word matches** a Malayalam name. "raj" finds "Sreeraj"
   when it is saved in English (plain text match), but not when it is saved as
   ശ്രീരാജ്.
4. **No "similar name" matching.** A small typing slip or a different spelling
   ("Sureesh" for "Suresh", "Rajeev" for "Rajiv", "Muhammed" for "Mohammed") finds
   nothing unless the sound code happens to match.

## Files to change

- `lib/utils/malayalam_transliterator.dart`: fix the letter rules (gap 1). Add a
  small "similar name" helper (edit distance, see below). Update `nameMatches` so
  the in-memory pickers behave the same as the main search.
- `lib/repositories/contact_repository.dart`: in `searchContactSummaries`, add
  space-free and middle-of-word matching (gaps 2, 3). Add a second "similar
  names" pass (gap 4). Put the closest matches first.
- `lib/database/database_helper.dart`: DB version 30 → 31. The migration calls the
  existing `rebuildContactSearchKeys`, so every saved contact gets new keys made
  with the fixed rules. No new columns or tables.
- `test/malayalam_transliterator_test.dart`, `test/name_search_key_test.dart`:
  new cases for the letter fixes and the similarity helper. Update any old
  expected values that change on purpose (for example ൃ → `ri`).
- `test/contact_search_malayalam_test.dart`: new repository tests (in-memory
  SQLite) for spaces, middle-of-word, and similar-name results.
- `test/db_search_index_test.dart`: check that the v31 migration rebuilds the keys.
- `docs/architecture.md`: a short note on how search ranks exact and similar
  matches.

## The fix

### 1. Better letter rules (`transliterateMalayalam` / `searchKey`)

- ന + ് + റ → `nt`. റ + ് + റ → `tt`. ങ + ് + ങ → `ng`.
- ൃ → `ri`.
- In `searchKey` only: `f` → `p`, so `f`, `ph` and ഫ all give the same key.
- The `name_phonetic` sound code uses the same transliteration, so it gets these
  fixes too.

### 2. Space-free and middle-of-word matching (SQL)

Remove spaces from the typed key. When it is at least 3 letters long, also match
`REPLACE(c.name_translit, ' ', '') LIKE '%key%'`. Then "sree raj", "sreerajp" and
"raj" all find ശ്രീരാജ് / "Sreeraj P". Shorter queries (1–2 letters) keep today's
start-of-word rule, so typing "a" does not list everyone.

### 3. "Similar names" pass (in Dart)

SQLite cannot measure how alike two words are, so this step runs in Dart:

- Read only `id` and `name_translit` for every visible contact. This is cheap,
  even for a few thousand contacts.
- For each word the user typed, compare it with each word of the name using
  **edit distance** (how many letters must be added, removed, changed or swapped
  to turn one word into the other). Compare against the start of the name word
  of the same length, so a half-typed name still works.
- Allowed mistakes: 0 for words of 1–3 letters, 1 for 4–6 letters, 2 for 7 or
  more letters. Every typed word must match some word in the name.
- Load the full rows for the contacts found, using the same summary query.

Secret contacts and the "favourites only" filter work the same way as today.

### 4. Order of results

1. Exact and start-of-word matches (today's results), in today's order.
2. Then middle-of-word and space-free matches.
3. Then similar-name matches, closest first (fewest mistakes).

So the old good results stay at the top, and the new "similar" results come
below them. The "Self" contact stays pinned at the top as today.

### 5. Existing contacts

The v31 migration rebuilds both search keys for every contact once, using the
existing idempotent `rebuildContactSearchKeys` ("idempotent" means running it
twice changes nothing more). The work is a single batch inside the migration.

### Not changing

- No new contact field, and no change to how names are shown.
- Phone number, email, tag and formal-name search stay as they are.
- The dialer T9 search and the voice "stem" search are not touched.

## Checks

- `dart format .`, `flutter analyze` (zero warnings).
- Run the changed sqlite-backed test files one file per `flutter test` call
  (known native-assets crash when they run together), then the pure-logic tests.
