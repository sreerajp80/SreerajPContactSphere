# Security

This is ContactSphere's filled-in copy of the master security blueprint
(`l:\Android\Flutter_Guidelines\security.md`). Per the manifest rule, this local copy is the
source of truth for this app. Keep it current — review it before every production release
(see section 18) and whenever a sensitive-data flow changes.

ContactSphere handles contact PII, "secret" contacts, and a locally encrypted database, so it
is in the **Sensitive Data Extension** profile. This document is required.

---

## 1. Security Scope

- App: `ContactSphere` (`smart_contacts_dialer`, applicationId `in.sreerajp.contact_sphere`)
- Data sensitivity level: **moderate** — personal contact data (names, numbers, emails,
  addresses, relationships, call history) plus user-marked **secret contacts**. No health,
  finance, or credential data.
- Engineering standard profiles in force:
  - `Core Baseline`
  - `Production App Extension`
  - `Sensitive Data Extension`
- Platforms in scope:
  - `Android` — the only configured platform.
  - `iOS` — **not in scope** (no `ios/` folder).
  - `Windows` — **not in scope**.

---

## 2. Security Objectives

- Protect the local contact database from casual extraction on a lost or stolen device — the DB
  is unreadable off-device without the Keystore-held key.
- Keep **secret contacts** behind an authentication gate at all times.
- Prevent accidental disclosure through logs, backups, screenshots, or exports.
- Keep device-to-device transfers (BLE share, P2P LAN sync) confidential and authenticated.
- Preserve recoverability (portable password-protected backup) without weakening the at-rest
  encryption.

---

## 3. Threat Model Summary

### In Scope Threats

- **Lost or stolen device** — someone with physical possession of a locked or unlocked device
  trying to read contact data off the storage.
- **Casual local access by another user** — someone who picks up the unlocked phone and opens
  the app, trying to view secret contacts.
- **Raw DB file extraction** — pulling `smart_contacts.db` off the device (adb, file manager,
  a backup) and trying to read it elsewhere.
- **Accidental plaintext export / leakage** — data escaping through logs, the Recents thumbnail,
  screenshots, or an unencrypted export.
- **Eavesdropping on a device-to-device transfer** — sniffing the BLE or Wi-Fi LAN sync payload.

### Out Of Scope Threats

- **Fully compromised / rooted device** — a root-level attacker can read the Keystore-decrypted
  key from a running process; no app-level control defends against this.
- **Physical hardware / chip-level attacks** on the secure element.
- **OS-level compromise** or a malicious OEM build.
- **Nation-state adversaries** and targeted forensic extraction tooling.

---

## 4. Sensitive Data Inventory

| Data Type | Example | Where It Exists | Protection Required |
|-----------|---------|-----------------|---------------------|
| Contact PII | Names, phone numbers, emails, addresses | SQLCipher DB `smart_contacts.db` | Encrypted at rest; excluded from OS backup |
| Secret contacts | Contacts flagged `is_secret` | Same DB, gated in UI | Encrypted at rest + auth gate before view |
| Call & interaction history | `call_logs`, `interactions`, `reminders` | Same DB | Encrypted at rest |
| Relationships | Reciprocal links between contacts | Same DB | Encrypted at rest |
| DB encryption key | 256-bit random hex passphrase | Android Keystore (`flutter_secure_storage`) | Never in APK, logs, or backup; never leaves device |
| App PIN + recovery code | Unlock PIN, one-time recovery code | Android Keystore, salted SHA-256 hash only | Raw values never persisted |
| Backup files | `.csbak` portable backup | User-chosen location (share sheet) | Encrypted with user passphrase (PBKDF2 + AES-GCM) |
| Missed-call name mirror | Digit→name map for the missed-call notification | Native `SharedPreferences` (RINGER_PREFS) | **Plaintext by design** — see note below |
| Emergency card (master copy) | Blood group, allergies, medicines, conditions, notes, address, people to call | SQLCipher DB (`emergency_info`, `emergency_contacts`) | Encrypted at rest |
| Emergency card (lock-screen copy) | Only the lines the user switched on | Native `SharedPreferences` (`contact_sphere_emergency`) | **Plaintext by design, opt-in** — see note below |
| Audit log | Before/after copies of changed contacts (`audit_log`) | Same SQLCipher DB | Encrypted at rest; local only — see note below |

