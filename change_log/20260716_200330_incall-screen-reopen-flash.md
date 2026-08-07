# Fix in-call screen flashing for a split second on reopen

Implements plan
[`plans/20260716_200330_incall-screen-reopen-flash.md`](../plans/20260716_200330_incall-screen-reopen-flash.md).

## Problem

After answering a call over the lock screen and then the call ending, reopening
the app briefly showed the in-call ("caller") screen for that contact before it
disappeared.

## Cause

In `lib/main.dart` `_onCall`, the call-ended branch chose between an instant
route removal (when backgrounded) and an **animated** pop (`popUntil`, when
`resumed`). In the answer-over-lock case, native `MainActivity.onCallChanged`
calls `moveTaskToBack(true)` and delivers the call-ended event in the same UI
callback; the "paused" lifecycle message reaches Dart only afterwards. So
`_onCall` still read `lifecycleState == resumed`, took the animated branch, and
the app then backgrounded mid-animation. With no frames rendering, the frozen
exit animation replayed on the next launch — the flash.

## Change

- `lib/main.dart` — rewrote the `else if (!state.phase.isOngoing &&
  _inCallRouteShown)` branch in `_onCall`. It no longer reads the (racy)
  lifecycle state. Instead it:
  1. Clears any routes the in-call screen pushed above itself (Add-call dialer,
     dialogs, the reject-with-message sheet) only when the in-call route is not
     the current route — a no-op in the backgrounded / over-lock-screen case.
  2. Removes the in-call route with `nav.removeRoute(route)` — instant, no exit
     animation, and frame-independent, so nothing is left to replay on reopen.

No native changes were made.

## Behaviour notes

- Ending a call from the foreground in-call screen now closes it instantly
  (no slide-away), matching stock dialers.
- Because removal is now surgical (`removeRoute`) rather than
  `popUntil(isFirst)`, the user returns to whatever screen they were on below
  the in-call route (e.g. the contact detail they called from) instead of the
  home shell.

## Verification

- `flutter analyze lib/main.dart` → "No issues found!".
- On-device verification steps are listed in the plan (answer-over-lock end,
  in-app call end, Add-call teardown). Not yet run on the moto g54.
