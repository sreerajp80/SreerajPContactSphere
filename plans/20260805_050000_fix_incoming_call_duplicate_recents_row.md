# Fix: incoming calls create two Recents entries with the same duration

**Status:** completed

## The issue

When an incoming call is answered and lasts longer than about 90 seconds, it
shows up **twice** in Recents — both rows have the same duration, but
different times (one near when the call started, one near when it ended).

### Why this happens

Two different code paths log the same call:

1. [lib/services/call_event_logger.dart](lib/services/call_event_logger.dart)
   writes a row the moment the call ends (`_logIncoming`, around line 222).
   It fills in the correct duration, but does **not** pass a `timestamp` to
   `InteractionRepository.logCall`, so the row is saved with the current
   time — the call's **end** time.

2. [lib/services/call_log_import_service.dart](lib/services/call_log_import_service.dart)
   separately pulls the same call from Android's own system call log, whose
   timestamp is the call's **start** time (when it began ringing).

3. [lib/repositories/call_log_repository.dart](lib/repositories/call_log_repository.dart#L172)
   treats two rows as "the same call" only if their timestamps are within
   90 seconds of each other (`matchWindow`).

For a short call, "end time" and "start time" are close enough that the
90-second window still catches it, and the two rows correctly merge into
one. For a call longer than ~90 seconds, they are more than 90 seconds
apart, so the device-log sync treats it as a brand-new call and inserts a
second row — the duplicate the user is seeing.

This only affects **incoming** calls. Outgoing calls already pass a
timestamp at write time (see `CallLifecycleMixin`), so they are not
affected. Missed calls have no connect time and their "ring end" and
device-log timestamps are already only seconds apart, so they are not
affected either.

## The fix

In `CallEventLogger._logIncoming` (lib/services/call_event_logger.dart), pass
the call's connect time as the row's `timestamp` instead of leaving it to
default to "now":

- When the call was answered (`wasActive` is true and `connectTimeMillis > 0`),
  pass `timestamp: DateTime.fromMillisecondsSinceEpoch(connectTimeMillis)`.
  This is only a few seconds after the device log's own timestamp (ring
  start), so it stays well inside the 90-second match window regardless of
  how long the call lasted.
- When the call was missed (no connect time), leave the timestamp as-is
  (defaults to "now"), since that path isn't affected by this bug.

## Files to change

- `lib/services/call_event_logger.dart` — pass `timestamp` in the
  `_interactions.logCall(...)` call inside `_logIncoming`.
- `test/` — check whether `call_event_logger` has existing tests to update;
  if not, no new test file is planned (the file doesn't currently have a
  dedicated test suite based on the test/ directory listing).

## Verification

- `flutter analyze` and `flutter test` after the change.
- Manual reasoning check: for a 5-minute incoming call, the app's own row
  will now be timestamped at answer time, and the device log's row is
  timestamped at ring-start time — a few seconds apart, safely inside the
  90-second match window, so the sync will update the existing row instead
  of inserting a duplicate.
