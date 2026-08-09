# Fix cross-direction call-log match overwrite

## Problem

`CallLogRepository.findMatch()` matches stored rows to device-log entries by
**number + time window only**, ignoring call direction. When an outgoing call
and an incoming call to/from the same number happen within 90 seconds of each
other, the import treats them as the same call and `backfillFromDeviceLog`
overwrites the outgoing row's `call_type` to `incoming`, making the outgoing
entry vanish from Recents.

Real-world scenario observed today:
- 19:07:17 — outgoing call to 8129998111 (0s, cancelled)
- 19:07:21 — incoming call from +918129998111 (79s, answered)
- Only 4 seconds apart → `findMatch` matched the incoming entry to the outgoing
  row → the outgoing row became incoming, the "missed outgoing" disappeared.

The live-logger path (`logCallIfNew`) already checks direction via `_isOutgoing`,
but the import path's `findMatch` does not — this is the inconsistency.

## Proposed Changes

### Call log repository

#### [MODIFY] [call_log_repository.dart](file:///l:/Android/SreerajPContactSphere/lib/repositories/call_log_repository.dart)

- Add an optional `bool? isOutgoing` parameter to `findMatch()`.
- When provided, skip candidates whose direction doesn't match
  (outgoing vs non-outgoing), using the same `_isOutgoing`-style check that
  `logCallIfNew` uses.
- Add a static helper `isOutgoingType(String?)` so both call sites share the
  same definition. `StoredCall` already carries `callType`.

### Call log import service

#### [MODIFY] [call_log_import_service.dart](file:///l:/Android/SreerajPContactSphere/lib/services/call_log_import_service.dart)

- Pass the mapped `callType`'s direction to `findMatch()` so the import never
  cross-matches an incoming device entry against an outgoing stored row (or
  vice versa).

### Outgoing outcome drain (CallEventLogger)

#### [MODIFY] [call_event_logger.dart](file:///l:/Android/SreerajPContactSphere/lib/services/call_event_logger.dart)

- The `drainOutgoingOutcomes` path also calls `findMatch`. Pass
  `isOutgoing: true` there (these are always outgoing outcomes).

### Existing tests

#### [MODIFY] [call_log_matching_test.dart](file:///l:/Android/SreerajPContactSphere/test/call_log_matching_test.dart)

- Add a test: an outgoing stored row and an incoming device entry within
  the match window must **not** match.
- Add a test: same-direction entries within the window still match.

## Verification Plan

### Automated Tests
- `flutter test test/call_log_matching_test.dart`
- `flutter test test/call_log_dedupe_test.dart`  (must still pass unchanged)
- `flutter test` (full suite)

### Manual Verification
- On device: place an outgoing call, have the number call back within 90s,
  verify both rows appear independently in Recents.
