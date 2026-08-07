# Fix Contact Search (English & Malayalam Names Matching & False Matches)

**Date & Time:** 2026-07-30 18:11:13 IST

## The Issues

### 1. English "Ale" returns "City Time Gallery" instead of "Alex"
* `searchKey("City Time Gallery")` collapses `ll` in `Gallery` to `l` (`galery`).
* The SQL query used an unanchored wildcard search `c.name_translit LIKE '%ale%'`.
* Because `%ale%` matches `g-ale-ry` inside "Gallery", "City Time Gallery" was returned as a match for "Ale".

### 2. English "Ale" / "Alex" search does not match Malayalam "അലക്സ്" (Alex)
* "അലക്സ്" transliterates to `alaks`.
* `searchKey("Ale")` returned `ale` and `searchKey("Alex")` returned `alex`.
* `searchKey` kept `e` vs `a` and `x` vs `ks` distinct, so `c.name_translit LIKE '%ale%'` or `%alex%` failed to match `alaks`.
* `phoneticCode("Ale")` returned `l` (length 1), which fell below `phoneticCodeMinLen` (2), disabling phonetic matching entirely.
* `phoneticCode("Alex")` returned `lx` (`x` passed through), while "അലക്സ്" returned `lks` (`ks` passed through), failing phonetic match.

### 3. Malayalam "അലക്" / "അലക" matches unrelated contacts like "Kumar Electrician" and "Lukose"
* `phoneticCode` stripped ALL vowels without preserving whether a word starts with a vowel.
* Query "അലക" (vowel-starting) reduced to `lk`. "Electrician" (`e-le-c-tri-ci-an`) reduced to `lktrkn` (starts with `lk`). "Lukose" (`lu-ko-se`) reduced to `lks` (starts with `lk`).
* The SQL query `LIKE '% lk%'` matched any contact with a word starting with L + C/K/G regardless of vowels or vowel-initial status.

---

## Technical Fix Plan

1. **`lib/utils/malayalam_transliterator.dart`**:
   - Update `searchKey`:
     - Convert English `x` to `ks` so English "Alex" (`alaks`) and Malayalam "അലക്സ്" (`alaks`) produce identical search keys.
     - Normalize vowel variations (`e` → `a`) in `searchKey` so "Ale" (`ala`) and "Alex" (`alaks`) match "അലക്സ്" (`alaks`).
   - Update `phoneticCode`:
     - Convert `x` to `ks` before vowel stripping.
     - Preserve initial vowel indicator (`V`) for words starting with a vowel, preventing vowel-initial queries ("അലക", "Alex") from phonetically matching consonant-initial words ("Lukose", "Kumar").
   - Update `phoneticMatches` and `nameMatches` to support the updated keys.

2. **`lib/database/database_helper.dart`**:
   - In `_onOpen(Database db)`, check `if (await staleContactSearchKeyCount(db) > 0)` and call `await rebuildContactSearchKeys(db)`.
   - Ensures existing contacts stored in SQLite automatically update their search keys (`name_translit`, `name_phonetic`) on startup.

3. **`lib/repositories/contact_repository.dart`**:
   - In `searchContactSummaries`:
     - Change `c.name_translit LIKE '%key%'` to word-anchored prefix matching: `(c.name_translit LIKE 'key%' OR c.name_translit LIKE '% key%')`.

4. **`lib/repositories/call_log_repository.dart`**:
   - In `searchCalls`:
     - Apply the exact same word-anchored prefix matching for `c.name_translit` and `c.name_phonetic` so Recents search produces identical results.

5. **Unit Tests**:
   - Add test cases in `test/malayalam_transliterator_test.dart`, `test/name_search_key_test.dart`, `test/contact_search_malayalam_test.dart`.

---

## Files to Change

| File | Change |
|---|---|
| `lib/utils/malayalam_transliterator.dart` | `x`→`ks`, `e`→`a` vowel normalization, initial vowel indicator in `phoneticCode` |
| `lib/database/database_helper.dart` | Rebuild stale search keys automatically in `_onOpen` |
| `lib/repositories/contact_repository.dart` | Word-anchored prefix matching for `name_translit` in `searchContactSummaries` |
| `lib/repositories/call_log_repository.dart` | Word-anchored prefix matching for `name_translit` in `searchCalls` |
| `test/malayalam_transliterator_test.dart` | Unit tests for "Ale", "Alex", "അലക്സ്", "അലക" search keys |
| `test/contact_search_malayalam_test.dart` | End-to-end repository search tests for the bug cases |
