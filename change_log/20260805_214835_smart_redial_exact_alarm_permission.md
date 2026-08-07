# Smart Redial: restore the exact-alarm permission and ask for it up front

Implements [plans/20260805_214410_smart_redial_exact_alarm_permission.md](../plans/20260805_214410_smart_redial_exact_alarm_permission.md).

## What was wrong

Confirmed on-device via logcat: every schedule attempt threw immediately —

```
java.lang.SecurityException: Caller in.sreerajp.contact_sphere needs to hold
android.permission.SCHEDULE_EXACT_ALARM or android.permission.USE_EXACT_ALARM
to set exact alarms.
    at android.app.AlarmManager.setAlarmClock(AlarmManager.java:914)
```

The earlier switch to `setAlarmClock` (so the auto-call launch survives the
app being killed) was the right fix, but the same change also dropped the
`SCHEDULE_EXACT_ALARM` manifest permission on the mistaken assumption
`setAlarmClock` never needs it — it does, on this device/Android version.
Every `scheduleSmartRedial` call since has silently thrown and armed
nothing: the task still got recorded and shown in the UI (that part never
touches `AlarmManager`), so it looked scheduled, but there was never a live
OS alarm behind it.

## What changed

`AndroidManifest.xml`: re-added `SCHEDULE_EXACT_ALARM`.

`SmartRedialManager.kt`: added `hasExactAlarmPermission()` /
`requestExactAlarmPermission()` (opens the system's "Alarms & reminders"
settings screen for the app — there's no runtime request dialog for this
permission on Android 13+). `armAlarm()` now also wraps `setAlarmClock` in a
try/catch, so a permission revoked between the check and the call degrades
to "not armed" instead of crashing the method-channel call.

`MainActivity.kt`: two new channel methods wrapping the above.

`lib/services/telecom_service.dart`: `hasExactAlarmPermission()` /
`requestExactAlarmPermission()` wrappers (the former reports `true` off
Android, where there's no such gate).

`lib/widgets/smart_redial_sheet.dart`: "Auto-Retry" now checks the
permission first. If it's missing, it shows a dialog explaining why and
offers to open the settings screen, instead of silently scheduling a
reminder that would never fire.

## Verification

- `flutter analyze` — no issues.
- `./gradlew :app:compileDevDebugKotlin` — compiles clean.
- `flutter test test/smart_redial_service_test.dart` — passes.
- Not verified on-device in this session (user builds/installs themselves):
  after installing, the first "Auto-Retry" attempt should prompt for
  "Alarms & reminders" if it isn't already granted; once granted, please
  confirm a scheduled call now actually fires with the app fully closed.
