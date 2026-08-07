# Call-waiting handling fixes

**Status:** completed

## Background

When ContactSphere is the default phone app and the user is already on a call,
a second incoming call (call waiting) is handled poorly. The user reported four
separate problems:

1. **Full ringtone instead of a beep.** The second call plays the loud
   incoming-call ringtone. Normal dialers play a short *call-waiting beep* into
   the earpiece instead.
2. **No screen for the second call.** Only the ringtone is heard; the in-call UI
   shows nothing to answer or reject the waiting call.
3. **Missed second call not in Recents.** When the second caller hangs up
   unanswered, a missed-call *notification* appears, but no row is written to
   Recents.
4. **Two missed-call notifications.** One posted by this app, and a second one
   from Android's own phone/Telecom, even though this app is the default dialer.

## Root causes

All four come from the multi-call path being incomplete:

1. **Ringtone (issue 1).** `CallRegistry.startRingingIfNeeded` fires whenever a
   call enters `RINGING` and `ringing` was false. It calls
   `RingController.startRinging`, which always plays the full ringtone via
   `IncomingCallRinger.start`. There is no branch for "a call is already active",
   so the second call rings at full volume.

2. **No UI (issue 2/3).** The in-call screen and the native snapshot are built
   around the **primary** call. `CallRegistry.primaryCall()` ranks `ACTIVE`
   above `RINGING`, so while the first call is active the snapshot's `number`,
   `state`, and `callId` all describe the *active* call. The ringing second call
   only appears as `heldNumber` / `heldState` (which is `"ringing"`).
   `InCallScreen` renders `heldNumber` with a static `_heldBanner` that always
   says "on hold" and gives no answer/reject buttons — so there is effectively no
   UI for the waiting call.

3. **Missed not in Recents (issue 3).** `CallEventLogger` (Flutter) logs
   incoming/missed calls from the snapshot, which only ever tracks the primary
   call's `callId`. The waiting call is never the primary, so the logger never
   sees it. The native `onMissedCall` still fires (from `onCallRemoved`), which
   is why the *notification* shows but the Recents row does not.

4. **Double notification (issue 4).** `onMissedCall` posts our notification and
   immediately calls `TelecomManager.cancelMissedCallsNotification()` to clear
   the system's duplicate. The platform posts its own missed-call notification
   asynchronously, often *after* our cancel runs, so the cancel is a no-op and
   the system notification survives.

## Files to change

Native (Kotlin):
- `android/app/src/main/kotlin/in/sreerajp/contact_sphere/CallRegistry.kt`
- `android/app/src/main/kotlin/in/sreerajp/contact_sphere/ContactSphereInCallService.kt`
- `android/app/src/main/kotlin/in/sreerajp/contact_sphere/IncomingCallRinger.kt`
- `android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt`

Flutter (Dart):
- `lib/services/telecom_service.dart`
- `lib/services/call_event_logger.dart`
- `lib/screens/in_call_screen.dart`
- `lib/screens/call_history_screen.dart`

## The fix

### Issue 1 — call-waiting beep instead of the full ringtone

- **CallRegistry.kt**
  - Add `private fun hasOngoingCall(except: Call): Boolean` — true when another
    top-level call is `ACTIVE` or `HOLDING`.
  - Change the `RingController.startRinging(call)` interface method to
    `startRinging(call, callWaiting)`.
  - In `startRingingIfNeeded(c)`, pass `hasOngoingCall(c)` as `callWaiting`.

- **ContactSphereInCallService.kt**
  - `startRinging(call, callWaiting)`: still post the incoming call notification
    (so the shade shows accept/decline), but when `callWaiting` is true call a
    new `ringer.startCallWaiting()` instead of `ringer.start(...)`.

- **IncomingCallRinger.kt**
  - Add `fun startCallWaiting()` that plays `ToneGenerator.TONE_SUP_CALL_WAITING`
    on `STREAM_VOICE_CALL`, repeating every ~4s via a `Handler` until stopped.
    It is **not** gated by ringer mode (a call-waiting tone is an in-call
    supervisory tone heard in the earpiece, like other dialers). Full best-effort
    try/catch so it can never crash call handling.
  - Extend `stop()` to also cancel the repeat handler and release the
    `ToneGenerator`. Since every stop path (`stopRinging`, `showOngoingCall`,
    `onCallEnded`, `onSilenceRinger`) already calls `stop()`, the beep is cleaned
    up when the waiting call is answered, rejected, or ends.

### Issue 2/3 — show an accept/reject card for the waiting call

