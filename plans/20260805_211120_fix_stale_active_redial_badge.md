# Fix: "Active scheduled redials" badge doesn't update after a cancel

**Status:** completed

## The issue

In SIM & calling settings, the Smart Redial card shows a green "N active"
badge for pending auto-redials. After cancelling one (via the X in the
"Active Auto-Redials" dialog, or now automatically when the contact calls
back), the badge still shows the old, too-high count until something else
happens to redraw the screen. The dialog itself is correct — it shows "No
active scheduled redials" — only the badge behind it is stale.

## Why

`lib/screens/sim_settings_screen.dart:546` reads
`SmartRedialService().activeTasks.length` once during `build()`. It never
subscribes to `SmartRedialService`'s change notifications
(`SmartRedialService` is a `ChangeNotifier` and does call `notifyListeners()`
on every schedule/cancel — see `smart_redial_service.dart`), so nothing tells
this screen to rebuild when the count changes elsewhere. This is a
pre-existing bug, not something introduced by today's native-scheduling
change — it just became visible now that cancelling actually works
reliably.

## Fix

Wrap the Smart Redial card's body in a `ListenableBuilder` (or
`AnimatedBuilder`) listening to `SmartRedialService()`, so it rebuilds
whenever the service calls `notifyListeners()` — matching the pattern
already used elsewhere in this codebase for singleton services that aren't
threaded through `Provider`.

## File to change

- `lib/screens/sim_settings_screen.dart` — `_smartRedialCard`.

## Verification

- `flutter analyze`.
- On your device: schedule a redial, cancel it from the dialog, confirm the
  badge on the settings screen updates immediately without needing to leave
  and re-enter the screen.
