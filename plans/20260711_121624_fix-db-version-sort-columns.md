# Fix: contact list blank — sort_first/sort_last never added on device

**Status:** completed

## The issue

On the device the main Contacts list is blank, while the dialer contacts,
call log, duplicate finder, and contact counts all show contacts. The log
shows repeated errors:

```
no such column: sort_first
```

### Why

`DatabaseHelper._initDatabase()` opens the DB two ways:

- Test / host path (plain sqflite): `version: 18` — [database_helper.dart:58](../lib/database/database_helper.dart#L58)
- On-device path (SQLCipher, encrypted): `version: 16` — [database_helper.dart:69](../lib/database/database_helper.dart#L69)

The migration that adds and backfills `contacts.sort_first` / `sort_last`
is gated on `oldVersion < 18` and calls `_ensureSortColumns` —
[database_helper.dart:507](../lib/database/database_helper.dart#L507).

Because the encrypted (device) open still asks for `version: 16`, `onUpgrade`
never advances the device DB to 18, so `_ensureSortColumns` never runs and the
two columns are never created on the device.

The contact **list** query orders by `c.sort_first` / `c.sort_last`
([contact_repository.dart:774-813](../lib/repositories/contact_repository.dart#L774)),
so it throws and the list renders empty. The other screens order by
`first_name`, so they keep working. The device-sync `UPDATE` also writes those
columns, producing the crash seen in the log.

Tests pass because the host path already uses `version: 18`, so the columns
exist there — the two paths drifted out of sync.

## The fix

Change the encrypted on-device open to `version: 18` so it matches the test
path and the highest migration step.

- [lib/database/database_helper.dart](../lib/database/database_helper.dart)
  line 69: `version: 16` → `version: 18`.

On the next app launch, the device DB (currently at 16) will run `onUpgrade`
16 → 18. The `oldVersion < 18` block calls `_ensureSortColumns`, which is
already PRAGMA-existence-checked: it adds `sort_first` / `sort_last` if missing
and backfills every row's romanized sort key. After that the list query
succeeds and contacts appear.

## Files to change

- `lib/database/database_helper.dart` — one-line version bump (16 → 18).

## Verification

- `flutter analyze` stays clean.
- On device: relaunch the app; the Contacts list shows all contacts and the
  `no such column: sort_first` errors stop.
