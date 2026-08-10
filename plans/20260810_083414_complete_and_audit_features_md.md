# Plan: Audit and Complete Features Reference Document (`docs/features.md`)

## Goal
Audit `docs/features.md` against the current codebase implementation of ContactSphere (`smart_contacts_dialer`) to ensure every feature, screen structure, and native integration is completely and accurately documented without any omissions or stale descriptions.

## Issue / Rationale
The Settings hub was recently reorganized into clean subpages (`SecurityScreen`, `SimSettingsScreen`, `RingtoneSettingsScreen`, `AppearanceScreen`, `AboutScreen`, etc.). Section 12 of `docs/features.md` currently describes Settings as a single flat list mentioning cards that have since moved into subpages (e.g. `DefaultDialerCard` in `SimSettingsScreen`, `AppLockCard` in `SecurityScreen`). 

Updating Section 12 to accurately reflect the modular sub-page layout of the Settings hub and verifying all 13 sections ensures `docs/features.md` remains the authoritative reference for the codebase.

## Proposed Changes

### [MODIFY] [docs/features.md](file:///l:/Android/SreerajPContactSphere/docs/features.md)

1. **Section 12 (Settings screen)**:
   - Re-structure Section 12 to document the modular sub-page architecture of the Settings hub:
     - **Security** (`SecurityScreen`): App Lock mode card (Off / Device lock / App PIN with setup), Screenshot Guard toggle (`ScreenshotGuardSettingsScreen`), and Audit Log (`AuditLogScreen`).
     - **Top contacts source card**: Inline card on hub to choose top contacts strip source (Most recent / Family & friends / Likely to answer now).
     - **Dialpad script card**: Inline card on hub to choose active T9 script (Latin, Malayalam, Devanagari, Cyrillic, Arabic, Greek, Auto-detect).
     - **Contacts** (`ContactsSettingsScreen`): Sort order, Name format, Hide contacts without number, Search index health check & rebuild, Secret contacts export, Sync device contacts, Blocked numbers, and Relationship names & quiet hours.
     - **Sync to Another Device** (`SyncHomeScreen`): Gated by biometric check; P2P LAN sync hub.
     - **Backup & Restore** (`BackupRestoreScreen`): Gated by biometric check; AES-GCM encrypted database backup/restore.
     - **SIM & calling** (`SimSettingsScreen`): Default dialer status card (`DefaultDialerCard`), SIM Cards & Accounts (`SimPreferencesScreen`), Identification & Spam (`IdentificationSettingsScreen`), Spoken caller announcement (`SpokenAnnouncementsScreen`), Relationship-tier quiet hours (`RelationshipQuietHoursScreen`), Quick replies (`QuickRepliesScreen`), Post-call options (`PostCallFeedbackScreen`), and Smart Redial & "Reach Me" (`SmartRedialSettingsScreen`).
     - **Ringtone** (`RingtoneSettingsScreen`): Volume & vibration (`RingtoneVolumeVibrationScreen`), Per-SIM ringtones (`PerSimRingtoneScreen`), and Ringtone pickers.
     - **Emergency info** (`EmergencyInfoScreen`): ICE card profile, published lock screen fields, persistent notification, lock screen preview, and PNG/text export.
     - **Default country** (`DefaultCountryScreen`): Country selection for phone number normalization.
     - **Appearance** (`AppearanceScreen`): Theme Mode (`ThemeModeSettingsScreen`), Typography & Text Size (`TypographySettingsScreen`), and Accent Color (`AccentColorSettingsScreen`).
     - **Features** (`FeaturesScreen`): In-app showcase screen.
     - **Permissions** (`PermissionsScreen`): Permissions list, rationale, and grant status.
     - **Help** (`HelpHomeScreen`): Categorized help pages.
     - **About** (`AboutScreen`): App version, build number, and dynamic app metadata.

2. **Full Section Consistency Audit**:
   - Double-check Sections 1–13, Known gaps, and Roadmap to ensure total accuracy across contacts management, dialer, search, sharing/airQR, sync, security, localization, and native Android services.

## Verification Plan

### Manual Verification
- Review updated `docs/features.md` to ensure all line items match the actual Flutter and native Kotlin implementation.