> **Audit log.** `audit_log` keeps a full JSON snapshot of each contact before and after every
> change, which makes it as sensitive as the contact tables themselves — including data the user
> has since deleted, and (for a secret contact) data the UI otherwise hides. It is therefore held
> to the same rules and a few extra ones:
>
> - It lives in the **same SQLCipher DB**, so it is encrypted at rest and covered by
>   `allowBackup="false"`. Nothing is written to plaintext prefs or to a log file.
> - It is **local only**: `audit_log` is in none of `SyncBundleService`'s table lists, so it is
>   never exported to a `.csbak` backup or sent in a P2P sync. A full restore clears it (its
>   snapshots describe the replaced database) and starts the history at the restore.
> - Entries for **secret contacts are hidden** in the UI until the user passes the same
>   biometric gate the contact list uses, and the screen holds `FLAG_SECURE` while they are shown.
> - It is **bounded**: 90 days, capped at 5000 rows, pruned when the screen opens, and clearable
>   from the screen's ⋮ menu.
>
> Widening what a snapshot carries (photos rather than paths, other tables, longer retention) is
> a change requiring a fresh review of this section.

> **Missed-call name mirror.** The contact name/number map that lets the missed-call
> notification show a name while the Flutter engine is down is stored in plaintext native
> prefs. This is intentional and user-approved: it is a small, functional mirror, the
> authoritative store (the DB) stays encrypted, and the notification would otherwise be unable
> to name the caller when the app is closed. It is not a leak to "fix".

> **Emergency card lock-screen copy.** The card exists to be read on a *locked* phone by a
> stranger helping the user, so it cannot be protected by the lock. It is therefore stored in
> plaintext native prefs (`contact_sphere_emergency`, key `card_json`) and rendered by
> `EmergencyInfoActivity` (`showWhenLocked`, no keyguard dismissal), which never touches the
> encrypted DB. The trade-off is deliberate and bounded:
>
> - The feature is **off by default**; nothing is written until the user turns it on.
> - **Per-field opt-in** — each line and each emergency contact has its own switch, and
>   `EmergencyInfo.toMirrorJson` is the single choke point that enforces it (unit-tested in
>   `test/emergency_info_test.dart`).
> - The **master record stays in the SQLCipher DB**; the plaintext copy is a derived subset of
>   labels and values, plus name/relation/number per shown contact. No contact ids, no photos,
>   nothing about other contacts.
> - Turning the feature off (or leaving nothing switched on) **wipes the copy and cancels the
>   notification**.
> - The file is app-private and still covered by `allowBackup="false"`.
> - **Only the master record is transportable.** The card is part of the `.csbak` backup and of
>   the P2P sync payload, so both already travel under the passphrase-derived AES-GCM
>   protection those paths use. The plaintext lock-screen copy is never transported — the
>   receiving phone rebuilds it from the restored/synced rows through the same
>   `toMirrorJson` choke point, so its own per-field switches still decide what is published.
>   In sync the card is only *installed* onto a phone that has no card of its own, so one
>   person's medical data cannot overwrite another's.
> - The edit screen warns, in plain words, that anyone holding the phone can read what is on it,
>   and previews exactly what will be shown.
>
> Medical detail is a more sensitive class than the rest of the app's data, so treat any change
> that *widens* what reaches this mirror (new fields, defaults flipped on, automatic population
> from contacts) as a change requiring a fresh review of this section.

---

## 5. Storage Model

### At Rest

- Primary local storage: `sqflite_sqlcipher` — the whole database (`smart_contacts.db`) is
  encrypted with SQLCipher. There is no separate unencrypted store for sensitive data.
