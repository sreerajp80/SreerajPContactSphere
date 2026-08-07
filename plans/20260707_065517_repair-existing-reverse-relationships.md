# One-time repair pass for existing wrong-gender relationship rows

**Status:** completed

## The issue

The earlier fix
([change_log/20260706_223145](../change_log/20260706_223145_gender-aware-reverse-relationship.md))
made the auto-computed reverse label gender-aware, but only for **new / re-saved**
links. Rows already in the database still carry the old wrong labels — e.g. a
female contact stored as "Cousin Brother", or a male contact as "Cousin Sister".
We now want a one-time pass that repairs those existing rows.

## Key insight — no "direction" flag is needed

Each relationship row `(contact_id = X, related_contact_id = Y, relationship_type = T)`
means "**Y is X's T**" — the label `T` describes **Y** (the `related_contact_id`,
which is exactly the node shown in the sphere/detail list). So we do **not** need to
know which of the two reciprocal rows was the user's "forward" choice. We only need
one rule:

> A gendered label must agree with the gender of the contact it describes
> (`related_contact_id`).

For the buggy pair the two rows are:
- `(she, he, 'Cousin Brother')` → describes **he** (male) → "Cousin Brother" is fine.
- `(he, she, 'Cousin Brother')` → describes **she** (female) → wrong → "Cousin Sister".

Repairing each row against its described contact's gender fixes exactly the broken
reverse rows and leaves correct rows untouched.

### Deliberately conservative

- Only swap a **gendered** label to its opposite-gender sibling **within the same
  family** (Brother↔Sister, Cousin Brother↔Cousin Sister, Father↔Mother, Uncle↔Aunt,
  Nephew↔Niece, Grandfather↔Grandmother, in-law and step variants, …). The
  relationship meaning is preserved; only the gendered wording changes.
- **Never** touch neutral labels (Cousin, Sibling, Child, Parent, Grandchild, …) —
  we don't force a gender the user left unset.
- **Never** touch rows whose described contact has no gender / a non-binary / custom
  gender — behaviour there stays as-is.
- Non-gendered relations (Spouse, Partner, Friend, Colleague, Neighbour, Relative)
  are irrelevant and untouched.

Note: this also corrects a **forward** row if its label contradicts the described
contact's recorded gender (e.g. "Brother" set on a female contact → "Sister"). That
is the desired consistency and only changes the gendered wording, not the relation.

## The fix

### Files to change

1. **[lib/models/relationship.dart](../lib/models/relationship.dart)**
   - Add a const list of male↔female label pairs (`_genderPairs`).
   - Add a pure helper
     `static String forGender(String type, String? gender)`: if `type` is the
     male member of a pair and `gender` is `Female` (case-insensitive), return the
     female member; if `type` is the female member and `gender` is `Male`, return
     the male member; otherwise return `type` unchanged (covers neutral labels,
     non-gendered relations, and unknown/non-binary gender).

2. **[lib/database/database_helper.dart](../lib/database/database_helper.dart)**
   - `import '../models/relationship.dart';` (model has no imports → no cycle).
   - Bump DB `version: 15` → `16` (line 25).
   - Add a small **public** method
     `Future<int> repairGenderedRelationshipLabels(DatabaseExecutor db)` that:
     joins `relationships` to `contacts` on `related_contact_id`, runs each row's
     `relationship_type` through `RelationshipTypes.forGender(type, gender)`, and
     `UPDATE`s (in a batch) only the rows whose label actually changes; returns the
     count fixed. Making it a named method (not inline) gives a clean, testable seam.
   - Add an `if (oldVersion < 16)` block in `_onUpgrade` that calls it — matching the
     existing v14→v15 backfill style. The migration runs automatically, exactly once,
     on the next app open after update.

3. **[test/relationship_repository_test.dart](../test/relationship_repository_test.dart)**
   - Unit tests for `forGender`: Cousin Brother + female → Cousin Sister; Cousin
     Sister + male → Cousin Brother; Brother + female → Sister; Uncle + female →
     Niece; neutral "Cousin"/"Sibling" unchanged; unknown/non-binary gender
     unchanged; Spouse unchanged.
   - Integration test for the repair: insert contacts (one male, one female) and
     deliberately inconsistent relationship rows **directly** (simulating legacy
     data written before the gender-aware path), call
     `DatabaseHelper().repairGenderedRelationshipLabels(db)`, and assert the wrong
     rows were corrected, the correct/neutral rows left alone, and the returned
     count is right. Also assert running it twice is idempotent (second run fixes 0).

No schema/column change; only data values in `relationships` are updated. No UI
change.

## Verification

- `flutter analyze` clean on the three files.
- `flutter test test/relationship_repository_test.dart` green (existing + new tests).
- Manual (optional): on a device holding the old data, open the app once (migration
  runs) and confirm the previously mislabeled cousin node now shows the correct
  gendered label.

## Risks / limits

- Relies on the recorded `gender` of the described contact. If a contact's gender is
  wrong in the DB, the "correction" follows that wrong gender — acceptable; fixing
  contact gender is out of scope.
- If a contact genuinely has no gender set, its rows are left neutral/as-is (no
  guessing).
- Idempotent and safe to re-run; the version guard ensures it runs only once.
