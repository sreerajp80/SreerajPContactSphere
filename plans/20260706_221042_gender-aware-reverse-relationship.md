# Gender-aware reverse relationships

**Status:** completed

## The issue

Every relationship link is stored as **two directed rows**: `A→B` with the label
the user picked, and `B→A` with an auto-computed *reverse* label
(`RelationshipRepository.setRelationship`, [relationship_repository.dart:21-42](../lib/repositories/relationship_repository.dart#L21-L42)).

The reverse label comes from `RelationshipTypes.reciprocalOf(type)`
([relationship.dart:205-208](../lib/models/relationship.dart#L205-L208)), which is a
plain `String → String` map and **ignores gender completely**. For gendered
relationships this produces wrong labels:

- `Cousin Brother` maps to `Cousin Brother`, `Cousin Sister` maps to `Cousin Sister`
  (mapped to themselves). So recording "B is A's **Cousin Brother**" stores the
  reverse "A is B's **Cousin Brother**" — even when A is female. That is the
  wrong-gender label circled in the screenshots (a male photo labelled
  "Cousin Sister", and vice-versa).
- `Brother`/`Sister` both collapse to the generic `Sibling` (gender lost).
- `Uncle`→`Nephew`, `Aunt`→`Niece` are fixed regardless of the *other* person's gender.
- `Father`/`Mother`→`Child`, `Son`/`Daughter`→`Parent` (gender lost).

### Why gender belongs on the reverse

The label on row `(contact_id = X, related = Y)` reads as "**Y is X's `<label>`**"
(this is how the sphere and detail screen display it). So the reverse row
`(B, A, reverse)` describes **A** — the original `contactId`/owner. Therefore the
reverse label must be chosen using **A's gender**, which the code has but never reads.

## The fix

Make the reverse computation gender-aware, using the gender of the contact the
reverse label will describe (the original owner, `contactId`).

### Files to change

1. **[lib/models/relationship.dart](../lib/models/relationship.dart)**
   - Change `reciprocalOf(String type)` to
     `reciprocalOf(String type, {String? subjectGender})`.
   - `subjectGender` = gender of the contact the reverse label describes.
     Compare case-insensitively: `male`/`female` are recognised; empty, null,
     `Non-binary`, `Prefer not to say`, or any custom value fall back to the
     existing gender-neutral behaviour (no regression).
   - Add two small const maps holding **only** the gendered entries, keyed by the
     forward label:

     | forward type(s)                              | reverse if owner **male** | reverse if owner **female** | reverse if **unknown** (current behaviour) |
     |----------------------------------------------|---------------------------|-----------------------------|--------------------------------------------|
     | Cousin / Cousin Brother / Cousin Sister      | Cousin Brother            | Cousin Sister               | Cousin                                     |
     | Brother / Sister / Sibling                   | Brother                   | Sister                      | Sibling                                    |
     | Father / Mother / Parent                     | Son                       | Daughter                    | Child                                      |
     | Son / Daughter / Child                       | Father                    | Mother                      | Parent                                     |
     | Grandfather / Grandmother / Grandparent      | Grandson                  | Granddaughter               | Grandchild                                 |
     | Grandson / Granddaughter / Grandchild        | Grandfather               | Grandmother                 | Grandparent                                |
     | Uncle / Aunt                                 | Nephew                    | Niece                       | Nephew / Niece (as today)                  |
     | Nephew / Niece                               | Uncle                     | Aunt                        | Uncle / Aunt (as today)                    |
     | Elder Brother / Elder Sister                 | Younger Brother           | Younger Sister              | (unchanged from today's map)               |
     | Younger Brother / Younger Sister             | Elder Brother             | Elder Sister                | (unchanged from today's map)               |

   - Lookup order: if `subjectGender` is male/female **and** the forward type is in
     the gendered map, return that; otherwise fall back to the existing
     `_reciprocals` map, then to the type itself. Non-gendered types (Spouse,
     Partner, Friend, Colleague, Neighbour, Relative, in-laws, step-relations)
     are untouched.

2. **[lib/repositories/relationship_repository.dart](../lib/repositories/relationship_repository.dart)**
   - In `setRelationship`, before computing the reverse, load the owner's gender
     with a lightweight query (`SELECT gender FROM contacts WHERE id = ?`) and
     pass it as `subjectGender` to `reciprocalOf`. Add a small private helper
     `_genderOf(txn, id)`. Keep everything inside the existing transaction.

No schema change. No UI change. No change to the forward label the user picks
(that stays their explicit choice).

## Scope / limits (please note)

- This fixes **new and re-saved** relationships. Existing wrong rows already in the
  database are not rewritten by this change (there is no stored "direction" flag to
  safely tell forward from reverse in a migration). Re-adding/editing a relationship
  rewrites both rows correctly (`setRelationship` deletes the pair and re-inserts).
  A one-time repair pass can be added later if wanted — out of scope here.
- If the owner contact has no gender set, behaviour is exactly as today
  (neutral label) — so nothing regresses for gender-less contacts.

## Verification

- `flutter analyze` clean for the two edited files.
- `flutter test` (add/keep a small unit test for `reciprocalOf` covering:
  Cousin Brother + female owner → Cousin Sister; + male owner → Cousin Brother;
  + unknown → Cousin; Brother + female → Sister; Father + male → Son;
  Spouse → Spouse unchanged).
- Manual: add a Cousin relationship where the owner is female, confirm the reverse
  node shows "Cousin Sister"; flip owner gender and re-add, confirm "Cousin Brother".
