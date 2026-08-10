# Plan: Complete and Audit features.md Documentation

## Issue
The features documentation file `docs/features.md` was recently updated with details on **Online Provider Contact Sync** and **Encrypted Cloud Backup & Restore** in Section 7, but:
1. Section 12 ("12. Settings screen") does not list the corresponding cards and screens on the Settings hub (`OnlineSyncSettingsScreen` and `CloudBackupSettingsScreen`).
2. The introductory overview ("What this app is") does not include opt-in online provider contact sync and encrypted cloud backup in its high-level summary of sync & backup capabilities.

## Changes Required
1. **Modify `docs/features.md`**:
   - Update Section "What this app is" (intro summary) to mention opt-in 2-way sync with online providers (Google, Microsoft Outlook, CardDAV) and encrypted cloud backup/restore (Google Drive, OneDrive, Nextcloud/WebDAV).
   - Update Section 12 ("Settings screen") to explicitly list **Online Provider Sync** (`OnlineSyncSettingsScreen`) and **Encrypted Cloud Backup** (`CloudBackupSettingsScreen`) cards and their responsibilities.

## Files to Modify
- `docs/features.md`

## Verification
- Re-read `docs/features.md` to ensure complete accuracy against all screens, services, repositories, database schemas, and native Android code in the codebase.
- Verify formatting and clickable links.
