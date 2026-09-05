# CLAUDE.md — SreerajP Contacts Sphere

This file is read by Claude Code at the start of every session in this repository.
Read it before making any change. See the docs table below for full architectural and technical detail.

---

## Project identity

| Field | Value |
|-------|-------|
| App name | SreerajP Contacts Sphere (`smart_contacts_dialer`) |
| Type | Advanced contacts and dialer app backed by local SQLite |
| Platform(s) | Android only (`android/` configured; minSdk 24, targetSdk 35) |
| Package / org id | `in.sreerajp.contact_sphere` |
| Flutter SDK | `3.24.x` or higher |
| Dart SDK | `^3.12.0` |
| State management | `Provider` (`AppSettings`) + `setState` (local screen state) |
| Navigation | Flutter `Navigator` (`MaterialPageRoute` + swipe gestures) |
| Database | `sqflite` + `sqflite_sqlcipher` (AES-256 encrypted at rest) |
| Orientation | Portrait only |
| Connectivity | Fully offline — no internet servers, no telemetry, no cloud |

---

## Read these docs before working

| Document | Read when |
|----------|-----------|
| [docs/architecture.md](docs/architecture.md) | Changing structure, screens, state, services, models, repositories, Telecom bridge |
| [docs/security.md](docs/security.md) | Touching permissions, logging, storage, crypto, manifest, biometric auth |
| [docs/release_process.md](docs/release_process.md) | Building a release, versioning, release checklist, APK verification |
| [docs/workflow_rules.md](docs/workflow_rules.md) | Plan-before-changing, approval gate, log-after-changing rules |
| [docs/project_structure.md](docs/project_structure.md) | Navigating the file tree and directory responsibilities |
| [docs/dependencies.md](docs/dependencies.md) | Checking approved dependencies and prohibited package list |
| [docs/known-gaps.md](docs/known-gaps.md) | Checking declared vs. deferred platform features and limits |
| [docs/GUIDELINES_MANIFEST.md](docs/GUIDELINES_MANIFEST.md) | Pointer to the shared Flutter guidelines submodule |
| [docs/guidelines/flutter_project_engineering_standard.md](docs/guidelines/flutter_project_engineering_standard.md) | Any code change — layers, naming, testing, accessibility |
| [docs/guidelines/guideline.md](docs/guidelines/guideline.md) | About config, release keystore, baseline layout, build commands |

---

## Hard rules (must follow — these override convenience)

1. **Fully offline-first.** The app never contacts an external internet server. All networking permissions (`INTERNET`, Wi-Fi) are used strictly for direct peer-to-peer LAN sync on the local network.
2. **Open source only.** Only permissive open-source packages (MIT, BSD, Apache 2.0). Never introduce commercial, proprietary, or closed-source SDKs.
3. **Scoped storage & privacy.** Never request broad external storage permissions. Use scoped file picking (`file_selector`) and system share sheets (`share_plus`).
4. **Secret contacts isolation.** Secret contacts (`is_secret == 1`) must remain locked behind biometric/PIN authentication at all times, are never synced to the Android system contacts provider, and are excluded from unauthenticated exports.
5. **Defensive data handling.** Database operations modifying contacts and reciprocal relationships must execute in atomic transactions (`db.transaction`). Never leave orphaned database rows.

---

## Architecture rules

- **Layered layout**: `screens → repositories / services → database → models`.
- **Layer boundaries**: UI widgets must not execute raw SQL queries, inspect SharedPreferences keys directly, or invoke platform channel methods directly. All data access funnels through `ContactRepository`, `RelationshipRepository`, or dedicated services.
- **Database singleton**: `DatabaseHelper` owns the SQLCipher schema and database instance. Database keys reside in Android Keystore via `flutter_secure_storage`.
- **Models**: Plain immutable Dart data classes with defensive `fromMap` and `toMap` converters.
- **State management**: `AppSettings` is provided at app root via `ChangeNotifierProvider` for global settings (theme, accent color, fonts, SIM choices). Individual screens manage their transient UI state using `setState`.

---

## Build & run commands

```bash
flutter pub get                        # install dependencies
flutter run --flavor dev               # run dev flavor on connected device
flutter run --flavor prod              # run prod flavor on connected device
flutter analyze                        # static analysis (must be zero warnings)
flutter test                           # run full test suite

# Production release APK (split per ABI, hardened with obfuscation)
flutter build apk --flavor prod --release \
  --split-per-abi --obfuscate --split-debug-info=build/symbols/android-prod/

# Production Google Play App Bundle
flutter build appbundle --flavor prod --release \
  --obfuscate --split-debug-info=build/symbols/android-prod/
```

> The app defines flavors (`dev` and `prod`). Always specify `--flavor` when invoking `flutter run` or `flutter build`.

---

## Build flavors

| Flavor | Application ID | Display Name | Signing |
|--------|----------------|--------------|---------|
| `dev` | `in.sreerajp.contact_sphere.dev` | SreerajP Contacts Sphere Dev | Android debug keystore |
| `prod` | `in.sreerajp.contact_sphere` | SreerajP Contacts Sphere | Production release keystore |

---

## Signing / keystore

