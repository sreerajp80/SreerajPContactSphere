# Release Process

This is ContactSphere's filled-in copy of the master release runbook
(`l:\Android\Flutter_Guidelines\release_process.md`). Per the manifest rule, this local copy is
the source of truth for this app. ContactSphere is shipped to real users, so it is in the
**Production App Extension** profile and this document is required.

Android is the only configured platform. The iOS and Windows sections are kept for template
parity but marked **not in scope**.

---

## 1. Release Scope

- App: `ContactSphere` (`smart_contacts_dialer`, applicationId `in.sreerajp.contact_sphere`)
- Release profile: **public** (direct APK/AAB distribution).
- Supported release platforms:
  - `Android` — the only configured target.
  - `iOS` — **not in scope**.
  - `Windows` — **not in scope**.
- Engineering standard profiles in force:
  - `Core Baseline`
  - `Production App Extension`
  - `Sensitive Data Extension` (see `docs/security.md`)

---

## 2. Roles And Responsibilities

| Role | Responsibility | Owner |
|------|----------------|-------|
| Release owner | Coordinates release readiness and final sign-off | Sreeraj P |
| Engineering | Code freeze, fixes, validation | Sreeraj P |
| QA | Test execution and regression sign-off | Sreeraj P |
| Distribution owner | Builds, signs, and distributes artifacts | Sreeraj P |

Single-maintainer project; one person currently fills every role. Keep the checklist honest even
so — it is the substitute for a second reviewer.

---

## 3. Versioning Policy

- Version format: `MAJOR.MINOR.PATCH+BUILD` (currently `15.8.9+30`).
- Source of truth: `pubspec.yaml` `version:`, which drives `flutter.versionName` /
  `flutter.versionCode` in `android/app/build.gradle.kts` and `PackageInfo.fromPlatform()`.
- **Keep in sync:** `assets/config/app_config.json` (version/build) must match `pubspec.yaml`.
  `ConfigService.loadAndVerify()` logs a debug drift note if they differ; the About screen shows
  the config values.
- Build-number increment rule: bump `+BUILD` on every distributed build; bump the semantic part
  per the size of the change.
- Git tag format: `vX.Y.Z`.

---

## 4. Branch And Merge Policy

- Release branch strategy: **trunk-based on `main`** (single maintainer).
- Hotfix strategy: commit the fix to `main`, bump the build number, and re-run the full checklist.
- Required checks before a release commit:
  - `flutter analyze` clean.
  - `flutter test` green (note the per-file sqlite test caveat in section 8).
  - Plan + change-log written per the project workflow rules (`CLAUDE.md`).

---

## 5. Environment And Flavor Matrix

Flavors are defined in `android/app/build.gradle.kts` under `flavorDimensions "env"`.

| Flavor | Mode | Purpose | Example Command |
|--------|------|---------|-----------------|
| `dev` | `debug` | Local development | `flutter run --flavor dev` |
| `dev` | `release` | Release-like QA (app name "ContactSphere Dev", id suffix `.dev`) | `flutter build apk --flavor dev --release` |
| `prod` | `release` | Final release artifact (app name "ContactSphere", id `in.sreerajp.contact_sphere`) | See section 9 |

- `dev` applies `applicationIdSuffix = ".dev"` and `versionNameSuffix = "-dev"`, so it installs
  side-by-side with prod and is visibly labelled.
- The Dart side reads the flavor via `AppFlavorConfig` (`AppFlavorConfig.instance.isDev`), which
  gates verbose logging (see `docs/security.md` §9).

> **Flavor signal at build time.** On Android, `--flavor <name>` is sufficient — the Flutter
> tool injects the flavor and rejects setting it via `--dart-define`. (Windows would use
> `--dart-define=APP_FLAVOR=<name>`, but Windows is not in scope.)

> **Known gotcha:** a plain `flutter build apk` (no `--flavor`) exits 1 at the final APK-lookup
> step because the output path is flavor-specific — but the flavored APKs are still built. Always
> pass `--flavor`.

---

## 6. Release Build Hardening

### 6.1 Obfuscation And Debug Symbols

