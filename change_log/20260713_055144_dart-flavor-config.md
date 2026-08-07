# Change log — Add Dart `AppFlavorConfig` (dev/prod)

Implements plan [plans/20260713_055144_dart-flavor-config.md](../plans/20260713_055144_dart-flavor-config.md).

## Why

The Android build already defined `dev`/`prod` flavors, but there was no matching Dart
flavor-config file. At runtime the app could not tell which flavor it was, and the app title
was hard-coded. Engineering standard §5.2 requires a two-variable `AppFlavorConfig`, and folder
guideline §3 fixes its path at `lib/core/config/`.

## What changed

- **New file** `lib/core/config/app_flavor_config.dart`:
  - `enum AppFlavor { dev, prod }` and `AppFlavorConfig` (singleton via `.instance`).
  - Reads `APP_FLAVOR` first (desktop dart-define path), falls back to the framework-injected
    `FLUTTER_APP_FLAVOR`, defaulting to `prod` for unflavored builds — the two-variable pattern
    required by §5.2.
  - Exposes `isDev`/`isProd`, `enableVerboseLogging`, `showEnvironmentBanner`, and `appName`
    (`'ContactSphere Dev'` for dev, `'ContactSphere'` for prod — aligned with the
    `resValue("string", "app_name", …)` values in `android/app/build.gradle.kts`).

- **Edited** `lib/main.dart`:
  - Added `import 'core/config/app_flavor_config.dart';`.
  - `MaterialApp.title` now uses `AppFlavorConfig.instance.appName` instead of the hard-coded
    `'ContactSphere'`.

No Gradle/native changes, no new dependency, no build-command changes. Android continues to use
`--flavor dev` / `--flavor prod`; `--dart-define=FLUTTER_APP_FLAVOR=…` is never passed (framework
reservation).

## Verification

- `flutter analyze lib/main.dart lib/core/config/app_flavor_config.dart` → **No issues found**.
- An IDE diagnostic briefly flagged `AppFlavorConfig` as undefined; it was a stale snapshot from
  the title edit captured before the import edit in the same turn, and cleared on analysis.
