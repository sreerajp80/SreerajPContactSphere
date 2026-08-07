# Show whether an outgoing call was answered

**Status:** completed

## The issue

Recents can tell you which way a call went, but for outgoing calls it cannot tell you
what happened.

`call_logs.call_type` only allows four values — `incoming`, `outgoing`, `missed`,
`blocked` ([database_helper.dart:224](../lib/database/database_helper.dart#L224)).
Three of those four quietly carry an outcome as well as a direction:

| stored `call_type` | direction | outcome |
| --- | --- | --- |
| `incoming` | inbound | answered |
| `missed` | inbound | not answered |
| `blocked` | inbound | rejected by our screening service |
| `outgoing` | outbound | **nothing recorded** |

So an outgoing call that nobody picked up and one that ran for two minutes look the
same in the list. The only hint today is that the subtitle drops the duration when it
is zero ([call_history_screen.dart:409](../lib/screens/call_history_screen.dart#L409)),
which reads as missing data rather than as a fact.

The information itself is not missing — it is thrown away. The incoming path already
decides `incoming` vs `missed` from `wasActive`, i.e. whether the call ever reached
`Call.STATE_ACTIVE` ([call_event_logger.dart:232](../lib/services/call_event_logger.dart#L232)).
The outgoing path has the same signal available and ignores it.

## The approach

Add a **new nullable column**, `call_logs.call_outcome`, holding *what happened*, next
to `call_type` which keeps holding *which way the call went*.

Values:

| value | meaning |
| --- | --- |
| `answered` | the call reached `STATE_ACTIVE` |
| `no_answer` | rang out, never connected |
| `busy` | the other side was busy |
| `declined` | the other side rejected it |
| `cancelled` | the user hung up before it rang out |
| `failed` | network or system error |

`null` means "we do not know" — every row written before this change, and every row
imported from the device log where only the duration is available.

**Why a new column and not a fifth `call_type` value.** Every place that asks "was
this call outbound?" is written as `callType == 'outgoing'` — for example
[interaction_repository.dart:169](../lib/repositories/interaction_repository.dart#L169)
and the direction bucket key at
[call_log_repository.dart:226](../lib/repositories/call_log_repository.dart#L226).
A new direction-bearing value such as `outgoing_missed` would make all of those
quietly wrong, and each one would have to be found and fixed. A brand-new column
breaks nothing, because no existing code reads it.

`call_type` is left exactly as it is. The overlap that creates — a `missed` row is
also `no_answer` — is deliberate, so nothing existing shifts.

### Two phases

**Phase 1** gets the feature visible using only signals the app already has
(`wasActive` and duration). It produces `answered` and `no_answer`.

**Phase 2** adds `busy`, `declined`, `cancelled` and `failed`, which need Android's
`DisconnectCause` carried from the native side to Flutter. `CallState` has no such
field today ([call_state.dart](../lib/models/call_state.dart)), so this is new
plumbing. It is additive — the column, the UI and the labels from Phase 1 do not
change, they just start seeing more values.

## Files to change

### Phase 1 — column, population, and UI

**[lib/database/database_helper.dart](../lib/database/database_helper.dart)**
- Add `call_outcome TEXT` to the `_onCreate` `call_logs` statement (line ~224).
  No CHECK constraint — an unexpected value should not fail a call-log write.

  **Correction during implementation:** the second CREATE at line ~506 must be
  left alone. It belongs to the v13 migration, which rebuilds the table as it
  stood at v13; adding the column there would make the later v27 ALTER fail with
  "duplicate column name" for any DB upgrading through v13.
- Bump the DB version 26 → 27 in both `openDatabase` calls (lines 67 and 79).
- Add a `v26 -> v27` block in `_onUpgrade` that adds the column.
- Add `_ensureCallOutcomeColumn(db)` to `_onOpen`, following the existing self-heal
  helpers (`_ensureEphemeralColumns` and friends). It checks `PRAGMA table_info` and
  adds the column if absent.

  This matters: a dev build that has already been bumped past version 27 would skip
  the `_onUpgrade` gate forever and end up with code reading a column the device does
  not have. The file's own comment at line 98 describes exactly this trap, and the
  self-heal is the established fix for it.
- Backfill in the same helper, once, for rows where `call_outcome IS NULL`:
  `duration > 0` → `answered`; `call_type IN ('missed','blocked')` → `no_answer`.
  Leave outgoing rows with duration 0 as `null` — for old rows we genuinely cannot
  tell "nobody answered" from "never reconciled", and a wrong label is worse than a
  blank one.

**[lib/utils/call_type_mapper.dart](../lib/utils/call_type_mapper.dart)**
- Add an `AppCallOutcome` class of string constants, matching the existing
  `AppCallType` style.
- Add `String? outcomeFromDuration(int? duration)` — the fallback used for rows where
  only the device log is available.

**[lib/models/call_record.dart](../lib/models/call_record.dart)**
- Add `final String? callOutcome`, the constructor parameter, and the
  `fromJoinedMap` read.
- The Recents queries use `SELECT cl.*`
  ([call_log_repository.dart:25](../lib/repositories/call_log_repository.dart#L25)
  and :72), so the column arrives with no query change.

**[lib/repositories/interaction_repository.dart](../lib/repositories/interaction_repository.dart)**
- Add an optional `String? callOutcome` to `logCall` and `logCallIfNew`, written into
  the insert map.
- In `logCallIfNew`'s match branch, follow the existing fill-do-not-overwrite rule:
  set `call_outcome` only when the stored value is null.
- Same optional parameter on `backfillFromDeviceLog`.

**[lib/services/call_service.dart](../lib/services/call_service.dart)**
- `placeCall` writes the provisional row with `call_outcome` left null (unknown so
  far), as it already does for duration.
- `reconcile` writes the outcome once the call has ended: `answered` when the
  reconciled duration is greater than zero, `no_answer` otherwise. Phase 2 replaces
  this with the `DisconnectCause` when one is available.

**[lib/services/call_event_logger.dart](../lib/services/call_event_logger.dart)**
- Set the outcome alongside the type it already derives from `wasActive`
  (lines ~122 and ~232): `answered` when active, `no_answer` when not.
- Blocked rows (line ~92) get `no_answer`.

**[lib/services/call_log_import_service.dart](../lib/services/call_log_import_service.dart)**
- Derive the outcome with `outcomeFromDuration` for imported entries.
- Pass it to `logCallIfNew` and `backfillFromDeviceLog` so it only fills a gap and
  never overwrites an outcome the app itself observed. This is the important rule:
  the device log rounds short answered calls to 0 seconds, so its opinion must never
  beat a live `wasActive` reading.

**[lib/screens/call_history_screen.dart](../lib/screens/call_history_screen.dart)**
- `_typeIcon` (line 716) takes the outcome as well as the type. Two icons for
  outgoing, no new glyphs elsewhere:

  | row | icon | colour |
  | --- | --- | --- |
  | incoming answered | `call_received` | green `0xFF10B981` (unchanged) |
  | incoming missed | `call_missed` | red `0xFFEF4444` (unchanged) |
  | blocked | `block` | red `0xFFEF4444` (unchanged) |
  | outgoing, got through | `call_made` | accent (unchanged) |
  | **outgoing, did not** | **`call_missed_outgoing`** | **amber `0xFFF59E0B`** |

  `call_missed_outgoing` is the mirror of the `call_missed` already in use, so the
  arrow language stays consistent and direction is still readable at a glance. Amber
  rather than red on purpose: red in this list means *needs your attention*, and an
  outgoing call that did not connect is information, not a task.

  A null outcome keeps today's appearance exactly, so old and imported rows do not
  change.
- The subtitle line (lines 405-414) fills the slot the duration leaves empty:

  ```dart
  if (call.duration != null && call.duration! > 0)
    _formatDuration(call.duration!)
  else if (outcomeLabel != null)
    outcomeLabel,
  ```

  Labels: `No answer`, `Busy`, `Declined`, `Cancelled`, `Failed`. `answered` gets no
  label — the duration already says it, and labelling the common case is noise. A
  null outcome adds nothing, exactly as today.

  Phase 1 can only ever produce `No answer`; the other labels arrive with Phase 2
  without touching this code again.

### Phase 2 — real disconnect reasons

**[android/.../CallRegistry.kt](../android/app/src/main/kotlin/in/sreerajp/contact_sphere/CallRegistry.kt)**
- `DisconnectCause` is already imported (line 9). Capture the cause code per call in
  `onCallRemoved`, next to the existing `sawActiveCalls` tracking, and map it to our
  vocabulary: `BUSY` → `busy`, `REJECTED` → `declined`, `CANCELED`/`LOCAL` before
  active → `cancelled`, `MISSED`/`REMOTE` before active → `no_answer`, `ERROR` →
  `failed`.
- Include the resulting string in the snapshot sent to Flutter.

**[android/.../MainActivity.kt](../android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt)**
- **Correction during implementation: no change needed.** `onCallChanged` passes
  the whole snapshot map straight to `eventSink.success(snapshot)`, so a new key
  in the map reaches Flutter on its own.

**[lib/models/call_state.dart](../lib/models/call_state.dart)**
- Add a nullable `disconnectOutcome` field and parse it in the existing factory.

**[lib/widgets/call_lifecycle_mixin.dart](../lib/widgets/call_lifecycle_mixin.dart)**
- `_onCallEvent` already sees the disconnected state (line 111). Hold the outcome from
  that event and hand it to `reconcile`, so the precise reason wins over the
  duration-based guess.

### Tests

**test/call_outcome_test.dart** (new)
- `outcomeFromDuration` mapping.
- The fill-do-not-overwrite rule in `logCallIfNew`: a device-log `no_answer` must not
  replace a stored `answered`.
- The migration self-heal adds the column when it is missing.

Note: sqlite-backed tests must be run one file per `flutter test` invocation on this
machine, because of the native-assets double-copy crash.

**[test/call_history_screen_test.dart]** — extend if it exists, otherwise fold the icon
and label assertions into the new test file:
- outgoing + `answered` → `call_made`; outgoing + `no_answer` → `call_missed_outgoing`.
- outgoing + null outcome renders exactly as it does today.

### Docs

**[docs/architecture.md](../docs/architecture.md)** — add `call_outcome` to the
`call_logs` row in the schema table, with a one-line note that direction and outcome
are separate columns and why.

## Risks and things to watch

- **The `call_type` CHECK constraint is untouched.** Nothing in this plan writes a new
  `call_type` value, so no table rebuild is needed.
- **The device log is the weakest source.** Its duration-0 reading must only ever fill
  a null, never overwrite. Getting this backwards would put a wrong `No answer` on
  calls that really connected.
- **DB version bump.** Phase 1 changes the schema, so the usual dev-build caution
  applies; the `_onOpen` PRAGMA check is what makes it safe on a device whose version
  already ran ahead.
- **`cancelled` vs `no_answer` colour.** Both amber in this plan. If the list feels
  noisy in use, `cancelled` and `failed` can move to a muted grey later — same two
  icons, one extra colour, no structural change.

## Follow-on this enables (not in scope)

Smart Redial and best-time-to-reach currently cannot tell "called four times at 9 AM
and got through" from "called four times at 9 AM and got nothing"
([smart_redial_service.dart](../lib/services/smart_redial_service.dart),
[reach_window_service.dart](../lib/services/reach_window_service.dart)). A real
answered flag is the single most useful input those features are missing. Worth a
separate plan once this column has real data in it.
