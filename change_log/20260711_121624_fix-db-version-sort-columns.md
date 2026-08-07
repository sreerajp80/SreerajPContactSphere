# Fix: contact list blank — sort_first/sort_last never added on device

Implements plan
[plans/20260711_121624_fix-db-version-sort-columns.md](../plans/20260711_121624_fix-db-version-sort-columns.md).

## What was wrong

On the device the main Contacts list was blank, while the dialer contacts,
call log, duplicate finder, and contact counts all worked. The log showed
repeated `no such column: sort_first` errors.

The encrypted on-device DB open asked for `version: 16`, but the migration
that adds and backfills `contacts.sort_first` / `sort_last` is gated on
`oldVersion < 18`. So on device the migration never ran and the two columns
were never created. The list query orders by those columns and threw (blank
list); the sync `UPDATE` that writes them also crashed. The host/test open
already used `version: 18`, so tests passed — the two paths had drifted.

## What changed

- `lib/database/database_helper.dart` (line 69): the encrypted on-device
  open version bumped from `16` to `18`, matching the host/test path and the
  highest migration step.

On next launch the device DB runs `onUpgrade` 16 → 18. That block calls the
already-PRAGMA-existence-checked `_ensureSortColumns`, which adds the columns
if missing and backfills each row's romanized sort key.

## Verification

- `flutter analyze lib/database/database_helper.dart` — No issues found.
- On-device: relaunch the app; the Contacts list should show all contacts and
  the `no such column: sort_first` errors should stop.
