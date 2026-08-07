# Smart Redial: clear the schedule entry as soon as it fires or is cancelled

**Status:** completed

## The issue

After yesterday's change, scheduling/firing/cancelling all happen natively
(`SmartRedialManager.kt`), which is what makes them reliable even with the
app killed. But the Dart-side copy of the task list — the one "Active
scheduled redials" reads to show the badge and the list — only re-checks
itself against the native truth once, right when the app cold-starts
(`SmartRedialService.init()`). If the app process is already running when a
reminder fires (the alarm auto-dials while the app is only backgrounded, not
killed) or gets auto-cancelled (the contact calls back while the app is
running), nothing tells the Dart side to notice — so the entry keeps showing
as "active" in Settings until the app is fully closed and reopened.

## Fix

Add a `refresh()` method to `SmartRedialService` that re-checks the Dart
task list against native (the same check `init()` already does once), but
callable any time. Call it from two points that already exist in
`lib/main.dart`:
- Whenever the app comes back to the foreground (`didChangeAppLifecycleState`,
  the `resumed` case) — catches a reminder that auto-cancelled (call-back)
  or auto-fired while the app was backgrounded.
- Right after the app places an auto-redial call it was just nudged about
  (`_collectPendingDial`, the `autoCall` branch) — catches the firing case
  immediately, without waiting for the next resume.

## Files to change

- `lib/services/smart_redial_service.dart` — add public `refresh()`.
- `lib/main.dart` — call it from the two points above.

## Verification

- `flutter analyze` / `flutter test`.
- On your device: schedule a short redial, background the app (don't kill
  it) until it fires, then reopen Settings and confirm the entry/badge is
  already gone.
