# Plan: eleventh gap-fill pass on docs/features.md

**Status:** completed

## Files to change

- `docs/features.md` (section 1, "Contacts management" — the ephemeral
  contacts bullet only)

## What the issue is

The user asked for a fresh critical check of `docs/features.md` for missing
features and an inclusive app description. This document has already had
ten independent gap-fill passes. I ran an eleventh independent check
(agent-assisted code audit, then verified the findings myself by reading
the source directly). Almost everything still matches the code — screens,
services, settings, native Kotlin features, manifest entries, and the
intro paragraph were all re-checked and found accurate.

Two real gaps were found, both in the same bullet (section 1, ephemeral
contacts, `docs/features.md` line 78):

1. **How timed expiry actually interacts with calls is not documented
   correctly.** The doc says a contact expires "after a set time (2h/24h/7d)
   or after one call," which reads as two separate, alternative modes. But
   in `lib/services/ephemeral_contact_service.dart` (`onCallCompleted`,
   lines 170-230), *any* ephemeral contact — even one set to a 7-day timer,
   not the "delete after 1 call" mode — gets scrubbed right after its very
   first completed call, because the code checks
   `if (autoDeleteCall || currentCalls >= 1)` and `currentCalls` is always
   at least 1 the moment a call finishes. So in practice, a timed ephemeral
   contact rarely reaches its timer at all if the user calls it — it is
   removed after the first call regardless. The doc should describe this
   actual behavior, not the "two separate expiry modes" reading it
   currently implies.

2. **Post-creation ephemeral controls are missing from the doc.** Opening
   an ephemeral contact's detail screen (`lib/screens/contact_detail_screen.dart`,
   lines ~860-970) shows a live countdown plus three buttons that are fully
   wired to real actions, none of which are mentioned anywhere in the doc:
   - "+24 Hours" — pushes the expiry further out.
   - "Keep Permanently" — converts it into a normal, non-expiring contact.
   - "Scrub Now" — deletes it immediately, on demand.

No other gap was found. The intro paragraph ("What this app is") was
re-checked against the full body and still reads as inclusive of every
major feature area — no change needed there.

## The fix

Rewrite the ephemeral-contacts bullet in section 1 to:
- describe the timed-expiry vs. call-count behavior accurately (a completed
  call scrubs the contact regardless of which expiry mode was picked, so
  the timer is really a fallback for contacts that are never called), and
- add the three post-creation controls (extend by 24 hours, keep
  permanently, scrub now) shown on the contact detail screen.

This is a wording-only change to one bullet — no other section changes.
