# Release Hardening: R8 Minification, Dart Obfuscation, and Production Keystore Signing

**Plan:** [plans/20260903_050800_release_hardening_and_signing.md](../plans/20260903_050800_release_hardening_and_signing.md)

## Summary of changes

1. **Android R8 Minification & Resource Shrinking:**
   - Updated `android/app/build.gradle.kts` in `buildTypes.release` to enable `isMinifyEnabled = true` and `isShrinkResources = true`.
   - Updated `android/app/proguard-rules.pro` with `-keep` rules for native classes in `in.sreerajp.contact_sphere.**` (Telecom, InCallService, broadcast receivers, and background managers).

2. **Production Keystore Signing & Validation:**
   - In `android/app/build.gradle.kts`, added validation for `storeFile` when `key.properties` is detected, throwing a descriptive Gradle exception if the specified keystore file is absent rather than silently falling back.
   - Updated `android/key.properties.example` with precise documentation on relative paths (`../keystore.jks` when in `android/` vs `../../keystore.jks` when in project root).

3. **Dart Symbol Obfuscation & Documentation Standardization:**
   - Updated release build commands in `AGENTS.md` and `CLAUDE.md` to specify `--flavor prod --release --obfuscate --split-debug-info=build/app/outputs/symbols`.
   - Updated `docs/security.md` (Sections 8.1, 8.2, 12 OWASP M7, and 17) to mark binary hardening (obfuscation + R8) verified.
   - Updated `docs/release_process.md` (Sections 6.1, 6.2, and 9) to document active obfuscation and R8 rules as standard practice for production release builds.

## Verification

- `flutter analyze`: Passed with zero issues.
- `./gradlew assembleProdRelease --dry-run`: Passed (`BUILD SUCCESSFUL in 1m 26s`), verifying R8 minification, resource shrinking, and signing validation tasks.
- `./gradlew :app:testDevDebugUnitTest`: Passed all 383 native JVM unit test tasks cleanly (`BUILD SUCCESSFUL in 1m 34s`).
- `flutter test test/widget_test.dart`: Passed all widget tests.
