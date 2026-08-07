# Missed-call "Call back" opens the app, add "Dismiss", and leave the app after a call it launched

**Status:** completed

## The issue

On the missed-call notification our app posts:

1. **Tapping "Call back" does not bring the app forward.** The notification / lock
   screen stays on screen; the user has to clear it by hand before the SIM-selection
   sheet (or dialer) appears. It should invoke the app screen straight away.

2. **There is no "Dismiss" button.** The user wants a way to clear the notification
   without calling back.

3. **The app's own screen is left showing after a call the user never opened the app
   for.** When the app is not in the foreground and a call comes in (missed *or*
   answered), after the call ends the app's contacts/home screen is left on display.
   The user didn't launch the app or dial from it, so it should not be left on screen.

### Why "Call back" fails to foreground

The "Call back" action uses a **broadcast** `PendingIntent` →
`CallActionReceiver.handleCallBack()` → `context.startActivity(...)`. Since Android 12
the OS **blocks activity starts made from a broadcast receiver (or service) that was
triggered by a notification action** — the "notification trampoline" restriction. So
`startActivity` is silently suppressed: the app never comes to the front, and the shade /
lock screen is left up. (The notification **body** tap works because it already uses a
direct `getActivity` PendingIntent — `missedContentIntent`.)

The fix is to launch the activity **directly** from the action's PendingIntent
(`getActivity`), not through a broadcast trampoline.

### Keeping the confused-deputy protection (security finding #6)

`MainActivity` is exported (it is the launcher + holds the `tel:` filters), so we must
not let an arbitrary app fire a "place this call now" intent at it — that was the hole
finding #6 closed. Today trust comes from `PendingCallback` being writable only by the
**non-exported** `CallActionReceiver`. Moving to a direct `getActivity` means the intent
reaches the exported `MainActivity`, so a crafted external intent could otherwise forge a
trusted call-back.

We defend this with a **random one-shot token (nonce)**:

- When the notification is built, we generate a 64-bit `SecureRandom` token, store it in
  `PendingCallback` keyed to the number, and put the same token in the "Call back"
  `getActivity` intent's extras.
- `MainActivity` treats the call-back as a trusted auto-call **only if** the token in the
  intent matches a currently-armed token in `PendingCallback` (consumed one-shot). An
  external app cannot guess a live 64-bit token, so it cannot auto-dial. An unmatched
  token is ignored (no call placed).

This preserves the exact trust guarantee finding #6 established, while allowing the direct
`getActivity` launch that actually foregrounds the app.

### Why the app is left on screen after an incoming call (issue 3)

As the default dialer we own the in-call UI, so `ContactSphereInCallService.onCallAdded()`
calls `launchInCallUi()` — starting `MainActivity` — for **every** call, incoming ones
included, even on a cold start. When the call ends, nothing sends the activity back, so
`MainActivity` is left in the foreground showing the app's home (contacts) screen. The
only existing "return to back" logic is a narrow keyguard case in
`MainActivity.onCallChanged`: `if (callArrivedOverKeyguard && isKeyguardLocked()) moveTaskToBack()`.
So when the phone is unlocked (or was unlocked during the call) the app stays on screen.

Fix: remember whether the call **brought the app to the front** (our in-call UI was **not**
already visible when the call arrived). When the last call ends, if the call brought the
app up, `moveTaskToBack()` so the app leaves the screen and the user returns to where they
were — regardless of lock state. A call placed from inside the app (UI already visible) is
unaffected and keeps the app on screen as today.

Capturing the pre-call visibility must happen the instant the call arrives (in
`CallRegistry.onCallAdded`, before `launchInCallUi` flips visibility). `CallRegistry`
already tracks `uiVisible` (from `MainActivity.onResume/onPause`), so `!uiVisible` at the
first call of a session is exactly this signal.

## Files to change

1. **`android/app/src/main/kotlin/in/sreerajp/contact_sphere/PendingCallback.kt`**
   - Replace the single `number` field with a small **token → number** map (bounded).
   - `arm(number): Long` — generate a `SecureRandom` token, store it, return it.
   - `take(token): String?` — return + remove the number iff the token matches (one-shot).
   - `drop(token)` — remove a token without dialing (used by "Dismiss").
   - Update the doc comment to describe the token-based trust anchor.

2. **`android/app/src/main/kotlin/in/sreerajp/contact_sphere/ContactSphereInCallService.kt`**
   - `callBackAction(...)`: build via `PendingIntent.getActivity(...)` targeting
     `MainActivity` with a private action `MainActivity.ACTION_TRUSTED_CALL_BACK`, and
     extras `EXTRA_NUMBER`, `EXTRA_TOKEN` (from `PendingCallback.arm(number)`), and
     `EXTRA_NOTIFICATION_ID`. Flags: `NEW_TASK | SINGLE_TOP`, immutable.
   - Add a new **`dismissAction(notifId)`**: a broadcast `PendingIntent` to
     `CallActionReceiver` with `ACTION_DISMISS_MISSED` + `EXTRA_NOTIFICATION_ID`
     (cancel-only, so no trampoline problem). Add it to the missed-call notification.

