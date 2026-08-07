# Plan: Add a `version:` field to pubspec.yaml so build/version stay in sync

**Status:** completed

## The issue

- `pubspec.yaml` has **no `version:` field**. In Flutter that field is the source of
  `flutter.versionName` and `flutter.versionCode`, which
  [android/app/build.gradle.kts:46-47](../android/app/build.gradle.kts#L46-L47) feeds into
  `versionCode` / `versionName`. With no field, the build falls back to Flutter's default
  (`versionName = 1.0.0`, `versionCode = 1`).
- The About screen's source of truth, `assets/config/app_config.json`, declares
  `version: 15.8.9`, `build: 30`.
- `ConfigService.loadAndVerify()` (guideline §1.5) compares `app_config.json`'s version/build
  against `PackageInfo.fromPlatform()` (the real build) and logs a drift note on mismatch.
  Because the real build carries `1.0.0+1`, the comparison is against a meaningless default —
  it would report drift on **every** build. The drift check effectively "can't exist."
- The now-deleted `lib/constants/app_info.dart` hard-coded `15.8.8`; it is already removed and
  replaced by the config pattern, so no Dart code hard-codes the version anymore. The one
  remaining gap is that nothing feeds the version into the actual build.

## The fix

1. **Add a `version:` field to `pubspec.yaml`**, matching `app_config.json`:
   `version: 15.8.9+30`. Place it under `description:` (conventional location). This makes
   `flutter.versionName = 15.8.9` and `flutter.versionCode = 30`, so the Android build,
   `PackageInfo.fromPlatform()`, and `app_config.json` all agree — and `loadAndVerify` becomes
   a real drift check.

2. **Make `loadAndVerify` tolerant of the `-dev` flavor suffix** in
   [lib/core/config/config_service.dart](../lib/core/config/config_service.dart). The `dev`
   flavor sets `versionNameSuffix = "-dev"`
   ([build.gradle.kts:81](../android/app/build.gradle.kts#L81)), so on a dev build
   `PackageInfo.version` is `15.8.9-dev`. A raw `!=` comparison against config's `15.8.9`
   would fire a false drift note on every dev run. Fix: strip a trailing `-<suffix>` from the
   build's version before comparing (compare the part before the first `-`). This keeps the
   check meaningful on both flavors without weakening prod verification.

## Files to change

- `pubspec.yaml` — add `version: 15.8.9+30`.
- `lib/core/config/config_service.dart` — normalize the build version (strip flavor suffix)
  before the mismatch comparison in `loadAndVerify()`.

## Out of scope

- No change to `app_config.json` values, `AppConfig`, or the About screen.
- No release/tagging; this only wires the version into the build.

## Verification

- `flutter pub get` succeeds (version field parses).
- `flutter analyze` clean for the edited file.
- Sanity: on a prod build, `PackageInfo` version/build = `15.8.9`/`30` = config → no drift note.
  On a dev build, `15.8.9-dev`/`30` normalizes to `15.8.9`/`30` → no false drift note.