- Secure key storage: `flutter_secure_storage`, backed by the Android Keystore
  (EncryptedSharedPreferences). Holds the DB key, the app-PIN hashes, and the recovery-code hash.
  - The DB key is a random 256-bit value minted once on first launch (`lib/database/db_key.dart`),
    stored as 64-char lowercase hex, and never hard-coded or shipped in the APK.
  - `AndroidOptions(resetOnError: false)` is forced on every secure-storage user so a transient
    read error can never silently wipe the key and orphan the DB.
- Backup behavior: **disabled** — `android:allowBackup="false"` with `tools:replace` in the
  manifest (see section 10). The DB never leaves the device via OS backup.

### In Memory

- The DB key lives in memory only while the DB is open. A shared `_pending` future in `DbKey`
  guarantees exactly one read/generate across concurrent startup callers (fixes a fresh-install
  race that previously minted multiple keys).
- Secret contacts are held in memory only while their gated view is open.
- No explicit memory-scrubbing is performed (Dart offers no guaranteed zeroization); this is an
  accepted limitation for the "moderate" sensitivity level.

### In Transit

- **No internet server is ever contacted.** The `INTERNET` permission exists **only** for the
  peer-to-peer LAN sync (a plain TCP socket to another phone on the same Wi-Fi).
- Transport protections for device-to-device features:
  - **P2P LAN sync** — every frame after the salt is AES-GCM sealed with a key derived
    (PBKDF2-HMAC-SHA256, 300k iterations) from a per-session ~320-bit pairing code that never
    crosses the socket. A wrong code derives a wrong key and decryption fails; that failure *is*
    the authentication (no fallback cipher).
  - **BLE contact share** — a photo-less vCard transferred over a chunked GATT protocol to a
    nearby device the user is actively pairing with.

---

## 6. Cryptography Design

Design only — no secrets are recorded here.

- **Database at rest:** SQLCipher default (AES-256) via `sqflite_sqlcipher`. Key = 256-bit random
  hex passphrase from `Random.secure()`, held in the Android Keystore.
- **Backup files (`.csbak`) and P2P sync:** AES-GCM-256 (`cryptography` package).
  - Key derivation: PBKDF2-HMAC-SHA256, **300,000 iterations**, 256-bit key.
  - Backup salt: 16 random bytes per file; nonce: 12-byte AES-GCM nonce; tag: 128-bit.
  - Format versioning: backup container starts with ASCII magic `CSBK` + a 1-byte format version
    (currently `1`). A schema-version (`dbVersion`) check gates restore.
- **App PIN / recovery code:** salted SHA-256 (16-byte per-value salt), stored as hex hashes;
  verified with a length-guarded constant-time compare.

### Rules (enforced)

- Keys, IVs, salts, and passwords are never hard-coded and never logged.
- All randomness uses a cryptographically secure generator (`Random.secure()` /
  the `cryptography` package CSPRNG).
- Encrypted container formats are versioned (`CSBK` v1; SQLCipher schema `user_version`).

---

## 7. Authentication And Access Control

- App-lock strategy: two modes.
  - **Device biometric / credential** via `local_auth` (`lib/services/auth_service.dart`) —
    used to gate **secret contacts** and the P2P-sync entry point.
  - **App-only PIN** with a one-time recovery code (`lib/services/app_pin_service.dart`).
- Fallback behavior: `AuthService.authenticate` **fails closed** — any platform error or an
  unconfigured device returns `false` (access denied), so secret contacts stay hidden.
- Recovery: entering the one-time recovery code on the lock screen clears the PIN so a user who
  forgot it can regain access and set a new one. The recovery code is 10 chars from a 31-char
  confusion-free alphabet — far too large to guess, unlike the short numeric PIN.
- Background lock rule: the app-lock screen re-gates on resume; secret contacts require a fresh
  auth each time their view is opened.
- Protected-route strategy: enforced in the screen/state layer (secret-contact gating in
  `contact_list_screen.dart`; sync behind an `AuthService` check).
- Lock screen implementation: `lib/screens/app_lock_screen.dart` (+ `app_pin_setup_screen.dart`).

---

## 8. Binary Protections

### 8.1 Obfuscation

