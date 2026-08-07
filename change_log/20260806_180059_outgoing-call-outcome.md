# Recents now shows whether an outgoing call was answered

Implements [plans/20260806_174615_outgoing-call-outcome.md](../plans/20260806_174615_outgoing-call-outcome.md).
Both phases were approved and both are done.

## What changed for the user

An outgoing call that never connected now looks different from one that was
picked up:

- **Icon** — `call_missed_outgoing` in amber instead of `call_made` in the accent
  colour. Same bent-arrow family as the existing missed-call icon, so direction
  is still readable at a glance. Amber rather than red on purpose: red in this
  list means "needs you" (a missed call) or "hostile" (a blocked one), and
  neither fits someone simply not picking up.
- **Subtitle** — the slot the duration leaves empty now reads `No answer`,
  `Busy`, `Declined`, `Cancelled` or `Failed`. So `11:20 AM · No answer · Jio`
  where it used to say just `11:20 AM · Jio`.

An answered call gets no label; its duration already says so. A call whose
outcome we never learned shows nothing at all and looks exactly as it did
before — which covers every row written before this change.

Incoming, missed and blocked rows are visually unchanged.

## How it works

A new nullable column, `call_logs.call_outcome`, records **what happened**, next
to `call_type` which keeps recording **which way the call went**. Values:
`answered`, `no_answer`, `busy`, `declined`, `cancelled`, `failed`, or null for
"not known".

A fifth `call_type` value was deliberately not used: every direction check in the
app is written as `callType == 'outgoing'`, and a new direction-bearing value
would have made all of them quietly wrong.

Outcome sources, strongest first:

1. **`DisconnectCause`** on the native disconnected snapshot — the only source
   that can say *why* a call didn't connect.
2. **`wasActive`** (the call reached `STATE_ACTIVE`) — already how the incoming
   path picks `incoming` vs `missed`.
3. **The device call log's duration** — fill-only, never overwriting, because it
   rounds short answered calls down to 0 seconds.

## Files changed

### Database
- **`lib/database/database_helper.dart`** — `call_outcome TEXT` on the
  `_onCreate` `call_logs` table; DB version 26 → 27; a `v26 -> v27` upgrade
  block; and `_ensureCallOutcomeColumn`, a PRAGMA-checked self-heal wired into
  `_onOpen`. The helper also seeds existing rows: real duration → `answered`,
  `missed`/`blocked` → `no_answer`. Outgoing 0-second rows are left null on
  purpose — on old data "nobody answered" and "never reconciled" are
  indistinguishable, and a blank beats a wrong label.

  No CHECK constraint on the column, so adding a value later never means
  rebuilding the table (which is what `blocked` cost at v13).

### Vocabulary
- **`lib/utils/call_type_mapper.dart`** — new `AppCallOutcome` constants, plus
  `outcomeFromDuration`, `mapDeviceCallOutcome`, `normalizeCallOutcome`
  (rejects any unmapped native string), `callOutcomeLabel` and
  `outgoingDidNotConnect`.

### Storage and plumbing
- **`lib/models/call_record.dart`** — `callOutcome` field. The Recents queries
  use `SELECT cl.*`, so no query changed.
- **`lib/repositories/interaction_repository.dart`** — optional `callOutcome` on
  `logCall`, `logCallIfNew`, `updateCallOutcome` and `backfillFromDeviceLog`.
  The two device-log paths only fill a null; the live reconcile path overwrites.
- **`lib/repositories/call_log_repository.dart`** — `StoredCall` carries
  `callOutcome`, and `needsOutcome` now also counts a row that has a duration
  but no outcome, so pre-existing rows still get filled in by an import.
- **`lib/services/call_service.dart`** — `reconcile` takes `observedOutcome`
  (from the Telecom stream) and falls back to the device log's reading.
- **`lib/services/call_event_logger.dart`** — writes the outcome next to the
  type it already derives from `wasActive`, on all three paths (primary
  snapshot, call-waiting drain, blocked drain).
- **`lib/services/call_log_import_service.dart`** — derives the outcome per
  imported entry and passes it to the fill-only writers.

### UI
- **`lib/screens/call_history_screen.dart`** — `_typeIcon` takes the outcome and
  returns the second outgoing icon; the subtitle falls back from duration to the
  outcome label.

### Native (Phase 2)
- **`android/.../CallRegistry.kt`** — `callOutcome(Call)` maps `DisconnectCause`
  to the same vocabulary (`BUSY` → busy, `REJECTED` → declined,
  `CANCELED`/`LOCAL` → cancelled, `MISSED`/`REMOTE` → no_answer, `ERROR` →
  failed), gated to the DISCONNECTED state, with reaching ACTIVE short-circuiting
  to `answered`. Emitted as `"outcome"` in the snapshot map. Unmapped causes
  return null rather than guessing.
- **`lib/models/call_state.dart`** — `outcome` field parsed from the snapshot.
- **`lib/widgets/call_lifecycle_mixin.dart`** — latches the outcome when it
  arrives and hands it to `reconcile`. Latched rather than read on demand: the
  registry drops the call moments after it disconnects, and the next event is an
  empty snapshot. Cleared when a new call is placed and after a successful
  reconcile.

**`MainActivity.kt` needed no change** — it forwards the whole snapshot map to
the event sink, so the new key flowed through by itself. The plan had assumed
otherwise.

### Tests and docs
- **`test/call_outcome_test.dart`** (new, 20 tests) — the mapping functions, the
  fill-don't-overwrite rule on both writers, `needsOutcome`, and the migration
  self-heal running against a table rebuilt without the column.
- **`test/call_log_matching_test.dart`** — one existing test updated. It pinned
  `needsOutcome == false` once a duration was known; with a row that has a
  duration but no outcome now counting as incomplete, that case was split into
  two tests.
- **`docs/architecture.md`** — schema section explains the direction/outcome
  split, why it isn't a new `call_type` value, and the source ranking.

## Verification

- `flutter analyze` — no issues.
- `./gradlew compileDebugKotlin` — exit 0.
- `flutter test` on each affected file (one per invocation, per the known
  native-assets crash): `call_outcome_test.dart` 20 passed,
  `call_log_matching_test.dart` 16 passed, `call_log_dedupe_test.dart` 9 passed,
  `interaction_repository_test.dart` 3 passed, `call_feature_test.dart` 4
  passed, `call_log_search_test.dart` 6 passed.

**Not yet verified on a device.** The `DisconnectCause` mapping is the part that
most needs real-world checking — which codes a given carrier actually reports is
device- and network-dependent. Until then the duration fallback covers every
call, so the worst case is `No answer` where `Busy` or `Declined` was meant.

## Deliberately left out

- **Smart Redial's trigger is unchanged.** It still offers a redial whenever the
  reconciled duration is 0, including for a call the user cancelled themselves.
  Now that `cancelled` is recorded, that could be narrowed — but it changes
  behaviour beyond this plan's scope and belongs in its own change.
- **A muted grey tier for `cancelled`/`failed`.** Both are amber for now. Worth
  revisiting only if the list feels noisy in daily use.
- **Best-time-to-reach still cannot use this.** `smart_redial_service.dart` and
  `reach_window_service.dart` remain unable to tell a call that got through from
  one that didn't; wiring them to the new column is the natural follow-on, once
  it has real data in it.
