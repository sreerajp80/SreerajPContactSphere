# Relationship Sphere: de-duplicate related contacts & remove the global menu entry

**Status:** completed

## Issues

### 1. The same related contact is shown twice
In both the ego-sphere (`RelationshipScreen`) and the Contact Profile's *Relationships*
section, a related contact can appear twice (e.g. "[name-1] / Spouse" listed twice under
[name-2]).

Root cause: every *write* path (`RelationshipScreen._addRelationship`,
`ContactDetailScreen._addRelationship`, `AddEditContactScreen._persistRelationships`) goes
through `RelationshipRepository.setRelationship`, which de-dupes the pair (`_deletePair`)
before inserting the two directed rows — so normal add/re-add is safe. But the **read**
path, `RelationshipRepository.getRelationsOf`, does a plain
`SELECT … WHERE r.contact_id = ?` with **no de-duplication**. If the `relationships` table
ever contains two rows with the same `(contact_id, related_contact_id)`, that contact is
listed twice. Such duplicate directed rows can be produced by the contact-**merge** routine
in `ContactRepository`, which re-points both `contact_id` and `related_contact_id` onto the
primary and only deletes self-referential rows (`contact_id = related_contact_id`) — it does
**not** collapse duplicate pairs. Legacy rows created before the current de-dup logic can do
the same.

`getRelationsOf` feeds both the sphere and the profile list, so fixing it there fixes both
screens at once.

### 2. "Relationship Sphere" global menu entry is unnecessary
The contacts-list overflow menu has a **Relationship Sphere** item that opens the sphere
focused on the most-connected contact. The sphere is already reachable, and more meaningfully,
from each contact's profile (the hub icon in the *Relationships* section). The global entry
picks an arbitrary focus and is redundant — remove it.

## Files to change

1. **`lib/repositories/relationship_repository.dart`**
   - `getRelationsOf`: de-duplicate by related contact so each related contact appears once.
     Change the query to `GROUP BY r.related_contact_id` (keeping one `relationship_type`,
     e.g. via `MIN`/`MAX`), preserving the existing `ORDER BY` name sort. This is the
     guaranteed display fix for both screens.
   - Remove `mostConnectedContactId()` — it becomes dead code once the menu entry is gone
     (its only caller is `_openRelationships`).

2. **`lib/repositories/contact_repository.dart`** (prevention, so merges stop creating dups)
   - In the merge routine, right after the two `UPDATE relationships …` re-point statements
     and the existing "drop self-referential rows" delete, add a step that collapses duplicate
     `(contact_id, related_contact_id)` rows keeping a single row per pair (delete rows whose
     `id` is not the `MIN(id)` for their `(contact_id, related_contact_id)` group).

3. **`lib/screens/contact_list_screen.dart`**
   - Remove the `PopupMenuItem(value: 'relationships', …)` ("Relationship Sphere").
   - Remove the `case 'relationships':` branch in `_handleMenu`.
   - Remove the now-unused `_openRelationships()` method.
   - Remove the now-unused `_relationships` field (`RelationshipRepository`) and the two
     now-unused imports (`relationship_repository.dart`, `relationship_screen.dart`).

## Not changing
- `RelationshipScreen` itself (still opened from the profile) — no change.
- The write/de-dup logic in `setRelationship` — already correct.
- No DB migration/one-time cleanup: the read-layer `GROUP BY` already hides any existing
  duplicate rows, and the merge fix stops new ones. (A migration to physically purge existing
  duplicates can be added later if desired — flagged, not included here.)

## Verification
- `flutter analyze` clean (no unused-import/field warnings from the removals).
- Profile → Relationships and the sphere each show a related contact only once, even after
  adding the same link from both contacts' profiles.
- The contacts-list overflow menu no longer lists "Relationship Sphere"; the hub icon on a
  profile still opens the sphere.
