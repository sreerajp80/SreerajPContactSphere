# Change Log: Build Metadata Generation & About Screen Build Date

**Date & Time**: 2026-08-30 11:38:15 IST  
**Plan Reference**: [plans/20260830_113800_build_metadata_and_about_build_date.md](../plans/20260830_113800_build_metadata_and_about_build_date.md)

---

## 1. Summary of Changes

Implemented automated build metadata generation (`app_version.g.dart` and `build_date.g.dart`) hooked into Gradle and Flutter compilation, and added the Build Date row to the About screen.

---

## 2. Detailed File Modifications

### 2.1. Standalone Build Scripts
- **[NEW] [tool/generate_app_version.dart](../tool/generate_app_version.dart)**:
  - Parses `pubspec.yaml` to extract the full `version` (e.g., `15.17.5+88`).
  - Writes `lib/core/constants/app_version.g.dart`.
  - Logs `app_version.g.dart updated → <version>`.
- **[NEW] [tool/generate_build_date.dart](../tool/generate_build_date.dart)**:
  - Formats current date as ISO `YYYY-MM-DD`.
  - Writes `lib/core/constants/build_date.g.dart`.
  - Logs `build_date.g.dart updated → <date>`.

### 2.2. Gradle Integration
- **[MODIFY] [android/app/build.gradle.kts](../android/app/build.gradle.kts)**:
  - Added resolution of Dart SDK from `local.properties` (`flutter.sdk`) or `FLUTTER_ROOT`.
  - Registered `generateBuildMetadata` task executing the two Dart scripts with input/output caching.
  - Wired task into `preBuild` and `compileFlutterBuild*` tasks.

### 2.3. Constants & UI
- **[NEW] [lib/core/constants/app_version.g.dart](../lib/core/constants/app_version.g.dart)**:
  - Generated constant `kAppVersion`.
- **[NEW] [lib/core/constants/build_date.g.dart](../lib/core/constants/build_date.g.dart)**:
  - Generated constant `kBuildDate`.
- **[MODIFY] [lib/screens/about_screen.dart](../lib/screens/about_screen.dart)**:
  - Imported `build_date.g.dart`.
  - Added "Build Date" display row in `_AboutView` showing `kBuildDate`.

### 2.4. Verification & Testing
- **[NEW] [test/build_metadata_test.dart](../test/build_metadata_test.dart)**:
  - Unit and widget tests verifying `kAppVersion`, `kBuildDate` format, and `AboutScreen` rendering.

---

## 3. Verification Results

- `dart run tool/generate_app_version.dart`: Output `app_version.g.dart updated → 15.17.5+88`.
- `dart run tool/generate_build_date.dart`: Output `build_date.g.dart updated → 2026-08-30`.
- `cmd /c gradlew.bat :app:generateBuildMetadata`: Task executed successfully and emitted updated log lines.
- `flutter analyze`: 0 issues found.
- `flutter test`: 455 passed (100%).
