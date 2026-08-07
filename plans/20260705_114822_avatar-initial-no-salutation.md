# Avatar initials must come from the name, not the salutation

**Status:** completed

## Issue

When a contact has no profile picture, the app falls back to showing the first
letter of a name string inside the avatar. In two of those places the string
used is the *full name including the salutation*, so a contact saved as
"Mr John" shows **M** instead of **J**:

1. **Relationship sphere** — [lib/screens/relationship_screen.dart](../lib/screens/relationship_screen.dart)
   `_NodeAvatar` (line 379) derives the initial from `name.trim()[0]`, and both
   call sites pass a salutation-prefixed full name:
   - the focus node passes `focus.fullName` (`Contact.fullName` joins
     `salutation + firstName + middleName + lastName`),
   - the orbit nodes pass `r.fullName` (`RelatedContact.fullName`, built in
     `RelationshipRepository.relatedContactsOf` with the salutation prepended).
2. **Relation Status list** (entry list into the sphere) —
   [lib/screens/relation_status_screen.dart](../lib/screens/relation_status_screen.dart)
   line 281 uses `row.fullName[0]`, and `RelationOverview.fullName` (built in
   `RelationshipRepository.relationOverviews`) also includes the salutation.

Already correct (initial taken from `firstName`, no change needed):
contact list (`contact_list_screen.dart:841`), contact detail
(`contact_detail_screen.dart:345`), relationship editor picker
(`relationship_editor.dart:225`).

The displayed *name text* keeps the salutation everywhere — only the
one-letter avatar fallback changes.

## Files to change

| File | Change |
|---|---|
| `lib/models/relationship.dart` | Add a `firstName` field to `RelatedContact` and `RelationOverview` so display code can derive a salutation-free initial. |
| `lib/repositories/relationship_repository.dart` | Populate the new `firstName` field from the already-selected `first_name` column in both `relatedContactsOf` and `relationOverviews`. |
| `lib/screens/relationship_screen.dart` | Give `_NodeAvatar` an explicit `initial` parameter (computed by the caller) instead of deriving it from `name`; pass `focus.firstName` / `r.firstName` initials at the three call sites. Fall back to `'?'` when the first name is empty. |
| `lib/screens/relation_status_screen.dart` | Use `row.firstName` instead of `row.fullName` for the initial. |

## Fix plan

1. `RelatedContact` / `RelationOverview`: add `final String firstName;`
   (required constructor param, default not needed — repository always has the
   column).
2. `RelationshipRepository`: pass `firstName: (row['first_name'] as String?) ?? ''`
   when constructing both models.
3. `relationship_screen.dart`:
   - `_NodeAvatar` keeps its `name` param only if still used; since `name` is
     used solely for the initial, replace it with `initial` (a single-character
     string) and compute at each call site:
     `firstName.trim().isNotEmpty ? firstName.trim()[0].toUpperCase() : '?'`
     via a small file-local helper `String _initialOf(String name)`.
   - Call sites: focus/center avatars use `_initialOf(focus.firstName)`,
     orbit nodes use `_initialOf(r.firstName)`.
4. `relation_status_screen.dart`: replace `row.fullName[0]` with
   `row.firstName` based initial (same helper logic inline).
5. Run `flutter analyze` on the touched files to confirm no new issues
   (the project has known pre-existing analyzer errors — see
   docs/known-gaps.md).

## Out of scope (noted, not changed)

The dialer favorites/match rows (`dialer_screen.dart:562`) and the in-call
screen (`in_call_screen.dart:327`) also derive initials from a resolved
`contact_name` that SQL-concatenates the salutation
(`contact_repository.dart` / `call_log_repository.dart`). Fixing those means
touching the resolver queries or threading `first_name` through
`PhoneMatch`; excluded here since the request scoped "relationship sphere and
contact". Can be a follow-up plan if wanted.
