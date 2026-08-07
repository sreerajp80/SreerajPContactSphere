# Add Dart `AppFlavorConfig` (dev/prod)

**Status:** completed

## The issue

The Android side already defines build flavors (`android/app/build.gradle.kts`:
`flavorDimensions += "env"`, product flavors `dev` and `prod`). But there is **no matching
Dart flavor-config file**. Nothing in `lib/` reads `FLUTTER_APP_FLAVOR` / `APP_FLAVOR`, so at
runtime the app cannot tell whether it is a `dev` or `prod` build. The app title is hard-coded
`'ContactSphere'` in [lib/main.dart:487](lib/main.dart#L487).

The engineering standard **§5.2 (Recommended Flavor Model)** requires a two-variable
`AppFlavorConfig`, and the folder-structure guideline **§3** fixes its home at `lib/core/config/`.
That file is missing. This is the gap flagged in the manifest-referenced guidelines.

## The fix

1. **Create `lib/core/config/app_flavor_config.dart`** — the two-variable `AppFlavorConfig`
   exactly per engineering standard §5.2, adapted to this app:
   - `enum AppFlavor { dev, prod }`.
   - Reads `APP_FLAVOR` first (desktop dart-define path), falls back to `FLUTTER_APP_FLAVOR`
     (auto-injected by Flutter on Android when `--flavor` is passed), default `'prod'`.
   - `AppFlavorConfig.instance`, `isDev`/`isProd`, `enableVerboseLogging`, `showEnvironmentBanner`.
   - `appName` → `'ContactSphere Dev'` for dev, `'ContactSphere'` for prod. These match the
     `resValue("string", "app_name", …)` values already in `build.gradle.kts`.
   - The two-variable pattern is kept even though this app is Android-only, because the
     guideline marks it as **MUST** (keeps a single config valid if desktop is added later).

2. **Wire it into `lib/main.dart`** — minimal integration so the value is actually used:
   - Import the new file.
   - Change the `MaterialApp` title from the hard-coded `'ContactSphere'` to
     `AppFlavorConfig.instance.appName`, so a `--flavor dev` build shows "ContactSphere Dev"
     in the task switcher / app title.

No native/Gradle changes (flavors already exist). No new dependency. No build-command change —
Android keeps using `--flavor dev` / `--flavor prod` (the guideline forbids passing
`--dart-define=FLUTTER_APP_FLAVOR=…`).

## Files to change

- **New:** `lib/core/config/app_flavor_config.dart`
- **Edit:** `lib/main.dart` (add import; use `AppFlavorConfig.instance.appName` for the title)

## Verification

- `flutter analyze` is clean for the new/edited files.
- `flutter run --flavor dev` → title resolves to "ContactSphere Dev"; `--flavor prod` (or an
  unflavored debug run, which defaults to `prod`) → "ContactSphere".

## After implementation

Write a change log to `change_log/` referencing this plan.
