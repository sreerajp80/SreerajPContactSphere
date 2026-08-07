# Fix: incoming calls creating two Recents entries with the same duration

Implements [plans/20260805_050000_fix_incoming_call_duplicate_recents_row.md](../plans/20260805_050000_fix_incoming_call_duplicate_recents_row.md).

## What changed

`lib/services/call_event_logger.dart` — `_logIncoming` now timestamps an
answered call's Recents row at its **connect (answer) time**, instead of
letting it default to "now" (call end time).

## Why

Two code paths log the same incoming call: the live in-app logger (on call
end) and the background sync of Android's system call log. They're merged
into one Recents row only if their timestamps land within 90 seconds of each
other. The in-app logger was timestamping its row at call **end**, while the
device log timestamps the same call at call **start** (ring time). For any
call longer than ~90 seconds, that gap exceeded the 90-second match window,
so the device-log sync couldn't recognize it as the same call and inserted a
second row — both showing the same (correct) duration.

Timestamping at connect time keeps the app's row only a few seconds off the
device log's ring-start timestamp, regardless of how long the call lasted, so
the two rows now always merge correctly.

## Verification

- `flutter analyze` on the changed file: no issues.
- `flutter test`: 352 passing, 4 failing — all 4 failures are pre-existing
  widget-test issues in unrelated screens (`widget_test.dart`,
  `contact_search_picker_sheet_test.dart`), not touched by this change.
