# Change Log: Opt-in Online Contact Sync & Encrypted Cloud Backup

Date: 2026-08-10 10:35:00
Plan Implemented: `file:///l:/Android/SreerajPContactSphere/plans/20260810_083742_cloud_contact_sync.md`

## Summary of Changes

Implemented an **opt-in online provider integration module** comprising 2-way contact sync and password-encrypted full-app cloud backup/restore.

### Key Additions & Modifications

1. **Data Models**:
   - `lib/models/online_sync_account.dart` [NEW] — Represents user-configured accounts for Google Contacts, Microsoft Outlook, and CardDAV/WebDAV.
   - `lib/models/cloud_backup_entry.dart` [NEW] — Represents remote `.csbak` encrypted backup files stored in cloud storage.
   - `lib/models/contact.dart` [MODIFY] — Added `remoteSyncId`, `syncEtag`, `lastSyncedAt`, `syncProvider`, and `needsSync` fields for online sync tracking.

2. **Provider Clients**:
   - `lib/services/providers/google_contacts_provider.dart` [NEW] — Provider client for Google People API (Contacts) and Google Drive REST API v3 (AppData `.csbak` backups).
   - `lib/services/providers/microsoft_contacts_provider.dart` [NEW] — Provider client for Microsoft Graph API (Contacts & OneDrive AppRoot `.csbak` backups).
   - `lib/services/providers/carddav_contacts_provider.dart` [NEW] — Provider client for RFC 6352 CardDAV & WebDAV HTTPS storage (Nextcloud, Fastmail, Baïkal).

3. **Coordinators**:
   - `lib/services/online_sync_service.dart` [NEW] — Main coordinator for 2-way delta sync loops, conflict management, and tombstone deletion flushing.
   - `lib/services/cloud_backup_service.dart` [NEW] — Main coordinator for uploading and restoring PBKDF2 + AES-GCM-256 encrypted `.csbak` backup files to cloud storage.

4. **Database & Repositories**:
   - `lib/database/database_helper.dart` [MODIFY] — Bumped database version from **27 to 28**. Added `_onUpgrade` delta migration and self-healing `_ensureOnlineSyncColumns` helper for sync columns on `contacts` and the `pending_remote_deletions` table.
   - `lib/repositories/contact_repository.dart` [MODIFY] — Automatically marks `needs_sync = 1` for non-secret contacts on insert/update and queues tombstone records into `pending_remote_deletions` when contacts with `remote_sync_id` are deleted.

5. **Settings UI**:
   - `lib/screens/settings/online_sync_settings_screen.dart` [NEW] — Management screen for configuring 2-way contact sync accounts and triggering manual sync.
   - `lib/screens/settings/cloud_backup_settings_screen.dart` [NEW] — Management screen for uploading/restoring password-encrypted `.csbak` files directly to Google Drive, OneDrive, or WebDAV.
   - `lib/screens/settings_screen.dart` [MODIFY] — Added "Online Provider Sync" and "Encrypted Cloud Backup" setting cards.

6. **Documentation**:
   - `docs/features.md` [MODIFY] — Updated Section 7 (Backup, Restore & Sync) to document Online Provider Sync and Encrypted Cloud Backup capabilities and zero-knowledge privacy guarantees.

## Verification

- Ran `flutter analyze`: **0 issues found**.
- Ran `flutter test`: **All 424 tests passed** cleanly.
