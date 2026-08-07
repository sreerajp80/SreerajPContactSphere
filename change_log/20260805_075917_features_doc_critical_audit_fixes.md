# Fix remaining gaps in docs/features.md after critical audit

Implements: `plans/20260805_075917_features_doc_critical_audit_fixes.md`

## What changed

`docs/features.md`, three edits:

1. Section 1 (Contacts management) — the duplicate-detection bullet no longer
   claims phonetic (Double Metaphone / Soundex) matching. That was removed from
   the code (it caused false positives, e.g. unrelated names colliding on a
   truncated Soundex code) — the doc now correctly says matching is by exact
   name, transliteration search key, and phone number only. Also added a note
   that a confirmed merge is remembered by phone number, so it survives Android
   reassigning the underlying device-contact id (e.g. after a WhatsApp re-link).
2. Section 2 (Dialer / calling), Caller context bullet — added that the card's
   header reads "About this contact" for outgoing calls vs. "Why they are
   calling" for incoming calls.
3. Section 2, Recents / call history bullet — added that adding or editing a
   contact retroactively links any existing unlinked Recents rows whose number
   matches, instead of leaving old calls showing a raw number forever.

## Why

The user asked for a critical re-check of `docs/features.md` against the real
code. A research pass found the doc's duplicate-matching description was out of
date (the phonetic step was removed for false positives) and three small
behaviors were undocumented: merge-identity stability across Android contact-id
reassignment, Recents self-healing on new/edited contacts, and the outgoing vs.
incoming header text on the in-call context card. The "What this app is" intro
paragraph was checked too and found already complete — no change needed there.

## Not changed

`lib/repositories/contact_repository.dart:1842-1843` has a doc-comment that
still mentions Soundex/Metaphone — flagged to the user as a separate, optional
follow-up since it's a code comment, not part of `docs/features.md`.
