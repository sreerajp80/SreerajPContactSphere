# Change Log: Added Cloud Sync & Backup Help Screen

**Plan Reference:** [20260810_110800_cloud-sync-help-screen.md](file:///l:/Android/SreerajPContactSphere/plans/20260810_110800_cloud-sync-help-screen.md)
**Timestamp:** 2026-08-10 11:09:55

## Summary of Changes

1. **New Help Screen (`lib/screens/help/cloud_sync_help_screen.dart`)**:
   - Created `CloudSyncHelpScreen` widget under `lib/screens/help/`.
   - Detailed the difference between 2-way Online Contact Sync (live contact delta sync via Google People API, Microsoft Graph Contacts, or CardDAV) and Encrypted Cloud Backup (uploading PBKDF2 + AES-GCM encrypted `.csbak` app database snapshots).
   - Documented how to set up multi-provider accounts (e.g. syncing live contacts with Google while backing up the encrypted app database to Microsoft OneDrive or a WebDAV server).
   - Documented privacy rules (Secret vault contacts are excluded from online contact sync; cloud backups are encrypted with a user-chosen passphrase before upload).

2. **Updated Help Hub (`lib/screens/help/help_home_screen.dart`)**:
   - Added a topic card titled **Cloud Sync & Backup** navigating to `CloudSyncHelpScreen()`.

## Verification Passed
- `flutter analyze`: 0 errors/warnings.
- `flutter test`: 424 tests passed cleanly.
