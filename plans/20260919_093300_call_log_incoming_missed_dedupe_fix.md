# Plan: Fix Call Log Toggling Between Incoming and Missed Call

**Status:** completed

## Issue
In the call history screen, one entry switches ("ping-pongs") between `incoming` (answered with duration) and `missed` (unanswered) every time the user opens the Recents page.

## Root Cause
1. **Conflated Call Direction**:
   In `CallLogRepository.isOutgoingType`, calls are categorized only as a boolean: `outgoing` vs `non-outgoing`.
   As a result, both `incoming` (answered) and `missed` (unanswered) return `false`.
   When `findMatch()`, `logCallIfNew()`, and `mergeDuplicateCalls()` compare directions, they treat any two inbound calls within the 90-second match window as the exact same physical call.
2. **Ping-Pong Overwrite on Device Sync**:
   When a user has an incoming call (e.g. 10:43 AM, duration 29s) and a missed call (e.g. 10:44 AM, duration 0s) within 90 seconds from the same number:
   Every time Recents opens, `CallLogImportService.syncFromDevice()` pulls device call logs from the last 2 days.
   Because `findMatch()` matches the missed call entry to the stored incoming call row, it overwrites the row with `call_type = 'missed'`, `duration = 0`, `timestamp = 10:44 AM`.
   On the next sync, `findMatch()` matches the incoming call entry to the same row and overwrites it back to `call_type = 'incoming'`, `duration = 29`, `timestamp = 10:43 AM`.
   This causes the entry to switch back and forth on alternate loads while hiding the fact that these are two distinct calls.

## Proposed Fix
1. `lib/repositories/call_log_repository.dart`:
   - Update `findMatch()` to accept `String? callType`. Candidate calls only match if candidate `callType == callType` (or for provisional calls where `c.duration == null`, candidate `callType == 'outgoing'` matches `outgoing`). Retain `isOutgoing` for backwards compatibility.
   - Update `mergeDuplicateCalls()` to group by `$key|$type` rather than `$key|${type == 'outgoing' ? 'out' : 'in'}` so answered incoming calls and unanswered missed calls are never merged or dropped.
2. `lib/repositories/interaction_repository.dart`:
   - Update `logCallIfNew()`: For non-provisional calls (`row['duration'] != null`), compare `row['call_type'] == callType` rather than `_isOutgoing`.
3. `lib/services/call_log_import_service.dart`:
   - In `_ingest()`: Pass `callType: callType` to `findMatch()`.
   - In `_ingest()`: Remove the matched candidate from `existing` once matched to avoid multiple entries in the same batch claiming the same row.
4. `test/call_log_dedupe_test.dart`:
   - Add unit tests verifying that incoming and missed calls within the match window from the same number are kept as separate entries and not conflated.

## Verification
- Run `flutter test test/call_log_dedupe_test.dart`
- Run `flutter analyze`
- Run `flutter test`
