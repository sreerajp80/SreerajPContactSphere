# Add a "Formal Name" field to contacts

**Status:** completed

## What the user wants

Add one more field to a contact: **Formal Name**.

Behaviour chosen by the user: **Stored + searchable**.
- It is a free-text field saved with the contact.
- It is shown on the contact detail screen.
- It can be found by contact search (both plain typing and the romanized /
  Malayalam transliteration search).
- It is **not** used as the display name anywhere, and there is no special
  device-address-book field for it (it just rides along in backup/sync like the
  other columns).

## The issue

There is no place to store or edit a formal name today. The contact has
`salutation`, `firstName`, `middleName`, `lastName`, `bloodGroup`, etc., but
nothing for a formal name.

## Files to change

1. **`lib/database/database_helper.dart`** — schema + migration.
   - Add `formal_name TEXT` to the `CREATE TABLE contacts` statement (near
     `last_name`).
   - Bump the DB version from `19` to `20` (two spots: the `openDatabase`
     `version:` at lines ~58 and ~70).
   - Add a `v19 -> v20` step in `_onUpgrade`:
     `ALTER TABLE contacts ADD COLUMN formal_name TEXT`.

2. **`lib/models/contact.dart`** — model.
   - Add `String? formalName;` field (next to the other name fields).
   - Add it to the constructor, to `toMap()` (`'formal_name': formalName`), and
     to `fromMap()` (`formalName: map['formal_name']`).

3. **`lib/repositories/contact_repository.dart`** — make it searchable.
   - Include `contact.formalName` in `_nameSearchKey(...)` so it is folded into
     the stored `name_translit` key. This makes the formal name reachable by the
     romanized / Manglish / Malayalam search that already runs on that column.
   - Add a plain-substring match on the new column in
     `searchContactSummaries(...)`: an extra
     `OR LOWER(COALESCE(c.formal_name, '')) LIKE ?` clause with the existing
     `like` argument, so exact-script typing finds it too.

4. **`lib/screens/add_edit_contact_screen.dart`** — edit UI.
   - Add a `_formalName` `TextEditingController`, initialise it from
     `c?.formalName`, dispose it (add to the dispose list), and write it back on
     save with `..formalName = _nullIfEmpty(_formalName.text)`.
   - Add a "Formal name" input field in `_nameSection()` (e.g. under the
     first/middle/last row, before or after Blood group).

5. **`lib/screens/contact_detail_screen.dart`** — show it.
   - Add a `ListTile` (guarded by a non-empty check, like the Blood group tile)
     that shows the formal name with subtitle "Formal name".

## Not changing (confirmed)

- **`lib/services/sync_bundle_service.dart` / `backup_service.dart`** — the
  export uses `db.query('contacts')` (all columns) and re-inserts the whole row
  map on restore, so `formal_name` is carried automatically. No edit needed.
- No name-migration backfill is needed for `name_translit`. Existing rows have
  no formal name, so their key is unchanged; the key is recomputed (now
  including the formal name) whenever a contact is next saved.

## Migration safety note

Following the pattern used by other recent columns, I can also make the v20 step
existence-checked (PRAGMA `table_info`) so a DB that was version-bumped during
development before this migration existed still self-heals. I will use a plain
`ALTER TABLE` gated by an existence check to match the project's habit
(see `_ensureSortColumns` / `_ensureMergedConfirmedColumn`).

## Test / verify

- `flutter analyze` stays clean for the touched files.
- Manual: add/edit a contact, set a formal name, save, reopen — value persists
  and shows on the detail screen; searching the formal name finds the contact.
- Existing tests in `test/contact_sync_service_test.dart` and backup tests
  should still pass (new column is nullable and defaults to NULL).