> **Current status: NOT yet applied — open item (see section 17).** Release builds do not
> currently pass `--obfuscate` / `--split-debug-info`. Adding them is tracked as future
> hardening and is a checklist item in `docs/release_process.md`.

When enabled, all production release builds MUST be compiled with:

```bash
--obfuscate --split-debug-info=build/symbols/android-prod-<version>/
```

Obfuscation renames Dart class/method names in the binary, raising the cost of casual
inspection. It is **not a strong security boundary on its own** — a determined analyst can still
reconstruct logic from the compiled code. It does not substitute for the at-rest encryption,
Keystore secret management, or the token-guarded call-back path.

The debug symbol files produced by `--split-debug-info` MUST be stored securely, retained for
the lifetime of the released version, never committed to source control, and accessible only to
the engineering team for crash symbolication.

### 8.2 R8 / ProGuard

> **Current status: no `android/app/proguard-rules.pro` exists yet — open item (section 17).**

Android release builds run R8 code shrinking. When rules are added they must keep classes
accessed via reflection: `io.flutter.**`, `sqflite`/`sqflite_sqlcipher`,
`local_auth`, `flutter_blue_plus`, and the app's own native telecom/BLE classes under
`in.sreerajp.contact_sphere`. Run a full release build after adding any dependency to catch
silently stripped classes (`ClassNotFoundException` / `NoSuchMethodException` in release only).

### 8.3 Debuggable Flag

Verify `android:debuggable=false` in the merged release manifest before every production
release (see `docs/release_process.md` §6.4). `build.gradle.kts` does not set `isDebuggable` on
the release build type, so it defaults to false; confirm per release.

---

## 9. Logging And Telemetry Policy

Logger: `AppLogger` (`lib/core/logging/app_logger.dart`), backed by the `logger` package.
Level is gated by `AppFlavorConfig.instance.isDev`:
- **dev** — `Level.trace`, console only.
- **prod** — `Level.info` and above, to console **and** a rotating file `app.log` in the app
  cache directory (5 MB rollover, at most 3 rotated files `app.1.log`…`app.3.log`).

### Never Log

- The DB key, the app PIN, the recovery code, or any backup/sync passphrase.
- Decrypted database payloads or full row content that contains contact PII.
- Secret-contact identities.

### Allowed Diagnostic Context

- Operation / screen / flow name.
- Error category and type (not a raw exception message that may embed user data).
- Non-sensitive identifiers where justified.

### Notes

- The **missed-call name mirror** in native prefs is plaintext by design (section 4) — that is a
  functional mirror, not a log statement, and is user-approved.
- There is no analytics, crash-reporting, or telemetry SDK; nothing is sent off-device.

---

## 10. Platform Security Controls

### Android

- `android:allowBackup`: **`false`**, with `tools:replace="android:allowBackup"` so the app's
  `false` wins the manifest merge unconditionally and no dependency manifest can flip it back.
  Rationale: the DB holds secret contacts; adb backup / cloud auto-backup must never sweep it
  off-device.
- `android:fullBackupContent` / `dataExtractionRules`: not needed — backup is fully disabled.
- Screenshot protection: `FLAG_SECURE` is toggled via `ScreenSecurity`
  (`lib/services/screen_security_service.dart`) through the `contact_sphere/telecom` method
  channel (`setSecureFlag` in `MainActivity`). It is reference-counted by named reason: the flag
  stays on until every reason is released. It blocks screenshots, screen recording, and the
  Recents/task-switcher thumbnail on screens showing sensitive data.
  Holders: the app-lock screen and the secret-contacts list (unconditional), plus the contact
  detail and in-call screens via `ScreenshotGuard`
  (`lib/widgets/screenshot_guard_mixin.dart`), which acquire a per-instance reason from
  `initState` to `dispose`. The last two follow the user setting **Settings → Block screenshots**
  (`AppSettings.screenshotGuardEnabled`, default **on**, read at screen-open time); the
  unconditional holders ignore it, because that data is hidden at the user's explicit request.
  Failure to read the setting defaults to protected.
