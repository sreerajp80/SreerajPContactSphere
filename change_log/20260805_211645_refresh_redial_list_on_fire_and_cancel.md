# Smart Redial: clear the schedule entry as soon as it fires or is cancelled

Implements [plans/20260805_211423_refresh_redial_list_on_fire_and_cancel.md](../plans/20260805_211423_refresh_redial_list_on_fire_and_cancel.md).

## What was wrong

Scheduling/firing/cancelling all happen natively now, but the Dart-side copy
of the task list (what "Active scheduled redials" reads) only checked itself
against native truth once, at cold start (`SmartRedialService.init()`). If
the app process was still alive when a reminder fired (backgrounded, not
killed) or got auto-cancelled (contact called back while the app was
running), nothing told the Dart side — so the entry kept showing as active
until the app was fully closed and reopened.

## What changed

`lib/services/smart_redial_service.dart`: added a public `refresh()` that
re-runs the same native-reconcile check `init()` does once, but callable any
time.

`lib/main.dart`: calls `SmartRedialService().refresh()` from two places:
- `didChangeAppLifecycleState`, on `resumed` — catches a reminder that fired
  or auto-cancelled while the app was merely backgrounded.
- `_collectPendingDial`, right after placing an auto-redial's call — clears
  the entry immediately when the firing happens with the app already in the
  foreground, without waiting for a resume event.

## Verification

- `flutter analyze` — no issues.
- `flutter test test/smart_redial_service_test.dart` — passes.
- Not verified on-device in this session (user builds/installs themselves):
  please confirm that backgrounding (not killing) the app until a short
  reminder fires, then reopening Settings, shows the entry already gone.
