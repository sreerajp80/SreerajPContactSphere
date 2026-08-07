# Remove the one-time plaintext→encrypted DB migration

**Status:** completed

## Context

The user has installed the encrypted build on their device and confirmed all
contacts migrated successfully. The migration + the per-launch probe in
`lib/database/database_helper.dart` have served their purpose and are now dead
weight (the probe runs every launch but does nothing once the DB is encrypted).

## Files to change

- `lib/database/database_helper.dart` — drop the migration/recovery/probe code;
  open directly with the key.

## Fix plan

- Remove the `_ensureEncrypted` call from `_initDatabase` and the helper methods
  `_ensureEncrypted`, `_migrate`, `_opensWith`, `_intOf`, `_deleteFiles`.
- `_initDatabase` (Android branch) becomes: get the key, then
  `cipher.openDatabase(path, password: key, version: 16, …callbacks)`. Fresh
  installs still get an encrypted DB via `onCreate`.
- Keep: the `_encryptionEnabled` / `Platform.isAndroid` split, the plain-sqflite
  test branch, `db_key.dart`, and the `dart:io` import (still needed for
  `Platform`; `File` is no longer used but `Platform` lives in `dart:io`).

## Consequence (accepted by the user)

Any install that still holds a *plaintext* DB (an old APK reinstalled, another
device, or restored old data) will no longer auto-convert — the keyed open will
fail instead. The user has migrated and this is their app, so this is accepted.
The git history retains the migration code if it is ever needed again.

## Testing

- `flutter analyze` clean.
- `flutter test` on a DB-backed file (host path is unaffected).
