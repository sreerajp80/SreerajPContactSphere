# Smart Redial: restore the exact-alarm permission and ask for it up front

**Status:** completed

## The issue

Confirmed from the device log while testing: scheduling a redial throws
immediately —

```
java.lang.SecurityException: Caller in.sreerajp.contact_sphere needs to hold
android.permission.SCHEDULE_EXACT_ALARM or android.permission.USE_EXACT_ALARM
to set exact alarms.
    at android.app.AlarmManager.setAlarmClock(AlarmManager.java:914)
```

The earlier fix (switching to `setAlarmClock` so the call-launch survives the
app being killed) was correct, but I also removed the `SCHEDULE_EXACT_ALARM`
manifest permission at the same time, on the mistaken assumption
`setAlarmClock` never needs it. It does, on this device/Android version. So
every schedule attempt since has thrown this exception and armed nothing —
the task still gets recorded and shown in the UI (that part doesn't touch
`AlarmManager`), but nothing was ever actually scheduled with the OS. This
explains every symptom since: no call ever fires, and the entry never clears
because there was never a live alarm to fire or reconcile against.

Separately: even with the permission declared in the manifest, Android
13+ treats it as a special, user-togglable permission (Settings → Apps →
ContactSphere → "Alarms & reminders") — declaring it doesn't grant it. The
user has to turn it on once.

## Fix

1. `AndroidManifest.xml` — re-add `<uses-permission
   android:name="android.permission.SCHEDULE_EXACT_ALARM"/>`.
2. `SmartRedialManager.kt` — add `hasExactAlarmPermission(context)` and
   `requestExactAlarmPermission(context)` (opens the system's "Alarms &
   reminders" settings screen for this app,
   `Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM`). `armAlarm()` also wraps
   the `setAlarmClock` call in a try/catch so a future permission revocation
   degrades to "silently not armed" instead of crashing the method-channel
   call.
3. `MainActivity.kt` — two new channel methods wrapping the above.
4. `lib/services/telecom_service.dart` — Dart wrappers.
5. `lib/widgets/smart_redial_sheet.dart` — before scheduling, check the
   permission; if not granted, show an explanation and a button that opens
   the settings screen, instead of silently scheduling something that will
   never fire.

## Files to change

- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/main/kotlin/in/sreerajp/contact_sphere/SmartRedialManager.kt`
- `android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt`
- `lib/services/telecom_service.dart`
- `lib/widgets/smart_redial_sheet.dart`

## Verification

- `flutter analyze` and `./gradlew :app:compileDevDebugKotlin`.
- On your device: after installing, go to Settings → Apps → ContactSphere →
  "Alarms & reminders" and confirm it now needs to be turned on there (the
  app should prompt for this the first time you try to schedule a redial if
  it's off). With it on, schedule a short redial, fully close the app, and
  confirm the call now actually fires.
