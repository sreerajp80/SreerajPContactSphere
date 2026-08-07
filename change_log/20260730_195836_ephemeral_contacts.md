# Change Log: Ephemeral / Self-Destructing Contacts

- **Date / Time**: 2026-07-30 19:58:36
- **Implements Plan**: `plans/20260730_195338_ephemeral_contacts.md`
- **Feature**: Ephemeral / Self-Destructing Contacts (Feature #1 from `docs/feature_analysis_and_roadmap.md`)

## Changes Made

1. **Model (`lib/models/contact.dart`)**
   - Added fields: `isEphemeral`, `ephemeralExpiresAt`, `ephemeralAutoDeleteCall`, and `ephemeralCallCount`.
   - Updated `toMap()` and `fromMap()` for DB serialization.

2. **Database Helper & Migration (`lib/database/database_helper.dart`)**
   - Bumped DB version from `23` to `24`.
   - Added v24 migration adding `is_ephemeral`, `ephemeral_expires_at`, `ephemeral_auto_delete_call`, and `ephemeral_call_count` columns to `contacts` table and index `idx_contacts_is_ephemeral`.
   - Added `_ensureEphemeralColumns` self-healing helper to `_onOpen`.

3. **Ephemeral Contact Service (`lib/services/ephemeral_contact_service.dart`)**
   - Created `EphemeralContactService` singleton managing background 1-minute checking and scrubbing.
   - `scrubEphemeralContact`: Permanently deletes contact, child tables (via CASCADE), notes, interactions, and associated `call_logs`.
   - `onCallCompleted`: Handles post-call auto-deletion trigger when `ephemeralAutoDeleteCall == true`.
   - Added methods `extendExpiry` (+24h) and `makePermanent`.

4. **Sync Isolation (`lib/services/contact_sync_service.dart`)**
   - Updated `ContactSyncService` to treat `isEphemeral` contacts as app-only (never pushed or synced to Google Account or Android System Contacts).

5. **Call Lifecycle Integration (`lib/services/call_service.dart`)**
   - Updated `CallService.reconcile` to notify `EphemeralContactService().onCallCompleted(...)`.

6. **UI Integration**
   - **Add / Edit Screen (`lib/screens/add_edit_contact_screen.dart`)**:
     - Added "Ephemeral Contact" toggle and Expiry Options selector (2 Hours, 24 Hours, 7 Days, Auto-delete after 1 call).
     - Save handler sets `isEphemeral`, expiry timestamp, `ephemeralAutoDeleteCall`, and clears `deviceId`.
   - **Contact List Screen (`lib/screens/contact_list_screen.dart`)**:
     - Added listener to `EphemeralContactService.onContactScrubbed` to reload list on scrubbing.
     - Added `⏱️ Ephemeral` / `⏱️ 1-Call` badge to contact list cards.
   - **Contact Detail Screen (`lib/screens/contact_detail_screen.dart`)**:
     - Added Ephemeral HUD banner with live countdown ticker updating every second.
     - Added actions: `+24 Hours`, `Keep Permanently`, and `Scrub Now`.

7. **Unit Tests (`test/ephemeral_contact_test.dart`)**
   - Added 6 unit tests covering model serialization, DB migration v24, expired contact scrubbing, post-call auto-delete scrubbing, `extendExpiry`, `makePermanent`, and `ContactSyncService` isolation.

## Verification Result
- `flutter analyze`: Clean (0 issues found).
- `flutter test test/ephemeral_contact_test.dart`: Passed (6/6 tests).
- `flutter test`: Passed full test suite.
