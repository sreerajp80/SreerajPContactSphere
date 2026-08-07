# Change Log: Unit Test Isolation & Native Mirroring Helpers

Date: 2026-07-23
Plan: plans/20260723_205600_test_isolation_and_native_mirror_helpers.md

## Summary of Changes
1. **Database Isolation for Unit Tests**:
   - Added `DatabaseHelper.setTestDatabaseName(String? name)` to allow test suites to run against isolated SQLite database files.
   - Updated `DatabaseHelper.close()` to ensure internal database and opening handles are safely reset on teardown.
   - Configured distinct test database file names across `test/backup_service_test.dart`, `test/call_feature_test.dart`, `test/contact_stem_search_test.dart`, `test/contact_sync_service_test.dart`, `test/flagged_number_repository_test.dart`, `test/group_ringtone_test.dart`, `test/interaction_repository_test.dart`, `test/p2p_bundle_test.dart`, and `test/relationship_repository_test.dart`.

2. **Native Mirroring Helpers & Privacy Protection**:
   - Added `c.is_secret = 0` filtering to `ringtoneMirrorEntries()` and `contactNameMirrorEntries()` in `ContactRepository` to prevent secret contact names or custom ringtones from leaking into unencrypted native `SharedPreferences`.
   - Verified auto-push hooks (`pushRingtoneMirror()`) in `ContactRepository`, `GroupRepository`, `AppSettings`, and `ContactSyncService`.

## Verification Results
- `flutter analyze`: 0 issues found.
- `flutter test`: All 193 unit tests passed (100% pass rate).
