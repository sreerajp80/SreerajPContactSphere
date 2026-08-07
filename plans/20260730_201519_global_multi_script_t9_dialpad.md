# Plan: Global Multi-Script T9 Dialpad System

**Date**: 2026-07-30 20:15:19
**Issue**: Extend the T9 dialpad system to support global scripts (Malayalam, Devanagari/Sanskrit/Hindi, Cyrillic, Arabic, Greek, Latin Diacritics) with user preference settings and auto-locale detection.
**Goal**: Provide a pluggable multi-script T9 dialpad system where users can configure their secondary dialpad script in Settings or use auto-detected system locale.

---

## Files to Change

1. `lib/state/app_settings.dart`
   - Add `DialpadScript` enum: `auto`, `malayalam`, `devanagari`, `cyrillic`, `arabic`, `greek`, `none`.
   - Add `dialpadScript` getter, setting method `setDialpadScript()`, and `shared_preferences` persistence.

2. `lib/utils/t9_utils.dart`
   - Add character-to-digit maps for Devanagari (Sanskrit/Hindi), Cyrillic, Arabic, Greek, and Latin diacritics.
   - Implement `getScriptKeyLegends(DialpadScript script, [String? countryIso])` returning script key legends for digits 2–9.
   - Update `isT9Match` and `scoreMatch` to process all active global script maps and Latin diacritic stripping.

3. `lib/screens/dialer_screen.dart`
   - Listen to `AppSettings.dialpadScript`.
   - Dynamically generate `_keys` with dual legends matching the chosen script (e.g. `ABC · ക-ങ`, `ABC · क-ङ`, `ABC · АБВГ`, `ABC · ا ب ت ث`).

4. `lib/screens/settings_screen.dart`
   - Add a "Dialpad script" setting tile under Dialer / Keypad section allowing users to switch scripts.

5. `test/t9_utils_test.dart`
   - Add unit tests for global script mappings (Devanagari, Cyrillic, Arabic, Greek, Diacritics) and dialpad legend resolution.

---

## Verification Plan

### Automated Tests
- Run `flutter test test/t9_utils_test.dart` to verify multi-script T9 character conversions and search score matching.
- Run `flutter analyze` to ensure 0 static analysis errors.

### Manual Verification
- Change dialpad script in Settings to Devanagari, Cyrillic, Arabic, Malayalam, or English.
- Verify dialpad key legends update dynamically.
- Type digits corresponding to native script names to verify search matching.
