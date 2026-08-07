# Fix wrong "Phonetic name match" duplicate groups

**Status:** completed

## Files to change

1. `lib/repositories/contact_repository.dart`

## The issue

The "Find duplicates" screen groups contacts under "Phonetic name match" using four
different signals unioned together (transitively, via union-find): exact name, `searchKey`
(spelling-variant normalization), Soundex, and Double Metaphone.

Soundex and Double Metaphone both compress a name down to a short, fixed-length code (4
characters). That truncation causes completely unrelated names to collide by chance:

- A long multi-word hospital business name and an unrelated short personal name encoded to
  the **same** Soundex code, purely because Soundex only looks at the first few consonant
  sounds — the business name runs out of "room" in the code before it says anything
  distinctive.
- `അമ്മ` (Amma), `അനു` (Anu), and `അമ്മു` (Ammu) — three different names — all encode to
  Soundex `A500`, because Soundex drops vowels entirely and only `m`/`n` survive, both of
  which map to the same digit.
- Two unrelated `അന`-prefixed personal names collided on both Soundex and Metaphone,
  because they share a prefix and Metaphone's 4-character limit cuts off before the names
  diverge. Another `അനു`-prefixed pair collided the same way.

Because group membership is transitive (union-find), one bad Soundex/Metaphone collision is
enough to pull a third, completely unrelated contact into the same "duplicate" card.

By contrast, `searchKey` — which normalizes spelling variants across the *whole* name instead
of truncating to a short code (e.g. th/t, sh/s, ee/i, doubled letters, Malayalam-to-Latin
transliteration) — did not produce a single false match in any of the examples reported. It
correctly matched a Malayalam-script name with its Latin spelling (e.g. `സുരേഷ് കുമാർ`
with `Suresh Kumar`, both normalizing to `"sures kumar"`) without over-matching anything
else.

The user has confirmed the Soundex/Metaphone-driven groups are consistently wrong and, per
their instruction, should be removed rather than kept in a broken state.

## The fix

In `findDuplicateGroups()` (`contact_repository.dart`, around lines 1862–1939):

- Stop computing and unioning contacts by Soundex code and Double Metaphone
  primary/secondary key. Remove the `soundexById`, `metaphonePrimaryById`, `bySoundex`,
  `byMetaphonePrimary`, `byMetaphoneSecondary` maps and their union calls.
- Keep exact-name union and `searchKey` union as-is — these are the checks that only merge
  genuine spelling/script variants of the same name, and none of the reported false positives
  came from them.
- Keep the phone-number and E.164 union logic entirely as-is (unrelated to this bug).
- Update `_reasonFor()` (around lines 2106–2162) to drop the now-unused `soundexById` /
  `metaphonePrimaryById` parameters and the Soundex/Metaphone comparisons — `sharedPhoneticName`
  becomes true only on a shared `searchKey`. The "Phonetic name match" / "Phonetic name &
  phone match" labels stay as-is, since `searchKey`-based matches are still legitimately
  phonetic/transliteration matches (e.g. the Malayalam-script vs Latin-spelling case above).
- Update the call site that passes `soundexById`/`metaphonePrimaryById` into `_reasonFor()`
  to match the new signature.

`Soundex` and `DoubleMetaphone` classes in `lib/utils/phonetic_utils.dart` are left in place
(not deleted) since removing dead code isn't required to fix the bug and they may be used
elsewhere or in tests — I'll only stop calling them from duplicate detection.

## What is out of scope

- The search-by-typing feature (`phoneticCode`/`phoneticMatches` in
  `malayalam_transliterator.dart`, used by contact search) is a different mechanism and the
  user has not reported it as wrong — not touched here.
- Not deleting the `Soundex`/`DoubleMetaphone` classes themselves, only their use in duplicate
  detection.
