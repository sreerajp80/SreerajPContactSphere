# Call ended during call-waiting never reaches Recents

**Status:** completed

## The issue

Reported case: a call is going on. A second call comes in. The user hangs up the
first call and answers the new one. The first call never shows up in Recents.

### Why it happens

The native bridge tracks *every* live call, but the snapshot it sends to Flutter
describes only the **primary** call
([CallRegistry.kt:496-558](android/app/src/main/kotlin/in/sreerajp/contact_sphere/CallRegistry.kt#L496-L558)).
`primaryCall()` picks the lowest-priority-number call:
`active(0) → dialing(1) → connecting(2) → ringing(3) → selecting(4) → holding(5) → other(6)`
([CallRegistry.kt:305-318](android/app/src/main/kotlin/in/sreerajp/contact_sphere/CallRegistry.kt#L305-L318)).

`CallEventLogger` builds its Recents row from that single primary snapshot. It
accumulates number / SIM / direction / connect-time for the call whose `callId`
it is tracking, and writes one row when it sees that call end
([call_event_logger.dart:130-183](lib/services/call_event_logger.dart#L130-L183)).

Walk the reported case through it:

1. Call A is active, B is ringing → A has priority 0, B has 3, so **A stays
   primary**. The logger is accumulating A (`_callId = A`).
2. User hangs up A. A goes to `DISCONNECTED` → its priority drops to 6, while B
   is still ringing at 3. The very next snapshot therefore describes **B**, not
   A's disconnect.
3. In `_onEvent`, `state.hasCall` is true and `state.callId != _callId`, so it
   hits `if (_callId != null && state.callId != _callId) _reset();`
   ([call_event_logger.dart:134](lib/services/call_event_logger.dart#L134)).
   Everything accumulated for A is thrown away, `_hadCall` is cleared, and the
   logger starts tracking B. **A's row is never written.**
4. The native missed-call journal does not rescue it either: A was answered, so
   `isMissedCall()` returns false and nothing is parked
   ([CallRegistry.kt:265-270](android/app/src/main/kotlin/in/sreerajp/contact_sphere/CallRegistry.kt#L265-L270)).

So A disappears completely.

This is not limited to the exact reported sequence. Any call that stops being the
primary before the logger sees it end is lost. The other common case: answer the
waiting call B, so A goes on hold (priority 5, B active at 0). B is now primary.
Whenever A ends, the logger is watching B and never records A.

Outgoing calls are not affected — `CallService.placeCall` writes a provisional
Recents row up front, so the row already exists before any of this.

Not affected either: the *missed* call-waiting case (native already journals it,
see `drainMissedCalls`).

## The fix

Stop trying to reconstruct call history from a primary-only snapshot. The native
side is the only layer that sees every call, so let it report each incoming call
when it ends, and reuse the journal + drain machinery that already exists for
call-waiting missed calls.

1. **`CallRegistry.kt`** — in `onCallRemoved`, before the tracking sets are
   cleared, classify the removed call. When it is an **incoming** call that was
   never the primary at end time (i.e. another call was live alongside it),
   report it through the `RingController` with what Recents needs: number,
   phone account id, whether it ever went active, its `connectTimeMillis`, and
   the disconnect time. Generalise the current `onMissedCall(callWaiting)` hook
   into one "ended incoming call" report so answered-then-ended calls are covered
   too, not just misses. Keep posting the missed-call notification only for real
   misses (unchanged `isMissedCall` logic).
2. **`ContactSphereInCallService.kt`** — extend `journalMissedCall` into a
   journal entry that also carries `wasActive`, `connectTimeMillis` and the
   computed duration, keeping the same bounded-list + clear-on-read behaviour.
3. **`TelecomService`** — widen the drained-event model to carry the new fields
   (`wasActive`, `durationSeconds`).
4. **`CallEventLogger`** — rename/extend `drainMissedCalls` to drain *ended
   incoming calls*: write `'incoming'` rows with the real duration when
   `wasActive`, `'missed'` rows with duration 0 otherwise. Drain on start and on
   the Recents screen load (as today), and additionally right after a call ends
   so the row appears without waiting for the next app start.
5. **`call_event_logger.dart` `_onEvent`** — keep the existing primary-tracking
   path for the ordinary single-call case, but make the dedupe robust: rows
   written from the journal and rows written from the snapshot must not
   double-log the same physical call. Simplest guard: the native side journals a
   call **only** when it ended with other calls present (never for a lone call),
   which is exactly the set `_onEvent` cannot handle. Keep `_lastLoggedId` for
   the flap case.

### Files to change

- `android/app/src/main/kotlin/in/sreerajp/contact_sphere/CallRegistry.kt`
- `android/app/src/main/kotlin/in/sreerajp/contact_sphere/ContactSphereInCallService.kt`
- `lib/services/telecom_service.dart`
- `lib/services/call_event_logger.dart`
- `lib/screens/call_history_screen.dart` (drain call rename, if it calls it)
- `change_log/<ts>_call-waiting-lost-recents-row.md` (after implementation)

### How to verify

On device, with ContactSphere as default dialer:

1. Call in → answer → second call in → hang up first → answer second. Both calls
   must appear in Recents: the first as `incoming` with its real duration, the
   second as `incoming`.
2. Call in → answer → second call in → answer it (first goes on hold) → end both.
   Both rows present.
3. Plain single incoming call answered, and plain single missed call: exactly one
   row each (no double-log regression).

## Alternative considered (rejected)

A one-line Flutter fix: in `_onEvent`, log the tracked call before `_reset()`
when `callId` changes. It fixes the exact reported case, but leaves the held-call
variant (case 2 above) still broken, because a held call is never tracked in the
first place. Not worth doing on its own.
