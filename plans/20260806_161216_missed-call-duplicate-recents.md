# Missed calls appear twice in Recents

**Status:** completed

## The issue

In Recents, a missed call often shows up as two rows with the same number and
(almost) the same time.

Two different code paths write a row for the same physical call, and only one of
them checks whether the call is already there.

1. **The live logger.** When an incoming call ends unanswered,
   `CallEventLogger._logIncoming` calls `InteractionRepository.logCall`
   (`lib/services/call_event_logger.dart:231`). `logCall` is a plain
   `db.insert` — it never looks for an existing row.
2. **The device import.** Android writes the same call into the system call log.
   `MainActivity`'s call-log observer sends `onCallLogChanged`, and `main.dart:127`
   fires `CallLogImportService.syncFromDevice(force: true)` right away.

The import path *does* dedupe: `_ingest` matches a device entry against stored
rows by the last 10 digits of the number within a 90-second window
(`CallLogRepository.findMatch`). But it reads the stored rows **once**, at the
start of the pass (`call_log_import_service.dart:160`). So the order of events
decides the outcome:

* Logger inserts first, then the sync runs → the sync finds the row and just
  back-fills it. Correct, one row.
* Sync reads the stored rows first, then the logger inserts → the sync saw no
  match, so it inserts the device row, and the logger then inserts a second row.
  **Two rows for one call.**

The logger loses this race easily. After the disconnect event it still awaits
`SimService.labelFor()` (a platform-channel round trip) and a contact lookup
before it writes, while the observer-driven sync starts the moment Android
writes its own call-log row.

Two things make missed calls the worst case:

* Outgoing calls are logged provisionally at dial time, long before the device
  row exists, so the import always finds a match.
* Answered incoming calls are back-dated to connect time
  (`call_event_logger.dart:227`), which keeps them inside the 90-second window.
  A missed call is stamped `DateTime.now()` — the moment the ringing stopped —
  while Android stamps the moment the ringing started. The gap is the whole ring
  time (often 30-45 s), eating most of the match window and making a near-miss
  more likely on top of the race itself.

The same hole exists for `drainCallWaitingCalls` and `drainBlockedCalls`, which
also insert blindly.

## The fix

Give the live write path the same duplicate check the import path already has,
and stop the two paths from running at the same time.

### 1. One shared "insert this call unless it is already there" helper

Add `logCallIfNew(...)` to `InteractionRepository`. It runs inside a single DB
transaction:

* read `call_logs` rows within ±`CallLogRepository.matchWindow` of the new
  timestamp,
* compare with `CallLogRepository.matchKey` (last 10 digits, unchanged),
* if a match exists: back-fill the missing bits (duration, call type, SIM label,
  contact id) onto that row and return its id,
* if not: insert as today.

Doing the look-up and the insert in one transaction closes the race for good —
two concurrent writers can no longer both see "nothing there".

`logCall` stays as it is for the outgoing/provisional path, which must always
create a row.

### 2. Use it from every live write

* `CallEventLogger._logIncoming` → `logCallIfNew`.
* `CallEventLogger.drainCallWaitingCalls` → `logCallIfNew`.
* `CallEventLogger.drainBlockedCalls` → `logCallIfNew`.

### 3. Serialise the logger and the importer

Add a small shared async lock (a simple `Future` chain in a new
`lib/core/utils/call_log_write_lock.dart`) held by `CallLogImportService._ingest`
and by the `CallEventLogger` writes. The transaction in step 1 is the real
guarantee; this just stops the two paths from interleaving and doing redundant
work.

### 4. Stamp a missed call at ring start, not ring end

So the app's row and the device's row describe the same moment:

* native: include the call's `Call.Details.getCreationTimeMillis()` in the call
  snapshot (`ContactSphereInCallService` / `CallRegistry` → the existing
  `CallState` map),
* Dart: carry it on `CallState` (`lib/models/call_state.dart`), accumulate it in
  `CallEventLogger._onEvent`, and use it as the timestamp for a missed call
  instead of `DateTime.now()`.

If the native value is missing (0), fall back to today's behaviour.

### 5. Clean up the duplicates already in the database

The rows already written are still there, so the user keeps seeing them. Add a
one-shot repair in `CallLogRepository`, run once at startup (guarded by a flag in
`AppSettings`, same pattern as the other one-shot heals): collapse `call_logs`
rows that share a match key and a call type and sit within the match window,
keeping the oldest row and merging any duration/SIM/contact the newer one has.

## Files to change

| File | Change |
| --- | --- |
| `lib/repositories/interaction_repository.dart` | new `logCallIfNew` (transactional match-or-insert) |
| `lib/repositories/call_log_repository.dart` | expose the match helpers for reuse; add the one-shot duplicate cleanup |
| `lib/services/call_event_logger.dart` | use `logCallIfNew`; use ring-start time for missed calls |
| `lib/services/call_log_import_service.dart` | take the shared write lock |
| `lib/core/utils/call_log_write_lock.dart` | **new** — small async lock |
| `lib/models/call_state.dart` | carry `creationTimeMillis` |
| `android/.../ContactSphereInCallService.kt` (and `CallRegistry.kt` if the snapshot is built there) | put `creationTimeMillis` in the snapshot |
| `lib/state/app_settings.dart` | flag for the one-shot cleanup |
| `lib/main.dart` | run the one-shot cleanup at startup |
| `test/call_log_dedupe_test.dart` | **new** — covers: live insert then import (one row), import then live insert (one row), and two genuinely separate calls from the same number staying two rows |

## Risk / things to watch

* The window de-dupe must not swallow a **real** second call from the same
  number within 90 seconds. That is why the merge also compares call type, and
  why the test above pins the behaviour. Two genuine missed calls 20 seconds
  apart from the same number would still be collapsed — that is the same
  trade-off the import path already makes today, not a new one.
* The one-shot cleanup edits existing history. It keeps the oldest row and only
  merges fields, so notes/feedback on the surviving row are kept.
