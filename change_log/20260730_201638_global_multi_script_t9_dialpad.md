# Change Log: Global Multi-Script T9 Dialpad System

**Date**: 2026-07-30 20:16:38
**Implements Plan**: `plans/20260730_201519_global_multi_script_t9_dialpad.md`

---

## Summary of Changes

1. **`lib/state/app_settings.dart`**:
   - Added `DialpadScript` enum (`auto`, `malayalam`, `devanagari`, `cyrillic`, `arabic`, `greek`, `none`).
   - Added `DialpadScriptInfo` extension for UI display labels.
   - Added `dialpadScript` getter, `setDialpadScript()` setting method, and `shared_preferences` persistence key `dialpad_script`.

2. **`lib/utils/t9_utils.dart`**:
   - Added character-to-digit maps for Devanagari (Sanskrit/Hindi/Marathi), Cyrillic (Russian/Ukrainian), Arabic, Greek, and Latin diacritics (`é/è/ê → 3`, `ñ → 6`, `ç → 2`, `ä/à → 2`, `ø/ö → 6`, `ü/ú → 8`, etc.).
   - Implemented `getScriptKeyLegends(DialpadScript script)` with automatic system locale detection fallback (`ml` → Malayalam, `hi`/`sa`/`mr` → Devanagari, `ru`/`uk`/`bg` → Cyrillic, `ar`/`fa`/`ur` → Arabic, `el` → Greek).
   - Updated `charToT9Digit` to inspect all global script character mappings.

3. **`lib/screens/dialer_screen.dart`**:
   - Updated `_dialpad` to listen to `AppSettings.dialpadScript` and dynamically generate `_keys` with key legends corresponding to the active script.

4. **`lib/screens/settings_screen.dart`**:
   - Added `_DialpadScriptCard` setting tile under Settings allowing users to choose their secondary dialpad script (Auto, Malayalam, Devanagari, Cyrillic, Arabic, Greek, or English only).

5. **`test/t9_utils_test.dart`**:
   - Added unit test cases verifying `getScriptKeyLegends` resolution and character-to-digit conversion for Devanagari, Cyrillic, Arabic, Greek, and Latin diacritics.

---

## Verification

- Ran `flutter analyze` — passed with 0 static analysis errors.
- Verified dynamic key legend rendering and multi-script T9 searching.
