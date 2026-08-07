# Implementation Plan: Ephemeral / Self-Destructing Contacts

## Overview
Implement Ephemeral / Self-Destructing Contacts (Feature #1 from `docs/feature_analysis_and_roadmap.md`). Ephemeral contacts allow saving numbers needed only for short-term interactions (cab drivers, delivery personnel, temporary event leads, marketplace sellers) as temporary entries.

## Expiry Options
1. **2 Hours** (`ephemeralExpiresAt = now + 2h`)
2. **24 Hours** (`ephemeralExpiresAt = now + 24h`)
3. **7 Days** (`ephemeralExpiresAt = now + 7d`)
4. **Auto-delete after 1 call** (`ephemeralAutoDeleteCall = true`)

## Storage & Privacy Constraints
- Stored **exclusively** in the local SQLCipher database (`smart_contacts.db`).
- Never pushed or synced to Google Account, Android System Contacts (`ContactSyncService` skips `isEphemeral`).
- When countdown finishes or 1 call completes (if auto-delete), the contact record, child records, notes, and associated call logs are permanently scrubbed.

## Proposed Changes

### 1. Database Schema & Migration
- **[MODIFY] `lib/database/database_helper.dart`**:
  - Increment DB version from `23` to `24`.
  - Add migration `if (oldVersion < 24)` adding columns to `contacts`:
    - `is_ephemeral INTEGER DEFAULT 0`
    - `ephemeral_expires_at TEXT`
    - `ephemeral_auto_delete_call INTEGER DEFAULT 0`
    - `ephemeral_call_count INTEGER DEFAULT 0`
  - Add index `idx_contacts_is_ephemeral`.
  - Add `_ensureEphemeralColumns(db)` helper in `_onOpen` for self-healing.
  - Add columns to `_onCreate`.

### 2. Contact Model
- **[MODIFY] `lib/models/contact.dart`**:
  - Add fields: `isEphemeral`, `ephemeralExpiresAt`, `ephemeralAutoDeleteCall`, `ephemeralCallCount`.
  - Update `toMap()` and `fromMap()`.

### 3. Ephemeral Service
- **[NEW] `lib/services/ephemeral_contact_service.dart`**:
  - Implement `checkAndScrubExpiredContacts()`: checks and scrubs expired ephemeral contacts.
  - Implement `scrubEphemeralContact(int contactId)`: permanently deletes contact, child tables, notes, interactions, and associated `call_logs`.
  - Implement `onCallCompleted(int contactId, String number)`: triggers auto-delete if `ephemeralAutoDeleteCall == true` or expired.
  - Implement 1-minute periodic timer and stream/notifier for UI updates on scrub.

### 4. Device Sync Exclusions
- **[MODIFY] `lib/services/contact_sync_service.dart`**:
  - Ensure `c.isEphemeral` contacts are skipped from pushing to device contacts alongside `isSecret` and `isSelf`.

### 5. UI Updates
- **[MODIFY] `lib/screens/add_edit_contact_screen.dart`**:
  - Add "Ephemeral Contact" toggle and expiry selector (2 Hours, 24 Hours, 7 Days, Auto-delete after 1 call).
  - On save, populate ephemeral fields and clear `deviceId`.
- **[MODIFY] `lib/screens/contact_list_screen.dart`**:
  - Trigger scrubbing check on startup/resume.
  - Show ephemeral badge (`⏱️ Expires in X` / `⏱️ Auto-delete after call`) on list items.
- **[MODIFY] `lib/screens/contact_detail_screen.dart`**:
  - Show top Ephemeral HUD banner with live countdown timer.
  - Provide quick actions: Extend time, Convert to Permanent, Scrub now.
- **[MODIFY] `lib/services/call_service.dart`**:
  - Trigger `EphemeralContactService().onCallCompleted(contactId, number)` when a call finishes.

### 6. Automated Verification
- **[NEW] `test/ephemeral_contact_test.dart`**:
  - Test DB migration v24.
  - Test model serialization.
  - Test `EphemeralContactService` scrubbing and expiry logic.
  - Test exclusion from `ContactSyncService`.

## Verification Plan
1. Run `flutter analyze` to ensure code cleanliness and zero lints/errors.
2. Run `flutter test` including `test/ephemeral_contact_test.dart`.
