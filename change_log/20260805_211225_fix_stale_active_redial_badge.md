# Fix: "Active scheduled redials" badge doesn't update after a cancel

Implements [plans/20260805_211120_fix_stale_active_redial_badge.md](../plans/20260805_211120_fix_stale_active_redial_badge.md).

## What was wrong

The green "N active" badge on the Smart Redial card (SIM & calling settings)
kept showing a stale, too-high count after a task was cancelled — you'd
cancel one from the "Active Auto-Redials" dialog (which correctly showed "No
active scheduled redials"), but the badge behind it still said "1 active".

`sim_settings_screen.dart` read `SmartRedialService().activeTasks.length`
once during `build()` but never subscribed to the service's change
notifications, so nothing told the settings screen to redraw when the count
changed elsewhere (a cancel, or the native auto-cancel-on-callback from the
Smart Redial fix earlier today). Pre-existing bug — just became visible now
that cancelling works reliably.

## What changed

`lib/screens/sim_settings_screen.dart`: `_smartRedialCard` now wraps its
content in a `ListenableBuilder` listening to `SmartRedialService()`, so it
rebuilds every time the service calls `notifyListeners()` (schedule, cancel,
or the native reconciliation on app resume).

## Verification

- `flutter analyze` — no issues.
- Not verified on-device in this session (user is building/installing
  themselves): please confirm the badge now updates immediately after
  cancelling a redial from the dialog, without needing to leave and re-enter
  the settings screen.
