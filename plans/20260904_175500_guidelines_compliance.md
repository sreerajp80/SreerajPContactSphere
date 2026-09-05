# Ensure Project Structure, Code, and Docs Adhere to Guidelines

**Status:** completed

## 1. Issue

An audit of the codebase, project structure, documentation, and configuration against the master guidelines (`docs/GUIDELINES_MANIFEST.md`, `docs/guidelines/guideline.md`, `docs/guidelines/flutter_project_engineering_standard.md`, `docs/guidelines/CLAUDE_MD_GUIDELINE.md`, `docs/guidelines/AGENTS_MD_GUIDELINE.md`, `docs/guidelines/DOCS_FOLDER_GUIDELINE.md`, and `docs/guidelines/release_process.md`) identified several compliance gaps:

1. **`CLAUDE.md` and `AGENTS.md` outdated structure**:
   - Both files still describe the project as an "early scaffold" with analyze errors ("missing files/classes and why flutter analyze currently errors"), which is long obsolete.
   - Missing canonical sections required by `CLAUDE_MD_GUIDELINE.md` and `AGENTS_MD_GUIDELINE.md`: Project Identity table, Build Flavors table, Security rules summary, Signing/keystore section, Localization rules, Code style/naming, Testing rules, Dependency constraints, Where things live (tree), Communication rules, Dos & Don'ts, and the mandatory privacy/relative-path clause in Workflow rules.

2. **Missing baseline documentation required by `DOCS_FOLDER_GUIDELINE.md` §6**:
   - `docs/workflow_rules.md` is missing from the mandatory baseline documentation suite.
   - `docs/project_structure.md` is missing from the mandatory baseline documentation suite.

3. **Stale/incomplete project documentation**:
   - `docs/dependencies.md`: Still claims packages are "not yet integrated", contains removed packages (`geolocator`, `flutter_ringtone_player`), and lacks recently integrated dependencies (`sqflite_sqlcipher`, `flutter_secure_storage`, `cryptography`, `logger`, `package_info_plus`, etc.) and the prohibited dependencies list.
   - `docs/release_process.md`: Missing the latest hardening standards from `docs/guidelines/release_process.md` (§6.5 Network Security Configuration, §6.6 Pre-Release Asset & Secret Leak Audit, §6.7 Exported Component Audit, updated checklist items, and post-build verification commands).
   - `docs/security.md`: Contains an absolute system path on line 4 violating the privacy/relative-path rule.
   - `docs/architecture.md`: Mentions that no `ChangeNotifierProvider` wiring exists, whereas `AppSettings` is now wired in `main.dart`.

4. **Android Network Security Hardening (`release_process.md §6.5`)**:
   - `android/app/src/main/res/xml/network_security_config.xml` does not exist to disable cleartext traffic and block user-installed certificates.
   - `android/app/src/main/AndroidManifest.xml` lacks explicit `android:usesCleartextTraffic="false"` and `android:networkSecurityConfig="@xml/network_security_config"` attributes on `<application>`.

## 2. Files to be changed

### New Files
- `android/app/src/main/res/xml/network_security_config.xml`
- `docs/workflow_rules.md`
- `docs/project_structure.md`

### Modified Files
- `CLAUDE.md`
- `AGENTS.md`
- `android/app/src/main/AndroidManifest.xml`
- `docs/dependencies.md`
- `docs/release_process.md`
- `docs/security.md`
- `docs/architecture.md`

## 3. The Plan for the Fix

### A. Root Instruction Files (`CLAUDE.md` & `AGENTS.md`)
1. Restructure both files to follow the Thin pointer profile from `CLAUDE_MD_GUIDELINE.md` and `AGENTS_MD_GUIDELINE.md` in canonical order:
   - Read-first banner & Project identity table
   - Required docs reference table
   - Hard non-negotiable rules (offline-first, open-source only, scoped storage, defensive error handling, isolated secret contacts)
   - Architecture rules (layers, dependency direction, database singleton)
   - Build & run commands (flavored dev/prod commands, analyze, test, obfuscation & split debug info)
   - Build flavors table (`dev` and `prod`)
   - Signing / keystore pointer
   - Security rules summary & link to `docs/security.md`
   - Localization rules (Material delegates, Malayalam fonts, English base)
   - Code style / naming rules
   - Testing rules (unit tests, SQLite mock tests, native JUnit unit tests)
   - Dependency constraints (explicit prohibited dependencies for offline dialer)
   - Directory layout tree
   - Workflow rules (plan before changing, explicit approval, log after changing, relative paths & zero local system details)
   - Communication rules (simple English)
   - Dos & Don'ts

### B. Baseline Documentation Suite
1. **Create `docs/workflow_rules.md`**:
   - Document plan-before-changing, explicit approval gate, and log-after-changing conventions.
   - Include relative repository paths only and zero local system details rules.
2. **Create `docs/project_structure.md`**:
   - Provide a complete directory and responsibility tree of the codebase (`lib/`, `android/`, `docs/`, `test/`, `assets/`).
3. **Update `docs/dependencies.md`**:
   - Mark integrated dependencies as integrated.
   - Remove stale entries (`flutter_ringtone_player`, `geolocator`).
   - Add security, encryption, and logging dependencies (`sqflite_sqlcipher`, `flutter_secure_storage`, `cryptography`, `logger`, `package_info_plus`, etc.).
   - Add explicit prohibited dependencies list (cloud BaaS, remote analytics, ad SDKs, remote trackers).
4. **Update `docs/release_process.md`**:
   - Sync sections §6.5 (Network Security Configuration), §6.6 (Asset & Secret Leak Audit), and §6.7 (Exported Component Audit) from upstream.
   - Add the corresponding verification steps to the release checklist.
   - Add post-build APK inspection commands (`aapt2`, `unzip`).
5. **Update `docs/security.md` & `docs/architecture.md`**:
   - In `docs/security.md`, replace absolute path with relative `docs/guidelines/security.md`.
   - In `docs/architecture.md`, update state management description to accurately document `AppSettings` provider.

### C. Android Hardening
1. **Create `android/app/src/main/res/xml/network_security_config.xml`**:
   - `<base-config cleartextTrafficPermitted="false">` with `<certificates src="system" />`.
2. **Update `android/app/src/main/AndroidManifest.xml`**:
   - Add `android:usesCleartextTraffic="false"` and `android:networkSecurityConfig="@xml/network_security_config"` to `<application>`.

## 4. Verification Plan

1. Static analysis: Run `flutter analyze` — verify zero issues found.
2. Unit and integration tests: Run `flutter test` — verify all tests pass.
3. Lint and format checks: Run `dart format --output=none --set-exit-if-changed .` or verify formatting.
4. Verify all internal links in `docs/` and root instruction files resolve to existing files.
