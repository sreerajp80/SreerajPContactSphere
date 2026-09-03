# Release Hardening: R8 Minification, Dart Obfuscation, and Production Keystore Signing

**Status:** planned

## The issue

Currently, release builds of ContactSphere have three gaps in their release binary protection and signing setup:

1. **Android R8 Minification & Resource Shrinking:**
   In `android/app/build.gradle.kts`, `buildTypes.release` sets `proguardFiles(...)` but omits `isMinifyEnabled = true` and `isShrinkResources = true`. As a result, native Kotlin code in `classes.dex` and unused resources remain un-minified and un-obfuscated.
2. **Dart Symbol Obfuscation:**
   Flutter release commands in documentation (`AGENTS.md`, `CLAUDE.md`, `docs/release_process.md`, `docs/security.md`) do not standardize the `--obfuscate --split-debug-info=...` flags. Without these flags, Dart class names, field names, and method signatures remain identifiable in `libapp.so`.
3. **Production Keystore Signing & Validation:**
   While `android/keystore.jks` and `android/key.properties` exist and are valid, the build configuration in `android/app/build.gradle.kts` does not validate that `storeFile` exists when `key.properties` is loaded. If misconfigured, it silently falls back or produces cryptic Gradle errors. Additionally, `android/key.properties.example` comments need alignment with the actual keystore location (`android/keystore.jks`).

## Proposed Changes

### 1. Android R8 Minification & Resource Shrinking
- File: `android/app/build.gradle.kts`
  - In `buildTypes.release`, add:
    ```kotlin
    isMinifyEnabled = true
    isShrinkResources = true
    ```
- File: `android/app/proguard-rules.pro`
  - Add keep rules for native classes in `in.sreerajp.contact_sphere.**` to ensure Telecom, InCallService, and broadcast receiver classes and methods remain intact through R8 shrinking and optimization.

### 2. Production Keystore Signing Verification
- File: `android/app/build.gradle.kts`
  - In `signingConfigs.getByName("release")` (or creation block), ensure `storeFile` is validated before assigning. If `key.properties` exists but `storeFile` is missing on disk, fail early with a clear descriptive message.
- File: `android/key.properties.example`
  - Ensure the example template and comments accurately document the relative path (`../keystore.jks` when located in `android/` or `../../keystore.jks` if at repo root).

### 3. Dart Symbol Obfuscation & Release Documentation
- File: `AGENTS.md` and `CLAUDE.md`
  - Update release build commands to include `--flavor prod --obfuscate --split-debug-info=build/app/outputs/symbols`.
- File: `docs/security.md`
  - Update Section 8.1 (Obfuscation), Section 8.2 (R8/ProGuard), Section 12 (OWASP M7: closed/verified), and Section 17 (Open Risks).
- File: `docs/release_process.md`
  - Update Section 6.1, Section 6.2, and Section 9 commands to reflect that `--obfuscate` and `--split-debug-info` are now standard.

## Files to Modify

- `android/app/build.gradle.kts`
- `android/app/proguard-rules.pro`
- `android/key.properties.example`
- `AGENTS.md`
- `CLAUDE.md`
- `docs/security.md`
- `docs/release_process.md`

## Verification Plan

### Automated / CLI Verification
1. Run `flutter analyze` to ensure Dart codebase remains clean.
2. Run unit tests (`flutter test test/widget_test.dart` or JVM tests `cd android && ./gradlew :app:testDevDebugUnitTest`) to verify no regressions.
3. Test Gradle configuration & R8 task resolution:
   Run `cd android && ./gradlew assembleProdRelease --dry-run` to ensure the Gradle DSL, R8 minification configuration, and signing configurations resolve cleanly without syntax or configuration errors.
4. Verify keystore properties match `android/keystore.jks`.
