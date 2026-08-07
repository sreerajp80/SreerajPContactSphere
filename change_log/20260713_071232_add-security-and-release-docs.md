# Change log: add docs/security.md and docs/release_process.md

Implements plan `plans/20260713_071232_add-security-and-release-docs.md`.

## Why

`docs/GUIDELINES_MANIFEST.md` places ContactSphere in all three guideline profiles
(`Core Baseline`, `Production App Extension`, `Sensitive Data Extension`). The Production and
Sensitive-Data profiles each require a local doc that was missing: `docs/release_process.md`
(§21.1) and `docs/security.md` (§15, §21.2). Under the manifest's "local copy wins" rule, the
two master templates were copied into this app's `docs/` and filled in with the app's real
decisions.

## What changed

Two new files (documentation only — no code touched):

1. **`docs/security.md`** — the security blueprint filled from the codebase:
   - SQLCipher at-rest encryption; 256-bit random DB key in the Android Keystore
     (`lib/database/db_key.dart`, `resetOnError:false`, shared `_pending` race fix).
   - App lock: biometric (`AuthService`, fails closed) + app-PIN with recovery code
     (`AppPinService`, salted SHA-256, constant-time compare).
   - `FLAG_SECURE` via `ScreenSecurity`; `allowBackup=false` with `tools:replace`.
   - Password-protected backup (`CSBK` v1, PBKDF2-300k + AES-GCM-256, `BackupService`) and
     P2P LAN sync crypto.
   - Full permission inventory from `AndroidManifest.xml` (INTERNET is LAN-sync only).
   - Logging policy (`AppLogger`), missed-call name mirror documented as intentional plaintext.
   - OWASP Mobile Top 10 table with honest statuses.
   - **Open items called out, not hidden:** no `proguard-rules.pro`, no `--obfuscate` on release
     builds (M7 marked risk-accepted), and no in-app "Delete all data" purge (uninstall is the
     only full purge today).

2. **`docs/release_process.md`** — the release runbook filled for the app:
   - Version `15.8.9+30` from `pubspec.yaml`; keep-in-sync with `app_config.json`.
   - `dev`/`prod` flavors and signing wiring from `android/app/build.gradle.kts`
     (release key from git-ignored `android/key.properties`, debug-key fallback).
   - Android-only; iOS/Windows sections marked not in scope.
   - Project-specific gotchas folded into the checklist: run `flutter build apk` with
     `--flavor`, run sqlite-backed tests one file per invocation, and confirm the install
     actually replaced the previous build.

## Verification

Documentation-only change; no code or build affected. Facts were taken from the current source
(`db_key.dart`, `app_pin_service.dart`, `auth_service.dart`, `backup_service.dart`,
`screen_security_service.dart`, `AndroidManifest.xml`, `build.gradle.kts`, `pubspec.yaml`,
`docs/architecture.md`) rather than the template placeholders.
