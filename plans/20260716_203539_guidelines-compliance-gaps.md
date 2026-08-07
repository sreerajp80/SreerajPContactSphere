# Fix two guideline-compliance gaps

**Status:** completed

## Context

Audited ContactSphere against `docs/GUIDELINES_MANIFEST.md` (guideline.md +
engineering standard). The app is already largely compliant: `flutter analyze`
is clean, no banned `print`/`debugPrint`, folder layout, About pattern, keystore
rules, lints, and `flutter_localizations` are all in place.

Two concrete gaps remain (scope confirmed with the user — fix only these two).

## Issue

1. **Version/build drift.** `pubspec.yaml` is `15.8.14+35`, but
   `assets/config/app_config.json` says `version: 15.8.13`, `build: 34`.
   guideline.md §1.2 requires these stay in sync; `ConfigService.loadAndVerify()`
   logs a debug drift note when they differ. `pubspec.yaml` is the build's source
   of truth, so the JSON should match it.
2. **CLAUDE.md does not reference the guidelines.** `GUIDELINES_MANIFEST.md`
   (usage step 3) says the app's `CLAUDE.md` must point to
   `docs/GUIDELINES_MANIFEST.md`. It currently has no such reference.

## Files to change

- `assets/config/app_config.json` — set `version` to `15.8.14`, `build` to `35`
  to match `pubspec.yaml`.
- `CLAUDE.md` — add a short line under the Project section telling readers to
  follow the guidelines listed in `docs/GUIDELINES_MANIFEST.md`.

## Plan

1. Edit `app_config.json`: `"version": "15.8.14"`, `"build": "35"`.
2. Edit `CLAUDE.md`: add a one-line pointer to `docs/GUIDELINES_MANIFEST.md`.
3. Verify: re-run `flutter analyze` (should stay clean); no Dart code changes,
   so no test impact.
4. Write the change log.

## Not in scope

Deep section-by-section audit of all 24 engineering-standard sections across the
110 Dart files (error taxonomy, DB migration/WAL/FK, accessibility, animation
tokens, etc.). The user chose to fix only the two concrete gaps above.
