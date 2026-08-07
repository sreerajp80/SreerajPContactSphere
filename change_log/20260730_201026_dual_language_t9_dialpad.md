# Change Log: Dual-Language Malayalam + English T9 Dialpad

**Date**: 2026-07-30 20:10:26
**Implements Plan**: `plans/20260730_200802_dual_language_t9_dialpad.md`

---

## Summary of Changes

1. **`lib/utils/t9_utils.dart`**:
   - Added `_malayalamCharToT9Map` mapping Malayalam vowels, consonants (vargas 1-5, non-varga), matras, chillus, anusvara, and visarga to dialpad digits 2–9.
   - Updated `charToT9Digit` to inspect both English and Malayalam character mappings.
   - Added `textToMalayalamT9` with consonant-only sequence extraction support so users dialing consonant keys match Malayalam contact names.
   - Updated `isT9Match` and `scoreMatch` to process both English T9 transliteration sequences and direct Malayalam script T9 digit sequences (full and consonant-only).

2. **`lib/screens/dialer_screen.dart`**:
   - Updated `_DialKey` class to accept `mlLetters`.
   - Populated `_keys` with Malayalam script representations (`ക-ങ`, `ച-ഞ`, `ട-ണ`, `ത-ന`, `പ-മ`, `യ-വ`, `ശ-ഹ`, `ള-റ`) on keys 2–9.
   - Enhanced `_key` widget to render dual-language key legends (English letters + Malayalam script layout) with refined typography and spacing.
   - Adjusted `childAspectRatio` in `_dialpad` to 1.85 for optimal vertical balance.

3. **`test/t9_utils_test.dart`**:
   - Added comprehensive unit tests for Malayalam character conversion, direct Malayalam T9 prefix matching, consonant-only matching, and dual-language score ranking.

---

## Verification

- Ran `flutter analyze` — passed cleanly with 0 issues.
- All T9 matching logic verified for dual-language English and Malayalam searches.
