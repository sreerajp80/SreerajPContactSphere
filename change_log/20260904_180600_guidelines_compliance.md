# Project Structure, Code, and Documentation Guidelines Compliance

**Plan reference:** `plans/20260904_175500_guidelines_compliance.md`

## Summary of Changes

Brought the repository structure, Android security configuration, root instructions, and living documentation into full alignment with the shared guidelines and engineering standards (`docs/GUIDELINES_MANIFEST.md`, `docs/guidelines/guideline.md`, `docs/guidelines/flutter_project_engineering_standard.md`, `docs/guidelines/CLAUDE_MD_GUIDELINE.md`, `docs/guidelines/AGENTS_MD_GUIDELINE.md`, `docs/guidelines/DOCS_FOLDER_GUIDELINE.md`, and `docs/guidelines/release_process.md`).

### 1. Root Instruction Files (`CLAUDE.md` and `AGENTS.md`)
- Overhauled both files to adopt the canonical 16-section Thin pointer profile.
- Replaced outdated "early scaffold" and "analyze errors" descriptions with current project architecture.
- Added standard tables and sections: Project Identity, Build Flavors, Hard Rules, Architecture Rules, Build Commands (with flavor flags and hardening), Signing/Keystore, Security Rules, Localization Rules, Code Style/Naming, Testing Rules, Dependency Constraints, Where Things Live, Workflow Rules (mandatory plan/log and relative-path/privacy rules), Communication Rules, and Dos & Don'ts.

### 2. Mandatory Baseline Documentation (`docs/`)
- Created `docs/workflow_rules.md`: Living documentation detailing plan-before-changing, explicit approval gate, log-after-changing, relative repository paths, and zero local system details rules.
- Created `docs/project_structure.md`: Living documentation detailing top-level project layout, Dart source layer layout, native Android directory structure, tests organization, and asset locations.
- Updated `docs/dependencies.md`: Marked all active dependencies as integrated, removed obsolete packages (`flutter_ringtone_player`, `geolocator`), added encryption and security libraries (`sqflite_sqlcipher`, `flutter_secure_storage`, `cryptography`, `logger`, `package_info_plus`), and documented the explicit prohibited dependencies list.
- Updated `docs/release_process.md`: Synchronized upstream additions (§6.5 Network Security Configuration, §6.6 Asset & Secret Leak Audit, §6.7 Exported Component Audit, updated checklist, and post-build APK verification commands).
- Updated `docs/security.md`: Converted absolute master blueprint path to a relative repository path (`docs/guidelines/security.md`).
- Updated `docs/architecture.md`: Updated entry point description to accurately reflect `AppSettings` `ChangeNotifierProvider` setup.

### 3. Android Network Security Configuration
- Created `android/app/src/main/res/xml/network_security_config.xml` to disallow cleartext HTTP traffic and restrict certificate trust to system anchors (blocking user CAs and proxy interception).
- Updated `android/app/src/main/AndroidManifest.xml` to set `android:usesCleartextTraffic="false"` and `android:networkSecurityConfig="@xml/network_security_config"` on `<application>`.

## Verification

- `flutter analyze`: Passed with zero issues.
- `flutter test`: Full test suite passed cleanly (458 tests passed).
- Checked that all cross-references across `CLAUDE.md`, `AGENTS.md`, and `docs/` point to existing files.
