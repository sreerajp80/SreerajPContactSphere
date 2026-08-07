# Fix Smart Redial: callbacks now fire reliably and auto-cancel on call-back

Implements [plans/20260805_070247_fix_smart_redial_scheduling.md](../plans/20260805_070247_fix_smart_redial_scheduling.md).

## What was wrong

Smart Redial (Settings → SIM & calling → "Smart Redial & Reach Me") scheduled
its reminder with a plain in-memory Dart `Timer` and only showed an immediate
notification once that timer fired. If Android killed the app in the
background before the delay elapsed — which it routinely does — the timer
was destroyed and the reminder never fired. The scheduled-task list was also
only in memory, so it disappeared from the UI on any app restart. Nothing
listened for the contact calling back, so a schedule never auto-cancelled.

## What changed

`lib/services/smart_redial_service.dart`:
- Reminders are now scheduled with `flutter_local_notifications`'
  `zonedSchedule` (`AndroidScheduleMode.inexactAllowWhileIdle`) instead of a
  Dart `Timer`. Android's own alarm manager now owns the fire time, so the
  reminder fires even if the app process has been killed. This mode needs no
  new permission.
- The task list is now persisted to `SharedPreferences` on every schedule/
  cancel, and reloaded on startup (`SmartRedialService.init()`), so the
  "Active scheduled redials" list and cancel action stay correct across app
  restarts. A task whose fire time already passed while the app was closed
  is reconciled as completed (the OS notification already handled it).
- Each task now carries a fixed `notificationId` (set once at creation) so
  cancelling still targets the right OS-level alarm after a restart.
- Added an incoming-call listener (`TelecomService().callEvents`) that
  compares the caller's number against every pending task using the
  existing `PhoneNormalizer.sameNumber()` helper, and auto-cancels any task
  for a number that just called back.

`lib/main.dart`: calls `SmartRedialService().init()` during app bootstrap so
persisted tasks are restored and the auto-cancel listener starts for the
whole app session, not just while a Smart Redial screen is open.

`docs/features.md`: updated the Smart Redial bullet — it previously
documented "lost if the app is killed" as a known limitation; that's now
fixed, and the auto-cancel-on-call-back behavior is documented.

`test/smart_redial_service_test.dart`: updated for the new required
`notificationId` constructor parameter.

## Not changed

- Viewing scheduled callbacks (Settings → SIM & calling → "Smart Redial &
  Reach Me" → "Active scheduled redials") and manually cancelling one (the
  cancel button in that list) were already working and needed no change.
- The unrelated `ReminderRepository` "nudge" gap (`docs/known-gaps.md:210-211`)
  is a separate, already-tracked issue and was left untouched.

## Verification

- `flutter analyze` — no issues.
- `flutter test test/smart_redial_service_test.dart` — passes (schedule,
  cancel, and constants tests).
- Not verified on-device (no connected device in this session): the actual
  "notification survives app kill" behavior and the auto-cancel-on-call-back
  behavior should be confirmed on a real phone before considering this
  fully verified.
