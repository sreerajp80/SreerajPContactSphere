# Change log — one-time repair of existing wrong-gender relationship rows

Implements plan
[plans/20260707_065517_repair-existing-reverse-relationships.md](../plans/20260707_065517_repair-existing-reverse-relationships.md).
Follows on from
[change_log/20260706_223145](20260706_223145_gender-aware-reverse-relationship.md),
which made new/re-saved reverse rows gender-aware but left existing rows unfixed.

## Problem

Relationship rows written before the gender-aware fix still held wrong-gender
labels (e.g. a female contact stored as "Cousin Brother"). A one-time pass was
needed to correct them.

## Approach

Each row `(contact_id = X, related_contact_id = Y, relationship_type = T)` means
"Y is X's T" — `T` describes **Y** (`related_contact_id`). So no forward/reverse
direction flag is needed: the repair simply makes each gendered label agree with
the gender of the contact it describes. Only a gendered label that contradicts the
described contact's gender is swapped to its opposite-gender sibling within the same
family; neutral labels, non-gendered relations, and rows whose contact has no /
non-binary gender are left untouched.

## Changes

1. **[lib/models/relationship.dart](../lib/models/relationship.dart)**
   - Added `_genderPairs` — the list of male↔female label pairs
     (Father/Mother, Son/Daughter, Brother/Sister, Elder & Younger variants,
     Cousin Brother/Cousin Sister, Grandfather/Grandmother, Grandson/Granddaughter,
     Uncle/Aunt, Nephew/Niece, and the in-law and step variants).
   - Added `static String forGender(String type, String? gender)` — a pure helper
     that returns the matching-gender label when `type` is a gender-specific label
     contradicting `gender` (`Male`/`Female`, case-insensitive), and returns `type`
     unchanged otherwise (neutral labels, non-gendered relations, unknown /
     non-binary gender).

2. **[lib/database/database_helper.dart](../lib/database/database_helper.dart)**
   - Imported `../models/relationship.dart`.
   - Bumped DB `version` 15 → 16.
   - Added public
     `Future<int> repairGenderedRelationshipLabels(DatabaseExecutor db)`: joins
     `relationships` to `contacts` on `related_contact_id`, runs each label through
     `RelationshipTypes.forGender`, batch-updates only the rows that change, and
     returns the count fixed. Idempotent.
   - Added `if (oldVersion < 16)` block in `_onUpgrade` that calls it — so the
     repair runs automatically, exactly once, on the next app open after update.

3. **[test/relationship_repository_test.dart](../test/relationship_repository_test.dart)**
   - Added a `forGender` group: wrong-gender swaps (Cousin Brother→Cousin Sister,
     Cousin Sister→Cousin Brother, Brother→Sister, Uncle→Aunt, Nephew→Niece,
     Father→Mother), already-correct labels kept, neutral labels kept, non-gendered
     relations kept, unknown/non-binary gender kept.
   - Added an integration test that seeds legacy inconsistent rows directly, runs
     `repairGenderedRelationshipLabels`, asserts only the two wrong rows were fixed
     (correct/neutral/non-binary-target rows untouched, count == 2), and that a
     second run fixes 0 (idempotent).

No schema/column change — only data values in `relationships` are updated. No UI
change.

## Verification

- `flutter analyze` on the three files: **No issues found**.
- `flutter test test/relationship_repository_test.dart`: **all 17 tests passed**.
  (One initial failure was a wrong expectation in the new test — `Uncle` gender-
  swaps to `Aunt`, not `Niece`; the code was correct and the assertion was fixed.
  Also cleared the recurring stale `build/native_assets/windows/sqlite3.dll` lock
  from a leftover Flutter test process — a known Windows tooling issue.)

## Notes / limits

- The repair trusts each contact's recorded `gender`; if that is wrong, the
  correction follows it. Fixing contact gender is out of scope.
- Runs once via the version guard; safe and idempotent if re-run.
