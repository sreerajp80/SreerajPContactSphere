# Plan: Tamper-Proof Audit Logging & 1-Click Signed Export

**Date:** 2026-07-30
**Target Files:**
- `lib/models/audit_entry.dart`
- `lib/database/database_helper.dart`
- `lib/repositories/audit_repository.dart`
- `lib/screens/audit_log_screen.dart`
- `test/audit_log_test.dart`

## Issue / Requirement
Implement tamper-proof audit logging in ContactSphere:
1. SHA-256 cryptographic hash chaining (`previousHash` + `currentPayload`) for local DB audit log rows.
2. Verification utility to detect if any audit row has been modified or tampered with.
3. 1-click Export Signed Audit Log feature to export and share a cryptographically signed audit log.

## Proposed Changes

### 1. `lib/models/audit_entry.dart`
- Add `prevHash` and `hash` fields to `AuditEntry`.
- Add `genesisHash` constant (`'0'*64`).
- Update `AuditEntry.fromRow(...)` to parse `prev_hash` and `hash`.
- Implement `static Future<String> calculateHash(...)` using `package:cryptography/cryptography.dart` to compute SHA-256 over `$prevHash|$contactId|$contactName|$action|$source|$changedAt|$summary|$isSecret|$beforeJson|$afterJson`.
- Add `Future<bool> verifyHash(String effectivePrevHash)` to validate entry integrity.

### 2. `lib/database/database_helper.dart`
- Bump DB version from 24 to 25.
- Update `_ensureAuditTable` to create `prev_hash TEXT` and `hash TEXT` columns.
- Self-heal schema by adding column existence checks (via PRAGMA) for `prev_hash` and `hash` and executing `ALTER TABLE audit_log ADD COLUMN ...` if missing.
- Add `if (oldVersion < 25)` upgrade logic in `_onUpgrade`.

### 3. `lib/repositories/audit_repository.dart`
- Update `record(...)` to query the preceding entry's hash, compute SHA-256 for the new payload chained to `prev_hash`, and insert both `prev_hash` and `hash`.
- Add `verifyChain()` method returning `AuditChainVerificationResult` (`isValid`, `totalEntries`, `verifiedEntries`, `firstTamperedId`, `errorMessage`).
- Add `ensureHashesBackfilled()` to sequentially compute missing hashes for any legacy entries.
- Add `exportSignedAuditLog({bool includeSecret = false})` method to generate a signed JSON export file containing audit entries and a cryptographic signature manifest, and open system share dialog via `SharePlus`.

### 4. `lib/screens/audit_log_screen.dart`
- Add visual Chain Integrity badge/status card (showing tamper-proof chain status).
- Add 1-Click "Export Signed Log" action in AppBar and PopupMenu.
- Trigger export flow and display success feedback SnackBar.

### 5. `test/audit_log_test.dart`
- Add unit tests for SHA-256 hash calculation, chain continuity, tamper detection (modifying DB row breaks verification), and signed export file generation.

## Verification
Run `flutter test test/audit_log_test.dart` and `flutter analyze` to verify correctness.
