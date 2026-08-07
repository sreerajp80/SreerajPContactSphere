# Duplicate detection: fixed stale comments and labels, roadmap row marked shipped

Implements [plans/20260806_160055_duplicate-detection-doc-and-labels.md](../plans/20260806_160055_duplicate-detection-doc-and-labels.md).

## What was wrong

Phonetic matching (Soundex / Double Metaphone) was taken out of duplicate detection on
2026-08-05 (see
[change_log/20260805_040000_fix_phonetic_duplicate_false_positives.md](20260805_040000_fix_phonetic_duplicate_false_positives.md)).
The matching code was right, but the words around it still described the old behaviour:

- The doc comment on `findDuplicates()` had been pasted over itself and was cut off
  mid-sentence.
- The doc comment on `findDuplicateGroups()` still said contacts are grouped by "a Soundex
  code, Double Metaphone keys". They are not — a reader could easily have put that back.
- Duplicate cards linked only by a shared `searchKey` were still headed "Phonetic name match".
  `searchKey` is a transliteration/spelling key (it is what matches `സുരേഷ് കുമാർ` with
  `Suresh Kumar`), not a phonetic code, so the word named something the app no longer does.
- The roadmap table filed the removal as a "⚠️ Correction to an earlier version of this
  document" rather than a finished piece of work, and credited the matching to
  `duplicates_screen.dart` when it lives in `contact_repository.dart`.

## What changed

`lib/repositories/contact_repository.dart`:
- Rewrote the `findDuplicates()` doc comment as one clean block, including why child hydration
  is skipped (the screen never reads those children).
- Updated the `findDuplicateGroups()` doc comment: dropped the Soundex/Metaphone claim, listed
  the four rules actually in use (exact name key, transliterated `searchKey`, exact phone
  digits, canonical E.164), and added a short note saying phonetic codes were removed on
  purpose and must not be re-added without a much stricter scoring model.
- Renamed two user-visible card headers: "Phonetic name match" → **"Similar name match"**, and
  "Phonetic name & phone match" → **"Similar name & phone match"**. Renamed the matching local
  variable `sharedPhoneticName` → `sharedSimilarName`. No behaviour change — the same groups
  are produced, only the label text differs.

`test/phonetic_duplicate_test.dart`:
- Updated the one assertion that expected the old "Phonetic name match" label.

`docs/feature_analysis_and_roadmap.md`:
- The **Duplicate detection & merge** row in section 6 now reads ✅ **Shipped** / "No further
  work planned". It points at `findDuplicateGroups()` as the engine and
  `duplicates_screen.dart` as the renderer, lists the live match rules and the five card
  headers, and keeps the guard-rail note about not re-adding phonetic matching.

## Verification

- `flutter test test/phonetic_duplicate_test.dart` — all 8 tests pass.
- `flutter analyze` — no issues found.

## Not changed

`lib/utils/phonetic_utils.dart` is untouched. Contact search still uses it; it is simply not on
the merge path.
