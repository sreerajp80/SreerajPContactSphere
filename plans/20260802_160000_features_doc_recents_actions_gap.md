# Plan — Document Recents context-menu actions in docs/features.md

**Status:** completed

## Files to change

- `docs/features.md` only. No code files.

## The issue

I ran a fresh, independent check of `docs/features.md` against the code
(this doc has already had several review rounds today, so this was a
skeptical re-check, not a repeat of the same pass). Two real, user-facing
features in `lib/screens/call_history_screen.dart` are missing from the
doc:

1. **Long-press actions on a Recents entry.** Long-pressing a call in the
   Recents list opens a bottom sheet with: Block number / Unblock number,
   Mark as spam / Not spam, Smart Redial & Reach Me, and Remove from
   history (deletes that one call-log row). Right now section 2 only
   mentions a *dedicated screen* for managing blocked/spam numbers
   (`blocked_numbers_screen.dart`) — it doesn't say you can also block,
   spam-mark, redial, or delete a single entry straight from Recents.
2. **Blocked calls show up in Recents as their own row type.** Calls
   rejected by the native call-screener (and calls parked during call
   waiting) are written into Recents with a distinct "Blocked" icon/label
   (`call_history_screen.dart:406,703`, `call_event_logger.dart`
   `drainBlockedCalls()` / `drainCallWaitingCalls()`). Section 2's Recents
   bullet currently only describes outgoing/incoming/missed calls plus
   manual import — it doesn't mention the "Blocked" row type.

Everything else was re-checked (all screens, widgets, services,
repositories, and models) and matched the doc — no other gaps found in
this pass.

## The fix

Edit section 2 ("Dialer / calling") of `docs/features.md`:

- In the "Recents / call history" bullet, add a clause noting that
  screened/blocked calls (and calls handled during call waiting) also
  appear in Recents with a distinct "Blocked" type.
- Add a new bullet (or extend the existing "dedicated screen to manage
  blocked/spam" bullet) noting that a call entry in Recents can also be
  long-pressed to block/unblock the number, mark/unmark it as spam,
  trigger Smart Redial & Reach Me, or remove that single entry from
  history — without going to the dedicated Blocked Numbers screen.

No other sections need changes; the "What this app is" summary paragraph
was re-checked and already covers all major feature areas.
