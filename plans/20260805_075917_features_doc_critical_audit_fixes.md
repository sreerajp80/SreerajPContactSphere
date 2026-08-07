# Fix remaining gaps in docs/features.md after critical audit

**Status:** completed

## Files to change

- `docs/features.md`

## The issue

The user asked me to critically check `docs/features.md` (already updated many times
before, per the `change_log/` "gap fill" entries) against the real code, and check
that the "What this app is" intro paragraph covers everything.

I compared the doc against the current code (including the uncommitted local edits
already in the working tree) and found:

1. **Wrong claim about duplicate matching.** Section 1 (line 68-69 in the current
   working copy) says duplicate detection matches "by phonetic similarity (Double
   Metaphone / Soundex) and normalized phone number." This is no longer true. I
   read `findDuplicateGroups` in `lib/repositories/contact_repository.dart` — it
   was changed to drop all Soundex/Metaphone grouping (this matches
   `change_log/20260805_040000_fix_phonetic_duplicate_false_positives.md` and the
   new test `test/phonetic_duplicate_test.dart`, which exists specifically to catch
   false positives like a multi-word hospital business name colliding on Soundex
   with an unrelated short personal name). Matching today is: exact full name, the transliteration
   `searchKey`, and phone number (digits or E.164) — no phonetic step. The doc's
   own internal docstring at `contact_repository.dart:1842-1843` is also stale and
   should be fixed at the same time (not part of this plan's file list, but I'll
   flag it to the user separately since it's code, not docs — see "Note" below).

2. **Missing: stable merge identity across Android contact-id reassignment.**
   `database_helper.dart` added a `confirmed_merge_phones` table (schema v25→v26),
   and `contact_repository.dart` (`recordMergedDeviceId(confirmed:)`,
   `confirmedMergePhones()`) uses it to remember a user-confirmed merge by phone
   number rather than by Android's device-contact id — because
   `contact_sync_service.dart` shows that id can be reassigned by Android (e.g. a
   WhatsApp re-link), which used to make a previously-merged contact reappear as a
   "new duplicate." This is a real behavior fix, not mentioned anywhere in section 1
   (duplicates) or section 5 (device sync).

3. **Missing: Recents rows self-heal when a matching contact appears later.**
   `contact_repository.dart` (`relinkCallLogs`, called from both `insertContact`
   and `updateContact`) back-fills `call_logs.contact_id` for existing unlinked
   Recents rows when a new/edited contact's number matches them. Before this, a
   call from an unknown number stayed unlinked (shown as a raw number) forever,
   even after you added that person as a contact. Not mentioned in section 2
   (Recents / call history).

4. **Missing: in-call context card header differs for outgoing calls.**
   `lib/screens/in_call_screen.dart` shows "ABOUT THIS CONTACT" as the card header
   for outgoing calls, vs. "WHY THEY ARE CALLING" for incoming calls (an incoming-
   call framing doesn't make sense for a call you placed yourself). Section 2 only
   describes the incoming-call framing today.

The intro "What this app is" paragraph was checked separately: it was already
recently expanded (tags/groups, ephemeral contacts, audit log, Smart Redial, quick
replies, relationship scoring/context, T9 scripts, sharing formats, WhatsApp/
Telegram linking, multi-SIM). Nothing in sections 1-13 is missing from it — no
change needed there.

## The plan

Edit `docs/features.md`:

1. In section 1 (Contacts management), rewrite the duplicate-detection bullet to
   drop the Soundex/Metaphone claim and describe matching as: exact full name,
   transliteration search key, and phone number (digits/E.164) — no phonetic step.
   Add a short clause noting a user-confirmed merge is remembered by phone number,
   so a person who merges once won't resurface as a "new" duplicate later even if
   Android reassigns the underlying device-contact id (e.g. after a WhatsApp
   re-link).
2. In section 2 (Dialer / calling), under Recents / call history, add one sentence:
   adding or editing a contact retroactively links any existing unlinked Recents
   rows whose number matches, so a call logged before the contact existed stops
   showing as a raw number.
3. In section 2, under the Caller context bullet, add a short clause: the card's
   header reads "About this contact" for outgoing calls and "Why they are calling"
   for incoming calls.

No other sections need changes. This is a documentation-only change — no app code
is touched.

## Note (not part of this plan, informational only)

`contact_repository.dart:1842-1843` has a doc-comment on `findDuplicateGroups` that
still says "a Soundex code, Double Metaphone keys" — that comment is now wrong too,
since the code no longer does phonetic matching. I'm not fixing it as part of this
plan (it's a code comment, not `docs/features.md`), but flagging it so you can ask
me to fix it separately if you want.
