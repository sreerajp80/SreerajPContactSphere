# Expand relationship types (siblings, cousins, in-laws, grand, step)

**Status:** completed

## The issue

The relationship picker only offers a small, generic list (Father, Mother, Brother,
Sister, Uncle, Aunt, Cousin, …). Users need finer Indian-family relations such as
elder/younger brother and sister, cousin brother/sister, and the in-laws
(father-in-law, mother-in-law, brother-in-law, sister-in-law, and so on).

## Where it lives

Everything is driven by two lists in
[lib/models/relationship.dart](lib/models/relationship.dart):

- `RelationshipTypes.presets` (lines 104-130) — the chips shown in the picker.
- `RelationshipTypes._reciprocals` (lines 133-159) — the reverse label stored on
  the *other* contact (relationships are saved as two rows A→B and B→A).

Confirmed there is nothing else to change:
- The picker widget [lib/widgets/relationship_editor.dart:203](lib/widgets/relationship_editor.dart#L203)
  just renders `presets` as chips — new entries appear automatically.
- `relationship_type` is a **free-text** column (no DB constraint / enum), so no
  migration is needed.
- No code branches on specific relationship strings (the only `type ==` checks in
  the codebase are for *address* types, not relationships).

## Files to change

1. `lib/models/relationship.dart` — extend `presets` and `_reciprocals`.
2. (docs) `docs/architecture.md` if it lists the preset set — will check and update
   only if it hard-codes the list.

## New relations to add (grouped for the picker)

Siblings: **Elder Brother, Younger Brother, Elder Sister, Younger Sister**
Cousins: **Cousin Brother, Cousin Sister**
In-laws: **Father-in-law, Mother-in-law, Son-in-law, Daughter-in-law, Brother-in-law, Sister-in-law**
Grand: **Grandson, Granddaughter**
Step: **Step-father, Step-mother, Step-son, Step-daughter, Step-brother, Step-sister**

(Kept gendered throughout to match the existing style of the list.)

## Reverse (reciprocal) labels

You chose "keep the same label" for the reverse side. I apply that for the **peer**
relations where it reads correctly. For the **vertical / directional** relations the
same label would be self-contradictory (e.g. "A is B's father-in-law" cannot make
"B is A's father-in-law"), so I use the natural opposite instead. Where the reverse
person's gender is unknown I pick the concrete same-gender opposite (consistent with
your preference for concrete over generic labels).

Peer — reverse = same label:
- Cousin Brother ↔ Cousin Brother
- Cousin Sister ↔ Cousin Sister
- Brother-in-law ↔ Brother-in-law
- Sister-in-law ↔ Sister-in-law
- Step-brother ↔ Step-brother
- Step-sister ↔ Step-sister

Directional — reverse = opposite:
- Elder Brother ↔ Younger Brother
- Elder Sister ↔ Younger Sister
- Father-in-law ↔ Son-in-law
- Mother-in-law ↔ Daughter-in-law
- Step-father ↔ Step-son
- Step-mother ↔ Step-daughter
- Grandson → Grandparent, Granddaughter → Grandparent  (grandparent gender unknown; matches existing Grandchild → Grandparent)

Existing reciprocals stay untouched.

## Not doing

- No change to the sphere view, scoring, or storage format.
- Not adding relationship gender inference from the linked contact (would be a
  larger change; can revisit later if you want the reverse label to follow the
  other person's real gender).

## Test / verify

- `flutter analyze` stays clean.
- Manually: open a contact → add relationship → confirm the new chips appear and the
  reverse label shows correctly on the linked contact.
- Update `test/relationship_repository_test.dart` only if it asserts on the exact
  preset count/content (will check).