> **Current status: Configured & enforced for production builds.**
> Every prod release build includes `--obfuscate` and `--split-debug-info`.

Every prod release build MUST include:

```bash
--obfuscate
--split-debug-info=build/app/outputs/symbols
```

Symbol archive policy: archive the symbols directory securely after every prod build, retain for
the lifetime of the released version, never commit it (already covered by `.gitignore`), and store it
alongside the artifact (e.g. `releases/v15.8.9/symbols/`). Without the symbols, stack traces
from that version are permanently unreadable.

### 6.2 ProGuard / R8 (Android)

> **Current status: Configured in `android/app/build.gradle.kts` and `android/app/proguard-rules.pro`.**

Android release builds run R8 with `isMinifyEnabled = true` and `isShrinkResources = true`.
ProGuard rules in `proguard-rules.pro` preserve the app's native classes under `in.sreerajp.contact_sphere.**`
(InCallService, Telecom, Receivers, and Managers) and silence unbundled ML Kit warnings. Always run
a full release build test after adding a dependency — R8 can silently strip reflection-only
classes (symptom: `ClassNotFoundException` / `NoSuchMethodException` in release only).

### 6.3 App Size Analysis

Run before every release to catch dependency bloat:

```bash
flutter build apk --flavor prod --release --analyze-size
```

Record the output in the release evidence section and compare against the previous release. A
>10% increase without a documented reason is a review item.

Size budgets:

| Platform | Target | Hard Limit |
|----------|--------|------------|
| Android APK arm64 | < 30 MB | 50 MB |
| Android AAB download | < 20 MB | 40 MB |

### 6.4 Debuggable Verification (Android)

Verify `android:debuggable` is `false` in the merged release manifest before every release.
`build.gradle.kts` does not set `isDebuggable` on the release build type, so it defaults to
false — but confirm per release:

```powershell
# PowerShell (this project's primary shell)
aapt2 dump badging build\app\outputs\apk\prod\release\app-arm64-v8a-prod-release.apk `
  | Select-String -Pattern debuggable
```

```bash
# bash equivalent
aapt2 dump badging build/app/outputs/apk/prod/release/app-arm64-v8a-prod-release.apk \
  | grep -i debuggable