- `android:debuggable`: MUST be `false` in release (section 8.3).
- Root detection: none (a rooted device is explicitly out of scope, section 3).
- The exported `MainActivity` treats every **external** `ACTION_CALL`/`tel:` intent as
  "open the dialer pre-filled", never a silent call. Auto-dial happens only from the app's own
  missed-call notification, guarded by a one-shot random token (`PendingCallback` /
  `handleTrustedCallbackIntent`) so a crafted external intent cannot forge a call
  (confused-deputy defense). `CallActionReceiver` is not exported.

### iOS

- **Not in scope** — no `ios/` target. If iOS is added later, fill in app-switcher overlay,
  Keychain behavior, and privacy descriptions per the master template.

### Windows

- **Not in scope** — no `windows/` target.

---

## 11. Permissions

| Permission | Why It Is Needed | Requested When | Denial Handling |
|------------|------------------|----------------|-----------------|
| `CALL_PHONE` | Place calls from the dialer | At first call attempt | Cannot dial; user prompted |
| `READ_CALL_LOG` | Reconcile real call duration/type; show history | On call-history use | History degraded, app works |
| `READ_PHONE_STATE` / `ANSWER_PHONE_CALLS` | In-call UI as default phone app | When taking the dialer role | In-call features off if denied |
| `FOREGROUND_SERVICE` / `FOREGROUND_SERVICE_PHONE_CALL` | Run the InCallService during a call | While default dialer | Required for in-call UI |
| `VIBRATE` / `USE_FULL_SCREEN_INTENT` / `WAKE_LOCK` | Own the ringing UI; proximity screen-off | Incoming call | Ring UI degraded |
| `READ_CONTACTS` / `WRITE_CONTACTS` | Sync with the device address book | On contact sync | Sync off, local app works |
| `ACCESS_FINE_LOCATION` / `ACCESS_COARSE_LOCATION` | `geolocator`; BLE scan on older Android | At point of use | Feature off if denied |
| `RECORD_AUDIO` | Speech-to-text search/dialing | On voice action | Voice off, typing works |
| `CAMERA` | QR contact scanning (`mobile_scanner`) | On scan | Scanner off; manual entry works |
| `USE_BIOMETRIC` | App lock / secret-contact gate (`local_auth`) | On unlock | Falls back / fails closed |
| `INTERNET` | **P2P LAN sync only** — local TCP socket to a peer | On sync | Sync off; **no internet server is ever contacted** |
| `ACCESS_NETWORK_STATE` / `ACCESS_WIFI_STATE` / `CHANGE_WIFI_STATE` | P2P LAN discovery | On sync | Sync off |
| `POST_NOTIFICATIONS` | Missed-call / reminder notifications (Android 13+) | On first notification | Notifications suppressed |
| `READ_MEDIA_IMAGES` / `READ_EXTERNAL_STORAGE` (≤32) | Pick a contact photo / calling card | On image pick | Picker off |
| `BLUETOOTH_SCAN` (neverForLocation) / `BLUETOOTH_CONNECT` / `BLUETOOTH_ADVERTISE` (+ legacy `BLUETOOTH`/`BLUETOOTH_ADMIN` ≤30) | BLE contact share/receive | On BLE share/receive | Feature off if denied |

Permission review rules:
- `INTERNET` is present **only** for LAN sync; confirm no code path contacts a remote server.
- Dangerous permissions are requested at the point of use, not blanket at startup.
- The app functions in a degraded but safe state when any non-critical permission is denied.
- `BLUETOOTH_SCAN` carries `neverForLocation` (BLE scans are not used to derive location).

---

## 12. OWASP Mobile Top 10 Compliance

Review and sign off each item before every production release.

