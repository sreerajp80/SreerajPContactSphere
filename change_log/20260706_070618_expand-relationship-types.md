# Expand relationship types

Implements [plans/20260706_070618_expand-relationship-types.md](../plans/20260706_070618_expand-relationship-types.md).

## What changed

Edited `lib/models/relationship.dart` only.

### `RelationshipTypes.presets` — added 20 relations (grouped near their kin)
- Siblings: Elder Brother, Younger Brother, Elder Sister, Younger Sister
- Grand: Grandson, Granddaughter
- Cousins: Cousin Brother, Cousin Sister
- In-laws: Father-in-law, Mother-in-law, Son-in-law, Daughter-in-law, Brother-in-law, Sister-in-law
- Step: Step-father, Step-mother, Step-son, Step-daughter, Step-brother, Step-sister

### `RelationshipTypes._reciprocals` — added reverse labels
- Peer (same label): Cousin Brother, Cousin Sister, Brother-in-law, Sister-in-law, Step-brother, Step-sister
- Directional (opposite): Elder Brother ↔ Younger Brother, Elder Sister ↔ Younger Sister,
  Father-in-law ↔ Son-in-law, Mother-in-law ↔ Daughter-in-law,
  Step-father ↔ Step-son, Step-mother ↔ Step-daughter
- Grandson → Grandparent, Granddaughter → Grandparent (matches existing Grandchild → Grandparent)

Existing presets and reciprocals were left untouched.

## Why no other files changed
- The picker ([lib/widgets/relationship_editor.dart](../lib/widgets/relationship_editor.dart)) renders `presets` as chips, so new entries appear automatically.
- `relationship_type` is a free-text column — no DB migration.
- No code branches on relationship strings.
- `test/relationship_repository_test.dart` only asserts on unchanged reciprocals, so no test change.
- `docs/architecture.md` does not hard-code the preset list.

## Verification
- `flutter analyze lib/models/relationship.dart` → No issues found.

## Known limitation (carried from the plan)
Gendered directional reverses (e.g. Father-in-law → Son-in-law) assume the linked
contact's gender and can be wrong. Inferring the reverse from the linked contact's
real gender was left out of scope.
