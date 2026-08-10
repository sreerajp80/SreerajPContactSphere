# Plan: Opt-in Online Contact Sync & Encrypted Cloud Backup (Google, Microsoft & CardDAV / WebDAV)

Date: 2026-08-10 10:15:00
Status: Proposed (Updated — Awaiting Approval)

## Overview & Background

ContactSphere is fundamentally built as an offline-first, local-encrypted SQLite contact manager and dialer. While Android native system sync automatically mirrors account contacts (e.g. Google/Exchange) into the OS `ContactsProvider`, power users may want ContactSphere to:

1. **Directly interface with cloud contact providers** (**Google People API**, **Microsoft Graph API**, or **CardDAV / Nextcloud / Fastmail / Baïkal**) without relying on native Android background daemons or when operating in isolated mode.
2. **Automatically or manually back up the full password-encrypted database payload (`.csbak`) to cloud storage** (**Google Drive AppData/Folder**, **Microsoft OneDrive AppRoot/Folder**, or **Nextcloud / WebDAV server**), ensuring complete loss-prevention (contacts, relationships, call logs, interactions, reminders, secret contacts, photos, and settings) while remaining fully zero-knowledge end-to-end encrypted.

This plan details an **opt-in, manual-configuration online integration module** that remains dormant by default and only operates when explicitly enabled and configured by the user.

---

## Architectural & Security Principles

1. **Strict Opt-In & Zero-Knowledge Privacy**: 
   - Feature is disabled by default. No network calls are made without explicit user enablement.
   - Zero telemetry or proxy servers; all API calls are direct client-to-provider HTTPS requests.
   - Cloud Backups uploaded to Google Drive / OneDrive / WebDAV are standard `.csbak` payloads encrypted with the user's passphrase via **PBKDF2-HMAC-SHA256 (300,000 iterations) + AES-GCM-256**. The remote cloud provider sees only ciphertext and cannot read any contact or call log data.
2. **Credential Hardening**:
   - OAuth 2.0 Refresh Tokens, Access Tokens, WebDAV passwords, and backup passphrases are encrypted at rest using `FlutterSecureStorage` (backed by Android Keystore).
3. **Local First & Offline Resiliency**:
   - SQLite remains the primary source of truth.
   - Offline edits are queued with a dirty flag (`needs_sync`) and synced when online connection and manual/scheduled sync triggers occur.
4. **Secret Contact Isolation**:
   - Secret contacts (`is_secret = 1`) are **strictly excluded** from direct cloud contact sync (Google People, MS Graph, CardDAV).
   - Secret contacts are included in full-app `.csbak` cloud backups **only** as part of the PBKDF2 + AES-GCM encrypted payload locked behind the user's passphrase.
5. **Conflict Resolution Policies**:
   - Provide configurable contact sync resolution rules: *Local Wins* (overwrite cloud), *Remote Wins* (overwrite local), or *Manual / Split*.

---

## Technical Components & Integration Strategy

### 1. Feature Breakdown

#### Feature A: Direct 2-Way Contact Sync (Google People API, MS Graph API, CardDAV)
- **Google Contacts (Google People API v1)**: OAuth 2.0 PKCE flow; delta sync via `syncToken`.
- **Microsoft Outlook Contacts (MS Graph API v1.0)**: OAuth 2.0 PKCE flow; delta sync via `@odata.deltaLink`.
- **CardDAV Protocol (RFC 6352)**: HTTPS WebDAV/vCard over HTTP Basic/Digest authentication; delta sync via `sync-collection` (RFC 6578) with vCard 3.0/4.0 parsing.
- **Tombstone Queue**: Track local contact deletions in a pending deletion queue so remote endpoints receive explicit HTTP DELETE calls during sync.

