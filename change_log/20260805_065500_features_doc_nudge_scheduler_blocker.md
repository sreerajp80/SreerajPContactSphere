# Change log: note the shared notification-scheduler blocker in docs/features.md

Implements plan `plans/20260805_065305_features_doc_nudge_scheduler_blocker.md`.

## What changed

In `docs/features.md`, under "Roadmap / aspirational — NOT implemented",
added a note under the "Proactive nudge notifications" and "Multiple
calling personas" bullets. It explains that both features depend on the
same missing piece: a notification scheduler. Reminder rows are already
written to the database, but nothing schedules a real system notification
for them — `flutter_local_notifications` is currently only used for
immediate `.show()` calls, not scheduled ones. Until that scheduler
exists, neither feature can actually fire, no matter how complete the
scoring or persona logic is.

No other part of the doc was touched.
