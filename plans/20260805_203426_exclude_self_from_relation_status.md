# Exclude "Me" contact from Relation Status list

**Status:** completed

## Issue

The Relation Status screen lists every contact that has at least one
relationship defined. The query that builds this list, `getContactsWithRelations()`
in `lib/repositories/relationship_repository.dart`, filters out secret contacts
(`c.is_secret = 0`) but does not filter out the special "Me" contact
(`c.is_self = 1`).

Because the user has linked "Me" to other contacts (e.g. as their relative),
"Me" shows up in the Relation Status list as if it were a regular contact.
But "Me" can never get a real relationship score, because scores are computed
from call interactions, and nobody calls themselves. So "Me" always sits at a
score of 0, which looks broken/confusing on the list.

## Plan

- File to change: `lib/repositories/relationship_repository.dart`
- In `getContactsWithRelations()`, add `AND c.is_self = 0` to the `WHERE`
  clause (alongside the existing `c.is_secret = 0`), so the self contact is
  excluded from this list the same way secret contacts already are.
- No changes needed elsewhere: the ego-sphere view (`RelationshipScreen`) and
  the "relationship to self" label logic are unaffected, since those work off
  a specific contact ID, not this list.

## Files to be changed

- `lib/repositories/relationship_repository.dart`

## Testing

- Run `flutter analyze` to confirm no errors.
- If there's an existing test file covering `relationship_repository.dart`,
  run it. Otherwise, this is a one-line query filter change verified by
  reading the SQL.
