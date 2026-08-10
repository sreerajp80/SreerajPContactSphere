# Plan: Add Cloud Sync & Backup Help Screen under Settings -> Help

## Context & Issue
The user requested adding a help section under **Settings → Help** titled **Cloud Sync** (or **Cloud Sync & Backup**) detailing:
1. The difference between 2-way Online Contact Sync (live contact delta sync) and Cloud Backup (encrypted `.csbak` app database snapshot).
2. How provider configuration works in ContactSphere, including configuring Google for live contact sync and Microsoft/WebDAV for encrypted cloud backups.
3. Privacy rules (Vault secret contacts excluded from online sync; cloud backup payloads encrypted with user passphrase).

## Proposed Changes

### [NEW] `lib/screens/help/cloud_sync_help_screen.dart`
- Create `CloudSyncHelpScreen` widget (stateless) matching the design system of existing help screens (e.g. `ContactSyncHelpScreen`, `BackupHelpScreen`).
- Detail:
  - **Overview**: How ContactSphere connects to cloud providers (Google, Microsoft, CardDAV/WebDAV).
  - **Online Contact Sync vs Cloud Backup**: Explaining 2-way live contact delta sync vs PBKDF2 + AES-GCM encrypted `.csbak` app snapshot files.
  - **Using Multiple Providers**: How to sync contacts with Google while storing cloud backups on Microsoft OneDrive or a WebDAV server.
  - **Privacy & Security**: Exclusion of `is_secret` vault contacts from live contact sync and requirement of user passphrase for cloud backup decryption.

### [MODIFY] `lib/screens/help/help_home_screen.dart`
- Import `cloud_sync_help_screen.dart`.
- Add a new `_HelpTopicCard` for "Cloud Sync & Backup" in `HelpHomeScreen` with subtitle describing online contact sync and decoupled cloud backups.

## Verification Plan
1. Run `flutter analyze` to ensure 0 lint errors or warnings.
2. Run `flutter test` to ensure existing tests pass cleanly.