3. **`android/app/src/main/kotlin/in/sreerajp/contact_sphere/CallActionReceiver.kt`**
   - Remove the `ACTION_CALL_BACK` branch + `handleCallBack()` (the call-back no longer
     goes through the receiver).
   - Add an `ACTION_DISMISS_MISSED` branch: cancel the notification id and
     `PendingCallback.drop(token)` if a token extra is present.
   - Keep the in-call action buttons (hangup/answer/decline/mute/speaker) untouched.

4. **`android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt`**
   - Add `ACTION_TRUSTED_CALL_BACK` (+ `EXTRA_NUMBER`, `EXTRA_TOKEN`,
     `EXTRA_NOTIFICATION_ID`) constants.
   - New `handleTrustedCallbackIntent(intent)`, called from `onCreate` / `onNewIntent`:
     validate the token via `PendingCallback.take(token)`; on match set
     `pendingDial = number`, `pendingDialAutoCall = true`, cancel the notification id, and
     nudge Dart (`dialReceived`). On no match, ignore.
   - When handling a trusted call-back while the keyguard is locked, make the app usable:
     `setShowWhenLocked(true)` + `setTurnScreenOn(true)` and
     `KeyguardManager.requestDismissKeyguard(...)`, so the SIM-picker sheet is visible /
     interactive instead of sitting behind the lock screen.
   - Remove the now-unused `drainTrustedCallback()` / `nudgeTrustedCallback()` (or repoint
     them at the new token path); simplify `getPendingDial` to just return `pendingDial`.
   - The Dart contract (`getPendingDial` → `{number, autoCall}`) is **unchanged**, so
     `lib/main.dart` needs no edit.
   - **Issue 3:** In `onCallChanged`, on the call-end edge (`!hasCall && hadCall`),
     `moveTaskToBack(true)` when `CallRegistry.didCallBringUiToFront()` is true (this now
     subsumes and replaces the old keyguard-only condition). Clear `callArrivedOverKeyguard`.

5. **`android/app/src/main/kotlin/in/sreerajp/contact_sphere/CallRegistry.kt`** (issue 3)
   - Add `callBroughtUiToFront` captured in `onCallAdded` only on the **first** call of a
     session (`calls` was empty): `callBroughtUiToFront = !uiVisible`. This runs before the
     service's `launchInCallUi()`, so `uiVisible` still reflects the pre-call state.
   - Add `fun didCallBringUiToFront(): Boolean`. Recomputed on every new session's first
     call, so no explicit reset is needed (a later app-dialed call sees `uiVisible == true`).

6. **`android/app/src/main/AndroidManifest.xml`**
   - Update the `ACTION_CALL` intent-filter comment: the trusted call-back now flows
     through the token-guarded `getActivity` path into `MainActivity` (not the receiver).
     No structural manifest change (the receiver stays non-exported for the in-call
     buttons + Dismiss).

7. **`docs/architecture.md`** (small doc touch)
   - Update the missed-call / trusted-call-back description to the token-guarded
     `getActivity` path, mention the Dismiss action, and note the "return to back after a
     call the app launched" behavior.

## Testing / risks

- Build: `./gradlew :app:compileDevDebugKotlin`, `flutter analyze`.
- On device (moto g54): miss a call → notification shows **Call back** + **Dismiss**.
  - Tap **Call back** from the lock screen → app comes forward immediately; SIM picker
    (or default-SIM call) runs; call is placed and logged. No need to clear the shade.
  - Tap **Dismiss** → notification clears, no call placed, no app launch.
  - Tap the notification **body** → app opens (unchanged).
- Issue 3, with the app **not** in the foreground:
  - Incoming call, let it miss → after it ends the app is **not** left on screen (returns
    to the previous app / home / lock screen).
  - Incoming call, answer then hang up → same: app is not left on screen afterwards.
  - Dial **from inside the app** → after the call the app stays on screen as before.
- Regression to guard: an external `ACTION_CALL` `tel:` intent must still only pre-fill
  the dialer (never auto-dial) — the token guard keeps finding #6 closed.
- Risk: keyguard-dismiss UX differs slightly across OEMs; the `getActivity` foregrounding
  is the core fix and works regardless.
- Risk (issue 3): confirm the post-call feedback sheet only shows for app-dialed calls, so
  `moveTaskToBack` on an incoming call doesn't background a just-shown sheet. Also confirm
  Recents logging (which runs off the event stream) still completes after `moveTaskToBack`
  (the process stays alive, only backgrounded).
