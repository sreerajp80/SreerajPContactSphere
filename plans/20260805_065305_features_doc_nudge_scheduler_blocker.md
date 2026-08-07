# Plan: note the shared notification-scheduler blocker in docs/features.md

**Status:** completed

## What the issue is

`docs/features.md` already says, in the "Known gaps" section (around line
420), that reminder rows are written to the database but nothing schedules
an actual system notification for them yet — they are stored but not
surfaced.

Separately, the "Roadmap / aspirational — NOT implemented" section (around
line 443) lists two roadmap ideas:

- Proactive "nudge" notifications from the relationship scoring engine.
- Multiple calling "personas" (Work/Personal/Freelance modes).

The doc does not connect these two facts. Both roadmap ideas quietly
depend on the same missing piece: a working notification scheduler.
Right now `flutter_local_notifications` is only used for immediate
`.show()` calls (see `lib/services/smart_redial_service.dart`), never for
scheduled/deferred notifications. Without that scheduler, relationship
decay nudges can't fire, and per-persona reminders can't fire either. A
reader could mistakenly think these are two independent, separately
buildable features, when in fact the scheduler is the actual prerequisite
blocking both.

## Files to be changed

- `docs/features.md` — the "Proactive nudge notifications" and "Multiple
  calling personas" bullets in the Roadmap section (around line 443-446).

## The fix

Add a short clause (or a shared note directly under both bullets) stating
that both features depend on building the notification scheduler first
(the gap already described earlier in the doc under reminders), so that
is the real prerequisite blocker, not the scoring/persona logic itself.

No other sections will be touched.

## Change log

After this edit is approved and made, a change log will be written to
`change_log/` describing the doc update and referencing this plan.
