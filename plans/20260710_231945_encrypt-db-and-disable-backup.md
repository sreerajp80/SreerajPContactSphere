# Encrypt the contact database and disable Android backup

**Status:** completed

**Migration decision:** migrate existing data (`sqlcipher_export`).

## The two issues

1. **Contact DB is stored unencrypted** (`lib/database/database_helper.dart:23-24`).
   Plain `sqflite`, no cipher. The "secret contacts" feature only hides rows behind a
   biometric prompt in the UI; the rows themselves sit in plaintext at
   `/data/data/in.sreerajp.contact_sphere/databases/smart_contacts.db`. On a rooted
   device, over ADB, or from a backup, every contact (including "secret" ones) is
   readable. The lock is a curtain, not a safe.

2. **`android:allowBackup` is not set** (`android/app/src/main/AndroidManifest.xml:74`).
   It defaults to `true`, so the plaintext DB can be pulled with `adb backup` and may be
   swept into cloud auto-backup. This is the cheapest high-value fix.

## Files to change

- `android/app/src/main/AndroidManifest.xml` — add `android:allowBackup="false"` to the
  `<application>` tag (issue 2).
- `pubspec.yaml` — replace `sqflite` with `sqflite_sqlcipher`, add
  `flutter_secure_storage` (issue 1).
- `lib/database/database_helper.dart` — open the DB with a key; add a one-time migration
  from the existing plaintext DB (issue 1).
- New file `lib/database/db_key.dart` — generate/read the 256-bit DB key from the Android
  Keystore via `flutter_secure_storage`.
- `test/` helpers / any test that opens the DB — keep host tests working (see Testing).

## Fix plan

### Issue 2 — disable backup (do this first; trivial)

Add `android:allowBackup="false"` to `<application>` in the manifest. One line, no code,
immediately stops `adb backup` and cloud auto-backup of the DB.

### Issue 1 — encrypt the DB at rest

**Cipher.** Switch `sqflite` → `sqflite_sqlcipher`. It is a drop-in replacement with the
same API plus a `password:` parameter on `openDatabase`. Only the import and the open call
change; the rest of `DatabaseHelper` (schema, migrations, PRAGMAs) stays the same.

**Key management.** The DB key must not be hard-coded (that would be no better than
plaintext). On first run, generate a random 256-bit key, hex-encode it, and store it with
`flutter_secure_storage` (Android-Keystore-backed, `EncryptedSharedPreferences`). On every
later run, read the same key back. The key never leaves the device and is not in the APK.

**Migration of existing installs.** An existing `smart_contacts.db` is plaintext, so
opening it with a password fails. On startup, if the plaintext DB exists and no key is
stored yet:
1. generate + store the key,
2. open the plaintext DB, `ATTACH` a new encrypted file with the key, run
   `SELECT sqlcipher_export('encrypted')`, `DETACH`,
3. delete the plaintext file and rename the encrypted file to `smart_contacts.db`.
This preserves all existing contacts. (If you confirm there is no real data on any device
yet, we can skip the migration and just recreate the DB encrypted — simpler and less risky.
See the open question.)

### Testing

Host tests use `sqflite_common_ffi`. `sqflite_sqlcipher` does not run on the desktop test
host, so the DB-backed tests must keep using the plain ffi factory (no password) under
test, while the app uses the cipher factory with a password. I'll gate the open path so
tests inject the ffi factory and skip encryption, and the production path uses the cipher +
key. This keeps `flutter test` green.

## Order of work

1. Manifest `allowBackup="false"` (issue 2).
2. `pubspec.yaml` deps + `flutter pub get`.
3. `db_key.dart` (keystore key).
4. `database_helper.dart` open-with-key + migration.
5. Verify `flutter analyze` and `flutter test` (one file per invocation per the sqlite
   test note).

## Open question for you

- **Migration vs. wipe:** do any real devices already hold contacts in the current
  plaintext DB? If yes, I do the `sqlcipher_export` migration (keeps data). If it is still
  only dev/test data, I can skip migration and just start the DB encrypted (much simpler).
