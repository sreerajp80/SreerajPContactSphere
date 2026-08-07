# Change Log: Fix Contact Search (English & Malayalam Names Matching & Precision)

**Date & Time:** 2026-07-30 18:15:00 IST  
**Plan Implemented:** [plans/20260730_181113_search-malayalam-english-fixes.md](../plans/20260730_181113_search-malayalam-english-fixes.md)

## Summary of Changes

Fixed three persistent contact search issues where typing "Ale" / "Alex" failed to find Malayalam names like "അലക്സ്", brought up unrelated names ("City Time Gallery"), or where typing Malayalam "അലക" matched unrelated contacts like "Kumar Electrician" or "Lukose".

### 1. Transliteration & Search Key Enhancements
* **`lib/utils/malayalam_transliterator.dart`**:
  * Updated `searchKey` to map `x` → `ks` so English queries ("Alex") and Malayalam script names ("അലക്സ്" → `alaks`) produce matching search keys.
  * Preserved initial vowels in `phoneticCode` so vowel-starting queries ("അലക", "Alex") only match vowel-starting names, preventing unwanted phonetic hits against consonant-starting names ("Lukose", "Kumar").
  * Updated `nameMatches` to support plain text substring, word-anchored `searchKey` prefix matching, and word-anchored `phoneticCode` matching.

### 2. SQL Word-Anchored Search Key Queries
* **`lib/repositories/contact_repository.dart`**:
  * Updated `searchContactSummaries` to match `c.name_translit` using word-anchored prefix matching (`LIKE 'key%' OR LIKE '% key%'`).
  * Prevents substring matches in the middle of unrelated words (e.g. "Ale" matching `g-ale-ry` in "City Time Gallery").
* **`lib/repositories/call_log_repository.dart`**:
  * Applied the exact same word-anchored prefix matching in `searchCalls` for Recents search consistency.

### 3. Automatic Stale Index Rebuild
* **`lib/database/database_helper.dart`**:
  * Added auto-rebuild check in `_onOpen`: `if (await staleContactSearchKeyCount(db) > 0) { await rebuildContactSearchKeys(db); }`.
  * Guarantees all existing contacts stored in SQLite on user devices automatically re-index their `name_translit` and `name_phonetic` keys on launch.

### 4. Tests Added & Passing
* Added unit tests in `test/malayalam_transliterator_test.dart` and end-to-end repository tests in `test/contact_search_malayalam_test.dart`:
  * `Ale` and `Alex` match `അലക്സ്` and `അലക്സ് കുമാർ`.
  * `Ale` does NOT match `City Time Gallery`.
  * `അലക` matches `അലക്സ്` and `അലക്സ് കുമാർ`, but NOT `Kumar Electrician` or `ലൂക്കോസ്`.
  * All 63 search & transliteration unit tests passed cleanly.
  * Static analysis (`flutter analyze`) reported 0 issues.
