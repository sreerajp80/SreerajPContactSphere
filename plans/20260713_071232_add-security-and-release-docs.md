# Add docs/security.md and docs/release_process.md

**Status:** completed

## The issue

The app follows the shared Flutter guidelines listed in `docs/GUIDELINES_MANIFEST.md`.
ContactSphere is a **shipped app that handles PII and keeps a local encrypted store**, so by
the manifest's profile table it is in all three profiles:

- `Core Baseline`
- `Production App Extension` — it is signed and distributed to real users.
- `Sensitive Data Extension` — it holds contact PII, "secret" contacts, and a SQLCipher DB.

The `Production App Extension` requires a local `docs/release_process.md`, and the
`Sensitive Data Extension` requires a local `docs/security.md`. Both are missing. The `docs/`
folder currently has only `architecture.md`, `dependencies.md`, `known-gaps.md`,
`README.md`, and `GUIDELINES_MANIFEST.md`.

The manifest's "local copy wins" rule means we should copy the two master templates
(`l:\Android\Flutter_Guidelines\security.md` and `release_process.md`) into this app's `docs/`
and **fill them in with ContactSphere's actual decisions** (they ship as blank templates with
`<placeholder>` fields).

## Files to change

1. **Create `docs/security.md`** — the master security template, filled in for ContactSphere.
2. **Create `docs/release_process.md`** — the master release template, filled in for ContactSphere.

No code changes. Only two new documentation files.

## What the docs will say (filled from the real code, not aspirational)

Verified facts gathered from the codebase to fill the templates:

- **Encryption at rest:** SQLCipher via `sqflite_sqlcipher`; DB `smart_contacts.db`. Key is a
  random 256-bit hex passphrase minted on first launch, stored in the Android Keystore via
  `flutter_secure_storage` (`lib/database/db_key.dart`); `resetOnError:false` so a transient
  read error never wipes the key. Startup race fixed by a shared `_pending` future.
- **App lock:** two modes — device biometric/credential via `local_auth` (`AuthService`, gates
  secret contacts, fails closed) and an app-only PIN with a one-time recovery code, stored as
  salted SHA-256 hashes in the Keystore with a constant-time compare (`AppPinService`).
- **Screenshot protection:** `ScreenSecurity` (`lib/services/screen_security_service.dart`)
  toggles Android `FLAG_SECURE` by reference-counted reason via the `contact_sphere/telecom`
  channel.
- **Backup/restore:** portable, password-protected file (`.csbak`, magic `CSBK` v1) —
  PBKDF2-HMAC-SHA256 300k iters + AES-GCM-256 (`BackupService`), reusing the same primitives as
  P2P sync. Restore is a full replace, guarded by a schema-version check.
- **P2P LAN sync crypto:** ~320-bit per-session pairing code, PBKDF2 300k + AES-GCM per frame,
  wrong code = failed decryption = auth (see architecture.md).
- **Backup flag:** `android:allowBackup="false"` with `tools:replace` so no dependency manifest
  can flip it back — documented as intentional (secret contacts must not leave the device).
- **Permissions:** the full manifest permission set (call/telecom, contacts, camera, BLE,
  location, mic, notifications, INTERNET for LAN sync only) — filled into the permissions table
  with the "why / when / denial" columns.
- **Logging:** `AppLogger` (`logger` package); dev = trace to console, prod = info+ to console
  and rotating `app.log` (5 MB, 3 files). Missed-call name mirror in native prefs is plaintext
  by design (DB is encrypted) — noted.
- **Binary protections:** flag the gaps honestly — there is **no** `proguard-rules.pro` yet and
  release builds do not currently pass `--obfuscate`/`--split-debug-info`. These go in "Open
  risks / future hardening" and the release checklist, not marked as done.
- **Release build:** flavors `dev`/`prod` (`flavorDimensions "env"`); signing from
  `android/key.properties` (git-ignored) with debug-key fallback; version `15.8.9+30` from
  `pubspec.yaml`. Android-only (no iOS/Windows) — the iOS/Windows sections will be marked
  "not in scope" rather than deleted, so the template stays reusable.
- **No "Delete all data" purge** exists yet — recorded as an open item, not claimed as present.

The OWASP Mobile Top 10 table will be filled with the real status per item (verified /
risk-accepted with a note where obfuscation and ProGuard are still open).

## Plan for the fix

1. Copy each master template's structure.
2. Replace every `<placeholder>` with ContactSphere's real values from the code above.
3. Keep the section numbering and headings so the docs stay comparable to the masters.
4. Mark iOS/Windows sections "N/A — Android only".
5. Be honest about gaps (obfuscation, ProGuard, purge) in the open-risks and checklist sections.
6. After approval + implementation, write a change log to `change_log/`.
