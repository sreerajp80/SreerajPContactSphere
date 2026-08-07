# Plan: Dual-Language Malayalam + English T9 Dialpad

**Date**: 2026-07-30 20:08:02
**Issue**: Extend dialpad and contact searching in dialer to support vernacular (Malayalam + English) T9 numeric keypad searching.
**Goal**: Enable multi-lingual T9 searching where keys 2-9 display both English letters and Malayalam script layout, and dialing matches contacts using both English T9 transliteration and direct Malayalam T9 script key mappings.

---

## Files to Change

1. `lib/utils/t9_utils.dart`
   - Define `_malayalamCharToT9Map` mapping Malayalam vowels, consonants (vargas 1-5, non-varga), matras, chillus, anusvara/visarga to digits 2–9.
   - Implement `charToMalayalamT9Digit(String char)` and `textToMalayalamT9(String text, {bool consonantsOnly})`.
   - Update `isT9Match` and `scoreMatch` to check both English T9 variants (transliterated) and direct Malayalam script T9 digit sequences (full and consonant-only).

2. `lib/screens/dialer_screen.dart`
   - Extend `_DialKey` with `mlLetters` field.
   - Update `_keys` list with Malayalam script representations for digits 2–9:
     - 2: `ABC` / `ക-ങ`
     - 3: `DEF` / `ച-ഞ`
     - 4: `GHI` / `ട-ണ`
     - 5: `JKL` / `ത-ന`
     - 6: `MNO` / `പ-മ`
     - 7: `PQRS` / `യ-വ`
     - 8: `TUV` / `ശ-ഹ`
     - 9: `WXYZ` / `ള-റ`
   - Update `_key` widget in `DialerScreen` to render dual-language legends (English + Malayalam) under each digit cleanly.

3. `test/t9_utils_test.dart`
   - Add unit tests verifying Malayalam character-to-digit conversion, direct Malayalam T9 prefix matching, consonant-only matching, and dual-language scoring.

---

## Verification Plan

### Automated Tests
- Run `flutter test test/t9_utils_test.dart` to verify all T9 tests pass.
- Run `flutter analyze` to check for any static analysis issues or missing types.

### Manual Verification
- Launch app (`flutter run`) or verify unit tests for dialer matching logic.
- Type digits corresponding to English names and Malayalam names on the dialpad to confirm live suggestion matches.
