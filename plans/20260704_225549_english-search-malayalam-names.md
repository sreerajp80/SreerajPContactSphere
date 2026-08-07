# English search matching Malayalam contact names

**Status:** completed

## Issue

Contact search ([contact_repository.dart:721](../lib/repositories/contact_repository.dart) →
`searchContactSummaries`) is a plain SQL `LIKE` over the stored name text. A contact saved with a
Malayalam-script name (e.g. `രമേഷ്`) can therefore never be found by typing its English/Latin
spelling (`ramesh`). The user wants: typing English in the search box should surface the matching
Malayalam-named contacts.

## Approach

Store a **romanized "search key"** alongside each contact's name and match the query against it:

- A new pure-Dart transliterator converts Malayalam script → practical "Manglish" Latin
  (Mozhi-style conventions people actually type: `ഴ → zh`, `ത → th`, `ക്ക → kk`, chillu
  `ൻ → n`, etc.), not academic ISO-15919 (nobody types `rameṣ`).
- The key is computed once at write time (insert/update) and backfilled for existing rows by a
  schema migration, so search stays a cheap indexed-ish `LIKE` with no per-keystroke computation.
- Names already in Latin script pass through unchanged, so the new column is harmless for
  English-named contacts (search already matches them via the existing name clause).

Known limitation (V1): Manglish spellings vary (`sreeraj` vs `sriraj`, `ph` vs `f`). The mapping
will cover the common conventions and also normalize a few ambiguous clusters on **both** the
stored key and the query (e.g. collapse `ee/ii → i`, `oo/uu → u`, double consonants → single) so
frequent variants still hit. Reverse direction (typing Malayalam to find English-stored names) is
out of scope.

## Files to change

1. **`lib/utils/malayalam_transliterator.dart` (new)**
   - `String transliterateMalayalam(String input)` — maps Malayalam code points (U+0D00–U+0D7F):
     independent vowels, consonants + vowel signs, virama/conjuncts, chillus, anusvara/visarga.
     Non-Malayalam characters pass through unchanged.
   - `String searchKey(String input)` — transliterates then applies the loose normalization
     (lowercase, collapse long vowels & doubled consonants) used for matching.
   - Pure function, no dependencies — easily unit-tested.

2. **`lib/database/database_helper.dart`**
   - Bump DB `version: 11 → 12`.
   - `_onCreate`: add `name_translit TEXT` to the `contacts` table.
   - `_onUpgrade` (`oldVersion < 12`): `ALTER TABLE contacts ADD COLUMN name_translit TEXT`,
     then backfill: read `id, salutation, first_name, middle_name, last_name` of all rows,
     compute the search key in Dart, and `UPDATE` each row (batched).

3. **`lib/repositories/contact_repository.dart`**
   - `insertContact` / `updateContact`: set `name_translit` = `searchKey(full name)` in the
     row map before writing (done in the repository, not the model, so every write path gets it).
   - `searchContactSummaries`: normalize the incoming query with the same `searchKey()` and add
     `OR LOWER(COALESCE(c.name_translit,'')) LIKE ?` to the `WHERE` clause.
   - ⚠️ This file is currently **UTF-16 encoded** on disk (grep sees NUL bytes). Editing it with
     the standard tools will rewrite it as UTF-8 — functionally identical for Dart, but the whole
     file may show as changed in git. Will verify content integrity after the edit.

4. **`test/malayalam_transliterator_test.dart` (new)**
   - Unit tests: common names (രമേഷ് → ramesh, ശ്രീരാജ് → sreeraj/sriraj via normalization),
     chillu endings, conjuncts, mixed Malayalam+Latin input, pure-Latin passthrough.

## Not in scope

- Dialer-screen T9/name search (separate code path; can follow up if wanted).
- Device-only (unsaved) contacts — search is DB-backed today and stays that way.
- Malayalam-query → English-name matching (reverse direction).
- Other Indic scripts (the util is structured so a Tamil/Hindi table could be added later).

## Verification

- `flutter analyze` and `flutter test` pass.
- Manual: save a contact named `രമേഷ്`, type `ramesh` in Contacts search → contact appears;
  upgrade path exercised by opening an existing DB (v11 → v12 backfill) and searching.
