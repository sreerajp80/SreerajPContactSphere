# Plan: Build Metadata Generation & About Screen Build Date

**Date & Time**: 2026-08-30 11:38:00 IST  
**Slug**: `build_metadata_and_about_build_date`

---

## 1. Problem Statement

When building the project (e.g. `flutter build apk --flavor prod --release --split-per-abi` or during standard Flutter builds), we want build metadata generated automatically and logged to the terminal:
```text
app_version.g.dart updated → <version>+<build>
build_date.g.dart updated → <yyyy-MM-dd>
```
Additionally, the About screen of the app should display the **Build Date** alongside the App Version and other metadata.

---

## 2. Proposed Changes

### 2.1. Standalone Generator Scripts
- **[NEW] `tool/generate_app_version.dart`**:
  - Reads `pubspec.yaml` using regex `r'^version:\s*(\S+)'`.
  - Writes `lib/core/constants/app_version.g.dart` exporting `const String kAppVersion = '<version>';`.
  - Outputs `app_version.g.dart updated → <version>`.
- **[NEW] `tool/generate_build_date.dart`**:
  - Computes `DateTime.now().toIso8601String().substring(0, 10)` (e.g. `2026-08-30`).
  - Writes `lib/core/constants/build_date.g.dart` exporting `const String kBuildDate = '<date>';`.
  - Outputs `build_date.g.dart updated → <date>`.

### 2.2. Gradle Build Integration
- **[MODIFY] `android/app/build.gradle.kts`**:
  - Resolve Flutter SDK path from `local.properties` (`flutter.sdk`) or `FLUTTER_ROOT`.
  - Locate `bin/dart` / `bin\dart.bat`.
  - Register Gradle task `generateBuildMetadata` to run `tool/generate_app_version.dart` and `tool/generate_build_date.dart` with inputs & outputs tracking.
  - Hook task to `preBuild` and all `compileFlutterBuild*` tasks so it executes whenever building or running Flutter/Android.

### 2.3. About Screen Update
- **[MODIFY] `lib/screens/about_screen.dart`**:
  - Import `lib/core/constants/build_date.g.dart`.
  - Add a "Build Date" row displaying `kBuildDate` right below the "Version" row.

### 2.4. Initial Generated Files & Tests
- **[NEW] `lib/core/constants/app_version.g.dart`** & **`lib/core/constants/build_date.g.dart`**:
  - Generate initial files so static analysis / tests pass immediately.
- **[NEW] `test/build_metadata_test.dart`**:
  - Verify generator scripts produce valid Dart files and correct date / version formats.

---

## 3. Verification Plan

1. Run `dart run tool/generate_app_version.dart` and `dart run tool/generate_build_date.dart` to verify stdout output format.
2. Run `flutter analyze` to ensure zero lint or syntax errors.
3. Run `flutter test` to ensure all existing and new tests pass.
4. Run a Gradle dry run / compile task (or `flutter build apk --flavor dev --debug`) to verify Gradle task execution and console output.
