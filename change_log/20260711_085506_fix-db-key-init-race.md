# Change log — Fix the startup race that orphaned the encrypted DB

Implements plan
[plans/20260711_084625_fix-db-key-init-race.md](../plans/20260711_084625_fix-db-key-init-race.md).

## The bug (device-proven)

On the Motorola, the encrypted contact DB became unreadable after a cold start
(`SQLiteNotADatabaseException: file is not a database (code 26)`,
`sqlcipher: hmac check failed for pgno=1`) — app blank, calls not logged,
caller-ID names gone, Restore failing with `open_failed`.

Root cause was a **concurrency race in our own code**, not the device, the
Android Keystore, `flutter_secure_storage`, or SQLCipher. Instrumented on-device
logging proved:

- Secure storage persists the key reliably here (same key fingerprint read back
  across many cold starts, in both a standalone probe and the real app).
- On a fresh install, many services call `DatabaseHelper().database` at startup.
  The getter was not single-flighted, so each concurrent caller ran its own
  `_initDatabase()`, and each called `DbKey.getOrCreate()`. With empty storage,
  each generated a **different** random key (four distinct keys were logged in
  one launch); the last write won in secure storage, while the DB file was
  created with a different one. The stored key and the DB's real key mismatched
  from creation → orphaned on the next launch. Reproduced in a single clean
  cycle (clear data → one launch → next launch already fails the HMAC).

## What changed

- **`lib/database/database_helper.dart`**
  - Added `static Future<Database>? _opening` and made the `database` getter
    single-flight: it caches the in-flight `_initDatabase()` (`_opening ??= …`,
    atomic on Dart's single event loop) so exactly one open runs; on failure it
    clears the cache so a later call can retry. This guarantees one
    `openDatabase` (one DB-file key) and one `getOrCreate()` call.
  - `close()` now also clears `_opening`.
- **`lib/database/db_key.dart`**
  - `getOrCreate()` is now single-flight via a cached `static Future<String>?
    _pending` (defence in depth), so even direct concurrent callers generate
    only one key; a transient failure clears the cache to allow a retry. The
    read/generate/store body moved to `_readOrCreate()`.

No dependency, schema, manifest, or UI changes. Encryption is unchanged and
intact — only the initialization concurrency was fixed.

## Recovery for the already-orphaned install (one time)

The fix prevents new orphaning but cannot decrypt the already-mismatched DB.
After installing the fixed build: clear app data
(`adb shell pm clear in.sreerajp.contact_sphere`) → open the app (a single,
correctly-keyed empty DB is created) → Restore from the `.csbak`. It then
survives every cold start.

## Verification

- `flutter analyze lib/database/database_helper.dart lib/database/db_key.dart` —
  no issues.
- `flutter build apk --flavor prod --release --build-number 2003` — built OK.
- On-device verification (install, clear data, cold-restart several times, confirm
  no `hmac check failed` and contacts persist; then restore and repeat) is being
  performed by the user, who is handling build/test on the connected Motorola.

## Related, already handled earlier

- Contacts list not refreshing after a restore — fixed separately in
  `change_log/20260711_080940_refresh-contacts-after-restore.md`.
- Temporary diagnostics used to find this (a `lib/probe_main.dart` entrypoint and
  logging in `db_key.dart`) were removed; the dev probe app was uninstalled.
