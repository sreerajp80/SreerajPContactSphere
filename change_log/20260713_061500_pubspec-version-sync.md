# Change log: Sync app version into the build via pubspec `version:`

Implements plan `plans/20260713_061500_pubspec-version-sync.md`.

## What was wrong

`pubspec.yaml` had no `version:` field, so `flutter.versionName`/`flutter.versionCode`
(used in `android/app/build.gradle.kts`) fell back to Flutter's default `1.0.0+1`. The About
config `assets/config/app_config.json` declares `15.8.9+30`, so
`ConfigService.loadAndVerify()`'s drift check compared the config against a meaningless default
and would report drift on every build. (The old `lib/constants/app_info.dart`, which hard-coded
`15.8.8`, was already deleted and replaced by the config pattern.)

## What changed

- **`pubspec.yaml`** — added `version: 15.8.9+30` (matching `app_config.json`), with a comment
  explaining it drives the Android version and `PackageInfo`, and must stay in sync with the
  config. Now the build, `PackageInfo.fromPlatform()`, and `app_config.json` all agree.
- **`lib/core/config/config_service.dart`** — in `loadAndVerify()`, the build version is now
  normalized by stripping the flavor suffix (`info.version.split('-').first`) before the
  mismatch comparison. Without this, the `dev` flavor's `-dev` `versionNameSuffix` would make
  `PackageInfo.version` (`15.8.9-dev`) trip a false drift note against the config's `15.8.9`.
  The build number comparison is unchanged.

## Verification

- `flutter pub get` — succeeds (version field parses).
- `flutter analyze lib/core/config/config_service.dart` — "No issues found!"
- Logic check: prod build → `15.8.9`/`30` == config → no drift note; dev build →
  `15.8.9-dev`/`30` normalizes to `15.8.9`/`30` == config → no false drift note.