| ID | Risk | Control | Status |
|----|------|---------|--------|
| M1 | Improper Credential Usage | No hardcoded secrets; DB key, PIN/recovery hashes in Keystore | verified |
| M2 | Inadequate Supply Chain Security | `pubspec.lock` committed; no analytics/telemetry SDKs; dependency audit each release | verified |
| M3 | Insecure Authentication | Biometric + app-PIN lock; secret contacts gated; auth fails closed | verified |
| M4 | Insufficient Input/Output Validation | Parameterized SQL via `sqflite`; backup/sync frames length-checked and reject truncation | verified |
| M5 | Insecure Communication | No internet server; P2P sync AES-GCM with per-session key = auth; wrong key fails | verified |
| M6 | Inadequate Privacy Controls | Data inventory maintained; no PII in logs; backup disabled at OS level | verified |
| M7 | Insufficient Binary Protections | `--obfuscate` and ProGuard **not yet applied** | **risk-accepted (open)** |
| M8 | Security Misconfiguration | `allowBackup=false` with `tools:replace`; exported components token/permission guarded; debug disabled in prod | verified |
| M9 | Insecure Data Storage | SQLCipher DB; no sensitive data in `SharedPreferences` except the intentional plaintext name mirror | verified (with documented exception) |
| M10 | Insufficient Cryptography | Versioned `CSBK`/SQLCipher formats; PBKDF2-300k key derivation; no hardcoded keys | verified |

**Risk-accepted justification (M7):** binary hardening (`--obfuscate`, `--split-debug-info`,
`proguard-rules.pro`) is not yet in place. Owner: release owner (see `docs/release_process.md`
§2). The at-rest encryption, Keystore key handling, and server-side-free design mean obfuscation
is defense-in-depth, not the primary control; it is tracked in section 17 and the release
checklist. Re-evaluate before the next store submission.

---

## 13. Data Retention And Purge Policy

### Retention Schedule

| Data Type | Retention / Rotation Policy | Deletion Trigger |
|-----------|-----------------------------|------------------|
| Contact data + history | Indefinite (user-owned) | User delete action; app uninstall |
| `app.log` files | 5 MB per file, 3 rotated files (`app.1`…`app.3`) | Size limit reached; app uninstall |
| Temp backup file (`.csbak`) | Written to `getTemporaryDirectory()` for the share sheet | OS temp cleanup / next session |
| Native name/tone mirror prefs | Kept in sync with the DB | Contact change; app uninstall |
| `audit_log` entries | 90 days, capped at 5000 rows (pruned when Settings → Audit Log opens) | Retention/cap reached; "Clear log"; app uninstall |

### Purge Implementation

> **Open item (section 17):** there is **no in-app "Delete all data" action yet.** The
> master template recommends one that clears the DB, logs, cache, secure-storage entries, and
> temp files, verified by an integration test. This is not implemented; on Android the practical
> purge today is **uninstall** (which drops app data and, because `allowBackup=false`, leaves no
> cloud copy). The Keystore key dies on uninstall, so any residual encrypted DB is unreadable.

Temporary files (backup staging) are created in `getTemporaryDirectory()` and handed to the
share sheet; they are not long-lived app state.

### Data Purge On Uninstall

- Android app data is deleted on uninstall. Because `allowBackup=false`, there is no cloud
  backup to restore, and the Keystore-held DB key is destroyed — so an extracted DB file is
  cryptographically inert after uninstall.

---

## 14. Backup, Import, Export, And Recovery

- Backup supported: **yes** — portable, password-protected `.csbak` file (`BackupService`).
- Backup format: **encrypted only** (PBKDF2-HMAC-SHA256 300k + AES-GCM-256; magic `CSBK` v1).
  There is no plaintext DB backup — a raw copy would be useless off-device anyway (Keystore key).
- Import supported: **yes** — restore is a **full replace** of all app data
  (`SyncBundleService.replaceAllFromBundle`), gated by a schema-version (`dbVersion`) check.
  Also: vCard import (QR / BLE / `.vcf` intent) and CSV import.
- Recovery flow: wrong password or a tampered/foreign file fails the GCM tag check and throws a
  user-safe `BackupException`; **nothing is modified** unless every check passes.
- Plaintext export policy: CSV/vCard export exists for interoperability. The export UX must make
  the sensitivity of the plaintext file clear before the user shares it. Secret contacts follow
  the export setting.

