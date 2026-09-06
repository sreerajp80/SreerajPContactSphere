# App Lock Can Be Force-Dismissed by the In-Call Route Recovery

**Status:** completed

**Follows up on:**
`plans/20260905_054350_block-guards-and-incall-route-state.md` and
`plans/20260906_045348_notification-tap-shows-call-screen.md`
(this plan fixes a hole found while auditing both)

---

## Issues

### Issue 1 — The app lock screen can be popped without authenticating (main issue)

`Navigator.popUntil` removes routes with `Navigator.pop()`. `pop()` does **not**
consult `PopScope`. So a route that sets `canPop: false` is still thrown away when a
`popUntil` above it runs. The app lock screen is exactly such a route
(`lib/screens/app_lock_screen.dart`, `PopScope(canPop: false)`).

Two places pop past it:

- `_showInCallScreen` in `lib/main.dart` — `nav.popUntil((r) => r == route || r.isFirst)`
  when the calling screen is buried (added by the notification-tap plan).
- `_onCall` in `lib/main.dart` — the same predicate when a call ends while the calling
  screen is buried (older code; its comment claims this "never runs over the lock
  screen", which is not true, see Issue 2).

**How a user reaches it**

1. During a live call, tap **Keypad** or **Add call** on the calling screen. Both push a
   route over the calling screen (`lib/screens/in_call_screen.dart`), so the calling
   route is now buried.
2. Background the app and come back. `_maybeLock` only skips when the calling route is
   `isCurrent`. It is buried, so the check passes and the lock screen is pushed.
   `_shouldLockOnResume` is set to false at that moment.
3. Tap the ongoing-call notification (or simply let the call end).
   `popUntil` runs and removes the lock screen along with the buried routes.

The app is now open with no PIN and no biometric check, and it stays open: the
"lock on resume" flag was already cleared, so nothing re-locks it for the rest of the
session. This defeats the App lock feature and the protection it gives the secret
contacts area.

### Issue 2 — Two comments state things that are no longer true

- `_showInCallScreen` says the calling screen is lost because "a back press during a
  live call pops the route". `InCallScreen` has set `PopScope(canPop: false)` for a
  while now, so back cannot pop it. The real ways it gets buried are the Keypad and
  Add-call routes.
- The `_onCall` end path says that when backgrounded or over the lock screen "nothing is
  stacked above, so this never runs". Issue 1 is the counter-example.

Wrong reasoning in comments is how the next change re-introduces the same bug, so both
should be corrected.

### Issue 3 — Duplicated intent check in `MainActivity`

`onCreate` and `onNewIntent` both test
`intent.action == ContactSphereInCallService.ACTION_SHOW_IN_CALL` to call
`applyShowWhenLocked(true)`, and then call `handleShowInCallIntent(intent)`, which tests
the very same action again. Cosmetic only — no behaviour change — but it invites the two
checks to drift apart.

---

## Files to change

| File | Change |
|------|--------|
| `lib/main.dart` | Track the lock route; stop both `popUntil` calls at it; show the calling screen after the unlock instead of through it; fix the two stale comments |
| `android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt` | Fold the duplicate action check into `handleShowInCallIntent` |
| `test/in_call_route_recovery_test.dart` (new) | Widget test proving the lock route survives the recovery pop |

---

## The fix

### 1. Remember the lock route — `lib/main.dart`

Next to the existing `_lockShown` / `_locking` fields, add:

```dart
/// The pushed app-lock route, kept so route clean-ups never pop past it.
Route<bool>? _lockRoute;
```

In `_maybeLock`, build the route into a local variable, store it in `_lockRoute`, push
it, and clear the field in the same place `_lockShown` is reset (both on the normal
unlock path and if the push completes any other way).

### 2. One shared stop rule for both pops — `lib/main.dart`

Add a small top-level helper so the rule lives in one place and can be tested:

```dart
/// Stop rule for the pops that clear routes stacked over the calling screen.
/// Stops at the calling route itself, at the app-lock route (popping past it would
/// dismiss the lock without authenticating — `pop` ignores `PopScope`), and at the
/// first route as a backstop.
@visibleForTesting
bool Function(Route<dynamic>) inCallPopStop(
  Route<dynamic> inCallRoute,
  Route<dynamic>? lockRoute,
) => (r) => r == inCallRoute || (lockRoute != null && r == lockRoute) || r.isFirst;
```

Use it at both call sites, in place of the current inline predicate:

- `_onCall`'s end path.
- `_showInCallScreen`'s "buried" branch.

### 3. Do not fight the lock — `lib/main.dart`

In `_showInCallScreen`, before anything else: if the lock is on screen
(`_lockShown` is true), do not touch the navigator. Park the request instead:

```dart
bool _showInCallAfterUnlock = false;
```

Set it and return. In `_maybeLock`, right after the `await nav.push(...)` returns and
`_lockShown` is set back to false, drain it: if it is set, clear it and call
`_showInCallScreen()`.

Effect: tapping the call notification while the app is locked brings the app forward and
leaves the lock in place; the moment the user authenticates, the calling screen comes
back on top by itself. The call is never hidden *behind* the lock without a way back.

The `_onCall` end path needs no equivalent: with the stop rule from step 2 it simply
leaves the lock alone and still removes the calling route underneath it via the existing
`nav.removeRoute(route)`, which targets one route directly and does not walk the stack.

### 4. Correct the two comments — `lib/main.dart`

- In `_showInCallScreen`, replace "a back press during a live call pops the route" with
  the real cause: the calling screen is buried by the Keypad and Add-call routes it
  pushes over itself, and the route can also be gone after a process-level reset.
- In `_onCall`, drop the "never runs over the lock screen" claim and say instead that the
  pop deliberately stops at the lock route.

### 5. Fold the duplicate check — `MainActivity.kt`

Move `applyShowWhenLocked(true)` inside `handleShowInCallIntent`, after its own action
check, and delete the two separate `if (intent.action == ...ACTION_SHOW_IN_CALL)` blocks
in `onCreate` and `onNewIntent`. The call order stays the same, so behaviour does not
change.

### 6. New test — `test/in_call_route_recovery_test.dart`

A widget test with a real `Navigator`:

- Pump a `MaterialApp`, push a stand-in calling route, then a stand-in "Add call" route,
  then a stand-in lock route.
- Run `nav.popUntil(inCallPopStop(inCallRoute, lockRoute))`.
- Assert the lock route is still on screen and still active.
- Second case: with `lockRoute` null, the same pop unburies the calling route as before,
  so the existing recovery still works.

This pins the security rule against a future refactor of the predicate.

---

## Verification

- `flutter analyze` — must stay at zero warnings.
- `flutter test` — full suite, including the new file.
  Note: sqlite-backed test files are run one file per invocation (a known
  native-assets crash when several run together).
- `cd android && ./gradlew :app:testDevDebugUnitTest` — native JVM unit tests.
- On-device checks with a `dev` build, App lock turned **on**:
  1. On a live call, tap **Add call**, background the app, return so the lock appears,
     then tap the ongoing-call notification — the lock must stay up and demand the
     PIN/biometric. After unlocking, the calling screen must come back on top.
  2. Same setup, but end the call from the other side while the lock is showing — the
     lock must stay up, and no calling screen may be left behind once unlocked.
  3. With App lock **off**, repeat the notification-tap checks from the previous plan —
     buried and popped calling screens must still come back, with no duplicate.
  4. Tap the ongoing-call notification with the app closed — the calling screen must
     still appear on a cold start.

---

## Risks and limits

- Behaviour change: tapping the call notification while the app lock is showing no
  longer jumps straight to the calling screen. This is the point of the fix — the call
  can still be answered and ended from the notification's own buttons and from the
  lock-screen call controls, so nothing becomes unreachable.
- If the lock route is somehow left set after it is gone, the stop rule simply never
  matches it and the pop falls back to `r.isFirst`, which is the current behaviour. The
  field is cleared in the same place `_lockShown` is, so the two cannot drift.
- The navigator behaviour is covered by the new widget test; the notification tap itself
  crosses a platform channel, so it stays covered by the on-device checks above.
