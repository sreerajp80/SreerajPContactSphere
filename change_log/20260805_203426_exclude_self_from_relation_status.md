# Exclude "Me" contact from Relation Status list

Implements: `plans/20260805_203426_exclude_self_from_relation_status.md`

## What changed

- `lib/repositories/relationship_repository.dart`: `getContactsWithRelations()`
  now filters out the self contact (`AND c.is_self = 0`) in addition to secret
  contacts, so "Me" no longer appears in the Relation Status list. Updated the
  method's doc comment to note why.

## Why

"Me" was showing up in Relation Status with a score of 0 because scores are
computed from call interactions, and nobody calls themselves — so the self
contact could never get a meaningful score and just looked broken on the list.

## Verification

- `flutter analyze lib/repositories/relationship_repository.dart` — no issues.
