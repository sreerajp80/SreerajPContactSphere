# Change log — architecture-document conformance (with real call duration)

Implements [plans/20260628_205250_architecture-conformance.md](../plans/20260628_205250_architecture-conformance.md).

## Summary

The architecture document describes services that score relationships and build
pre-call summaries over the `interactions` and `call_logs` tables, with the
contact's local time in the summary. Those tables were never written and the
timezone lookup was a hard `null`, so the described behavior never happened. This
change creates the missing write path, captures **real call duration** from the
device call log, implements the timezone lookup, and reconciles two stale
statements in the doc.

## Changes

### New: `lib/repositories/interaction_repository.dart`
Write path for the two read-only tables:
- `logCall(...)` → inserts a `call_logs` row (ISO-8601 timestamp).
- `logInteraction(...)` → inserts an `interactions` row.
- `updateCallOutcome(...)` → transactionally back-fills real
  `duration`/`call_type`/`timestamp` onto the provisional `call_logs` and
  `interactions` rows.

### `lib/screens/contact_detail_screen.dart`
- State now mixes in `WidgetsBindingObserver` (registered in `initState`, removed
  in `dispose`).
- `_call` records a `_PendingCall` (number, placed-at time, provisional row ids),
  places the call, then logs provisional `call_logs` + `interactions` rows.
- `didChangeAppLifecycleState` → on `resumed` with a pending call,
  `_reconcilePendingCall` queries the device call log via `CallLog.query`
  (`call_log` package), matches the entry by normalized trailing digits within
  the post-call window, back-fills real duration/type/timestamp via
  `updateCallOutcome`, recomputes the relationship score, and refreshes the
  summary. All best-effort: any failure leaves the provisional (null-duration)
  row intact; the interaction is never lost.
- `CallType` → schema-allowed `call_type` string mapping
  (`incoming`/`outgoing`/`missed`).

### `lib/services/permission_service.dart`
Added `ensureReadCallLog()` (delegates to `Permission.phone`, which bundles
`READ_CALL_LOG`), so the call site reads clearly.

### `lib/services/pre_call_summary_service.dart`
Replaced the `_getTimezoneForLocation` `null` stub with an offline lookup: a
built-in city/country → IANA-zone map + the bundled `timezone` database, lazily
initialized once, formatted with `intl` (e.g. `5:30 PM (Asia/Kolkata)`). Unknown
locations still return `null`.

### `docs/architecture.md`
- Database described as **version 2** (was "version 1"), noting the v1→v2 FK-index
  migration.
- Replaced the stale "contact_list is the only screen / screens don't exist yet"
  paragraph with the current screen set and the new call/interaction logging
  behavior. Noted the relationship-map screen is still unbuilt.

### `test/interaction_repository_test.dart` (new)
Host-side sqflite (ffi) tests covering: log round-trip read back by
`PreCallSummaryService`; `updateCallOutcome` back-filling both rows and surfacing
in the summary; and a logged interaction producing a non-zero, denormalized
relationship score.

## Deviation from the plan

The plan said "no `pubspec.yaml` change". One **dev-only** dependency was added —
`sqflite_common_ffi: ^2.3.6` (resolved to 2.4.0+3) — so the unit tests can run
sqflite under `flutter test` (the default sqflite factory is Android-only). This
does not affect the app, runtime, or APK. Note: the package's import entry point
is `package:sqflite_common_ffi/sqflite_ffi.dart` (not `..._common_ffi.dart`).

## Not included (per plan — known-gaps items, not architecture.md)
`provider` state management; QR/BLE/speech-to-text/device-contact-sync; reminder
notification scheduling; bulk historical call-log import/sync.

## Verification
- `flutter analyze` → **No issues found.**
- `flutter test` → **all tests passed** (3 new repository tests + existing widget
  smoke test).
- Device-only paths (system call-log query + lifecycle reconciliation) are
  platform-channel bound and need manual on-device verification: place a call,
  end it, return to the app, confirm the summary shows the real duration.
