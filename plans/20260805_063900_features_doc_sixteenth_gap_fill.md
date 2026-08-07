# Features doc — sixteenth gap fill

**Status:** completed

## Files to change

- `docs/features.md`

## What the issue is

The user asked for a fresh critical read of `docs/features.md` against the real code,
checking both that every feature is listed and that the App Description intro is
inclusive. This doc has already been through 15 rounds of gap-filling, so most things
are covered, but a code audit (duplicates screen, contact pickers, BLE share/receive,
relationship screens, caller-context service, quick replies, dependencies, Kotlin
native files) turned up a few real gaps and one small accuracy fix:

1. **Quick replies are a user-managed list, not just "canned texts + write your own."**
   `lib/screens/quick_replies_screen.dart` and `lib/state/app_settings.dart`
   (`setQuickReplies`/`resetQuickReplies`/`defaultQuickReplies`) show the user can
   add, edit, delete, and reset-to-default their own canned reply texts (40-char
   default set, 160-char limit per reply) from Settings → SIM & calling. The current
   doc line only says "canned SMS texts, plus a 'Write your own…' free-text option" —
   it doesn't say the canned list itself is editable/manageable.

2. **The relationship sphere screen does more than just visualize.** Doc section 1
   says only "a visual 'relationship sphere' centered on one contact." The actual
   screen (`lib/screens/relationship_screen.dart`) lets you tap an orbit node to
   re-center the sphere on that contact, long-press a node for a menu (re-centre,
   open profile, edit relationship type, remove relationship), and tap an edge's
   type-label pill to jump straight to editing that relationship type.

3. **Caller context builds an actual one-line sentence, not just "info."** Doc
   section 2 says caller context "pulls together relationship info, call history...
   to answer 'why might this person be calling?'" but doesn't mention that the
   service assembles this into a single natural-language headline (e.g. "Ravi —
   your cousin. Last spoke 3 weeks ago. You owe him a callback. Birthday next
   Tuesday.") shown to the user, per `caller_context_service.dart`'s
   `buildSmartHeadline()`.

4. **Duplicate merge screen lets you change who's kept, and merge everything at
   once.** Doc section 1's duplicate-detection bullet describes the matching logic
   and default tick/untick behavior, but not that (a) tapping a different non-kept
   contact in a set re-points which contact is "kept" before merging, and (b) a
   sticky bottom bar totals the selections across every set and can merge all sets
   in one tap ("Merge all sets"), on top of each set's own per-set Merge button.

5. **BLE share has a proximity indicator and an idle timeout, not just "progress
   shown."** Doc section 4's BLE bullet doesn't mention that the receiving phone
   shows an approximate proximity label from Bluetooth signal strength ("Very
   close" / "Nearby" / "Weak signal — move the phones closer") instead of raw
   signal numbers, and that a share session with no activity for 2 minutes times
   out on its own with a "Try again" option.

6. **App Description intro paragraph doesn't mention relationship scoring/caller
   context or quick replies at all.** The intro (lines 8–33) covers the big-ticket
   items (dialer, sync, backup, security, T9, sharing) but never mentions that the
   app scores relationship health and surfaces "why is this person calling"
   context before/during a call, or that missed calls can be answered with a
   canned text reply. These are substantial, distinct features worth one clause
   each in the summary paragraph, not just buried in the section detail.

Two things the audit flagged that are **not** doc gaps, so no change needed for
them:
- `geolocator` is declared in `pubspec.yaml` but not imported anywhere in `lib/`
  (the pre-call summary's "local time for the contact" is computed from a
  hardcoded city/country → timezone table, not the `geolocator` package). This is
  a `docs/dependencies.md` accuracy question, not a `features.md` one — out of
  scope for this task, not touching it.
- Contact picker sheets (single-select search picker, multi-select picker with
  affiliation suggestions) are internal building blocks reused across several
  already-documented flows (dialing, group/tag membership, relationship linking,
  emergency contacts) — the group/tag "suggested members" behavior they power is
  already documented in section 1; the pickers themselves aren't a separate
  user-facing feature worth their own bullet.

## The plan for the fix

Edit `docs/features.md` only, in place:

1. In the App Description intro paragraph, add a short clause noting relationship
   health scoring / caller context, and one noting quick-reply rejection.
2. Section 1, duplicate-detection bullet: add a sentence on re-picking the kept
   contact and the "merge all sets" bulk action.
3. Section 1, relationship bullet: expand "visual relationship sphere" to mention
   re-centering by tapping a node, the long-press menu, and editing a relationship
   type from its edge label.
4. Section 2, caller context bullet: add that this is assembled into a one-line
   natural-language headline shown to the user.
5. Section 2, quick replies bullet: note the canned list itself is user-editable
   (add/edit/delete/reset), not just one-off free text.
6. Section 4, BLE bullet: add the proximity label and 2-minute idle timeout detail.

No other sections change. This is a documentation-only change — no code, tests, or
behavior are touched.
