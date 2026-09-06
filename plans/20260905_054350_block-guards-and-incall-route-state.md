# Block-Disconnect Guards, Suffix-Match Mismatch, and Stale In-Call Route State

**Status:** completed

**Follows up on:** `plans/20260905_052100_block-call-and-history.md`
(implemented in `change_log/20260905_053200_block-call-and-history.md`)

---

## Issues

### Issue 1 — A settings sync can hang up an outgoing call

`CallRegistry.disconnectBlockedCalls(blockedList, blockUnknown)` loops over **every**
live call and hangs up any that "matches". It has two problems:

1. **No direction check.** It treats a call the user *placed* the same as a call that
   *arrived*. The blocklist and the "block unknown callers" setting describe callers,
   not numbers we dial.
2. **"No number yet" counts as unknown.** When `call.details.handle` is null the code
   falls back to `blockUnknown`. An outgoing call sitting in `STATE_CONNECTING` often
   has no handle yet, so with "block unknown callers" turned on the user's own outgoing
   call is hung up.

This matters because `MainActivity.setScreeningMirror()` now calls this on **every**
mirror push, and mirror pushes are fire-and-forget from app load, settings changes and
quiet-hours syncs — not just from a deliberate "block this number" tap.

There is also no check for a call that is already ending, so a call in
`STATE_DISCONNECTING` can be disconnected a second time.

### Issue 2 — Dart and native disagree on how numbers match

`FlaggedNumberRepository._disconnectIfRunning()` treats two numbers as the same when one
is a **7**-digit-or-longer suffix of the other. The native side
(`ContactSphereCallScreeningService.sameNumber`) uses **9** (`MIN_SUFFIX_DIGITS`).

Seven digits is too short: real mobile numbers can share their last 7 digits, so the
Dart path can hang up a call to the wrong person. The two sides must agree.

### Issue 3 — The full-screen calling screen stops appearing until the app is restarted

Reported symptom: after some time, dialing a number connects the call and shows the
ongoing-call notification, but the full-screen calling screen never appears. Clearing
the app from recents (killing the process) restores normal behaviour.

That "fixed by killing the process" behaviour points at in-process state, not at the
native bridge: the native side had clearly emitted the event, because the ongoing
notification is posted from the same `notifyChange()` that pushes it.

In `_onCall` the pair `_inCallRouteShown` / `_inCallRoute` tracks the calling screen.
The screen is only pushed when `_inCallRouteShown` is false. If that flag is ever left
true while no calling screen is actually on display — for example the route is still on
the navigator stack but buried under a route pushed on top of it — then every later call
takes the "already showing" path and pushes nothing. Nothing resets the flag except a
pop of that route or a call-ended event, so the app stays stuck until it is restarted.

The fix is to stop trusting the flag on its own and check the route's real state before
deciding the screen is already up.

---

## Files to change

| File | Change |
|------|--------|
| `android/app/src/main/kotlin/in/sreerajp/contact_sphere/CallRegistry.kt` | Guard `disconnectBlockedCalls` by direction and call state |
| `lib/repositories/flagged_number_repository.dart` | Match numbers the same way native does (9 digits) |
| `lib/main.dart` | Make the calling-screen route check self-healing |
| `test/block_call_disconnect_test.dart` | Cover the corrected suffix rule |
| `android/app/src/test/kotlin/in/sreerajp/contact_sphere/CallScreeningMatchingTest.kt` | Keep as-is; add a case pinning the 9-digit rule |

---

## The fix

### 1. `CallRegistry.disconnectBlockedCalls`

- Skip any call that is **not incoming**, using the existing private `isIncoming(call)`
  helper (it reads `Call.Details.getCallDirection` on API 29+ and falls back to
  "was ever seen ringing").
- Skip any call already in `STATE_DISCONNECTING` or `STATE_DISCONNECTED`.
- Keep the rest of the behaviour: reject a ringing call, disconnect an established one.

With the direction guard in place the "no digits means unknown" fallback becomes correct
on its own, because it can then only ever apply to a call that arrived.

### 2. `FlaggedNumberRepository._disconnectIfRunning`

- Add a private constant `_kMinSuffixDigits = 9` with a comment naming
  `ContactSphereCallScreeningService.MIN_SUFFIX_DIGITS` as the value it mirrors.
- Replace the two `>= 7` checks with the same shorter/longer suffix rule the native
  `sameNumber` uses, so both sides accept and reject exactly the same pairs.

This only makes matching *stricter*, so it cannot introduce a new wrong disconnect.

### 3. `_onCall` in `lib/main.dart`

- Treat the calling screen as "already showing" only when the tracked route is still
  really on the navigator (`_inCallRoute?.isActive == true`), not merely when the
  boolean says so.
- When the flag is set but the route is gone or inactive, clear both and push a fresh
  calling screen instead of silently doing nothing.

This keeps the existing behaviour in the normal case and recovers by itself in the
stuck case, so the screen can no longer go missing until the app is restarted.

---

## Verification

- `flutter analyze` — must stay at zero warnings.
- `flutter test` — full suite, plus the new/updated cases.
  Note: sqlite-backed test files are run one file per invocation (a known
  native-assets crash when several run together).
- `cd android && ./gradlew :app:testDevDebugUnitTest` — native JVM unit tests.
- On-device check after installing a `dev` build:
  1. Place an outgoing call with "block unknown callers" **on** — the call must connect
     and stay connected, and the full-screen calling screen must appear.
  2. Receive a call from a blocked number — it must still be rejected and recorded in
     block history.
  3. Place several calls in a row without restarting the app — the calling screen must
     appear every time.

---

## Risks and limits

- The direction guard means a mirror push no longer ends an **outgoing** call to a
  number that was just blocked. This is intentional, and the deliberate
  "block this number now" path is unaffected: `FlaggedNumberRepository.add()` still
  calls `_disconnectIfRunning()` for that case.
- `CallRegistry` depends on Telecom types that are awkward to construct in a JVM unit
  test, so the direction guard is covered by the on-device checks above rather than by
  an automated test.
- Issue 3 is diagnosed from the code plus the "killing the process fixes it" evidence;
  it was not reproduced under a debugger. The change is defensive and safe either way,
  but if the screen goes missing again we should capture device logs to confirm.
