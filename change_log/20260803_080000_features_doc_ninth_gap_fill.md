# Change log: ninth gap-fill pass on docs/features.md

Implements: `plans/20260803_080000_features_doc_ninth_gap_fill.md`

## What changed

Made three small additions to `docs/features.md`, no other content changed:

1. §1 "Contact list" bullet now names the Email and Delete quick actions on
   each contact row, alongside call and view-profile (was previously just
   "quick-call actions").
2. §4 "Sharing / interoperability" gained a new bullet for two share-sheet
   options that existed in code but weren't documented: "Share as Text"
   (plain-text share) and "Copy Name & Phone" (clipboard copy).
3. §2 "Dialer / calling", in-call screen bullet, now notes the
   proximity-sensor screen-off during an active call (native Android
   behavior, like the stock in-call UI).

## Why

A fresh, independent 9th audit (re-checked every screen/service/widget file,
native Kotlin code, the manifest, and pubspec dependencies against the doc,
rather than trusting the 8th pass's "zero gaps" conclusion) found these three
real user-facing behaviors in code with no mention anywhere in the doc. No
doc claim was found to lack matching code, and the intro paragraph still
covers every headline feature category, so no other change was made.
