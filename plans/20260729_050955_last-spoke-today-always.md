# Fix: caller context always says "Last spoke today"

**Status:** completed

## Files to change

- `lib/services/caller_context_service.dart` — the "last spoke" query.
- `test/caller_context_service_test.dart` — add tests for the new rules.

## The issue

On the in-call screen the smart context card shows "Last spoke today" for every
caller, no matter when you really last talked to them.

Cause: the card counts the **current call itself** as a past conversation.

- For an outgoing call, `CallService.placeCall` writes a provisional `call_logs`
  row (and an `interactions` row) at the moment the call is placed
  ([call_service.dart:112](lib/services/call_service.dart#L112)). Those rows have
  `duration = NULL` until the call ends and is reconciled.
- `InCallScreen` then builds the caller context while the call is still running
  ([in_call_screen.dart:234](lib/screens/in_call_screen.dart#L234)).
- `_resolveLastSpoke` takes the newest row from `call_logs` / `interactions`
  ([caller_context_service.dart:211-258](lib/services/caller_context_service.dart#L211-L258)),
  which is that just-written row, timestamped now → "Last spoke today".

A second, smaller problem: rows for **missed**, **rejected** and **blocked**
calls, and zero-second calls, also count as "spoke", even though no one talked.
So an incoming call from someone who missed you yesterday can read "Last spoke
yesterday".

## The fix

Change `_resolveLastSpoke` so it only counts calls that were real conversations,
and never counts the call in progress.

1. `call_logs` query: add `AND duration IS NOT NULL AND duration > 0` and
   `AND call_type IN ('incoming','outgoing')`.
   - `duration IS NOT NULL` drops the provisional row of the call in progress.
   - `duration > 0` drops unanswered / cancelled calls.
   - the `call_type` filter drops `missed`, `rejected` and `blocked` rows.
2. `interactions` query: add `AND duration IS NOT NULL AND duration > 0` — the
   provisional interaction row written at placement has a null duration and gets
   back-filled by `updateCallOutcome`.
3. Add an optional `DateTime? notAfter` parameter to
   `getCallerContextByNumber` / `getCallerContextByContactId`, passed down to
   `_resolveLastSpoke`, which adds `AND timestamp < ?`. This is a belt-and-braces
   guard for any row that is already complete but belongs to the current call
   (for example an incoming call reconstructed by the device-log import).
   Callers may leave it out; `InCallScreen` will not pass it in this change.
4. If nothing is left after the filters, `lastSpokeLabel` stays null and the card
   simply omits the "Last spoke" chip — the existing behaviour for a contact with
   no history.

No change to `formatLastSpokeTime`; the wording rules stay as they are.

## Tests

In `test/caller_context_service_test.dart`, add cases that:

- a `call_logs` row with `duration = NULL` (call in progress) is ignored;
- a `missed` row is ignored;
- a `duration = 0` row is ignored;
- an older answered call is what the label reports;
- with only ignored rows, `lastSpokeLabel` is null.

(Note: this project's sqlite-backed tests must be run one file per
`flutter test` invocation.)

## Risk

Low. The only visible change is that "Last spoke ..." now reflects real
conversations, and the chip disappears for contacts whose only history is missed
or in-progress calls.
