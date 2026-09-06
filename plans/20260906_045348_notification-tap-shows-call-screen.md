# Tapping the Call Notification Does Not Open the Full-Screen Calling Screen

**Status:** completed

**Related:** `plans/20260905_054350_block-guards-and-incall-route-state.md`
(self-healing route flag; this plan fixes the remaining gap on the tap path)

---

## The issue

Reported: tapping the call notification (the ringing one, or the ongoing-call entry in
the shade) brings the app to the front, but the full-screen calling screen does not
appear.

### Why it happens

The notification's tap target is `activityIntent()` in
`android/app/src/main/kotlin/in/sreerajp/contact_sphere/ContactSphereInCallService.kt`.
It starts `MainActivity` with the action `SHOW_IN_CALL` and the flags
`NEW_TASK | SINGLE_TOP`.

In `android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt`, both
`onCreate` and `onNewIntent` do only one thing with that action: call
`applyShowWhenLocked(true)`. **Nothing tells the Dart side to show the calling screen.**

The calling screen is pushed only from `_onCall` in `lib/main.dart`, which runs when the
call event stream emits. So:

- **Cold start** (app process not running): the engine starts, Dart subscribes, native
  pushes the current snapshot on subscribe, and `_onCall` pushes the screen. This works.
- **Warm app, calling screen still on top of the navigator**: the tap just foregrounds
  the task and the screen is already there. This works.
- **Warm app, calling screen gone or buried**: nothing happens. Tapping the notification
  only foregrounds whatever screen the user was last on. The call state has not changed,
  so no new event is emitted and nothing re-pushes the screen.

The last case is the bug. It is easy to reach: the calling screen is a normal
`MaterialPageRoute`, so a back press pops it while the call stays live. After that the
notification tap can never bring it back for the rest of that call. The app lock screen,
or any route pushed over the calling screen, produces the same "buried" variant.

## Files to change

| File | Change |
|------|--------|
| `android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt` | On a `SHOW_IN_CALL` intent, park a pending flag and nudge Dart; expose the flag over the existing telecom method channel |
| `lib/main.dart` | Handle the nudge: bring the calling screen back to the top, pushing it again if it is gone; also drain the pending flag on cold start |
| `test/` | New widget/unit test for the "route gone / route buried" recovery, if it can be covered without the platform channel; otherwise on-device checks only |

## The fix

### 1. Native — tell Dart the user asked for the calling screen

In `MainActivity`:

- Add `private var pendingShowInCall = false`, mirroring the existing `pendingDial` /
  `pendingNotificationPayload` pattern.
- Add `private fun handleShowInCallIntent(intent: Intent?)`: when the action is
  `ContactSphereInCallService.ACTION_SHOW_IN_CALL`, set `pendingShowInCall = true` and,
  for the warm case, `runOnUiThread { telecomChannel?.invokeMethod("showInCall", null) }`.
- Call it from both `onCreate` and `onNewIntent`, next to the existing
  `applyShowWhenLocked(true)` handling (which stays as it is).
- Add a `"consumePendingShowInCall"` case to the telecom method-call handler that returns
  the flag and clears it, so a cold start can pick it up after the engine is ready.

No new channel, no new permission, no manifest change.

### 2. Dart — bring the calling screen back

In `lib/main.dart`:

- Pull the route-pushing part of `_onCall` out into a small private helper
  (`_pushInCallRoute(CallState state)`) so both paths build the route the same way.
- Add `_showInCallScreen()`:
  1. Read the live call once with `TelecomService().activeCall()`.
  2. If the phase is not ongoing, do nothing (the call ended between the tap and here).
  3. If the tracked route is active and already current, do nothing.
  4. If the tracked route is active but buried, `popUntil` back to it.
  5. Otherwise clear the stale flag/route pair and push a fresh calling screen.
- Handle `showInCall` in the existing `_telecomChannel.setMethodCallHandler` (warm path).
- In `_bootstrap` (after the first frame), call `consumePendingShowInCall` and run
  `_showInCallScreen()` when it returns true (cold path; harmless when the stream has
  already pushed the screen, because of check 3).

This reuses the existing self-healing checks, so it cannot end up with two calling
screens stacked.

## Verification

- `flutter analyze` — must stay at zero warnings.
- `flutter test` — full suite. Note: sqlite-backed test files are run one file per
  invocation (known native-assets crash when several run together).
- `cd android && ./gradlew :app:testDevDebugUnitTest` — native JVM unit tests.
- On-device checks with a `dev` build:
  1. During an active call, press back to leave the calling screen, then tap the ongoing
     call notification — the calling screen must come back.
  2. During an active call, open another screen in the app (so the calling screen is
     buried), then tap the notification — the calling screen must come back on top,
     with no duplicate below it.
  3. Incoming call with the app closed — the full-screen calling screen must still
     appear on its own, and tapping the heads-up notification must also show it.
  4. End the call while the app is in the background — no stale calling screen may be
     left behind or replay on the next launch.

## Risks and limits

- The nudge fires on every `SHOW_IN_CALL` intent, including ones already handled by the
  stream. Check 3 (route already current) makes that a no-op.
- `activeCall()` is a one-shot platform call; if it fails it returns `CallState.none` and
  we simply do nothing, which is the current behaviour.
- The tap path crosses a platform channel, so it is covered by the on-device checks
  above rather than by an automated test.
