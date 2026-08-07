# Duplicate detection: fix stale code comments/labels, mark roadmap row completed

**Status:** completed

## Files to be changed

1. `lib/repositories/contact_repository.dart`
2. `test/phonetic_duplicate_test.dart`
3. `docs/feature_analysis_and_roadmap.md`

## What the issue is

Phonetic matching (Soundex / Double Metaphone) was removed from duplicate detection on
2026-08-05 (see
[change_log/20260805_040000_fix_phonetic_duplicate_false_positives.md](../change_log/20260805_040000_fix_phonetic_duplicate_false_positives.md)).
The code path is correct today, but three leftovers still say otherwise:

1. **Corrupted doc comment** at `contact_repository.dart:1843-1850`. The comment block for
   `findDuplicates()` was pasted over itself:

   ```
   /// per-contact child hydration is intentionally skipped  /// Contacts that share a name or a phone number with another contact.
   ```

   One sentence is cut off mid-way and the whole header is repeated.

2. **Stale doc comment** at `contact_repository.dart:1860-1866`. It still tells the reader that
   `findDuplicateGroups()` unions contacts by "a Soundex code, Double Metaphone keys". It does
   not. This is exactly the kind of note that would lead someone to re-add the removed
   behaviour.

3. **Misleading UI labels** at `contact_repository.dart:2151` and `:2155`. A group whose only
   link is a shared `searchKey` is still headed **"Phonetic name match"** / **"Phonetic name &
   phone match"**. `searchKey` is a transliteration/spelling-normalization key (it is what
   matches `സുരേഷ് കുമാർ` with `Suresh Kumar`), not a phonetic code. The word
   "phonetic" now names something the app no longer does.

Separately, the roadmap table row for **Duplicate detection & merge**
(`docs/feature_analysis_and_roadmap.md:308`) carries the removal as a "⚠️ Correction to an
earlier version of this document" instead of a completed-work status, and it credits the
matching logic to `duplicates_screen.dart` when it actually lives in
`contact_repository.dart` (`findDuplicateGroups()`); the screen only renders the result.

## The plan for the fix

### 1. `lib/repositories/contact_repository.dart`

- Rewrite the `findDuplicates()` doc comment (lines 1843-1850) as a single clean block, keeping
  the intended meaning: slim summaries via `_summarySelect`, full child hydration intentionally
  skipped.
- Update the `findDuplicateGroups()` doc comment: drop "a Soundex code, Double Metaphone keys",
  and add one line saying phonetic-code matching was deliberately removed (false positives on
  short names) and should not be re-added without a stricter scoring model.
- Rename the two reason labels for accuracy:
  - `'Phonetic name match'` → `'Similar name match'`
  - `'Phonetic name & phone match'` → `'Similar name & phone match'`

  These strings are user-visible headers on the duplicate cards in the Find-duplicates screen.
  No other behaviour changes. **If you would rather keep the current wording, say so and I will
  do only the comment fixes.**

### 2. `test/phonetic_duplicate_test.dart`

- Update the one assertion at line 96 that expects `contains('Phonetic name match')` to the new
  label. No test logic changes.

### 3. `docs/feature_analysis_and_roadmap.md`

Replace the **Duplicate detection & merge** row (line 308) so that:

- *Current state* reads ✅ **Shipped**, points at `contact_repository.dart`
  (`findDuplicateGroups()`) as the matching engine with `duplicates_screen.dart` as the renderer,
  and lists the live match rules: exact name key, transliterated `searchKey`, exact phone digits,
  canonical E.164 — grouped transitively (union-find).
- *Recommended change* reads "No further work planned", and keeps the guard-rail note: phonetic
  matching (Double Metaphone / Soundex) was implemented and then removed because truncated codes
  collided on unrelated names; `phonetic_utils.dart` still exists but is not in the merge path;
  do not re-add it without a much stricter scoring model.

## Verification

- `flutter test test/phonetic_duplicate_test.dart` (run alone — sqlite-backed).
- `flutter analyze`.

## Not in scope

- `lib/utils/phonetic_utils.dart` stays as is. It is still used by contact search, and its own
  `arePhoneticallySimilar()` helper is not on the merge path.