```

Expected: **no** `application-debuggable` line. If it appears, investigate
`buildTypes.release.isDebuggable` in `build.gradle.kts`. Alternatively, Android Studio →
Build → Analyze APK → AndroidManifest.xml.

### 6.5 Network Security Configuration And Cleartext Traffic

Verify that cleartext HTTP traffic is disabled for production builds:
- Ensure `android:usesCleartextTraffic="false"` in the merged manifest (enforced by default on Android 9+ / API 28+).
- In `res/xml/network_security_config.xml`, verify:
  - `<base-config cleartextTrafficPermitted="false">` is in place.
  - In production builds, no `<trust-anchors>` allow user-installed certificates (which would enable easy MITM proxy inspection via tools like Charles, Proxyman, or Burp Suite).

### 6.6 Pre-Release Asset And Secret Leak Audit

While `--obfuscate` scrambles compiled Dart logic in `libapp.so`, **files in the APK's `assets/` and `res/` directories remain completely unencrypted**. Any party with access to the APK can inspect its contents with `unzip` or `apktool`.

Before releasing, audit the bundled assets in the APK:

```bash
# bash / zsh
unzip -l build/app/outputs/apk/prod/release/app-arm64-v8a-prod-release.apk "assets/*"
```

```powershell
# PowerShell (Windows)
tar -tf build\app\outputs\apk\prod\release\app-arm64-v8a-prod-release.apk | Select-String "assets/"
```

**Audit checklist:**
- [ ] No `.env`, `.env.production`, or secret credentials files are packaged in `assets/`.
- [ ] No private keys, `.pem`, `.p12`, or test keystores exist in assets.
- [ ] No raw database files containing seed customer or internal test data are bundled.
- [ ] Only declared runtime config (e.g., `assets/config/app_config.json`) is included.

### 6.7 Exported Component Audit

Inspect all declared activities, services, and broadcast receivers in the merged manifest:
- Every component with an `<intent-filter>` automatically requires an explicit `android:exported` attribute.
- Components intended strictly for internal app usage MUST specify `android:exported="false"`.
- If an activity or receiver must be exported (e.g., deep linking or Telecom `InCallService`), ensure it enforces proper input validation and permission controls.

---

## 7. Signing And Secret Handling

> Keystore location, `key.properties` naming, and `.gitignore` rules: see the master
> `guideline.md §2` (source of truth). This app's build wiring is in `android/app/build.gradle.kts`.

- Signing config location: `android/key.properties` (git-ignored; template at
  `android/key.properties.example`). It provides `keyAlias`, `keyPassword`, `storeFile`,
  `storePassword`. `storeFile` is resolved relative to `android/app`, so `../../keystore.jks`
  points at the repo root.
- **Debug-key fallback:** if `key.properties` is absent (a machine/CI without the production
  keystore), the release build falls back to the shared debug key so `flutter run --release`
  still works. **A real public release MUST be built on a machine with `key.properties` present**
  — verify the artifact is signed with the release key, not the debug key.
- Keystore or certificate ownership: Sreeraj P.
- Rules:
  - Signing material never lives in source control.
  - The keystore MUST be backed up in at least two separate secure locations — losing it means
    being unable to ship signed updates users can install over the existing app.

---

## 8. Release Checklist

Complete before every release.

### Code And Quality

- [ ] `flutter analyze` passed with zero warnings.
- [ ] `flutter test` passed.
- [ ] No critical / release-blocking bugs open.
- [ ] `pubspec.yaml` version and `assets/config/app_config.json` version/build **match**.

### Performance

- [ ] Release build checked for jank on the primary flow (contact list, dialer, in-call).
- [ ] App size analyzed and within budget (section 6.3).
- [ ] Startup verified acceptable on a mid-range device (dev target: moto g54).

### Security & Hardening

- [ ] `--obfuscate` and `--split-debug-info` applied to all release builds.
- [ ] Debug symbols archived securely for this version.
- [ ] ProGuard / R8 rules verified (`proguard-rules.pro`).
- [ ] `android:debuggable=false` confirmed in the merged manifest (section 6.4).
- [ ] `android:allowBackup=false` (with `tools:replace`) verified in merged manifest.
- [ ] Cleartext traffic disabled (`usesCleartextTraffic=false`) and network security config verified (§6.5).
- [ ] Pre-release asset audit passed — no `.env`, keys, or seed data bundled in APK `assets/` (§6.6).
- [ ] Manifest component export audit completed — no accidental `android:exported="true"` (§6.7).
- [ ] Manifest and permission review done — no unnecessary permissions; `INTERNET` still LAN-only.
- [ ] OWASP Mobile Top 10 table reviewed (`docs/security.md` §12).
- [ ] Artifact signed with the **release** key, not the debug fallback (section 7).
- [ ] Backup restore and vCard/CSV import paths revalidated.

### Product And Documentation

- [ ] `pubspec.yaml` version updated and tagged.
- [ ] Release notes / change log updated.
- [ ] User-visible behavior changes documented.

### Artifact Validation

- [ ] Intended artifact built successfully **with `--flavor prod`** (a no-flavor build fails at
      the APK-lookup step — see section 5).
- [ ] Artifact installs and launches on a clean device.
- [ ] Correct flavor confirmed (prod shows app name "ContactSphere", **no** "-dev" suffix / id
      suffix). Confirm the install actually replaced the old build.
- [ ] Version name and build number correct in the installed app (About screen).
- [ ] Tested end-to-end on the **release** build, not just debug.

---

## 9. Android Release Steps

1. Pull the intended release commit and verify the tree is clean (`git status`).
2. Verify the version in `pubspec.yaml` and that `app_config.json` matches.
3. Confirm `android/key.properties` is present (release key, not debug fallback).
4. Fetch dependencies: `flutter pub get`.
5. Run analyze and tests: `flutter analyze` and `flutter test`.
6. Build the prod artifact(s) with the hardening flags (`--release`, `--obfuscate`, `--split-debug-info`, `--split-per-abi`).
7. Run size analysis and record the output.
8. Verify `android:debuggable=false` and `android:allowBackup=false` in the merged manifest (§6.4).
9. Perform pre-release asset extraction audit to ensure no secrets were packaged in `assets/` (§6.6).
10. Verify naming, signing, installability, and flavor on a physical device.
11. Archive debug symbols from `build/symbols/` or `build/app/outputs/symbols`.
12. Distribute the artifact.
13. Tag the release: `git tag v<version>` and push.

### Android Build Commands

**Bash / macOS / Linux:**
```bash
flutter pub get
flutter analyze
flutter test

