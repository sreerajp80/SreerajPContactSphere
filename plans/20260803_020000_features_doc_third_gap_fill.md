# Plan: third gap-fill pass on docs/features.md

**Status:** completed

## Files to change

- `docs/features.md` (documentation only, no code changes)

## The issue

`docs/features.md` has already been checked against the code twice (see
`plans/20260803_000000_features_doc_intro_gap_fill.md` and
`plans/20260803_010000_features_doc_second_gap_fill.md`). This is a third,
deeper pass. I read the doc in full, then had an explore agent dig into
specific source files, and I hand-checked its two most surprising claims
(Smart Redial's real behavior, and the audit log screen) by reading the
source myself. Below are the confirmed gaps.

## The fix

Eleven small edits to `docs/features.md`, plus one intro-paragraph mention.
No wording changes beyond what's needed to fix each gap.

1. **Section 2, Smart Redial — fix a wrong claim.** The doc says it
   "schedules automatic retry calls after a delay." That's not what happens:
   `lib/services/smart_redial_service.dart` only shows a notification when
   the delay elapses ("Smart Redial Ready… Tap to dial"); the call is placed
   only if the user taps it. Reword to say it schedules a notification that
   prompts a one-tap redial, not an automatic call.

2. **Section 2/12, Smart Redial — add persistence caveat.** Scheduled
   redials live only in memory (`_tasks`/`_activeTimers` in
   `smart_redial_service.dart`), so a killed app silently drops any pending
   redial before it fires. Add one sentence noting this.

3. **Section 2/12, Smart Redial — add configurable delay + editable
   message.** `sim_settings_screen.dart` and `smart_redial_sheet.dart` let
   the user pick the retry delay (1/3/5/10/15/30 min) and edit the preset
   "Reach Me" text, both persisted in `AppSettings`. Currently undocumented.

4. **Section 12, Smart Redial — add the active-redials list.** SIM & calling
   settings shows a live list of pending auto-redials with per-task cancel
   (`sim_settings_screen.dart`). Add a short mention.

5. **Section 1, Audit log — add filter chips.** The Audit Log screen has
   All/Added/Edited/Deleted filter chips (`audit_log_screen.dart`). Add to
   the existing audit-log bullet.

6. **Section 1, Audit log — add manual "Clear log."** Confirmed in
   `audit_log_screen.dart:_clear()` — a menu action wipes the whole log
   (contacts untouched) after a confirm dialog. The doc currently only
   describes automatic pruning; add that a manual clear also exists.

7. **Section 1, Audit log — add the visible chain-verification badge.**
   The screen shows a live "Tamper-Proof Chain Verified X/Y" badge, or a
   named tamper warning, from `AuditRepository.verifyChain()`. Add that this
   is surfaced in the UI, not just computed internally.

8. **Section 1, Duplicate detection — note the safety-tuned default
   selection.** In `duplicates_screen.dart`, name-only matches (no shared
   phone) start every non-kept member **unticked**; phone-linked matches
   start ticked. Add one clause noting the default varies by match strength.

9. **Section 2, Caller context — add "recent note."** The caller-context
   card also surfaces the most recent call's notes/intent/sentiment
   (`caller_context_service.dart: _resolveRecentNote`). Add to the existing
   bullet's list.

10. **Section 2, Caller ID — add the "service call" label.** Besides
    flagging `140…` numbers as spam, `caller_id_service.dart` labels Indian
    `160…` numbers as "Service call" (non-spam). Add this alongside the
    existing telemarketer-range mention.

11. **Section 8, Emergency info — add the persistent notification.**
    Enabling the emergency card also adds a persistent notification with a
    1-tap emergency call action (`emergency_info_screen.dart`), not just the
    lock-screen card. Add one clause.

12. **Intro paragraph — mention audit log and Smart Redial.** The
    "What this app is" summary currently doesn't gesture at either the
    tamper-evident audit log or Smart Redial, even though both are
    documented in the body as distinctive features. Add a short mention of
    each to the intro.

## Not changing

- Everything the explore agent checked and found already accurate:
  `settings_screen.dart`, `contacts_settings_screen.dart`,
  `identification_settings_screen.dart`, the `lib/repositories/` list,
  `blocked_numbers_screen.dart`, `quick_replies_screen.dart`.
- Nothing already listed in `docs/known-gaps.md` as deferred/not-integrated
  (call recording, reminder notifications, state management, release
  hardening, delete-all-data, other platforms) — those stay out of
  `features.md` by design.
