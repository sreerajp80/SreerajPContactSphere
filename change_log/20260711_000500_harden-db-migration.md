# Make the plaintext→encrypted DB migration crash-safe

Implements plan `plans/20260710_233500_harden-db-migration.md`. Closes two
interruption windows in the first-run migration added by
`change_log/20260710_233000_encrypt-db-and-disable-backup.md` that could leave
the DB unreadable if the process was killed partway through.

## What was wrong

1. The "should I migrate?" decision keyed off `DbKey.exists()`, but the key is
   stored *before* the migration runs. A mid-migration kill meant the next
   launch skipped migration and tried to open the still-plaintext file with a
   password → lockout.
2. The plaintext file was deleted just before the encrypted copy was renamed in,
   so a rename failure could start the app with an empty DB.

## Changes

- `lib/database/database_helper.dart`:
  - Replaced `_migratePlaintextIfPresent` + its call site with `_ensureEncrypted`,
    which decides what to do by **probing the files**, not a stored flag, so an
    interrupted run retries cleanly:
    - missing DB (fresh install) → left alone (created encrypted on open),
    - opens with the key → already encrypted → strays cleaned up,
    - opens as plaintext → migrate,
    - opens as neither → throw, touch nothing.
  - Added interrupted-swap recovery: if `path` is missing but `path.bak` exists,
    the original is restored from `.bak` before re-running.
  - New `_migrate` uses **verify-then-swap**: export to `path.enc`, reopen it
    with the key and require the same `contacts` row count and `user_version`,
    then rename `path`→`path.bak`, rename `path.enc`→`path` (rolling back to
    `.bak` if that fails), and only then delete `.bak`. The original plaintext is
    never destroyed until the encrypted copy is written, verified, and live.
  - Stale plaintext journal siblings (`-wal`/`-shm`) are removed before the
    encrypted file takes over `path`, so they can't be mis-associated with it.
  - Added helpers `_opensWith` (read-only, non-cached probe), `_intOf`,
    `_deleteFiles`.
- `lib/database/db_key.dart`: removed the now-unused `DbKey.exists()`.

## Verification

- `flutter analyze` — no issues.
- `flutter test test/contact_stem_search_test.dart` — all pass (host path never
  reaches the encryption branch).
- Confirmed `sqflite_sqlcipher` 3.4.0 `openDatabase` supports `password` (nullable),
  `readOnly`, and `singleInstance`, matching the probe usage.

## Still needs a device run

The migration/recovery only executes when `Platform.isAndroid`, so it is not
exercised on the host. Recommend testing on a device/emulator: (a) upgrade over an
install that has a plaintext DB and confirm contacts survive, (b) fresh install
creates an encrypted DB, and — if feasible — (c) kill the app mid-migration and
confirm the next launch recovers.
