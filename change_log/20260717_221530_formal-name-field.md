# Change log: Add a "Formal Name" field to contacts

Implements plan `plans/20260717_220725_formal-name-field.md`.

## What changed

Added a new free-text **Formal name** field to a contact. It is stored with the
contact, shown on the contact detail screen, and can be found by contact search
(both plain typing and the romanized / Malayalam transliteration search). It is
not used as the display name and has no special device-address-book handling.

## Files changed

1. **`lib/database/database_helper.dart`**
   - Added `formal_name TEXT` to the `CREATE TABLE contacts` statement.
   - Bumped the DB version from `19` to `20` (both the plain and the encrypted
     `openDatabase` calls).
   - Added the `v19 -> v20` migration, which calls the new
     `_ensureFormalNameColumn` helper. The helper checks `PRAGMA table_info`
     before running `ALTER TABLE contacts ADD COLUMN formal_name TEXT`, so it
     self-heals a DB that was version-bumped during development before the
     migration existed (same pattern as `_ensureSortColumns` /
     `_ensureMergedConfirmedColumn`).
   - Exposed a public `ensureFormalNameColumn(db)` wrapper (mirrors the public
     `ensureSortColumns`) so the migration and tests drive the same code.

2. **`lib/models/contact.dart`**
   - Added the `String? formalName` field (with a doc comment), the constructor
     parameter, and the `toMap()` / `fromMap()` mappings for `formal_name`.

3. **`lib/repositories/contact_repository.dart`**
   - Included `contact.formalName` in `_nameSearchKey(...)`, so it is folded
     into the stored `name_translit` key and reachable by the romanized search.
   - Added `OR LOWER(COALESCE(c.formal_name, '')) LIKE ?` to
     `searchContactSummaries(...)` (with the matching `like` argument) so exact-
     script typing finds the formal name too.

4. **`lib/screens/add_edit_contact_screen.dart`**
   - Added the `_formalName` controller (declare, init from `c?.formalName`,
     dispose), a "Formal name" input field in `_nameSection()` (between the
     name row and Blood group), and `..formalName = _nullIfEmpty(_formalName.text)`
     on save.

5. **`lib/screens/contact_detail_screen.dart`**
   - Added a `ListTile` (guarded by a non-empty check) showing the formal name
     with subtitle "Formal name", placed just above the Blood group tile.

## Not changed

- `lib/services/sync_bundle_service.dart` / `backup_service.dart`: the export
  uses `db.query('contacts')` (all columns) and re-inserts the whole row map on
  restore, so `formal_name` is carried automatically.

## Verification

- `flutter analyze` on all five touched files: **No issues found**.
- New migration test `test/db_formal_name_column_test.dart`: builds a pre-v20
  contacts table (no `formal_name`), runs `ensureFormalNameColumn`, and asserts
  the column is added, existing rows stay NULL, a written value round-trips, and
  a second call is a no-op. **Passes.**
- Re-ran `test/contact_stem_search_test.dart` (search-query change) and
  `test/contact_sync_service_test.dart` (model/repository) — **all pass**, so the
  added `formal_name` search clause and argument list are correct.
- The new column is nullable and defaults to NULL, so existing rows and the
  existing sync/backup tests are unaffected.
