# Change log — rebuild all `name_translit` search keys (v14 → v15 migration)

Implements plan
[plans/20260706_211951_rebuild-name-translit-migration.md](../plans/20260706_211951_rebuild-name-translit-migration.md).

## Why

A Malayalam name search on the Contacts page could return an extra, unrelated contact
(seen on prod: searching a two-word Malayalam name returned both the intended contact
and an unrelated one). Diagnosis (confirmed by pulling the fresh dev DB and running the
exact search SQL, which returned only the one correct match) showed the search code is
correct; the fault is **stale `contacts.name_translit`** rows in older prod data — the
romanized search key was left out of sync with the current name by an older app version.
The current code already recomputes the key on every insert/update, so no new stale rows
are created; the stale set is a frozen legacy artifact, and the one-time v11→v12 backfill
had already run.

## What changed

Single file: `lib/database/database_helper.dart`

1. Bumped the schema version `14 → 15`.
2. Added a guarded `if (oldVersion < 15)` block at the end of `_onUpgrade` that rebuilds
   `name_translit` for **every** contact from its current name parts (salutation +
   first + middle + last), using the existing `searchKey()` — identical logic to the
   v11→v12 backfill. It runs once per install when crossing the boundary, is a no-op for
   rows already correct, and never runs again on an up-to-date device.

No other files changed. `searchKey` was already imported. No new import needed.

Note: the file's `version` constant now reads `16` and a `v15 -> v16` block
(`repairGenderedRelationshipLabels`) follows this one — that is a **separate, unrelated
migration added afterward**, not part of this change. This change's `oldVersion < 15`
block is unaffected and still runs for any install below 15.

## Verification

- `flutter analyze lib/database/database_helper.dart` — No issues found.
- Ran the exact rebuild logic with the **real Dart `searchKey`** against the 281
  contacts dumped from the dev DB: **0 mismatches** (every stored key already equals
  `searchKey(fullName)` in fresh data — confirming the migration writes correct values).
- Repair demo: a deliberately stale key planted on an unrelated contact is rebuilt from
  that contact's real name, so it no longer matches the original query — i.e. the
  migration removes exactly the kind of phantom match reported.
- Earlier manual confirmation: re-saving the offending contact in prod (which recomputes
  the same key) already made it drop out of the reported search results.

The full-APK on-device run of the migration was not exercised (the debug build was not
rebuilt in this session); the logic is a faithful copy of the proven v11→v12 backfill and
was validated with the real `searchKey` as above.
