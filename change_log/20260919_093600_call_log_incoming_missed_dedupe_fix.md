# Change Log — Fix Call Log Entry Switching Between Incoming and Missed Call

Implements plan `plans/20260919_093300_call_log_incoming_missed_dedupe_fix.md`.

## What was broken

In the Recents call history screen, an entry would switch back and forth ("ping-pong") between an answered incoming call (e.g. 10:43 AM, duration 29s) and an unanswered missed call (e.g. 10:44 AM, duration 0s) every time the user opened or refreshed the Recents screen.

This happened because:
1. `CallLogRepository.isOutgoingType()` reduced all call directions to a single boolean (`callType == 'outgoing'`). Both `incoming` (answered) and `missed` (unanswered) evaluated to `false`.
2. As a result, `findMatch()`, `logCallIfNew()`, and `mergeDuplicateCalls()` treated any two inbound calls within the 90-second match window from the same number as the same physical call.
3. Every time the Recents tab opened, `CallLogImportService.syncFromDevice()` pulled calls from the Android device call log. It matched the device's missed call entry to the stored incoming call row, overwriting it with `missed` (10:44 AM, 0s). On the next sync, it matched the device's incoming call entry to the same stored row and overwrote it back to `incoming` (10:43 AM, 29s). This caused the entry to toggle on every load and suppressed one of the real calls.

## What changed

### Repository layer (`lib/repositories/call_log_repository.dart`)
- Updated `findMatch()` to support matching by `callType`. A candidate must match the given `callType`: an answered incoming call (`incoming`) never matches an unanswered missed call (`missed`). A provisional call (`duration == null`) only matches an `outgoing` query.
- Kept the optional `isOutgoing` parameter for backwards compatibility when `callType` is omitted.
- In `mergeDuplicateCalls()`, updated the grouping bucket key from `$key|${type == 'outgoing' ? 'out' : 'in'}` to `$key|$type`. Incoming calls and missed calls are kept in separate buckets and are never merged or deleted.

### Interaction repository (`lib/repositories/interaction_repository.dart`)
- In `logCallIfNew()`, updated the deduplication candidate check. For completed calls (`row['duration'] != null`), candidate matching now enforces `row['call_type'] == callType`. An answered incoming call will no longer match or suppress a subsequent missed call from the same number within the match window.

### Sync service (`lib/services/call_log_import_service.dart`)
- In `_ingest()`, passed `callType: callType` to `CallLogRepository.findMatch()`.
- When a candidate from `existing` matches an entry in the batch, it is removed from `existing` so subsequent entries in the same sync batch cannot match the same stored record.

### Unit tests (`test/call_log_dedupe_test.dart`)
- Added test verifying that `logCallIfNew()` preserves both an incoming answered call and a missed call within 40 seconds of each other from the same phone number.
- Added test verifying that `mergeDuplicateCalls()` does not merge an incoming answered call with a missed call.
- Added test group for `CallLogRepository.findMatch()` verifying type-awareness (identical type matches, mismatched type returns null, and provisional rows only match outgoing queries).

## Files changed

- `lib/repositories/call_log_repository.dart`
- `lib/repositories/interaction_repository.dart`
- `lib/services/call_log_import_service.dart`
- `test/call_log_dedupe_test.dart`
- `plans/20260919_093300_call_log_incoming_missed_dedupe_fix.md`

## Verification

- Static analysis: `flutter analyze` completed with 0 warnings or errors.
- Unit tests: `flutter test test/call_log_dedupe_test.dart` passed all 14 tests.
- Full test suite: `flutter test` executed all test files.
