# Missed calls no longer appear twice in Recents

Implements [plans/20260806_161216_missed-call-duplicate-recents.md](../plans/20260806_161216_missed-call-duplicate-recents.md).

## What was wrong

A missed call could show up as two rows in Recents. Two paths write the same
call and only one of them checked for a duplicate:

* `CallEventLogger` wrote a row as the call ended, through
  `InteractionRepository.logCall` — a plain insert with no check at all.
* Android wrote the same call into the system call log, its content observer
  fired `onCallLogChanged`, and `main.dart` started a forced device import.

The import matched device entries against the stored rows, but it read those
rows **once** at the start of the pass. When that read happened before the live
insert landed, neither side saw the other and one call became two rows. Missed
calls were hit hardest: the platform writes its row the moment the ringing
stops, exactly while the live logger is still resolving the SIM label and the
contact. A missed call was also stamped at ring *end* while the device stamps
ring *start*, which ate most of the 90-second match window.

## What changed

**`lib/repositories/interaction_repository.dart`**
New `logCallIfNew(...)`: finds an existing `call_logs` row for the same number
within `CallLogRepository.matchWindow` and, if there is one, fills in only what
that row is missing (duration, call type on a provisional row, contact link,
SIM, intent) instead of inserting. The look-up and the insert run in one
transaction, so two concurrent writers can no longer both conclude "nothing is
there". Outgoing calls never match inbound ones. `logCall` is unchanged for the
provisional row the outgoing path writes at placement.

**`lib/core/utils/call_log_write_lock.dart`** (new)
A small chained-`Future` lock, so the live logger and the device import do not
interleave. The transaction above is the real guarantee; this avoids the race
and the redundant work.

**`lib/services/call_event_logger.dart`**
`_logIncoming`, `drainCallWaitingCalls` and `drainBlockedCalls` now write through
`logCallIfNew`, under the lock. A call is dated by the platform's creation time
(ring start) — the same instant the device call log uses — falling back to
connect time for an answered call and to "now" when neither is reported.

**`lib/models/call_state.dart`**, **`android/.../CallRegistry.kt`**
The native call snapshot carries `creationTimeMillis`
(`Call.Details.getCreationTimeMillis()`, guarded to API 26+; 0 below that) and
`CallState` exposes it.

**`lib/services/call_log_import_service.dart`**
`syncFromDevice` and `importFromDevice` take the shared write lock.

**`lib/repositories/call_log_repository.dart`**
New `mergeDuplicateCalls()`: a one-shot repair for rows written before the fix.
Rows that share a match key and direction and sit within the match window are
collapsed; the oldest row survives (it is the one that may carry a note, intent
or feedback) and takes anything it was missing from the row that is dropped.

**`lib/state/app_settings.dart`**, **`lib/main.dart`**
`readCallLogDuplicatesMerged` / `writeCallLogDuplicatesMerged` guard the repair,
which runs once per install from `_bootstrap` and refreshes Recents only if it
actually removed something.

## Tests

New `test/call_log_dedupe_test.dart` (9 tests, all passing) covers both orderings
(import first, live first) collapsing to one row, filling a provisional row, and
the cases that must stay two rows: the same number outside the window, an
outgoing call next to a missed one, and two different numbers at the same
moment; plus the repair collapsing a duplicate, leaving genuine calls alone, and
being idempotent.

`flutter analyze` is clean. `interaction_repository_test`,
`call_log_matching_test`, `call_log_search_test` and `call_feature_test` still
pass (run one file per invocation — the sqlite3 double-copy crash). The Kotlin
change compiles: `flutter build apk --debug --flavor dev` succeeds.

## Not verified here

The end-to-end behaviour on a real missed call needs a device run — the race
being fixed only happens with the real Telecom stack and the system call log.
