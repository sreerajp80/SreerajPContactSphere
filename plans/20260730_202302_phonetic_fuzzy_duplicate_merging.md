# Phonetic & Fuzzy Duplicate Merging Plan

## Goal
Enhance duplicate contact detection in `duplicates_screen.dart` / `ContactRepository.findDuplicateGroups()` by integrating Double Metaphone and Soundex algorithms for Malayalam/Indian name transliteration variations (e.g., Sreeraj vs Sriraj) and standardizing phone comparison with E.164 normalization using `phone_numbers_parser`.

## Files to Change

### 1. [NEW] `lib/utils/phonetic_utils.dart`
- Implement **Soundex** algorithm: generates standard 4-character phonetic codes for names (handling pre-transliterated Malayalam & English scripts).
- Implement **Double Metaphone** algorithm: computes primary and secondary phonetic encoding keys to handle Indian and Malayalam transliteration variations (e.g. `Sreeraj` vs `Sriraj`, `Kiran` vs `Keeran`, `Deepak` vs `Dipak`).
- Add helper method `phoneticNameMatches(String name1, String name2)` leveraging Soundex, Double Metaphone, and `searchKey` / `phoneticCode` from `lib/utils/malayalam_transliterator.dart`.

### 2. [MODIFY] `lib/repositories/contact_repository.dart`
- Enhance `findDuplicateGroups()` and `findDuplicates()`:
  - Phone normalization: Use `PhoneNormalizer.toE164(raw, defaultIso: defaultIso)` (backed by `phone_numbers_parser`) to compare contacts' phone numbers in canonical E.164 form alongside raw digits.
  - Name matching: Use exact name keys, transliterated `searchKey`, Soundex codes, and Double Metaphone primary/secondary keys in the Union-Find algorithm.
  - Update `_reasonFor(...)` to generate descriptive set reasons: "Same phone number", "Same name", "Phonetic name match", "Same name & number", "Phonetic name & phone match".

### 3. [NEW] `test/phonetic_duplicate_test.dart`
- Add unit tests for:
  - Soundex encoding (`Sreeraj` & `Sriraj` -> matching Soundex code).
  - Double Metaphone primary & secondary key generation.
  - Standardized E.164 phone normalization matching in duplicate groups.
  - `ContactRepository.findDuplicateGroups()` end-to-end grouping with transliterated Indian name variations and E.164 numbers.

## Verification Plan
1. Run `flutter test test/phonetic_duplicate_test.dart` to verify Soundex, Double Metaphone, and duplicate grouping.
2. Run `flutter test test/phone_normalizer_test.dart` to ensure no regression in existing phone normalization.
3. Run `flutter analyze` to ensure clean static analysis.
