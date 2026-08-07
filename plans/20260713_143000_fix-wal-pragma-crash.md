# Fix WAL pragma crashing every DB query

**Status:** completed

## Issue

The app opens blank on every DB-backed screen. The on-screen error is:

```
DatabaseException(unknown error (code 0): Queries can be performed using
SQLiteDatabase query or rawQuery methods only.) sql 'PRAGMA journal_mode = WAL' args []
```

Yesterday's change added WAL mode in `_onConfigure`:

```dart
await db.execute('PRAGMA journal_mode = WAL');   // lib/database/database_helper.dart:84
```

`PRAGMA journal_mode = WAL` **returns a result row** (the new journal mode).
sqflite's `execute()` refuses statements that return rows and throws the error
above. Because `_onConfigure` runs on every connection open, the whole database
fails to open, so every query fails and the screens render empty.

`PRAGMA foreign_keys = ON` (line 83) returns no rows, so `execute()` is fine
there — only the WAL line is wrong.

## Files to change

- `lib/database/database_helper.dart` — run the WAL pragma via `rawQuery`
  instead of `execute`.

## Fix

Change line 84 from:

```dart
await db.execute('PRAGMA journal_mode = WAL');
```

to:

```dart
await db.rawQuery('PRAGMA journal_mode = WAL');
```

`rawQuery` reads the returned row and does not throw. WAL still gets set.

## Verify

- Reopen the app; the previously-blank screens (duplicates, contacts, recents)
  load without the DatabaseException.
