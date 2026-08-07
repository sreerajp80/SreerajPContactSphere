# Plan: Unit Test Isolation & Native Mirroring Helpers

**Status:** completed

Date: 2026-07-23

## Issue
1. `flutter test` across all files fails on 20 tests with SQLite file locks (`database is locked (code 5)`) and UNIQUE constraint errors (`UNIQUE constraint failed: groups.name`) because test runner isolates share the default database file (`smart_contacts.db`).
2. `ContactRepository` is missing `ringtoneMirrorEntries()`, `contactNameMirrorEntries()`, and `pushRingtoneMirror()`, which are expected by `GroupRepository`, `AppSettings`, `ContactSyncService`, and `TelecomService`.

## Proposed Solution
1. Update `DatabaseHelper` to allow configuring test database paths (`DatabaseHelper.setTestDatabasePath(...)`).
2. Update test files to assign isolated, unique database filenames per test suite.
3. Implement `ringtoneMirrorEntries()`, `contactNameMirrorEntries()`, and `pushRingtoneMirror()` in `ContactRepository`.
