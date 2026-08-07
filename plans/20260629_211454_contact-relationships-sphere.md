# Contact Relationships + Ego-Sphere View

**Status:** completed

## Issue

The app's headline feature — linking contacts to one another and viewing the web of
relationships — is unbuilt. The `relationships` table exists
(`database_helper.dart:141-150`, columns `contact_id`, `related_contact_id`,
`relationship_type`) and is indexed, but:

- `Contact` has no `relationships` field (`lib/models/contact.dart`),
- no repository reads/writes the table,
- no screen exposes it.

(Not to be confused with `relationship_score`, the computed closeness number produced by
`RelationshipScoringService`. That stays as-is.)

## Goal / chosen design (from the design Q&A)

1. **Visualization — Ego sphere.** A focused contact sits at the center of a circular
   "sphere"; its directly-related contacts orbit on a ring with labeled edges. Tapping an
   orbiting contact re-centers the sphere on them. Built with `CustomPaint` +
   `GestureDetector` — **no new pub dependency** (consistent with the existing `_RingPainter`
   approach).
2. **Reciprocal — Auto.** The user picks a relationship type from one side
   (e.g. "Father"); the app stores **both** directions in a single transaction using a
   reverse-label map (Father↔Son/Daughter→"Child", Spouse↔Spouse, Sibling↔Sibling,
   Friend↔Friend, Colleague↔Colleague, Parent↔Child, etc.). Editing/removing a link affects
   both rows. Unknown reciprocals default to the same label.
3. **Entry points (all of):**
   - **Contact detail screen** — a "Relationships" section listing the contact's links, plus
     a button that opens the Relationship (sphere) screen focused on that contact. That
     screen has an AppBar back button returning to where it was opened from.
   - **Main menu / global** — a "Relationships" item in the contact-list overflow menu that
     opens the sphere starting from the most-connected contact (or a chosen one).
   - **Add/Edit contact screen** — an inline "Relationships" section to add/remove links
     while editing; persisted after the contact's id is known.

## Approach

### Data layer (no schema change needed — table already exists)
The `relationships` table is sufficient. We store **two rows per link** (A→B and B→A) so each
contact's relationships are a trivial `WHERE contact_id = ?` query and the sphere is naturally
symmetric. `relationship_type` is stored from the row-owner's perspective.

- A `relationships` row is `{contact_id (owner), related_contact_id (other), relationship_type}`.
- `ON DELETE CASCADE` on both FKs already cleans up when either contact is deleted.
- One concern: duplicate links. We de-dupe in the repository (delete any existing pair before
  inserting) rather than adding a UNIQUE constraint, to avoid a DB version bump/migration.

### Files to change / add

**New files**
- `lib/models/relationship.dart` — `Relationship` data class
  (`id`, `contactId`, `relatedContactId`, `relationshipType`) with `toMap`/`fromMap`, mirroring
  the other models. Plus a small `RelationshipTypes` helper (list of common types + a
  `reciprocalOf(type)` function for the auto-reciprocal map).
- `lib/repositories/relationship_repository.dart` — data access:
  - `setRelationship(contactId, relatedContactId, type)` — in a transaction, removes any
    existing rows for the (a,b)/(b,a) pair, then inserts both directed rows using
    `RelationshipTypes.reciprocalOf`. Guards against self-links.
  - `removeRelationship(contactId, relatedContactId)` — deletes both directed rows.
  - `getRelationsOf(contactId)` — returns `List<RelatedContact>` (the related `Contact`'s
    display fields + the `relationship_type`) via a JOIN to `contacts`, ordered by name.
    Used by the detail section and the sphere's center/ring.
  - `mostConnectedContactId()` — `GROUP BY contact_id ORDER BY COUNT(*) DESC LIMIT 1`, for the
    global entry point's default focus. Returns null when there are no relationships.
