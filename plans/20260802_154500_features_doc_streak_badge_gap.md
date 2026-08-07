# Plan — Document the missing "streak" badge feature in docs/features.md

**Status:** completed

## Files to change

- `docs/features.md`

## The issue

I did a fresh critical read of `docs/features.md` against the actual code in
`lib/` (this is the 7th review pass — six earlier rounds already fixed other
gaps, per the `change_log/` history). Comparing the doc to
`lib/repositories/interaction_repository.dart` and
`lib/screens/contact_list_screen.dart`, I found one real feature that exists
in the code but is not mentioned anywhere in the doc:

- `InteractionRepository.recentInteractionCountByContact()` counts a
  contact's interactions in the last 30 days.
- `ContactListScreen` uses that count to show a small fire-icon badge with
  the count next to a contact's row, whenever the count is 3 or more
  (`contact_list_screen.dart:1491-1506`). It is always on — there is no
  settings toggle for it.

This is a small but real, user-visible piece of UI that a developer reading
this file to check "does this app already do X" would want to know about
(e.g. before proposing to add a similar "frequently contacted" indicator).

Apart from this, the rest of the document holds up well against the code —
no other missing screens, services, or fields were found in this pass. The
"What this app is" summary already names all major pillars (contacts,
dialer, sync, backup, relationships, spam blocking, security) from the prior
round's fix, so no change is needed there.

## The fix

Add one sentence to the "Contact list" bullet in section 1 (Contacts
management), noting the streak badge and the 3-interactions/30-day
threshold. No other section needs changes.
