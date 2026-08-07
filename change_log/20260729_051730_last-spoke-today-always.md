# Caller context no longer always says "Last spoke today"

Implements [plans/20260729_050955_last-spoke-today-always.md](../plans/20260729_050955_last-spoke-today-always.md).

## What was wrong

The smart context card on the in-call screen said "Last spoke today" for every
caller. It was counting the current call as a past conversation: an outgoing call
writes a provisional `call_logs` row (and an `interactions` row) at placement,
timestamped now, and the card was built while that call was still running. Missed,
rejected, blocked and zero-second calls also counted as "spoke".

## What changed

`lib/services/caller_context_service.dart`

- `_resolveLastSpoke` now only counts real conversations:
  - `call_logs`: `duration IS NOT NULL AND duration > 0` and
    `call_type IN ('incoming','outgoing')`.
  - `interactions`: `duration IS NOT NULL AND duration > 0`.
  The null-duration test is what drops the call in progress; the duration and
  type tests drop unanswered, missed, rejected and blocked calls.
- Added an optional `notAfter` parameter to `getCallerContextByNumber` and
  `getCallerContextByContactId`, passed down to `_resolveLastSpoke` as a
  `timestamp < ?` cut-off. It is an extra guard for a row that is already
  complete but belongs to the current call. No caller passes it yet.
- `formatLastSpokeTime` and the wording rules are unchanged.

When nothing survives the filters, `lastSpokeLabel` stays null and the card just
omits the "Last spoke" chip.

`test/caller_context_service_test.dart`

Three new tests:

- a null-duration row (call in progress), a missed row and a zero-duration row
  are all ignored, and the label reports the older answered call;
- with only such rows, `lastSpokeLabel` is null;
- `notAfter` cuts off a complete row belonging to the current call.

## Verification

- `flutter test test/caller_context_service_test.dart` — 7 tests, all pass.
- `flutter analyze` on both changed files — no issues.
