# Encrypt the contact database and disable Android backup

Implements plan `plans/20260710_231945_encrypt-db-and-disable-backup.md`.
Fixes two at-rest security gaps: the contact DB was stored in plaintext, and
Android auto-backup was implicitly enabled.

## Issue 2 — Android backup disabled

- `android/app/src/main/AndroidManifest.xml`: added `android:allowBackup="false"`
  to the `<application>` tag (with a comment). `adb backup` and cloud auto-backup
  can no longer sweep the DB off the device.

## Issue 1 — database encrypted at rest (SQLCipher)

- `pubspec.yaml`:
  - added `sqflite_sqlcipher: ^3.1.0` (SQLCipher-backed `openDatabase`),
  - added `flutter_secure_storage: ^10.3.1` (stores the DB key in the Android
    Keystore). Kept `sqflite` for the shared types (`Database`,
    `ConflictAlgorithm`) used by repositories and by the `sqflite_common_ffi`
    host tests. `flutter_secure_storage` was bumped from the planned `^9.2.2` to
    `^10.3.1` to resolve a `win32` version clash with `share_plus`.
- `lib/database/db_key.dart` (new): `DbKey.getOrCreate()` returns a random
  256-bit hex passphrase, generated once and persisted in the Keystore;
  `DbKey.exists()` reports whether a key is already stored. Uses the default
  keystore-backed AES-GCM options with `resetOnError: false` so a transient read
  error never silently wipes the key (which would orphan the encrypted DB).
- `lib/database/database_helper.dart`:
  - opens the DB with `sqflite_sqlcipher` + the key on Android; on the host test
    VM (`!Platform.isAndroid`) it still opens plain `sqflite`, honoring the
    injected `databaseFactoryFfi`. No test changes were needed.
  - `_migratePlaintextIfPresent()`: on the first launch after this change, an
    existing plaintext `smart_contacts.db` is converted in place via SQLCipher's
    `sqlcipher_export` (ATTACH encrypted target, copy, carry `user_version`
    across, swap files, delete plaintext + journal siblings). No contacts are
    lost. The key/passphrase is hex-only and the paths are app-internal, so the
    inlined SQL literals can't be broken out of.

## Verification

- `flutter analyze` — no issues.
- `flutter test test/contact_stem_search_test.dart` and
  `test/relationship_repository_test.dart` — all pass (host path still uses the
  ffi factory). DB-backed tests are run one file per invocation per the known
  sqlite3.dll double-copy crash.
- `minSdk` is 24, above SQLCipher's API-21 floor.

## Not runtime-verified (needs a device)

The on-device encryption + plaintext→encrypted migration path only runs when
`Platform.isAndroid`, so it was not exercised on the host. Recommend a run on a
device/emulator that already has a plaintext DB to confirm the migration and
that contacts remain readable, plus a fresh install to confirm a new encrypted
DB is created.
