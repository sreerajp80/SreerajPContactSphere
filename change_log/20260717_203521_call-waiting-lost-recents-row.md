# Change log — Call ended during call-waiting now reaches Recents

Implements [plans/20260717_192514_call-waiting-lost-recents-row.md](../plans/20260717_192514_call-waiting-lost-recents-row.md).

## The problem

When a call was in progress and a second call arrived, hanging up the first call
and answering the second left the first call missing from Recents. The Flutter
snapshot logger (`CallEventLogger`) builds Recents rows from a snapshot of the
**primary** call only. The moment the first call was hung up it stopped being the
primary (the still-ringing second call outranked its `disconnected` state), so
the logger switched to tracking the second call and threw away everything it had
accumulated for the first — no row was ever written. The same loss happened
whenever any incoming call stopped being the primary before the logger saw it end
(for example after the waiting call was answered and the first went on hold).

## The fix

The native layer is the only one that sees every call, so it now reports each
call-waiting incoming call when it ends, reusing the existing journal-and-drain
path. Because the native side journals a call **only** when another call was live
alongside it — exactly the set the snapshot logger structurally cannot see — the
two paths never double-log.

## Changes

- **`android/.../CallRegistry.kt`**
  - `RingController.onMissedCall` no longer takes `callWaiting` (journaling moved
    out of it). Added `RingController.onIncomingCallEnded(number, phoneAccountId,
    wasActive, durationSeconds)`.
  - `onCallRemoved` now also calls `maybeJournalCallWaiting(c)`, which — for an
    incoming call that ended while another call was still present — reports it via
    `onIncomingCallEnded` with whether it was ever answered (`wasActive`) and its
    computed duration. A lone incoming call is skipped (the snapshot logger already
    logs it).
- **`android/.../ContactSphereInCallService.kt`**
  - `onMissedCall(number, phoneAccountId)` now only posts the missed-call
    notification; it no longer journals.
  - Added `onIncomingCallEnded(...)`, which journals via the renamed
    `journalIncomingCall(...)`. The journal entry now also carries `wasActive` and
    `duration`.
- **`android/.../MainActivity.kt`** — `drainMissedCallEvents()` now passes the new
  `wasActive` and `duration` fields through to Flutter.
- **`lib/services/telecom_service.dart`** — renamed `drainMissedCallEvents()` to
  `drainCallWaitingEvents()`; its records now carry `wasActive` and
  `durationSeconds`.
- **`lib/services/call_event_logger.dart`** — renamed `drainMissedCalls()` to
  `drainCallWaitingCalls()`; it now writes `'incoming'` rows with the real
  duration when the call was answered, `'missed'` (duration 0) otherwise. `_onEvent`
  also drains once no call remains, so a parked call-waiting call surfaces in
  Recents immediately instead of only on the next app start.
- **`lib/screens/call_history_screen.dart`** — `_load()` calls the renamed
  `drainCallWaitingCalls()`.

## Verification

- `flutter analyze` on the changed Dart files: no issues.
- `./gradlew :app:compileDevDebugKotlin`: compiled clean.
- On-device manual check (default dialer) still to be run by the user:
  1. Incoming answered → second incoming → hang up first → answer second: both
     appear (first `incoming` with real duration, second `incoming`).
  2. Incoming answered → second incoming → answer it (first held) → end both:
     both rows present.
  3. Plain single answered call and plain single missed call: exactly one row each
     (no double-log).
