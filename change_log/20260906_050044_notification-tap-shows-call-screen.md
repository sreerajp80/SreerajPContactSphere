# Tapping the Call Notification Now Opens the Calling Screen

**Implements:** `plans/20260906_045348_notification-tap-shows-call-screen.md`

---

## What was wrong

The call notification's tap target starts `MainActivity` with the action
`SHOW_IN_CALL`, but the activity did nothing with it except allow showing over the
lock screen. The full-screen calling screen is pushed only when the call event stream
emits, and a tap does not change the call state. So when the calling screen had been
popped (a back press during a live call) or buried under another route, tapping the
notification only brought the app forward on whatever screen the user was last on, and
the calling screen never came back for the rest of that call.

## What changed

### `android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt`

- New field `pendingShowInCall`, following the existing `pendingDial` pattern.
- New `handleShowInCallIntent(intent)`, called from both `onCreate` and `onNewIntent`:
  on a `SHOW_IN_CALL` intent it sets the flag and invokes `showInCall` on the telecom
  method channel. The invoke passes a result callback; Dart answering it is what clears
  the flag, so a cold start (no Dart handler yet) leaves the flag for Dart to drain.
- New `consumePendingShowInCall` method-channel case that returns the flag and clears it.

### `lib/services/telecom_service.dart`

- New `consumePendingShowInCall()` wrapper over that method.

### `lib/main.dart`

- The calling-screen push in `_onCall` moved into a new `_pushInCallRoute(nav, state)`
  so both paths build the route identically and keep the tracking pair in step.
- New `_showInCallScreen()`: reads the live call once; does nothing if it has ended or
  if the calling screen is already on top; `popUntil`s back to it when it is buried;
  otherwise clears the stale tracking pair and pushes a fresh calling screen.
- The telecom method-call handler now handles `showInCall` (warm path).
- `_bootstrap` drains `consumePendingShowInCall()` after the first frame and calls
  `_showInCallScreen()` when it is true (cold path). Harmless when the call event stream
  has already shown the screen, because of the "already on top" check.

No manifest, permission, channel-name or schema changes.

## Verification

- `flutter analyze` — no issues found.
- `flutter test` — all 465 tests pass (1 skipped, as before).
- `cd android && ./gradlew :app:testDevDebugUnitTest` — build successful, tests pass.

## Not covered by automated tests

The tap path crosses a platform channel and ends in the full in-call screen, so the
recovery is left to the on-device checks listed in the plan:

1. Back out of the calling screen during a live call, then tap the ongoing-call
   notification — the calling screen must come back.
2. Bury the calling screen under another screen, then tap the notification — it must
   come back on top with no duplicate below it.
3. Incoming call with the app closed — the full-screen calling screen must still appear
   on its own, and the heads-up tap must also show it.
4. End a call while the app is in the background — no stale calling screen may replay
   on the next launch.
