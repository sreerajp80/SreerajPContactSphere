# Call outcome: stop labelling an unanswered call "Failed"

Implements [plans/20260806_184304_call-outcome-error-mapping.md](../plans/20260806_184304_call-outcome-error-mapping.md)
(Part A and Part B, both approved, with the "unknown" fallback for an
unmatched `ERROR`).

## Why

Recents showed two calls to the same number, two minutes apart, with different
statuses — 6:27 PM "No answer", 6:25 PM "Failed" — when both were simply calls
the other side never picked up.

The device's own call log recorded both identically (outgoing, 0 seconds), so
the difference came from the live Telecom reading, which wins over the device
log. Logcat showed the call ending with:

```
Code: (ERROR) ... ImsReasonInfo :: {336 : CODE_SIP_TEMPRARILY_UNAVAILABLE, 480, ...}
```

SIP 480 "Temporarily Unavailable" is what a VoLTE network returns when the far
end doesn't answer. Android buckets that under `DisconnectCause.ERROR`, and the
old mapping read `ERROR` literally as `"failed"`.

A second, related gap: a Smart Redial retry is dialed natively with the app
possibly closed, so nothing on the Dart side captured the reason for it at all.

## What changed

### Part A — the mapping (native)

**`android/.../CallRegistry.kt`**

- `callOutcome()` no longer returns `"failed"` for `DisconnectCause.ERROR`.
  It now resolves the SIP response code first, and returns **null** ("we don't
  know") when there is none — the Flutter side then falls back to the duration
  and the row reads "No answer", as the device log and stock dialer do.
- New `imsSipCode()`: reads the SIP code out of the
  `ImsReasonInfo :: {code, extraCode, extraMessage}` fragment in
  `DisconnectCause.toString()`. Android exposes no public getter for it and
  reflection onto the hidden one is blocked since Android 9, so this parses the
  printed form — defensively: anything not matching the expected shape, or a
  value outside the 100–699 SIP range, returns null.
- New `outcomeFromSipCode()`:

  | SIP | Outcome |
  | --- | --- |
  | 408, 480, 487 | `no_answer` |
  | 486, 600 | `busy` |
  | 603 | `declined` |
  | anything else | `failed` |

Every other `DisconnectCause` branch is unchanged, and nothing on the Dart side
changed for this part — `AppCallOutcome.failed` and the "Failed" label stay as
they were, they are just written only when the network really did fail.

### Part B — capturing the reason for natively-placed calls

New one-shot journal, mirroring the existing blocked-call and call-waiting ones.

- **`CallRegistry.kt`** — new `RingController.onOutgoingCallEnded(number,
  outcome, atMillis)`, fired from `onCallRemoved` via
  `maybeJournalOutgoingOutcome()` for outgoing calls with a known outcome. Dated
  at call creation, which is how the device log dates an outgoing call, so the
  two records stay matchable.
- **`IncomingCallRinger.kt`** — new `KEY_OUTGOING_OUTCOMES` prefs key.
- **`ContactSphereInCallService.kt`** — `journalOutgoingOutcome()` appends
  `{number, at, outcome}`, capped at 200 (oldest dropped), best-effort.
- **`MainActivity.kt`** — `getOutgoingOutcomeEvents` method channel + a
  read-and-clear `drainOutgoingOutcomeEvents()`.
- **`lib/services/telecom_service.dart`** — `drainOutgoingOutcomeEvents()`.
- **`lib/repositories/interaction_repository.dart`** —
  `backfillObservedOutcome()`: updates `call_outcome`
  `WHERE id = ? AND call_outcome IS NULL`, returning whether it changed
  anything.
- **`lib/services/call_event_logger.dart`** — `drainOutgoingOutcomes()`,
  called from `start()` and from the Recents load. It matches each event to a
  stored row by number + the existing 90-second window and patches it.
  **It never inserts**, so it cannot produce a duplicate Recents entry — row
  creation for outgoing calls stays with the device-log import.
- **`lib/screens/call_history_screen.dart`** — drains on load alongside the
  other two.

One thing the plan did not anticipate: the device sync that writes the row runs
unawaited, so a drain triggered by app start or a Recents load routinely arrives
*before* the row exists. Rather than dropping those events (the native journal
clears on read, so the reason would be lost for good), unmatched events are held
in a process-lifetime retry buffer — static, because `CallEventLogger` is
constructed ad-hoc at each call site — capped at 50 and with a 6-hour TTL. The
import fires `CallLogEvents`, Recents reloads, and the next drain finds the row.

## Tests

- New `test/outgoing_outcome_journal_test.dart` (5 tests, all passing): the
  reason lands on the imported row across different number forms and a few
  seconds of drift; it never replaces an existing outcome; an unmapped native
  string is ignored; an event arriving before its row is retried rather than
  lost and never inserts a row of its own; an event outside the match window is
  not treated as the same call.
- `test/call_outcome_test.dart` — two tests added for
  `backfillObservedOutcome` (fills a gap; leaves an existing outcome alone).
  22 tests passing.
- `flutter analyze` — clean.
- `flutter build apk --debug --flavor dev` — builds, so the Kotlin compiles.

## Still to do

The Kotlin mapping has no unit-test source set in this project, so it needs the
on-device runs listed in the plan (rang out / switched off / busy / declined /
cancelled / genuine failure, plus a Smart Redial retry checked for exactly one
Recents row). **Not yet done:** installing the new build failed with
`INSTALL_FAILED_UPDATE_INCOMPATIBLE` — the dev app on the device was signed with
a different key, and clearing it would wipe that install's app data, so it was
left alone pending a decision.