VERSION=$(grep '^version:' pubspec.yaml | cut -d' ' -f2)

# Split APKs for direct distribution (hardened with obfuscation)
flutter build apk \
  --flavor prod \
  --release \
  --split-per-abi \
  --obfuscate \
  --split-debug-info=build/symbols/android-prod-$VERSION/

# App Bundle for Google Play Store (hardened with obfuscation)
flutter build appbundle \
  --flavor prod \
  --release \
  --obfuscate \
  --split-debug-info=build/symbols/android-prod-$VERSION/

# Size analysis
flutter build apk --flavor prod --release --analyze-size
```

**PowerShell (Windows):**
```powershell
flutter pub get
flutter analyze
flutter test

$VERSION = (Get-Content pubspec.yaml | Select-String '^version:').ToString().Split(' ')[1].Trim()

# Split APKs for direct distribution
flutter build apk `
  --flavor prod `
  --release `
  --split-per-abi `
  --obfuscate `
  --split-debug-info="build/symbols/android-prod-$VERSION/"

# App Bundle for Google Play Store
flutter build appbundle `
  --flavor prod `
  --release `
  --obfuscate `
  --split-debug-info="build/symbols/android-prod-$VERSION/"

# Size analysis
flutter build apk --flavor prod --release --analyze-size
```

### Post-Build APK Verification Commands

```bash
# Verify no debuggable flag and verify allowBackup=false
aapt2 dump badging build/app/outputs/apk/prod/release/app-arm64-v8a-prod-release.apk | grep -i debuggable
aapt2 dump xmltree build/app/outputs/apk/prod/release/app-arm64-v8a-prod-release.apk --file AndroidManifest.xml | grep -i allowBackup

# Audit asset bundle for unencrypted secrets
unzip -l build/app/outputs/apk/prod/release/app-arm64-v8a-prod-release.apk "assets/*"
```

---

## 10. iOS Release Steps

**Not in scope** — no `ios/` target. Fill in per the master template if iOS is ever added.

---

## 11. Windows Release Steps

**Not in scope** — no `windows/` target. Fill in per the master template if Windows is ever added.

---

## 12. Distribution Channels

| Channel | Artifact | Audience | Notes |
|---------|----------|----------|-------|
| Direct download / sideload | `apk` (split per ABI) | End users | Signed with the release keystore |
| Store channel (if used) | `aab` | End users | App Bundle from section 9 |

---

## 13. Rollback And Hotfix Process

- Rollback trigger: a crash on launch, data-loss bug, or a security regression in a shipped build.
- Rollback method: stop distributing the affected version; ship a hotfix build with a bumped
  build number.
- Hotfix branch naming: n/a (trunk-based) — commit to `main`.
- Verification after a hotfix: **the full release checklist (section 8) MUST be completed even
  for a hotfix.** Archive symbols for the hotfix build too (once obfuscation is adopted).

---

## 14. Release Evidence

Record after each release.

- Test report: `<local run output / date>`
- Size analysis output: `<location>`
- Debug symbols archive: `<secure location — once obfuscation is adopted>`
- Built artifact: `<location>`
- Release notes: `<location / change_log entry>`
- Distribution record: `<where uploaded / shared>`
- OWASP checklist sign-off: `<signed by / date>`

---

## 15. Post-Release Checks

- [ ] Post-install smoke test on a clean device (this is an offline app — no remote crash
      telemetry to watch).
- [ ] User-reported issues triaged.
- [ ] Release tag created and pushed: `git tag v<version> && git push origin v<version>`.
- [ ] Debug symbols confirmed in the secure archive (once obfuscation is adopted).
- [ ] Follow-up tasks recorded.
