# Plan: twelfth gap-fill pass on docs/features.md

**Status:** completed

## Files to change

- `docs/features.md` only (sections 1, 2, 4, 6 — small additions/corrections; no
  change needed to the intro "What this app is" paragraph)

## What the issue is

The user asked for another critical check of `docs/features.md`: are all
features listed, and is the App Description (intro paragraph) inclusive?
This document already went through eleven independent gap-fill passes. I
ran a twelfth independent audit (agent-assisted full code sweep, then
verified the two most surprising findings myself by reading the source
directly). The intro paragraph is still accurate and inclusive — no change
needed there. But five real gaps and two real inaccuracies were found in
the body:

### Gaps (feature exists in code, missing from the doc)

1. **vCard import also writes to the device address book; CSV import does
   not.** `lib/services/export_import_service.dart:170-181` — vCard import
   saves each contact through `ContactSyncService().saveContact()`, which
   pushes to Android system contacts too. CSV import
   (`export_import_service.dart:185-204`) only inserts into the app's own
   database. The doc currently lists these two import paths as if they
   behave the same way.

2. **The in-call screen has its own Block/Unblock button**, a third way to
   block a number besides the Blocked Numbers screen and the Recents
   long-press menu. `lib/screens/in_call_screen.dart:1003-1061` — shown
   both while ringing and once connected; blocking while still ringing also
   hangs up immediately.

3. **The dialer shows an "Add to contacts" shortcut** when the typed T9
   number matches no existing contact. `lib/screens/dialer_screen.dart:410-420,
   678-729`.

4. **Scrubbing an ephemeral contact also deletes its matching call-history
   rows**, not just the contact record.
   `lib/services/ephemeral_contact_service.dart:128-141` — deletes
   `call_logs` rows by contact id and by each of the contact's phone
   numbers. Neither the ephemeral-contacts bullet (section 1) nor the
   Recents description (section 2) mentions this.

5. **The in-call quick-reply sheet has a "Write your own…" free-text
   option**, in addition to the preset canned messages.
   `lib/screens/in_call_screen.dart:1103-1115, 1133+`.

### Inaccuracies (existing bullets that no longer match the code)

1. **"Filter suspected spam" silences more than spam-marked numbers.**
   `android/app/src/main/kotlin/in/sreerajp/contact_sphere/ContactSphereCallScreeningService.kt:65-69`
   and `lib/services/caller_id_service.dart:56-71` — it silences a call if
   the number is either user-marked spam **or** matches a known Indian
   telemarketer range (e.g. `140…`), regardless of any user mark. The doc
   currently describes this toggle as only covering "spam-marked numbers."

2. **P2P sync's "self" contact exclusion only holds for incremental/
   selective syncs — a Full Sync does send it.**
   `lib/services/sync_bundle_service.dart:435-458` — on a Full Sync the
   sender's self-contact is included in the payload and lands on the
   receiver as an ordinary contact (its self-flag is cleared). It is
   skipped only when `!fullMode`. The doc currently states flatly that the
   self contact is never included in a P2P sync.

I re-verified the two inaccuracies directly in the source (grep above) and
they hold. Several other complex-logic bullets (ephemeral scrub-on-call
behavior, duplicate-merge default selection, relationship scoring weights,
Smart Redial's in-memory-only nature, audit log retention) were re-checked
and are still correct — no change needed there.

## The fix

Small, targeted edits to `docs/features.md`, no wording changes beyond
what's needed to state the above accurately:

- Section 1 (Contacts management): add the call-history deletion detail to
  the ephemeral-contacts bullet.
- Section 2 (Dialer / calling): add the in-call Block/Unblock button, the
  dialer's "Add to contacts" shortcut, the quick-reply free-text option,
  and correct the "filter suspected spam" description to include the
  telemarketer-range heuristic.
- Section 4 (Sharing / interoperability): note that vCard import also
  writes to the device contacts while CSV import stays app-only.
- Section 6 (Phone-to-phone sync): correct the self-contact exclusion
  claim to say it applies to incremental/selective syncs, not Full Sync.

No structural changes, no new sections, and no change to the intro
paragraph.
