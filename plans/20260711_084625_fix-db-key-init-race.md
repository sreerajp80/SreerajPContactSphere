# Fix the startup race that orphans the encrypted database

**Status:** completed

## The issue (proven on-device)

On the Motorola, the encrypted DB becomes unreadable after a cold start —
`SQLiteNotADatabaseException: file is not a database (code 26)` with
`sqlcipher: hmac check failed for pgno=1`. Everything goes blank (no contacts,
no recents, calls not logged); settings survive because they are in
SharedPreferences.

### Root cause — a concurrency race in our own code (device-confirmed)

Instrumented logging on the device proved it end to end:

- `flutter_secure_storage` persists reliably here: a stored key reads back
  identical across many cold starts (verified with a standalone probe and with
  the real app). It is **not** a Keystore / plugin / device-storage failure.
- On the very first launch after a clean wipe, the log showed **four concurrent
  calls to `DbKey.getOrCreate()`**, each reading empty storage and generating a
  **different** key (fingerprints `793396019`, `178095725`, `1044498166`,
  `826314494`). The last write wins in secure storage (`826314494`).
- The DB file is created by whichever `openDatabase` runs first, adopting a
  **different** one of those keys. So the stored key and the DB's real key
  mismatch from creation. On the next cold start the app reads the (stable)
  stored key, tries to open the DB, and fails the HMAC — orphaned.
- Reproduced in a single clean cycle: clear data → one launch → next launch
  already fails with `hmac check failed`, while the stored key is read back
  unchanged. Definitive.

Why the race exists:

- `DatabaseHelper.database` is not single-flighted:
  ```dart
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();   // many concurrent callers all enter here
    return _database!;
  }
  ```
  Many services call `DatabaseHelper().database` at startup. Because there is an
  `await` before `_database` is set, every concurrent caller runs its own
  `_initDatabase()`.
- Each `_initDatabase()` calls `DbKey.getOrCreate()`, which generates a fresh
  random key when storage is empty, and then calls
  `cipher.openDatabase(path, password: <that key>)`.

This is unrelated to the earlier encryption-key theories. No need to drop
SQLCipher or add a passphrase — the encryption is fine once the race is removed.

## The fix

Single-flight both the DB open and the key creation so exactly one key is ever
generated and exactly one `openDatabase` creates the file.

### Files to change

1. **`lib/database/database_helper.dart`** — make `database` single-flight by
   caching the in-flight open Future, so only one `_initDatabase()` ever runs:
   ```dart
   static Database? _database;
   static Future<Database>? _opening;

   Future<Database> get database async {
     if (_database != null) return _database!;
     final opening = _opening ??= _initDatabase();
     try {
       final db = await opening;
       _database = db;
       return db;
     } catch (_) {
       _opening = null; // let a later call retry after a failed open
       rethrow;
     }
   }
   ```
   (`_opening ??= ...` is atomic on Dart's single-threaded event loop, so
   concurrent callers share one open.)

2. **`lib/database/db_key.dart`** — single-flight `getOrCreate()` as defense in
   depth, so even direct concurrent callers generate only one key:
   ```dart
   static Future<String>? _pending;

   static Future<String> getOrCreate() =>
       _pending ??= _readOrCreate().catchError((Object e) {
         _pending = null; // allow retry on a transient read/write failure
         throw e;
       });

   static Future<String> _readOrCreate() async {
     final existing = await _storage.read(key: _storageKey);
     if (existing != null && existing.isNotEmpty) return existing;
     final key = _generateHexKey();
     await _storage.write(key: _storageKey, value: key);
     return key;
   }
   ```

No dependency, schema, or manifest changes.

## Recovery for the already-orphaned install

The fix prevents new orphaning; it cannot decrypt the DB that is already
mismatched. After installing the fixed build the user does this ONCE:
1. Clear app data (or the fix will keep failing to open the old orphaned DB).
2. Open the app (a single, correctly-keyed empty DB is created).
3. Restore from the `.csbak` backup.
From then on the DB and key stay matched across every cold start.

(Optional: `_initDatabase` could, on a wrong-key open failure, delete the
orphaned file and recreate — turning step 1 into an automatic self-heal. Left
out of this plan to keep the change minimal and non-destructive; can be a
follow-up.)

## Verification

- `flutter analyze` on both changed files — expect no issues.
- On the device (release build, versionCode > 2001 so it updates in place):
  clear data, cold-start several times, confirm the log shows the key generated
  **once** and **no** `hmac check failed` on later launches. Then restore a
  backup and confirm it survives repeated force-stop / cold starts.

## Cleanup already done

- Temporary diagnostic entrypoint `lib/probe_main.dart` deleted.
- Temporary logging in `db_key.dart` reverted.
- Dev probe app (`in.sreerajp.contact_sphere.dev`) uninstalled.