#### Feature B: Encrypted Cloud Backup & Restore (`.csbak` via Cloud Storage APIs)
- Leverages [BackupService](file:///l:/Android/SreerajPContactSphere/lib/services/backup_service.dart) to generate or decrypt standard `.csbak` payloads using the user's passphrase.
- Uploads/downloads encrypted `.csbak` snapshot files directly to:
  - **Google Drive**: `drive.appdata` / private folder scope using Google Drive REST API v3.
  - **Microsoft OneDrive**: `/me/drive/special/approot` using MS Graph API.
  - **WebDAV / Nextcloud**: Custom WebDAV storage path over HTTPS `PUT`/`GET`.
- Restores can list available remote backup files, download the chosen `.csbak`, and invoke `BackupService.restoreBytes` inside a database transaction.

### 2. Database Schema Extension
Add sync tracking columns to the local SQLite database (`contacts` table) and a pending deletion table:
- `contacts.remote_sync_id` (TEXT NULL): Unique identifier from Google/Microsoft/CardDAV.
- `contacts.sync_etag` (TEXT NULL): Version tag/hash from remote provider.
- `contacts.last_synced_at` (TEXT NULL): ISO 8601 timestamp of last successful sync.
- `contacts.sync_provider` (TEXT NULL): Identifier (`google`, `microsoft`, `carddav`).
- `contacts.needs_sync` (INTEGER DEFAULT 0): Flag indicating pending local edits.
- `pending_remote_deletions` table (NEW): Stores `remote_sync_id`, `sync_provider`, `deleted_at` so cascade-deleted local contacts can still be deleted from the cloud.

### 3. File Changes

#### Proposed New Files
- `lib/models/online_sync_account.dart` [NEW] — Model for configured cloud provider accounts & sync state.
- `lib/models/cloud_backup_entry.dart` [NEW] — Model representing remote `.csbak` backup files.
- `lib/services/online_sync_service.dart` [NEW] — Coordinator service managing 2-way contact sync loops and conflict resolution.
- `lib/services/cloud_backup_service.dart` [NEW] — Coordinator service for uploading/downloading encrypted `.csbak` files to Google Drive, OneDrive, and WebDAV.
- `lib/services/providers/google_contacts_provider.dart` [NEW] — Google People API & Google Drive API client.
- `lib/services/providers/microsoft_contacts_provider.dart` [NEW] — Microsoft Graph API (Contacts & OneDrive AppRoot) client.
- `lib/services/providers/carddav_contacts_provider.dart` [NEW] — RFC 6352 CardDAV & WebDAV storage client.
- `lib/screens/settings/online_sync_settings_screen.dart` [NEW] — UI for configuring 2-way contact sync, conflict resolution, and credential setup.
- `lib/screens/settings/cloud_backup_settings_screen.dart` [NEW] — UI for configuring automated/manual encrypted `.csbak` cloud backups and listing remote restore snapshots.

#### Proposed File Modifications
- `lib/database/database_helper.dart` [MODIFY] — Bump database version and add `_onUpgrade` delta migration for remote sync columns and tombstone deletion table.
- `lib/repositories/contact_repository.dart` [MODIFY] — Exclude secret contacts (`WHERE is_secret = 0`), handle `needs_sync` flags on contact save/edit, and write to `pending_remote_deletions` on contact delete.
- `lib/services/backup_service.dart` [MODIFY] — Expose byte-stream helper methods for direct push/pull from `CloudBackupService`.
- `lib/screens/settings_screen.dart` [MODIFY] — Add "Online Provider Sync" and "Cloud Backup & Restore" cards under Backup & Sync section.
- `docs/features.md` & `docs/architecture.md` [MODIFY] — Document direct online contact sync, encrypted cloud backup architecture, and security guarantees.

---

## Verification & Testing Plan

### Automated Verification
- Unit tests for vCard/JSON serialization, delta-sync change set calculation, and tombstone queue operations.
- Unit tests for credential encryption / retrieval using mock secure storage.
- Unit tests for encrypted `.csbak` cloud backup payload creation and decryption verification with mock HTTP providers.
- SQLite migration tests verifying `contacts` table and `pending_remote_deletions` schema upgrades.

### Manual Verification
- Test manual enablement, credential entry, and OAuth authentication in Settings.
- Test 2-way contact sync with test accounts (Google, Microsoft Graph, Nextcloud CardDAV).
- Test manual and scheduled encrypted backup upload to Google Drive, OneDrive, and Nextcloud WebDAV.
- Test downloading and restoring an encrypted `.csbak` backup on a fresh installation using the user's passphrase.
- Verify secret contact isolation (secret contacts are omitted from 2-way contact sync, but encrypted safely in `.csbak` cloud backups).

---

## Action Required
Wait for explicit approval from the user before modifying any source code or creating new service/UI files.
