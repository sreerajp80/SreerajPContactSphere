# Change log — Call-waiting handling fixes

Implements plan `plans/20260713_051727_call-waiting-handling.md`.

## What was broken

When already on a call and a second call arrived (call waiting):
1. The loud full ringtone played instead of a beep.
2. No in-call UI appeared for the second call — only the ringtone was heard.
3. If the second caller hung up unanswered, a missed-call *notification* showed
   but no Recents row was written.
4. Two missed-call notifications appeared (ours + Android's system one).

## What changed

### Issue 1 — call-waiting beep instead of the ringtone

- `IncomingCallRinger.kt`: added `startCallWaiting()`, which plays
  `ToneGenerator.TONE_SUP_CALL_WAITING` on the voice-call stream, repeating every
  4 s until stopped (not gated by ringer mode — it is an in-call supervisory
  tone). `stop()` now also releases the tone generator and cancels the repeat via
  a new `stopCallWaiting()`. Added `KEY_MISSED_EVENTS` prefs key and the two tone
  constants.
- `CallRegistry.kt`: `RingController.startRinging` now takes a `callWaiting` flag;
  `startRingingIfNeeded` computes it from a new `hasOngoingCall(except)` helper
  (another top-level call is ACTIVE/HOLDING).
- `ContactSphereInCallService.kt`: `startRinging(call, callWaiting)` plays the
  beep via `startCallWaiting()` when `callWaiting`, else the normal ringtone.

### Issues 2 & 3 (UI) — answer/reject card for the waiting call

- `CallRegistry.kt`: added `answerRingingCall()` and `rejectRingingCall()` that
  target the *ringing* top-level call (the waiting call), plus a private
  `ringingCall()` selector. Reject uses `reject(false, null)` (no-arg `reject()`
  is unavailable at minSdk). Answering relies on Telecom's auto-hold of the
  active call.
- `MainActivity.kt`: wired `answerWaiting`, `rejectWaiting` method-channel calls.
- `telecom_service.dart`: added `answerWaiting()` and `rejectWaiting()`.
- `in_call_screen.dart`: when the background call is *ringing*
  (`heldPhase == CallPhase.ringing`) the screen now shows a **call-waiting card**
  (caller name/number + "Incoming call" + Answer/Decline buttons) instead of the
  static "on hold" banner. Added a lightweight, cached `_resolveHeldName` so the
  card can show the waiting caller's contact name.

### Issue 3 (Recents) — log the missed waiting call

- `CallRegistry.kt`: `RingController.onMissedCall` now takes `phoneAccountId` and
  a `callWaiting` flag; `maybeNotifyMissed` sets `callWaiting` when another live
  call is present (the miss was never the primary the Flutter logger tracks).
- `ContactSphereInCallService.kt`: `onMissedCall(...)` journals call-waiting
  misses as `{number, at, phoneAccountId}` in the ringer prefs
  (`KEY_MISSED_EVENTS`, capped at 200) for the Flutter side to drain. Normal
  misses are not journaled (they are already logged from the snapshot), avoiding
  double-counting.
- `MainActivity.kt`: added `getMissedCallEvents` — a one-shot drain-and-clear of
  `KEY_MISSED_EVENTS` (mirrors `drainBlockedCallEvents`).
- `telecom_service.dart`: added `drainMissedCallEvents()`.
- `call_event_logger.dart`: added `drainMissedCalls()`, which writes each parked
  miss as a `'missed'` Recents row (duration 0) with its SIM; called from
  `start()`.
- `call_history_screen.dart`: `_load()` now also calls `drainMissedCalls()` so a
  waiting-call miss shows the next time Recents is opened/refreshed.

### Issue 4 — clear the system's duplicate missed-call notification

- `ContactSphereInCallService.kt`: after posting our missed-call notification and
  the immediate `cancelSystemMissedCallNotification()`, we now also re-cancel at
  ~500 ms and ~2 s (via a new `missedHandler`) to clear the system notification
  the platform posts asynchronously afterward.

## Files changed

Native (Kotlin):
- `android/app/src/main/kotlin/in/sreerajp/contact_sphere/IncomingCallRinger.kt`
- `android/app/src/main/kotlin/in/sreerajp/contact_sphere/CallRegistry.kt`
- `android/app/src/main/kotlin/in/sreerajp/contact_sphere/ContactSphereInCallService.kt`
- `android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt`

Flutter (Dart):
- `lib/services/telecom_service.dart`
- `lib/services/call_event_logger.dart`
- `lib/screens/in_call_screen.dart`
- `lib/screens/call_history_screen.dart`

## Verification

- `flutter analyze` on the four changed Dart files: **No issues found**.
- `./gradlew :app:compileDevDebugKotlin`: **compiles clean** (after switching the
  reject call to the two-arg form).
- On-device manual testing still required (call waiting needs a real second
  call): beep + Answer/Decline card on the second call; answering holds the
  first; a missed waiting call yields exactly one notification and one Recents
  row; a normal single missed call is unaffected (one row, one notification).
