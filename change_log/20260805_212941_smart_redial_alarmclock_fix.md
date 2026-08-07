# Smart Redial: switch to setAlarmClock so it fires with the app fully killed

Implements [plans/20260805_212641_smart_redial_alarmclock_fix.md](../plans/20260805_212641_smart_redial_alarmclock_fix.md).

## What was wrong

With the app fully closed, the scheduled auto-call still wasn't happening.

`SmartRedialManager.armAlarm()` was using
`setExactAndAllowWhileIdle`/`setAndAllowWhileIdle`, whose fired
`PendingIntent` launches `MainActivity` directly. Android 10+ blocks apps
from starting an Activity while they have no foreground presence at all
(exactly the "app fully killed" case this feature needs to survive) unless
the launch goes through one of a specific, documented list of trusted paths
— a plain alarm-fired activity launch isn't on that list, so Android quietly
dropped it. The alarm still fired on schedule; nothing visibly happened.

## What changed

`android/app/src/main/kotlin/in/sreerajp/contact_sphere/SmartRedialManager.kt`:
`armAlarm()` now uses `AlarmManager.setAlarmClock()` instead — the
documented API for reliably waking the device and launching an Activity from
a fully background app (the same one real alarm-clock apps use), which is
explicitly exempted from the background-activity-launch restriction, is
immune to Doze deferral, and needs no extra permission. Added a small
`showIntent` (opens the app) as `setAlarmClock` requires one — shown if the
user taps the alarm-clock icon Android now displays in the status bar while
a redial is pending (standard OS behaviour for this API).

`android/app/src/main/AndroidManifest.xml`: removed the `SCHEDULE_EXACT_ALARM`
permission — no longer needed, since `setAlarmClock` doesn't require it. The
`canScheduleExactAlarms()` fallback branch in `armAlarm()` was removed along
with it.

## Verification

- `flutter analyze` — no issues.
- `./gradlew :app:compileDevDebugKotlin` — compiles clean.
- Not verified on-device in this session (user builds/installs themselves):
  please confirm the call is placed automatically after fully closing the
  app (swiped away from Recents, not just backgrounded) and waiting out a
  short scheduled delay.
