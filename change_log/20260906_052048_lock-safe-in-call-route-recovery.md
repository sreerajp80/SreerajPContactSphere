# Change Log — Lock-Safe In-Call Route Recovery

**Implements:** `plans/20260906_051226_lock-safe-in-call-route-recovery.md`

**Date:** 2026-09-06

---

## Why

An audit of the two previous call-screen changes found that the app lock could be
dismissed without any PIN or biometric check.

`Navigator.popUntil` removes routes with `Navigator.pop()`, and `pop()` does not consult
`PopScope`. The app-lock screen sets `PopScope(canPop: false)`, but that only blocks the
back gesture — it does not stop a `popUntil` running above it. Two clean-ups in
`lib/main.dart` used a `popUntil` that walked straight past the lock.

The path a user could hit:

1. On a live call, open **Keypad** or **Add call** — both push a route over the calling
   screen, so the calling route is buried.
2. Background the app and return. The lock gate only skips when the calling route is the
   current one, so it pushed the lock and cleared its own "lock on resume" flag.
3. Tap the ongoing-call notification, or let the call end. The `popUntil` removed the
   lock along with the buried routes, and nothing re-locked the app afterwards.

---

## What changed

### `lib/main.dart`

- **New top-level `inCallPopStop(inCallRoute, lockRoute)`** — one shared stop rule for
  both clean-up pops. It stops at the calling route, at the app-lock route when one is
  up, and at the first route as a backstop. Marked `@visibleForTesting` so the rule can
  be pinned by a test. Its doc comment states plainly why stopping at the lock is a
  security rule and not a nicety.
- **New `_lockRoute` field** — holds the pushed app-lock route. `_maybeLock` now builds
  the route into a local, stores it, pushes it, and clears the field in a `finally`
  right where `_lockShown` is reset, so the two can never drift apart.
- **New `_showInCallAfterUnlock` field** — `_showInCallScreen` now returns immediately
  when the lock is on screen, parking the request instead of touching the navigator.
  `_maybeLock` drains it as soon as the user authenticates, so the calling screen comes
  back *after* the unlock rather than through it.
- **Both pop sites now use the shared rule** — the call-ended clean-up in `_onCall` and
  the notification-tap recovery in `_showInCallScreen`.
- **Two stale comments corrected.** The call-ended path no longer claims the pop "never
  runs over the lock screen" (that was the bug). The recovery path no longer blames a
  back press for losing the calling screen — `InCallScreen` has had `PopScope(canPop:
  false)` for a while, so back cannot pop it; the real causes are the Keypad and
  Add-call routes it pushes over itself, and a route that is gone entirely.

### `android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt`

- Folded a duplicated intent check. `onCreate` and `onNewIntent` each tested for the
  `ACTION_SHOW_IN_CALL` action to call `applyShowWhenLocked(true)` and then called
  `handleShowInCallIntent`, which tested the same action again. `applyShowWhenLocked` now
  lives inside `handleShowInCallIntent`, after its own check, and the two separate blocks
  are gone. Same call order, no behaviour change.

### `test/in_call_route_recovery_test.dart` (new)

Four widget tests driving a real `Navigator`:

- The pop stops at the app lock: the lock stays active and visible, and the routes below
  it are untouched. This is the regression guard for the bug above.
- With no lock up, the pop still unburies the calling screen — the existing recovery is
  unchanged.
- A lock route that was never pushed cannot match, so the rule falls back to the calling
  route.
- With no calling route on the stack, `isFirst` acts as the backstop.

---

## Behaviour change worth knowing

Tapping the call notification while the app lock is showing no longer jumps straight to
the calling screen. The lock holds and asks for the PIN or biometric first; the calling
screen appears on top the moment authentication succeeds. The call itself stays
controllable throughout from the notification's own buttons and the device lock-screen
call controls, so nothing becomes unreachable.

---

## Verification

| Check | Result |
|-------|--------|
| `flutter analyze` | No issues found |
| `flutter test` | 469 passed, 1 skipped (up from 465 — four new tests) |
| `flutter test test/in_call_route_recovery_test.dart` | 4 passed |
| `cd android && ./gradlew :app:testDevDebugUnitTest` | BUILD SUCCESSFUL |
| `dart format` | Clean |

The on-device checks listed in the plan (lock held on a notification tap during a call,
calling screen restored after unlock, unchanged behaviour with the lock off, and the
cold-start tap) still need to be run on a `dev` build.

No version bump was made: the pending `15.17.9+92` bump from the previous change has not
been released yet, so this fix rides along with it.
