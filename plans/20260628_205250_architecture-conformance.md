# Implement what the architecture document describes

**Status:** completed

## Goal

Bring the implementation into conformance with [docs/architecture.md](../docs/architecture.md).
The architecture document describes a layered app whose services
(`RelationshipScoringService`, `PreCallSummaryService`) operate over the
`interactions` and `call_logs` tables, and whose pre-call summary includes the
contact's local timezone. Today those services **read** from tables that nothing
ever **writes**, and the timezone lookup is a hard `null`. So the described
behavior never actually happens. This plan closes that gap and reconciles two
stale statements in the doc itself.

## What the architecture document says vs. what the code does

| Architecture doc says | Reality | Action |
|---|---|---|
| `relationship_scoring_service` computes a "weighted frequency/recency/emotional-tone score over the `interactions` table" (architecture.md:21-22) | Reads `interactions`, but no code ever inserts a row → score is always 0 | Wire interaction logging |
| `pre_call_summary_service` = "recent interactions + last call + upcoming birthday + timezone" (architecture.md:22-23) | Reads `interactions`/`call_logs` (never written) and timezone always `null` | Wire call/interaction logging + implement timezone |
| `relationship_score` "denormalized onto `contacts` and recomputed by `RelationshipScoringService`" (architecture.md:36) | `calculateRelationshipScore` exists but is never invoked | Invoke it after logging an interaction |
| `database_helper` is "version 1" (architecture.md:10) | Actually `version: 2` ([database_helper.dart:23](../lib/database/database_helper.dart#L23)) | Fix the doc |
| `contact_list_screen.dart` "is the only screen … reference screens … that do not exist yet" (architecture.md:24-26) | Add/edit, detail, groups, duplicates all exist and are wired | Fix the doc |

## The issue (root cause)

There is no write path into `call_logs` or `interactions`. The dialer in
[contact_detail_screen.dart:60-71](../lib/screens/contact_detail_screen.dart#L60-L71)
(`_call`) places the call via `FlutterPhoneDirectCaller` but records nothing.
Because nothing populates those tables:

- `RelationshipScoringService.calculateRelationshipScore` (reads `interactions`)
  always returns ~0 and is, in any case, never called.
- `PreCallSummaryService.getPreCallSummary` always reports "0 recent
  interaction(s)" and no last-call info.
- `_getTimezoneForLocation` ([pre_call_summary_service.dart:76-79](../lib/services/pre_call_summary_service.dart#L76-L79))
  returns `null`, so the summary's "Their time" line never renders.

## Plan for the fix

### 1. New `InteractionRepository` (write path for the two read-only tables)
New file `lib/repositories/interaction_repository.dart`. Methods:

- `Future<int> logCall({required int contactId, required String phoneNumber, String callType = 'outgoing', int? duration, String? callIntent})`
  — inserts into `call_logs` (columns per [database_helper.dart:127-137](../lib/database/database_helper.dart#L127-L137)).
- `Future<int> logInteraction({required int contactId, String interactionType = 'call', String? emotionalTone, int? duration})`
  — inserts into `interactions` (columns per [database_helper.dart:154-162](../lib/database/database_helper.dart#L154-L162)).
- `Future<void> updateCallOutcome({required int callLogId, int? interactionId, required int duration, required String callType, String? timestamp})`
  — updates the provisional `call_logs` row's `duration`/`call_type`/`timestamp`
  and the matching `interaction` row's `duration`/`timestamp` in one transaction
  (used by the resume-time reconciliation, step 2b).

Both write `timestamp` as `DateTime.now().toIso8601String()` (don't rely on the
SQL `CURRENT_TIMESTAMP` default, since the services parse the value with
`DateTime.parse`). Defensive: wrap in try/catch and never throw into the UI,
matching the existing service style.

### 2. Wire logging into the dialer — with real duration capture

`flutter_phone_direct_caller` hands control to the system dialer and returns
immediately, so duration/outcome are **not** available at placement time. The
real duration lives in the **device call log**, written by Android only after the
call ends. So we log in two steps: a provisional row at placement, then reconcile
the true duration/type when the user returns to the app.

**a. At placement** — edit `_call` in
[contact_detail_screen.dart:60-71](../lib/screens/contact_detail_screen.dart#L60-L71):
record `_pendingCall = {number, contactId, placedAt: DateTime.now()}`, place the
call, then insert a provisional `call_logs` row via `logCall`
(`call_type = 'outgoing'`, `duration = null`) capturing its row id, and a
provisional `interaction` row. Logging failures must never surface as call
failures.

**b. On return (reconciliation)** — make `_ContactDetailScreenState` a
`WidgetsBindingObserver` (register in `initState`, remove in `dispose`). In
`didChangeAppLifecycleState`, when state becomes `resumed` and a `_pendingCall`
exists:

- Ensure the call-log read permission (step 2c). If denied/unavailable, keep the
  provisional row as-is (graceful degradation) and clear `_pendingCall`.
- Query the system log via the `call_log` package:
  `CallLog.query(number: <dialed>, dateFrom: placedAt.millisecondsSinceEpoch)`,
  take the most recent matching entry, and map its fields:
  - `duration` (seconds) → update the provisional `call_logs` row **and** the
    provisional `interaction` row (`InteractionRepository.updateCallOutcome`).
  - `CallType` → `call_type` string: `outgoing`→`'outgoing'`,
    `incoming`→`'incoming'`, `missed`/`rejected`/`blocked`→`'missed'` (the
    schema's CHECK allows only these three, [database_helper.dart:131](../lib/database/database_helper.dart#L131)).
  - entry `timestamp` → overwrite the provisional `timestamp` with the system
    value so recency scoring uses the real call time.
- Then re-score (step 3), refresh via `_load()`, and clear `_pendingCall`.

Add to `InteractionRepository`: `updateCallOutcome({required int callLogId, int? interactionId, required int duration, required String callType, String? timestamp})` that updates both rows in one transaction.

**c. Permission** — duration capture needs `READ_CALL_LOG`, already declared in
[AndroidManifest.xml:4](../android/app/src/main/AndroidManifest.xml#L4).
permission_handler bundles `READ_CALL_LOG` in the `Permission.phone` group, so
the existing `ensureCallPhone()` request covers it; on Android 9+ the OS may show
a separate "Call logs" prompt. Add `ensureReadCallLog()` to
[permission_service.dart](../lib/services/permission_service.dart) as an explicit
alias (delegates to `Permission.phone`) so the call site reads clearly, matching
the existing `ensure*` style.

> Matching caveat: `CallLog.query` filters by number + start time, but number
> formatting can differ (spaces, +country code). We match on the most recent
> entry within the time window whose normalized digits (strip non-digits, compare
> last 7–10) equal the dialed number. If no entry matches, the provisional
> null-duration row stands — we never lose the interaction.

### 3. Recompute the denormalized score after an interaction
In the same `_call` flow, call
`RelationshipScoringService().calculateRelationshipScore(widget.contactId)`
(it already updates `contacts.relationship_score`,
[relationship_scoring_service.dart:63-68](../lib/services/relationship_scoring_service.dart#L63-L68)).
This makes the "recomputed by RelationshipScoringService" claim true. Run it
after logging and ignore failures.

### 4. Implement timezone lookup
Replace the `null` stub in
[pre_call_summary_service.dart:76-79](../lib/services/pre_call_summary_service.dart#L76-L79).
Implementation, kept offline (no network — none is declared/permitted):

- Add a small built-in country/city → IANA timezone map covering common cases,
  initialize the `timezone` package (`tz.initializeTimeZones()`) once, resolve
  the location to a `tz.Location`, and return the contact's current local time
  formatted with `intl` (e.g. `5:30 PM (Asia/Kolkata)`). Both `timezone` and
  `intl` are already declared in [pubspec.yaml](../pubspec.yaml).
- Unknown location → return `null` (current behavior preserved; the summary line
  simply omits, see [contact_detail_screen.dart:192-193](../lib/screens/contact_detail_screen.dart#L192-L193)).

This is the architecture-described "timezone" feature with a pragmatic offline
lookup; a full geocoding lookup remains out of scope.

### 5. Reconcile the architecture document
Edit [docs/architecture.md](../docs/architecture.md):

- Line 10: "version 1" → "version 2" and note the v1→v2 migration adds FK indexes.
- Lines 24-26: replace the stale "only screen / screens that do not exist yet"
  paragraph with the current screen set (add/edit, detail+dialer, groups,
  duplicates) and that interactions/calls are now logged from the detail screen.

## Files to change

- `lib/repositories/interaction_repository.dart` — **new** (`logCall`,
  `logInteraction`, `updateCallOutcome`).
- `lib/screens/contact_detail_screen.dart` — provisional log at placement +
  lifecycle observer that reconciles real duration/type/timestamp from the system
  call log on resume, re-score, refresh.
- `lib/services/permission_service.dart` — add `ensureReadCallLog()`.
- `lib/services/pre_call_summary_service.dart` — real timezone lookup.
- `docs/architecture.md` — fix version + screen-status drift.
- `test/interaction_repository_test.dart` — **new** (see below).

No `pubspec.yaml` change: `call_log: ^6.0.0` is already declared
([pubspec.yaml:25](../pubspec.yaml#L25)) and `READ_CALL_LOG` is already in the
manifest ([AndroidManifest.xml:4](../android/app/src/main/AndroidManifest.xml#L4)).

## Tests

Add `test/interaction_repository_test.dart` using sqflite's in-memory/ffi DB (or
the existing test DB pattern) to verify:

- `logCall` / `logInteraction` insert rows that `PreCallSummaryService` and
  `RelationshipScoringService` then read back (round-trip).
- `updateCallOutcome` updates the provisional `call_logs` **and** `interaction`
  rows' `duration`/`call_type`/`timestamp`, and the summary's `lastCallDuration`
  then reflects the real value.
- After logging a positive interaction, `calculateRelationshipScore` returns
  `> 0` and updates `contacts.relationship_score`.

The `call_log` device query and lifecycle reconciliation depend on Android
platform channels and can't run in a unit test; they'll be verified manually on a
device/emulator (place a call, end it, return to the app, confirm the summary
shows the real duration). The repository-level `updateCallOutcome` — the part that
persists the duration — is covered by the unit test above.

Run `flutter analyze` and `flutter test` after implementation; both must pass.

## Explicitly out of scope (not described by architecture.md)

These are [docs/known-gaps.md](../docs/known-gaps.md) items, not part of the
architecture document, and are **not** included:

- `provider` state management — architecture.md describes `setState` as the
  current reality and does not prescribe a `ChangeNotifierProvider` migration.
- QR, BLE, speech-to-text, device-contact sync, and notification scheduling for
  the `reminders` table.
- Full system-call-log **import/sync** (backfilling historical calls into
  `call_logs`). We only capture the duration of calls the app itself places; a
  general call-history sync remains a known-gaps item.

## Risks / notes

- **Reconciliation timing.** Duration is filled in only when the user returns to
  the app after the call. If they never return (or the OS kills the app), the row
  keeps `duration = null`. Acceptable degradation — the interaction is still
  logged for frequency/recency scoring.
- **Number matching.** System call-log numbers may be formatted differently than
  the dialed string; we match on normalized trailing digits within the post-call
  time window. A mismatch leaves the null-duration provisional row intact rather
  than logging a wrong duration.
- **Call-log permission.** If the user grants `CALL_PHONE` but denies the call-log
  read, calls still place and log provisionally; only duration is unavailable.
- `tz.initializeTimeZones()` must run once; guard against double-init.
