# Avatar initials no longer include the salutation

Implements [plans/20260705_114822_avatar-initial-no-salutation.md](../plans/20260705_114822_avatar-initial-no-salutation.md).

When a contact has no profile picture, the fallback initial in the
relationship sphere and the Relation Status list was taken from the full name,
which is salutation-prefixed — "Mr John" showed **M**. The initial now comes
from the first name only, so it shows **J**. Displayed name text is unchanged
(still includes the salutation).

## Changes

- `lib/models/relationship.dart` — `RelatedContact` and `RelationOverview`
  gained a required `firstName` field (given name only, no salutation), the
  source for avatar initials.
- `lib/repositories/relationship_repository.dart` — both `getRelationsOf` and
  `getContactsWithRelations` populate `firstName` from the already-selected
  `first_name` column.
- `lib/screens/relationship_screen.dart` — `_NodeAvatar` now takes an explicit
  `initial` string instead of deriving it from a `name` param; a file-local
  `_initialOf(String)` helper computes it. All three call sites (empty-state
  avatar, centre node, orbit nodes) pass the first-name initial
  (`focus.firstName` / `r.firstName`), falling back to `?` when empty.
- `lib/screens/relation_status_screen.dart` — the list-row initial uses
  `row.firstName` instead of `row.fullName`.

Already correct, untouched: contact list, contact detail, and relationship
editor (all take the initial from `firstName`).

## Verification

`flutter analyze` on the four changed files: no issues.

## Noted follow-up (not done)

Dialer match rows (`dialer_screen.dart`) and the in-call screen
(`in_call_screen.dart`) derive initials from a SQL-resolved `contact_name`
that concatenates the salutation; fixing those requires threading
`first_name` through the resolver queries / `PhoneMatch`.
