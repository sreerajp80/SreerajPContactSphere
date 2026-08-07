# Fix WAL pragma crashing every DB query

Implements [plans/20260713_143000_fix-wal-pragma-crash.md](../plans/20260713_143000_fix-wal-pragma-crash.md).

## What changed

- `lib/database/database_helper.dart`: in `_onConfigure`, changed
  `db.execute('PRAGMA journal_mode = WAL')` to
  `db.rawQuery('PRAGMA journal_mode = WAL')`.

## Why

`PRAGMA journal_mode = WAL` returns a result row (the new journal mode).
sqflite's `execute()` rejects statements that return rows and throws
`DatabaseException(... Queries can be performed using SQLiteDatabase query or
rawQuery methods only.) sql 'PRAGMA journal_mode = WAL'`. Since `_onConfigure`
runs on every connection open, the database failed to open and every DB-backed
screen rendered blank. `rawQuery` reads the returned row without throwing while
still switching the DB to WAL mode.

The `PRAGMA foreign_keys = ON` line was left on `execute()` because it returns
no rows.