- **CallRegistry.kt**
  - Add `fun answerRingingCall()` — answer the top-level `RINGING` call
    (`answer(VideoProfile.STATE_AUDIO_ONLY)`); Telecom auto-holds the active one.
  - Add `fun rejectRingingCall()` — `reject()` the top-level `RINGING` call.
  - (The snapshot already carries the waiting call as `heldNumber` +
    `heldState == "ringing"`, so no new snapshot field is needed.)

- **MainActivity.kt**
  - Wire two new method-channel calls: `answerWaiting` → `answerRingingCall()`,
    `rejectWaiting` → `rejectRingingCall()`.

- **telecom_service.dart**
  - Add `Future<void> answerWaiting()` and `Future<void> rejectWaiting()`.

- **in_call_screen.dart**
  - When `_state.heldPhase == CallPhase.ringing` (a waiting call), render a
    dedicated **call-waiting card** instead of the static "on hold" banner: it
    shows the waiting caller (resolved name if we can, else the number) labelled
    "Incoming call", with **Answer** and **Decline** buttons wired to
    `answerWaiting()` / `rejectWaiting()`. The existing `_heldBanner` stays for a
    genuinely held (non-ringing) call.
  - Add a lightweight name resolve for `heldNumber` (best-effort, mirrors the
    existing `_resolveName`) so the waiting card can show a contact name.

### Issue 3 (Recents) — log the missed waiting call

Native has no DB access, so it journals the missed waiting call for the Flutter
side to drain into Recents (the same pattern already used for blocked calls).
Only *call-waiting* misses are journaled, so normal misses (already logged by the
snapshot logger) are not double-counted.

- **CallRegistry.kt**
  - Change `RingController.onMissedCall(number)` to
    `onMissedCall(number, phoneAccountId, callWaiting)`.
  - In `maybeNotifyMissed(c)` (runs before `c` is removed), compute
    `callWaiting = calls.any { it !== c }` — another live call means this missed
    call was never surfaced as the primary to the Flutter logger. Pass the SIM
    (`c.details?.accountHandle?.id`) too.

- **ContactSphereInCallService.kt**
  - `onMissedCall(number, phoneAccountId, callWaiting)`: post the notification as
    today; when `callWaiting`, also append `{number, at, phoneAccountId}` to a new
    `KEY_MISSED_EVENTS` list in the ringer prefs (capped, oldest dropped).

- **MainActivity.kt**
  - Add a `getMissedCallEvents` method-channel handler that drains and clears
    `KEY_MISSED_EVENTS` (mirrors `drainBlockedCallEvents`), returning
    `{number, at, phoneAccountId}` records oldest-first.

- **telecom_service.dart**
  - Add `drainMissedCallEvents()` mirroring `drainBlockedCallEvents()`.

- **call_event_logger.dart**
  - Add `drainMissedCalls()` that drains and writes each as a `'missed'` Recents
    row (duration 0), resolving the contact and SIM label like `_logIncoming`.
    Call it from `start()` (alongside `drainBlockedCalls`).

- **call_history_screen.dart**
  - In the load path, after `drainBlockedCalls()`, also call `drainMissedCalls()`
    so a waiting-call miss shows the next time Recents is opened/refreshed.

### Issue 4 — clear the system's duplicate missed-call notification

- **ContactSphereInCallService.kt**
  - In `onMissedCall`, besides the immediate
    `cancelSystemMissedCallNotification()`, schedule one or two delayed re-cancels
    (e.g. ~500 ms and ~2 s later via a `Handler`) to catch the system
    notification that the platform posts asynchronously after the call ends.
    Best-effort and guarded (each call already swallows `SecurityException`).

## Testing / verification

Manual on-device (moto g54), since call waiting needs a real second call:
1. Be on call A. Have B call in.
   - Expect a **beep** (no loud ringtone), and an in-call **Answer/Decline card**
     for B.
2. Answer B → A goes on hold, B active. Reject B → back to A only.
3. Let B ring out unanswered → exactly **one** missed-call notification, and a
   **missed** row for B in Recents (open Recents to trigger the drain).
4. Regression: a normal single incoming missed call still logs exactly one
   Recents row and one notification (not journaled/double-counted).

`flutter analyze` for the Dart changes. Native has no unit tests here; rely on
the on-device pass above.

## Notes / risks

- The waiting-call detection for journaling (`another live call present`) and for
  the beep (`another ACTIVE/HOLDING call`) is deliberately conservative so normal
  single calls keep their existing (working) behaviour and are never
  double-logged.
- Answering a waiting call relies on Telecom's standard auto-hold of the active
  call; no explicit hold call is issued.
