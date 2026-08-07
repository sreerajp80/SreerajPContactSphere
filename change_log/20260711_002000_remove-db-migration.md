# Remove the one-time plaintext→encrypted DB migration

Implements plan `plans/20260711_001500_remove-db-migration.md`. The user confirmed
their device migrated all contacts to the encrypted DB, so the one-time migration
and the per-launch probe are no longer needed.

## Changes

- `lib/database/database_helper.dart`:
  - `_initDatabase` (Android branch) now opens directly:
    `cipher.openDatabase(path, password: key, version: 16, …callbacks)`.
  - Removed `_ensureEncrypted`, `_migrate`, `_opensWith`, `_intOf`, and
    `_deleteFiles`, plus the per-launch probe call.
  - Kept the `Platform.isAndroid` split (encrypted on device, plain sqflite +
    `databaseFactoryFfi` under `flutter test`), `db_key.dart`, and the `dart:io`
    import (still used for `Platform`; `File` is no longer referenced).

Fresh installs still create an encrypted DB via `onCreate`.

## Consequence

An install that still holds a *plaintext* DB (old APK reinstalled, another device,
restored old data) will no longer auto-convert; the keyed open will fail instead.
Accepted by the user. The migration code remains recoverable from git history
(see `change_log/20260711_000500_harden-db-migration.md`).

## Verification

- `flutter analyze` — no issues.
- `flutter test test/contact_stem_search_test.dart` — all pass.
