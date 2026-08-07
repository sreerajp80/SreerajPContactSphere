# Fix wrong "Phonetic name match" duplicate groups

Implements [plans/20260805_040000_fix_phonetic_duplicate_false_positives.md](../plans/20260805_040000_fix_phonetic_duplicate_false_positives.md).

## What was wrong

The "Find duplicates" screen was grouping completely unrelated contacts together under
"Phonetic name match" — e.g. a hospital's business name with a person's short name, or three
different everyday names like Amma/Anu/Ammu. The cause: duplicate detection used Soundex and
Double Metaphone codes, both of which compress a name into a fixed 4-character code. Short or
multi-word names run out of "room" in that code and collide with unrelated names purely by
chance (confirmed with the exact names from the bug reports: a multi-word hospital business
name and an unrelated short personal name shared one Soundex code; `Amma`, `Anu`, and `Ammu`
all encode to `A500`).
Because grouping is transitive, one such collision could pull a third unrelated contact into
the same card.

## What changed

`lib/repositories/contact_repository.dart`:
- `findDuplicateGroups()` no longer computes or unions contacts by Soundex code or Double
  Metaphone key. It still unions on exact name and on `searchKey` (spelling/transliteration
  normalization across the whole name, e.g. matching `സുരേഷ് കുമാർ` with
  `Suresh Kumar`), plus the existing phone-number and E.164 matching — none of these
  produced any false positive in the reported cases.
- `_reasonFor()` dropped its `soundexById`/`metaphonePrimaryById` parameters; a group is now
  labeled "Phonetic name match" only when contacts share a `searchKey`.
- Removed the now-unused `phonetic_utils.dart` import (Soundex/Metaphone are still used
  elsewhere, e.g. contact search, so the classes themselves were not deleted).

`test/phonetic_duplicate_test.dart`:
- Added a regression test that inserts the three reported false-positive names and asserts
  `findDuplicateGroups()` returns no groups for them.

## Verification

- `flutter test test/phonetic_duplicate_test.dart` — all 8 tests pass, including the new
  regression test and the existing "Sreeraj vs Sriraj" phonetic-match test (still passes via
  `searchKey` alone).
- `flutter analyze` — no issues.