### Validation Requirements

- Import parsing rejects malformed / truncated data safely (`_need` length guards throw rather
  than corrupting state).
- Recovery and restore paths are treated as high-value targets and covered by tests
  (round-trip encode → decode).
- Encrypted backups use a versioned container (`CSBK` v1) to support future format changes.

---

## 15. Security Testing Strategy

| Area | Test Type | Notes |
|------|-----------|-------|
| Backup crypto | Unit | `encodeBackup` → `restoreBytes` round-trip; wrong password rejected |
| App PIN | Unit | `test/app_pin_service_test.dart` — hash/verify, recovery code, constant-time compare |
| Secret-storage isolation | Review / unit | No sensitive value written to plain `SharedPreferences` (except the documented name mirror) |
| Lock / auth flow | Widget / manual | Auth fails closed; secret contacts re-gate on open |
| Backup schema guard | Unit | Restore refused on `dbVersion` mismatch |
| DB key race | Unit / review | Single shared `_pending` future; no double-mint on concurrent startup |
| Obfuscation | Release build verification | **Once adopted:** confirm `--obfuscate` present |
| Debuggable | Release build verification | `android:debuggable=false` in merged manifest |
| Permission audit | Release build verification | Merged manifest carries only the declared, needed permissions |

### Required Regression Areas

- Backup encode/decode round-trip with a known passphrase.
- Backup restore refused across a schema-version change.
- DB-key single-generation under concurrent first-launch opens (regression: the multi-key race).
- Corrupt / truncated backup file handled gracefully (no partial-state corruption).

---

## 16. Incident Response Notes

- Triage owner: app maintainer (Sreeraj P).
- Severity model: **high** = key/secret exposure or unauthenticated data access;
  **medium** = data leak via logs/export/backup; **low** = non-sensitive defect.
- Immediate containment actions:
  - Halt distribution of the affected version.
  - If the DB-key or crypto handling is implicated, ship a patched build and, if a format change
    is required, provide a migration path.
- User communication trigger: notify users if sensitive data could have left the device or if
  the encryption of stored data was weakened.
- Patch release process reference: `docs/release_process.md`.

---

## 17. Open Risks And Future Hardening

- **Risk:** release builds are not obfuscated and there is no `proguard-rules.pro`.
  **Hardening:** add `--obfuscate --split-debug-info=…` to the prod build commands and author
  ProGuard keep-rules for the reflection-using dependencies; archive symbols per release.
- **Risk:** no in-app "Delete all data" purge; the only full purge today is uninstall.
  **Hardening:** add a Settings danger-zone action that clears DB, logs, cache, secure storage,
  and temp files, verified by an integration test.
- **Risk:** in-memory secrets are not zeroized (Dart limitation).
  **Hardening:** minimize key lifetime; accepted for the current sensitivity level.
- **Risk:** the missed-call name mirror stores names/numbers in plaintext native prefs.
  **Hardening:** accepted and documented (section 4); revisit if sensitivity level rises.

---

## 18. Security Review Checklist

Complete before every production release.

- [ ] Threat model reviewed and current.
- [ ] Sensitive data inventory updated.
- [ ] Logging policy reviewed — no new statement logs PII or a secret.
- [ ] Storage and backup behavior reviewed (`allowBackup=false` still set with `tools:replace`).
- [ ] Permission usage reviewed — no unnecessary permissions; `INTERNET` still LAN-only.
- [ ] `--obfuscate` / `--split-debug-info` status re-evaluated (open item — section 17).
- [ ] Debug symbols archived for this release version (once obfuscation is adopted).
- [ ] `android:debuggable=false` verified in merged release manifest.
- [ ] ProGuard rules status re-evaluated (open item — section 17).
- [ ] OWASP Mobile Top 10 table (section 12) reviewed and signed off.
- [ ] Data retention reviewed; purge story (uninstall today) still accurate.
- [ ] Backup restore, vCard/CSV import, and schema-guard paths tested.
- [ ] `FLAG_SECURE` still applied on sensitive screens; secret-contact gate still fails closed.
