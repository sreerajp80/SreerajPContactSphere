# Change log — gender-aware reverse relationships

Implements plan
[plans/20260706_221042_gender-aware-reverse-relationship.md](../plans/20260706_221042_gender-aware-reverse-relationship.md).

## Problem

Relationship links are stored as two directed rows (A→B chosen by the user, B→A
auto-computed). The reverse label came from `RelationshipTypes.reciprocalOf(type)`,
which ignored gender. So the reverse of `Cousin Brother` was `Cousin Brother` and
of `Cousin Sister` was `Cousin Sister`, regardless of the other person's gender —
producing wrong-gender labels (e.g. a male contact shown as "Cousin Sister"), plus
`Brother`/`Sister` collapsing to generic `Sibling`, etc.

The reverse row describes the original owner (`contactId`), so the reverse label
must be chosen using that owner's gender.

## Changes

1. **[lib/models/relationship.dart](../lib/models/relationship.dart)**
   - `reciprocalOf(String type)` → `reciprocalOf(String type, {String? subjectGender})`.
   - Added two const maps `_reciprocalsMale` and `_reciprocalsFemale` holding only
     the gender-dependent reverses (Cousin, Sibling, Parent/Child, Grandparent/
     Grandchild, Uncle/Aunt ↔ Nephew/Niece, Elder/Younger Brother/Sister).
   - Lookup: if `subjectGender` is `male`/`female` (case-insensitive) and the type
     is in the gendered map, use that; otherwise fall back to the existing neutral
     `_reciprocals` map, then to the type itself. Non-gendered types (Spouse,
     Partner, Friend, in-laws, step-relations, …) and unknown/empty/non-binary
     gender behave exactly as before — no regression.

2. **[lib/repositories/relationship_repository.dart](../lib/repositories/relationship_repository.dart)**
   - `setRelationship` now loads the owner's gender inside the existing transaction
     and passes it as `subjectGender` to `reciprocalOf`.
   - Added private helper `_genderOf(txn, id)` — a light
     `SELECT gender FROM contacts WHERE id = ?` query.

3. **[test/relationship_repository_test.dart](../test/relationship_repository_test.dart)**
   - `insertContact` now accepts an optional `gender`.
   - Added tests: gendered `reciprocalOf` (Cousin Brother→Cousin Sister for female
     owner, →Cousin Brother for male, →Cousin Brother when unknown; Brother/Sister;
     Father→Son/Daughter; Uncle→Niece), neutral fallback for non-binary/empty
     gender, Spouse unaffected, and an end-to-end `setRelationship` test asserting
     the reverse row is gendered by the owner.

## Verification

- `flutter analyze` on the three files: **No issues found**.
- `flutter test test/relationship_repository_test.dart`: **all 11 tests passed**.
  (Cleared a stale `build/native_assets/windows/sqlite3.dll` locked by a leftover
  `flutter_tools`/`flutter_tester` process — a known Windows tooling issue,
  unrelated to the change.)

## Scope / follow-ups not done

- Fix applies to **new and re-saved** relationships only. Existing wrong rows in the
  database are not rewritten (no stored direction flag to migrate safely). Re-adding
  a relationship rewrites both rows correctly. A one-time repair pass over existing
  data was left out of scope.
