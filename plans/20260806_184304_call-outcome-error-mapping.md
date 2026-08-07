# Fix "Failed" shown for calls that simply were not answered

**Status:** completed

Approved 2026-08-06: Part A, Part B, and the "unknown" fallback for an
unmatched `ERROR` (decision 3, the recommended option).

## The issue

Recents showed two calls to the same number, minutes apart, with different statuses:

- 6:27 PM — "No answer"
- 6:25 PM — "Failed"

Both were the same thing: an outgoing call the other side never picked up.

### What the evidence says

The phone's own call log records both the same way — outgoing, 0 seconds:

```
9876543210  2026-08-06 18:25:02  duration=0  type=2 (outgoing)
9876543210  2026-08-06 18:27:40  duration=0  type=2 (outgoing)
```

So the device log alone would have labelled both "No answer"
(`outcomeFromDuration`, duration 0 -> `no_answer`).

The "Failed" came from the live Telecom reading, which wins over the device log
(`lib/services/call_service.dart:185-187`). Logcat for one of these attempts:

```
disconnectCause=DisconnectCause [ Code: (ERROR) ... Reason: (ERROR_UNSPECIFIED)
  TelephonyCause: 36/-1
  ImsReasonInfo :: {336 : CODE_SIP_TEMPRARILY_UNAVAILABLE, 480, -1:normal unspecified}]
setCallState DIALING -> DISCONNECTED
```

`SIP 480 Temporarily Unavailable` is what a VoLTE network (Jio here) returns when
the far end does not answer, is switched off, or is out of coverage. Android
wraps that in `DisconnectCause.ERROR`, and our mapping
(`CallRegistry.kt:335`) reads it literally:

```kotlin
DisconnectCause.ERROR -> "failed"
```

So a plain no-answer is labelled "Failed". `DisconnectCause.ERROR` is a coarse
bucket — it covers real network failures **and** ordinary no-answers on IMS.

### A second, smaller problem

A Smart Redial retry is dialed natively by `SmartRedialReceiver` while the app
may be closed. Nothing on the Dart side holds a pending call for it, so the live
outcome is never captured; that row falls back to the device log's
duration-only reading. Retried calls therefore can never say "Busy",
"Declined" or "Cancelled" — only "No answer". This is why the two rows above came
from two different sources in the first place.

## Files to change

### Part A — stop calling a no-answer a failure (the actual bug)

| File | Change |
| --- | --- |
| `android/app/src/main/kotlin/in/sreerajp/contact_sphere/CallRegistry.kt` | Refine the `DisconnectCause.ERROR` branch using the IMS/SIP detail; add a small parser + mapping helper. |

### Part B — capture the outcome for natively-placed calls (optional, separable)

| File | Change |
| --- | --- |
| `android/.../CallRegistry.kt` | New `RingController.onOutgoingCallEnded(...)`, called from `onCallRemoved`. |
| `android/.../ContactSphereInCallService.kt` | Journal the event into `RINGER_PREFS` under a new key. |
| `android/.../MainActivity.kt` | New method-channel call `drainOutgoingOutcomeEvents`. |
| `lib/services/telecom_service.dart` | `drainOutgoingOutcomeEvents()` wrapper. |
| `lib/services/call_event_logger.dart` | `drainOutgoingOutcomes()` — patch matching rows on start/Recents load. |
| `lib/repositories/interaction_repository.dart` | `backfillObservedOutcome(...)` — patch-only, never inserts. |
| `test/` | Dart test for the drain/patch behaviour. |

## The plan

### Part A

1. In `CallRegistry.kt`, keep every existing branch of `callOutcome()` as-is.
   Only the `DisconnectCause.ERROR` branch changes: instead of returning
   `"failed"` outright, ask a new helper what the IMS layer actually said.

2. Add `private fun imsSipCode(cause: DisconnectCause): Int?`. Android does not
   expose `ImsReasonInfo` through public API, but it is present in
   `DisconnectCause.toString()` in the AOSP format
   `ImsReasonInfo :: {code, extraCode, extraMessage}`, where `extraCode` is the
   SIP response code. Parse it with a defensive regex; return null if the shape
   is anything other than expected. No hidden-API reflection (blocked since
   Android 9), no crash if a vendor prints it differently.

