# Phonetic & Fuzzy Duplicate Merging — Change Log

Implements `plans/20260730_202302_phonetic_fuzzy_duplicate_merging.md`.

## Summary of Changes

### 1. `lib/utils/phonetic_utils.dart` (New)
- **Soundex algorithm**: Implemented standard Soundex encoding (`Soundex.encode(input)`) for names after transliterating Malayalam script to Latin.
- **Double Metaphone algorithm**: Implemented Lawrence Philips' Double Metaphone algorithm (`DoubleMetaphone.encode(input)`) generating primary and secondary phonetic keys (up to 4 characters), covering Indian/Malayalam name transliteration variations (e.g., `Sreeraj` vs `Sriraj`, `Deepak` vs `Dipak`, `Kiran` vs `Keeran`, `Menon` vs `Manon`).
- **Phonetic Name Matcher**: Added `phoneticNameMatches(name1, name2)` combining Soundex codes, Double Metaphone keys, and `searchKey` / `phoneticCode` from `malayalam_transliterator.dart`.

### 2. `lib/repositories/contact_repository.dart` (Modified)
- **Standardized E.164 Phone Normalization**: Integrated `PhoneNormalizer.toE164(number, defaultIso: defaultIso)` (backed by `phone_numbers_parser`) to compare phone numbers in canonical E.164 form alongside raw digits.
- **Phonetic & Fuzzy Name Union-Find**: Extended candidate grouping in `findDuplicateGroups()` to link contacts sharing exact names, `searchKey` transliteration keys, Soundex codes, Double Metaphone keys, raw digits, or canonical E.164 phone numbers.
- **Set Reasons**: Updated `_reasonFor(...)` to generate descriptive set headers ("Same phone number", "Same name", "Phonetic name match", "Same name & number", "Phonetic name & phone match").

### 3. `test/phonetic_duplicate_test.dart` (New)
- Unit tests covering Soundex encoding, Double Metaphone primary/secondary keys, `phoneticNameMatches`, E.164 phone normalization, and database-backed `findDuplicateGroups()` for phonetic name pairs and national vs. international phone numbers.

## Verification
- `flutter test test/phonetic_duplicate_test.dart` -> All 7 tests passed.
- `flutter test test/phone_normalizer_test.dart` -> All 12 tests passed.
- `flutter analyze` -> No issues found (clean static analysis).