- Release keystore properties live at `android/key.properties` (git-ignored, never committed).
- Template provided at `android/key.properties.example`.
- Keystores (`*.jks`, `*.keystore`) and `key.properties` are strictly excluded in `.gitignore`.
- Fallback to debug key occurs automatically on machines lacking `android/key.properties` for testing.

---

## Security rules

- Never log personal data, phone numbers, contact names, crypto keys, or passwords. All logging must use `AppLogger` (`lib/core/logging/app_logger.dart`).
- Database is encrypted at rest using SQLCipher with a 256-bit AES key held in the Android Keystore.
- Sensitive screens (e.g., app lock PIN, secret contacts list) enforce `FLAG_SECURE` to prevent screenshot leaks and task switcher exposure.
- Cleartext HTTP traffic is disabled across the application (`android:usesCleartextTraffic="false"` and `android:networkSecurityConfig="@xml/network_security_config"`).

---

## Localization rules

- Minimum setup requirement: declare `GlobalMaterialLocalizations`, `GlobalWidgetsLocalizations`, and `GlobalCupertinoLocalizations` delegates in `MaterialApp` (configured in `lib/main.dart`).
- Supported locales: `en` (base) and `ml` (Malayalam).
- Malayalam fonts (`Manjari`, `Anek Malayalam`, `Noto Sans Malayalam`) are bundled in `assets/fonts/` for Malayalam script rendering.
- Section indexing and avatar generation use `characters` package for grapheme-cluster safety.

---

## Code style / naming

- Files: `snake_case.dart`. Classes: `PascalCase`. Variables/functions: `camelCase`. Constants: `lowerCamelCase` or `kPascalCase`.
- Imports: Always prefer package imports (`package:smart_contacts_dialer/...`) over relative imports across directory boundaries.
- Formatting: Format code with `dart format .` and maintain `flutter analyze` at zero warnings.
- Constructors: Prefer `const` constructors wherever possible.

---

## Testing rules

- Mirror `lib/` layout in `test/` (e.g. `test/repositories/`, `test/services/`).
- Database tests use `sqflite_common_ffi` with in-memory SQLite to test real schema queries and migrations.
- Pure logic (T9 matching, phonetic algorithms, phone normalization, crypto) must have dedicated unit tests.
- Native JVM unit tests reside in `android/app/src/test/` (run with `cd android && ./gradlew :app:testDevDebugUnitTest`).

---

## Dependency constraints

- **Prohibited packages**: Remote telemetry/analytics (Firebase, Mixpanel), crash reporters (Crashlytics, Sentry), ads SDKs, cloud BaaS, and HTTP clients (`http`, `dio`).
- Every new package added to `pubspec.yaml` must be vetted for license compatibility, offline conformance, and absence of hidden networking.

---

## Where things live

```text
CLAUDE.md            # this file — project rules for Claude Code
AGENTS.md            # project rules for AI agents and LLMs
docs/                # design docs, security blueprint, release runbook
plans/               # change plans (yyyymmdd_hhMMss_<slug>.md)
change_log/          # change logs (yyyymmdd_hhMMss_<slug>.md)
lib/                 # Flutter application Dart source code
android/             # Android native code, Telecom InCallService, Gradle build
test/                # unit, repository, and widget tests
assets/              # runtime config (app_config.json) and bundled fonts
```

---

## Workflow rules (mandatory — from global rules)

Every change follows plan-before-changing and log-after-changing:

1. **Plan before changing.** Write a full plan to `plans/` named
   `yyyymmdd_hhMMss_<short-slug>.md` with a `**Status:** pending` line, the files to change, the issue,
   and the fix. Then **STOP and get explicit approval** before editing/creating/deleting any
   project file (other than the plan). A question or ambiguous reply is not approval.
2. **Log after changing.** After implementing, write a change log to `change_log/` named
   `yyyymmdd_hhMMss_<short-slug>.md` describing what changed and referencing its plan.
3. **Relative paths & privacy only.** `plans/` and `change_log/` files are committed and may become
   public on the internet. They MUST use relative repository paths only (never absolute system
   paths like `C:\...`, `l:\...`, or `file:///...`). They MUST NOT contain any **local system
   details** — OS user name, computer/host name, home or drive-letter paths, network share names,
   LAN/internal IP addresses, local server URLs with ports, device serial numbers, personal email
   addresses — or any secret (API keys, tokens, passwords, keystore passphrases, credentials, PII).
   Write them as if a stranger will read them; nothing should reveal the machine they came from.

Create `plans/` and `change_log/` if they do not exist.

---

## Communication rules

- **Always use simple English.** Write all responses, plans, change logs, and explanations in
  plain, simple English. Short sentences, common words. Explain any jargon you must use.

---

## What Claude must always / never do

**Always:**
- Read this file and relevant `docs/` files before making any modifications.
- Obtain explicit user approval before modifying code or documentation files.
- Run `flutter analyze` and `flutter test` after code changes.
- Keep the database schema and migrations synchronized in `DatabaseHelper`.

**Never:**
- Never call SQLite queries directly from UI widgets.
- Never add internet networking dependencies or analytics trackers.
- Never log user contact data, passwords, or cryptographic keys.
- Never put machine-specific absolute file paths or local usernames in committed files.
