# Change log: Relationship Sphere de-dup & menu removal

Implements plan
[plans/20260703_124905_relationship-sphere-dedup-and-menu.md](../plans/20260703_124905_relationship-sphere-dedup-and-menu.md).

## Problem
- A related contact could appear **twice** in both the ego-sphere (`RelationshipScreen`)
  and the Contact Profile's *Relationships* list.
- The contacts-list overflow menu carried a redundant **Relationship Sphere** entry (the
  sphere is reachable per-contact from each profile's Relationships hub icon).

## Root cause of the duplication
Every write path de-dupes the pair via `RelationshipRepository.setRelationship`, but the
read path `getRelationsOf` did a plain `WHERE contact_id = ?` with no de-duplication. Any
duplicate directed rows in the `relationships` table — which the contact-merge routine in
`ContactRepository` could leave behind (it re-points both `contact_id` and
`related_contact_id` onto the primary and only dropped self-referential rows) — surfaced as
the same contact listed twice. `getRelationsOf` feeds both screens.

## Changes

### `lib/repositories/relationship_repository.dart`
- `getRelationsOf`: added `GROUP BY r.related_contact_id` (with `MIN(r.relationship_type)`)
  so each related contact is returned once regardless of duplicate directed rows. Fixes both
  the sphere and the profile list. Updated the doc comment.
- Removed `mostConnectedContactId()` — dead code once the global menu entry was removed.

### `lib/repositories/contact_repository.dart` (merge-path prevention)
- In the merge routine, after re-pointing relationship rows and dropping self-referential
  rows, added a `DELETE` that keeps one row per `(contact_id, related_contact_id)` pair
  (`id NOT IN (SELECT MIN(id) … GROUP BY contact_id, related_contact_id)`), so merges no
  longer leave duplicate directed rows behind.

### `lib/screens/contact_list_screen.dart`
- Removed the `PopupMenuItem(value: 'relationships', …)` ("Relationship Sphere").
- Removed the `case 'relationships':` branch in `_handleMenu`.
- Removed the now-unused `_openRelationships()` method, the `_relationships`
  (`RelationshipRepository`) field, and the now-unused `relationship_repository.dart` and
  `relationship_screen.dart` imports.

### `test/relationship_repository_test.dart`
- Removed the obsolete `mostConnectedContactId` test.
- Added a test asserting `getRelationsOf` collapses duplicate directed rows to a single
  related contact.

## Verification
- `flutter analyze` on the three changed lib files: **No issues found**.
- `flutter test test/relationship_repository_test.dart`: **all 8 tests pass**, including the
  new de-dup test.
- The overflow menu no longer lists "Relationship Sphere"; the profile hub icon still opens
  the sphere.

## Notes
- No DB migration was added: the read-layer `GROUP BY` hides any pre-existing duplicate rows
  and the merge fix prevents new ones. A one-time migration to physically purge existing
  duplicate rows could be added later if desired.