3. Add `private fun outcomeFromSipCode(sip: Int): String?`:

   | SIP code | Meaning | Outcome |
   | --- | --- | --- |
   | 408 Request Timeout, 480 Temporarily Unavailable, 487 Request Terminated | rang out / unreachable / cancelled by the network | `no_answer` |
   | 486 Busy Here, 600 Busy Everywhere | the line is busy | `busy` |
   | 603 Decline | actively rejected | `declined` |
   | anything else | a real error | `failed` |

4. Unrecognised `ERROR` — no `ImsReasonInfo` in the string at all — returns
   **null** ("we don't know") rather than `"failed"`. Flutter then falls back to
   the duration and the row reads "No answer", matching the device log and what
   the stock dialer shows. Rationale: "Failed" is a strong claim and we now know
   `ERROR` alone is not evidence for it. (Say so in the doc comment.)

5. Update the doc comment on `callOutcome()` to explain why `ERROR` needs the
   SIP code, so nobody simplifies it back.

Nothing on the Dart side changes for Part A: `AppCallOutcome.failed` and the
"Failed" label stay exactly as they are — they will just be written only when
the network really did fail.

### Part B

6. `CallRegistry.onCallRemoved` already calls `maybeNotifyMissed` and
   `maybeJournalCallWaiting` before dropping its tracking sets. Add
   `maybeJournalOutgoingOutcome(c)` alongside them: for an **outgoing** call with
   a non-null `callOutcome(c)`, hand `{number, phoneAccountId, outcome,
   at, duration}` to the `RingController`.

7. `ContactSphereInCallService` journals it into `IncomingCallRinger.RINGER_PREFS`
   under a new `KEY_OUTGOING_OUTCOMES`, capped like the existing journal
   (oldest dropped) — same shape and same best-effort behaviour as
   `journalIncomingCall`.

8. `MainActivity` exposes `drainOutgoingOutcomeEvents` (read-and-clear, matching
   `drainBlockedCallEvents` / `drainCallWaitingEvents`); `TelecomService` wraps it.

9. `CallEventLogger.drainOutgoingOutcomes()` runs from `start()` and from the
   Recents screen load, like the other drains. For each event it finds the
   stored outgoing row by `CallLogRepository.matchKey` + `matchWindow` and calls
   `InteractionRepository.backfillObservedOutcome`, which patches
   `call_outcome` **only where it is currently NULL** (`where: 'id = ? AND
   call_outcome IS NULL'`, the same guard `backfillFromDeviceLog` uses).
   It never inserts a row: the device-log import owns creating outgoing rows, so
   there is no way for this to produce a duplicate Recents entry. If no row
   matches yet, the event is simply dropped — the next device sync will still
   write the duration-based outcome.

10. No change to the foreground path: `CallLifecycleMixin` keeps latching the
    outcome for calls placed from the app, and since the journal only fills
    NULLs, the two paths cannot fight.

## Risks and how they are handled

- **`toString()` parsing is not a documented contract.** It is fenced: a
  non-matching string returns null, which is the safe "unknown" path. The
  regex touches only the `ImsReasonInfo :: {...}` fragment, which is AOSP's own
  format, not Motorola's annotation.
- **Genuine failures on non-IMS (2G/3G circuit-switched) calls** will now read
  "No answer" instead of "Failed", because there is no `ImsReasonInfo` to check.
  This is a deliberate trade: under-claiming beats mislabelling. Alternative, if
  you prefer: keep `"failed"` as the fallback for unmatched `ERROR`. Say which
  you want.
- **Part B adds a second writer for outgoing outcomes.** Contained by making it
  patch-only over NULLs, never an insert.

## Testing

`android/app/src` has no Kotlin unit-test source set, so the Kotlin mapping is
verified on-device:

1. `flutter build`/install to the moto g54, call a number that will not answer
   on the Jio SIM, let it ring out — Recents must read "No answer".
2. Call a number that is switched off — must read "No answer", not "Failed".
3. Call a busy line — must read "Busy".
4. Decline from the other handset — must read "Declined".
5. Hang up while dialing — must read "Cancelled".
6. Airplane mode on the far end / an invalid number — should still read "Failed".
7. Part B: schedule a Smart Redial, close the app, let the retry fire unanswered,
   reopen — the row must carry the outcome, and there must be exactly **one**
   Recents row for it.

Dart side: `flutter analyze` clean, `flutter test` for the new Part B repository
test (run one file per invocation — see the known sqlite3 test crash).

## Decisions I need from you

1. Approve Part A? (This is the reported bug.)
2. Include Part B now, or leave it for later?
3. Unmatched `ERROR` -> "unknown/No answer" (my recommendation) or keep "Failed"?
