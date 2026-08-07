# In-call screen flashes for a split second when reopening the app

**Status:** completed

## The issue

Steps to reproduce:

1. Phone is locked.
2. A call comes in and the user answers it over the lock screen.
3. The call ends (still locked / app in background).
4. Later, the user opens the app.
5. The in-call ("caller") screen for that contact appears for a split second,
   then disappears, revealing the normal app.

The stale caller screen should never show — the call is already over.

## Root cause

When a call ends, the Flutter side removes the in-call route in
[`lib/main.dart`](../lib/main.dart) `_onCall`, at the branch
`else if (!state.phase.isOngoing && _inCallRouteShown)` (around lines 439-452).
It picks between two ways to remove the route:

- If the app is **not** resumed (backgrounded): `nav.removeRoute(route)` — an
  instant removal with **no exit animation**.
- If the app **is** resumed: `nav.popUntil((r) => r.isFirst)` — an **animated**
  pop.

The comment there already knows the danger: an animated pop that starts while
the app is going to the background freezes mid-transition (no frames render) and
then replays its exit animation on the next launch — the "stale calling screen"
flash.

The bug is that the `resumed` check is **unreliable** in the answer-over-lock
case. On the native side, when the call ends,
`MainActivity.onCallChanged` (see
[`MainActivity.kt`](../android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt)
~lines 411-430) calls `moveTaskToBack(true)` to send the app to the background,
and then, in the **same** UI callback, delivers the "call ended" event to
Flutter via `eventSink?.success(null)`.

`moveTaskToBack` causes Android to pause the activity only *after* this callback
returns, so the platform → Dart "paused" lifecycle message is queued **after**
the call-ended event. Dart therefore runs `_onCall(none)` while
`WidgetsBinding.instance.lifecycleState` is still `resumed`, takes the
**animated** `popUntil` branch, and the app then backgrounds mid-animation. The
frozen animation replays on the next launch — exactly the reported flash.

In short: at the moment the call-end event is handled, the lifecycle state does
not yet reflect that the app is already being sent to the background, so the
"backgrounded → remove instantly" guard is skipped.

(The related native mitigations — `setRecentsScreenshotEnabled(false)` during a
call and `moveTaskToBack` on end — are already in place and are not the source
of this remaining flash, which is the Flutter route animation replaying.)

## Files to change

1. `lib/main.dart` — the `_onCall` call-ended branch only.

No native changes are needed.

## The plan

Stop depending on the (racy) lifecycle read when the call ends. Always tear the
in-call route down **without** an exit animation, because an animated removal is
never safe once the app may be backgrounding, and an instant close of the call
screen when a call ends is standard, expected behaviour anyway.

Rewrite the `else if (!state.phase.isOngoing && _inCallRouteShown)` branch to:

- Clear anything the in-call screen pushed **above** itself first (the Add-call
  dialer, a confirm dialog, the reject-with-message sheet) — only when the
  in-call route is not the current route. In the backgrounded / over-lock-screen
  case nothing is stacked above, so this is a no-op there and never animates.
- Then remove the in-call route itself with `nav.removeRoute(route)` — instant,
  no exit animation, and frame-independent (it completes even while the app is
  backgrounded), so there is nothing left to replay on reopen.

Concretely, replace the current `resumed`-based conditional:

```dart
final resumed =
    WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
if (!resumed && route != null) {
  nav.removeRoute(route);
} else {
  nav.popUntil((r) => r.isFirst);
}
```

with an always-instant teardown:

```dart
if (route != null) {
  // Clear anything the in-call screen pushed above itself (Add-call dialer,
  // a dialog / sheet). Only needed when the in-call route isn't on top; when
  // backgrounded nothing is stacked above, so this never runs / animates there.
  if (route.isActive && !route.isCurrent) {
    nav.popUntil((r) => r == route || r.isFirst);
  }
  // Remove the in-call route WITHOUT an exit animation. An animated pop started
  // while the app is being sent to the background (call answered over the lock
  // screen, then ended -> task moved to back) freezes mid-transition and
  // replays on the next launch -- the "stale calling screen" flash. removeRoute
  // completes instantly and frame-independently, so nothing is left to replay.
  // The lifecycle state is unreliable here: native moves the task to back
  // concurrently with this end event, so we may still read `resumed`.
  nav.removeRoute(route);
}
```

### Behaviour notes / trade-offs

- Ending a call while looking at the in-call screen in the foreground now closes
  the screen instantly instead of sliding it away. This matches stock dialers
  and is the expected feel.
- Using `removeRoute(route)` (instead of the old `popUntil(isFirst)`) also
  **preserves** any screen the user was on *below* the in-call route (e.g. they
  tapped Call from a contact's detail page): they return to that screen rather
  than being dumped to the home shell. This is an improvement, not a regression.

## Risks

- Low. The change is confined to one branch of `_onCall`. The instant-removal
  primitive (`removeRoute`) is already used and trusted for the backgrounded
  case today; this only extends it to the racy "looks resumed but actually
  backgrounding" case.

## Verification

- `flutter analyze` stays clean for `lib/main.dart`.
- On the moto g54 (build + install a flavored debug APK):
  1. Lock the phone, receive and **answer** a call, then end it while still
     locked. Reopen the app — confirm the caller screen no longer flashes.
  2. Place a call from inside the app, then end it from the in-call screen —
     confirm the screen closes cleanly and returns to the previous screen.
  3. During an in-app call, open "Add call", then have the other side hang up —
     confirm both the dialer and the in-call screen close (no orphaned dialer).