- `lib/screens/relationship_screen.dart` — the **ego-sphere** screen:
  - `RelationshipScreen({required int focusContactId})`, `StatefulWidget`.
  - AppBar with title (focused contact name) and the default back button.
  - Loads the focus contact + `getRelationsOf(focusId)`.
  - Body: a `CustomPaint` (`_SpherePainter`) drawing the center node (focus avatar/initial),
    the orbiting related nodes evenly spaced on a ring, edges with the relationship-type label
    at the midpoint. Themed via `AppColors` / `colorScheme.primary` like the rest of the app.
  - A `GestureDetector`/hit-test maps taps to nodes: tapping an orbit node pushes a new
    `RelationshipScreen` focused on it (so you can walk the graph; back button unwinds).
    Tapping the center opens that contact's detail screen.
  - A FAB ("Add relationship") opens the add-relationship flow (see shared widget below).
  - Empty state when the focus contact has no links yet, with a prompt to add one.
- `lib/widgets/relationship_editor.dart` — shared add/edit UI used by both the detail screen
  and the sphere screen (and the add/edit screen): a bottom-sheet/dialog that lets the user
  (1) pick another contact (searchable list from `ContactRepository.getAllContacts`, excluding
  self and already-linked) and (2) pick a relationship type from `RelationshipTypes`. Returns
  the chosen `(relatedContactId, type)`.

**Edited files**
- `lib/models/contact.dart` — add `List<RelatedContact> relationships = []` (display-only;
  not part of `toMap`/`fromMap`, populated on hydrate). Keeps the aggregate consistent with
  how `groups`/`tags` are handled.
- `lib/repositories/contact_repository.dart` — hydrate relationships in `_hydrate` (so detail
  screen has them) via the new repository, and **explicitly do not** add `relationships` to the
  wholesale child-delete list in `updateContact` (so editing a contact never wipes its links).
  `mergeContacts` already re-points `relationships` on both sides — leave as-is, but add a
  post-merge cleanup to drop any self-referential rows a merge could create.
- `lib/screens/contact_detail_screen.dart` — add a "Relationships" section (list of
  `RelatedContact` with type + a remove button) and a "View relationship sphere" button that
  pushes `RelationshipScreen(focusContactId: contactId)`. An "Add relationship" affordance uses
  the shared editor, then reloads.
- `lib/screens/add_edit_contact_screen.dart` — add a "Relationships" section. For an existing
  contact, edits persist immediately via `RelationshipRepository`. For a brand-new contact
  (no id yet), collect pending links in state and persist them right after `insertContact`
  returns the new id, before popping.
- `lib/screens/contact_list_screen.dart` — add a "Relationships" item to the overflow menu
  (`_handleMenu`) that resolves `mostConnectedContactId()` (falling back to the first contact,
  or a "add a relationship first" message when there are none) and pushes `RelationshipScreen`.

**Docs**
- `docs/known-gaps.md` — move "relationship map" from unbuilt to implemented.
- `docs/architecture.md` — note the new `relationship_repository`, `relationship_screen`, and
  the two-row reciprocal storage convention; drop the "relationship-map screen is still
  unbuilt" parenthetical.

### Notes / decisions
- **No new dependency** and **no DB version bump** — the table and indexes already exist;
  storage is two directed rows; de-dup is enforced in code.
- The sphere is **ego-centric** (one hop), navigable by tapping to re-center — this keeps the
  custom painter simple and readable while letting the user traverse the whole web.
- `RelatedContact` is a lightweight view-model (`contactId`, `fullName`, `photoPath`,
  `relationshipScore`, `relationshipType`) so the sphere/detail don't each re-hydrate full
  `Contact` aggregates.

## Testing
- `flutter analyze` clean.
- Extend `flutter test`: a unit test for `RelationshipRepository` (set creates both
  directions; remove clears both; `reciprocalOf` mapping; self-link guard; `getRelationsOf`)
  using the existing `sqflite_common_ffi` host-side setup. Reuse the test DB pattern already
  in `test/`.
- Manual smoke (described in the change log): add a relationship from add/edit, see it on both
  contacts' detail screens, open the sphere, tap to re-center, remove a link.

## Out of scope
- Full multi-hop force-directed network graph (the "Both"/"Full network" options were not
  chosen). The ego sphere's tap-to-recenter covers traversal.
- Relationship strength/weighting on edges (kept to type label only for now).
