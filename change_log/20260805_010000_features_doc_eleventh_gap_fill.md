# Change log: eleventh gap-fill pass on docs/features.md

Implements: `plans/20260805_010000_features_doc_eleventh_gap_fill.md`

## What changed

Rewrote the ephemeral (self-destructing) contacts bullet in
`docs/features.md`, section 1 ("Contacts management"). No other content
changed.

1. Clarified that timed expiry (2h/24h/7d) and "delete after 1 call" are not
   independent alternatives: in `lib/services/ephemeral_contact_service.dart`,
   any completed call scrubs the contact immediately regardless of which
   mode was picked, so a timed contact's clock only matters if it's never
   called before the timer runs out.
2. Added the three post-creation controls on the contact detail screen that
   were missing from the doc: "+24 Hours" (extend expiry), "Keep
   Permanently" (convert to a normal contact), and "Scrub Now" (delete
   immediately).

## Why

An eleventh independent audit (agent-assisted code read, then verified by
hand against `lib/services/ephemeral_contact_service.dart` and
`lib/screens/contact_detail_screen.dart`) found these two real, user-facing
gaps in an otherwise accurate document. The intro paragraph and every other
section were re-checked and found to still match the code — no other
change was needed.
