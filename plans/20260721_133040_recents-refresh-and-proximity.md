# Recents auto-refresh, pull-to-refresh, and proximity blank fixes

**Status:** completed

This plan covers three separate issues reported after placing calls from the Recents
screen. ContactSphere is confirmed to be the **default phone app** (its own in-call UI
shows during a call), which matters for issues 1 and 3.

---

## Issue 1 — A call placed from Recents does not show when the call ends

### What happens
Call a contact from the Recents tab. When the call ends, the just-placed call is not
shown in the list. Switching to another tab and back makes it appear.

### Why
Because ContactSphere is the default dialer, the in-call screen is a Flutter route that
`main.dart` (`_onCall`) pushes on top of the home shell. During the call the app is
**never sent to the background**, so no `resumed` lifecycle event fires. When the call
ends, `_onCall` removes that route with `nav.removeRoute(...)`. A `removeRoute` does
**not** notify the screen underneath through the normal route hooks
(`RouteObserver.didPopNext`), so Recents has no reliable "I am visible again" signal to
reload. Switching tabs works only because that path calls `reload()` directly
(`home_shell.dart` → `_recentsKey.currentState?.reload()`).

### Fix
Two small, low-risk changes so Recents reloads the moment it is shown again — the same
effect the tab switch has today:

1. **RouteObserver reload (covers normal navigation).** Add a shared
   `RouteObserver<ModalRoute<void>>`, register it in `MaterialApp.navigatorObservers`
   in `main.dart`, and make `CallHistoryScreenState` a `RouteAware` subscriber. Reload in
   `didPopNext()`. This refreshes Recents whenever a screen opened *from* Recents (contact
   detail, add-contact, the dialer) is popped back to it.

2. **Explicit reload when the in-call route closes (covers the reported case).** In
   `main.dart._onCall`, at the point the in-call route is removed on call-end, fire
   `CallLogEvents.instance.notifyCallLogged()` (scheduled after the current frame). Every
   open history view already listens to `CallLogEvents` and reloads, so Recents
   re-queries the instant the in-call screen closes — exactly like the tab-switch
   workaround, but automatic.

*Note:* needs on-device confirmation, since the exact timing depends on the default-dialer
in-call flow.

---

## Issue 2 — Add pull-to-refresh to the Recents screen

### What happens
There is no way to manually refresh Recents by pulling the list down.

### Fix
Wrap the Recents `ListView.builder` in a `RefreshIndicator`. Its `onRefresh` resets paging
(`_loadedCount = _pageSize`), awaits `_load()`, and kicks `_syncDeviceCallLog()` so a pull
both re-reads the local history and pulls anything new from the device call log. Give the
list `AlwaysScrollableScrollPhysics` so the pull gesture works even when there are only a
few rows.

---

## Issue 3 — Proximity screen blank no longer works during a call

### What happens
Holding the phone to the ear during a call no longer blanks the screen. It worked in an
earlier build. Reported symptom: the screen **never** goes dark.

### Why (most likely)
ContactSphere is the default dialer and its in-call UI updates live, which means
`MainActivity.onCallChanged` is running and does call `applyProximityLock(true)` for an
active earpiece call. The wake-lock code itself is correct and `WAKE_LOCK` is granted.

The strong suspect is a conflict introduced with the later lock-screen in-call work:
`applyShowWhenLocked(hasCall)` calls `setTurnScreenOn(true)` (and on older APIs adds
`FLAG_TURN_SCREEN_ON`) and keeps it asserted for the **whole** call. On many OEM builds an
activity that asserts "turn the screen on" defeats `PROXIMITY_SCREEN_OFF_WAKE_LOCK`, so the
proximity sensor can never blank the display. This matches "worked before, not now".

### Fix
Separate the two concerns in the native code:
- **Show over the lock screen** (`setShowWhenLocked(true)`) must stay on for the whole call
  so the in-call UI can appear over the keyguard — keep as is.
- **Turn the screen on** (`setTurnScreenOn(true)` / `FLAG_TURN_SCREEN_ON`) is only needed as
  a one-shot pulse to wake the device when a call first arrives (and when the screen-on
  receiver re-shows the UI). After that pulse, clear it (`setTurnScreenOn(false)` / clear
  the flag) so the proximity wake lock can blank the display.

*Note:* native change; must be verified on-device (screen blanks at the ear and wakes back
on when the phone is moved away). On-device logging via the Dart VM service (see project
notes) can confirm `applyProximityLock` is entered and the lock is held.

---

## Files to change
- `lib/main.dart` — register the RouteObserver; fire `notifyCallLogged()` when the in-call
  route is removed on call-end.
- `lib/screens/call_history_screen.dart` — RouteAware reload on `didPopNext`; wrap the list
  in a `RefreshIndicator`; always-scrollable physics.
- `lib/utils/app_route_observer.dart` *(new, small)* — the shared `RouteObserver` instance
  (or keep it as a top-level in `main.dart` if preferred).
- `android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt` — stop holding
  `setTurnScreenOn(true)` / `FLAG_TURN_SCREEN_ON` for the whole call so proximity can blank.

## Testing
- Issue 1: place a call from Recents; on end, the call row appears without switching tabs.
- Issue 2: pull the Recents list down; it refreshes.
- Issue 3: during an earpiece call, the screen blanks near the ear and wakes when moved away;
  speaker calls and ringing do **not** blank.
