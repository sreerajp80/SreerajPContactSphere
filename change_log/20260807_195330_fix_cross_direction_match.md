# Fix cross-direction call-log match overwrite

**Plan:** `plans/20260807_194814_fix_cross_direction_match.md`

## Problem

`CallLogRepository.findMatch()` matched stored rows to device-log entries by
number + time window only, ignoring call direction. When an outgoing call and an
incoming call to/from the same number happened within 90 seconds, the import
treated them as the same call and `backfillFromDeviceLog` overwrote the outgoing
row's `call_type` to incoming — making the outgoing entry vanish from Recents.

## Changes

### `lib/repositories/call_log_repository.dart`
- Added `static bool isOutgoingType(String?)` — shared direction check.
- Added optional `bool? isOutgoing` parameter to `findMatch()`. When non-null,
  candidates whose direction doesn't match are skipped.

### `lib/services/call_log_import_service.dart`
- Passes `isOutgoing: CallLogRepository.isOutgoingType(callType)` to
  `findMatch()` during import, preventing cross-direction matches.

### `lib/services/call_event_logger.dart`
- Passes `isOutgoing: true` to `findMatch()` in `drainOutgoingOutcomes()`.

### `test/call_log_matching_test.dart`
- Added 3 tests: cross-direction rejection, same-direction match, and legacy
  (null) behaviour preservation.

## Verification

- `flutter test test/call_log_matching_test.dart` — 19/19 passed
- `flutter test test/call_log_dedupe_test.dart` — 9/9 passed
- `flutter test` (full suite) — 34/34 passed
