# Rebuild all `name_translit` search keys (v14 → v15 migration)

**Status:** completed

## The issue

Searching a Malayalam name in the Contacts page can return an **extra, unrelated
contact**. Example seen on the prod install: searching a two-word Malayalam name
returned both the intended contact (correct) **and** an unrelated contact (wrong).

### Root cause (confirmed, not a guess)

The search matches the query's romanized key `searchKey(q)` against the stored
`contacts.name_translit` column
([contact_repository.dart:768](../lib/repositories/contact_repository.dart#L768)).
`name_translit` is supposed to equal `searchKey(fullName)`.

We pulled the fresh **dev** database off the device and ran the exact search SQL:
it returned only the one correct contact. The unrelated row's key there was correct.
So the **search code is correct**; the bug is that the **prod** install has
rows whose stored `name_translit` is **stale** — left over from an earlier name and
never refreshed. Re-saving the affected contact by hand recomputed its key and the
phantom match disappeared, which confirms the diagnosis.

The current code already keeps the key current on every `insertContact` /
`updateContact`, so no new stale rows are being created — the stale set is a **frozen
legacy artifact** from an older app version. The one-time v11→v12 backfill already ran,
so it will not re-correct them. We cannot enumerate the affected rows from outside (the
release build is not debuggable), and hand-editing every contact is impractical.

## The fix

Add a one-time repair step to `_onUpgrade` that **recomputes `name_translit` for every
contact** from its current name parts. This is safe to run blindly: a row that is
already correct is rewritten to the same value; stale rows are corrected. It mirrors the
existing v11→v12 backfill logic exactly
([database_helper.dart:360](../lib/database/database_helper.dart#L360)).

Because it is guarded by `if (oldVersion < 15)`, it runs **once** per install when
crossing that version boundary and is skipped forever after. Fresh installs go through
`onCreate` and never run it. The block stays in the file permanently (append-only
migration history) so any old install can still catch up.

### Changes (single file: `lib/database/database_helper.dart`)

1. Bump the schema version: line 25, `version: 14` → `version: 15`.
2. Append a new guarded block at the end of `_onUpgrade` (after the `oldVersion < 14`
   block, ~line 419):

   ```dart
   // v14 -> v15: repair stale name_translit keys. Older app versions could leave
   // this column out of sync with the current name (e.g. a rename that did not
   // recompute it), which made an unrelated contact match a name search. Rebuild
   // every row's key from its current name; harmless for rows already correct.
   if (oldVersion < 15) {
     final rows = await db.query(
       'contacts',
       columns: ['id', 'salutation', 'first_name', 'middle_name', 'last_name'],
     );
     final batch = db.batch();
     for (final r in rows) {
       final name = [
         r['salutation'],
         r['first_name'],
         r['middle_name'],
         r['last_name'],
       ].whereType<String>().where((s) => s.isNotEmpty).join(' ');
       batch.update(
         'contacts',
         {'name_translit': searchKey(name)},
         where: 'id = ?',
         whereArgs: [r['id']],
       );
     }
     await batch.commit(noResult: true);
   }
   ```

`searchKey` is already imported in this file (used by the v11→v12 block), so no new
import is needed. No other files change.

## Files to change

- `lib/database/database_helper.dart`
  - Bump `version: 14` → `version: 15`.
  - Add the `if (oldVersion < 15)` repair block at the end of `_onUpgrade`.

## Verification

- `flutter analyze` — no new errors.
- Build + install the **dev** flavor (fresh DB is already at the new version via
  `onCreate`, so the migration path is not exercised there). To actually exercise the
  repair, install a build over an existing dev DB, or verify on prod after the update:
  repeat the reported search and confirm only the intended contact appears.
- Optional confidence check: pull the dev DB and confirm every row satisfies
  `name_translit == searchKey(fullName)`.
