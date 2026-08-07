# Change log — Document the streak badge in docs/features.md

Implements: `plans/20260802_154500_features_doc_streak_badge_gap.md`

## What changed

Edited `docs/features.md` only. No code files were touched.

- Section 1 (Contacts management), "Contact list" bullet: added a sentence
  noting the "streak" badge (fire icon + count) shown on a contact's row
  when they've had 3 or more interactions in the last 30 days.

## Why

A fresh critical review compared the doc directly against the code, this
time focused on `lib/repositories/interaction_repository.dart` and
`lib/screens/contact_list_screen.dart`. The streak badge is a real,
always-on, user-visible feature (`contact_list_screen.dart:1491-1506`,
backed by `InteractionRepository.recentInteractionCountByContact()`) that
was not mentioned anywhere in the doc. No other gaps were found in this
pass — the rest of the document, including the "What this app is" summary
fixed in the previous round, matched the code.
