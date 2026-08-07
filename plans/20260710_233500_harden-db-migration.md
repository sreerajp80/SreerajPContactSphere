# Make the plaintext→encrypted DB migration crash-safe

**Status:** completed

## Issue

The first-run migration in `lib/database/database_helper.dart` preserves data on a
clean run, but two interruption windows can leave the DB unreadable:

1. **Wrong retry gate.** "Should I migrate?" is decided by `DbKey.exists()`, but the
   key is stored *before* the migration runs. If the process is killed mid-migration,
   the next launch sees the key, skips migration, and tries to open the still-plaintext
   file *with a password* → open fails → app can't read existing contacts (lockout).
2. **Delete-before-rename window.** The plaintext file is deleted right before the
   encrypted copy is renamed in. If the rename fails there, the app starts with an
   empty DB (the encrypted copy is stranded at `.enc`).

## Files to change

- `lib/database/database_helper.dart` — replace the migration + its call site with a
  resumable, verify-then-swap version.
- `lib/database/db_key.dart` — remove now-unused `exists()`.

## Fix plan

Decide state by **probing the file**, not a stored flag, so any interrupted run just
retries cleanly. Staging files: `path` (live), `path.enc` (fresh encrypted staging),
`path.bak` (old plaintext fallback). The original plaintext is only destroyed after the
encrypted copy is written, **verified**, and swapped in.

`_ensureEncrypted(path, key)`:
- **Recover first:** if `path` is missing but `path.bak` exists, an interrupted swap
  left the original at `.bak` — restore it (`bak`→`path`). Delete any stale `.enc`.
- If `path` is missing (fresh install) → return; the DB is created encrypted on open.
- Probe `path` (read-only, no version/callbacks so nothing is created or upgraded):
  - opens **with** the key → already encrypted → clean up strays, return.
  - opens **without** a key → plaintext → migrate.
  - opens with neither → corrupt/unknown → throw, touch nothing.

`_migrate(path, key)`:
1. Delete any stale `path.enc*`.
2. Open plaintext, record `user_version` and `contacts` row count, `sqlcipher_export`
   into `path.enc` (with key), carry `user_version` over, detach, close.
3. **Verify:** open `path.enc` with the key; require the same row count and
   `user_version`. Mismatch → throw before deleting anything.
4. **Swap:** delete stale plaintext journal siblings (`path-wal/-shm`; their data is
   already in the exported+verified copy), rename `path`→`path.bak`, rename
   `path.enc`→`path`. If the second rename fails, restore `bak`→`path` and rethrow.
5. Delete `path.bak` (and any `.enc`/`.bak` journal leftovers).

Probes use `readOnly: true, singleInstance: false`; the key/paths are hex/app-internal
so inlined SQL literals are safe.

## Testing

- `flutter analyze` clean.
- `flutter test` on two DB-backed files (host path is unaffected — it never reaches the
  encryption branch).
- On-device migration still needs a manual device run (documented in the change log).
