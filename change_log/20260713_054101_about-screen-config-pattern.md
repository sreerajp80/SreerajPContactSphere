# About-screen config pattern (guideline.md §1)

Implements plan `plans/20260713_054101_about-screen-config-pattern.md`.

Conforms the About screen to the master guideline §1 (folder-structure guideline
at `l:\Android\Flutter_Guidelines\guideline.md`, pointed to by
`docs/GUIDELINES_MANIFEST.md`). An earlier pass used a reconstructed schema; this
change replaces it with the exact spec shape.

## What changed

### `assets/config/app_config.json` (source of truth)
- Now has top-level `appName`, `description`, `version`, `build`, and a
  `details` **string → string map** (`Author`, `Email`, `License`, `AI used`,
  `IDE used`). Removed the old `footer` / icon-per-row shape.

### `lib/core/config/app_config.dart`
- `AppConfig{appName, description, version, build, Map<String,String> details}`
  with `static const fallback` and a per-field `fromJson` (never throws).
- Removed the `AppDetail` class.

### `lib/core/config/config_service.dart`
- `assetPath` constant; injectable `_loadAsset` (defaults to
  `rootBundle.loadString`) so tests can supply text.
- `load()` returns `AppConfig.fallback` on any error.
- `loadAndVerify({PackageInfo?})` compares the config's `version`/`build` with
  `package_info_plus` and logs a non-fatal debug note on mismatch.

### `lib/screens/about_screen.dart`
- `FutureBuilder` on `loadAndVerify()` (fallback shown while loading).
- Header renders `appName` + `description`; a fixed `Version (build …)` row, then
  one row per `details` entry, skipping empties. An `email` key opens a `mailto:`
  composer via `url_launcher`. No hard-coded field names; no icon mapping.

### `pubspec.yaml`
- Added dependency `package_info_plus: ^10.2.0` (bumped from ^8.0.0 to resolve a
  `win32` conflict with `share_plus`).
- Assets entry registers the directory `assets/config/`.

## Notes / decisions
- `pubspec.yaml` has no `version:` line, so there is no build number to mirror;
  the JSON uses `version: 15.8.9`, `build: 1`. In debug, `loadAndVerify()` may log
  a version/build-mismatch note against the real package build — expected until a
  `version:` is added to `pubspec.yaml` (left out of scope).
- `description` taken from the pubspec description; `Email` set to
  `sreerajp@zohomail.in`.

## Verification
- `flutter pub get` succeeded (after the `package_info_plus` bump).
- `flutter analyze` on the three changed Dart files: no issues found.
