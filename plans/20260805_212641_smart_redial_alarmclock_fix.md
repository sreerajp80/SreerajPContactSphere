# Smart Redial: switch to setAlarmClock so it fires with the app fully killed

**Status:** completed

## The issue

With the app fully closed (not just backgrounded), the scheduled auto-call
still doesn't happen.

## Why

`SmartRedialManager.armAlarm()` currently schedules with
`AlarmManager.setExactAndAllowWhileIdle()` (or its inexact fallback), firing
a `PendingIntent` that launches `MainActivity` directly to place the call.

Android 10+ blocks apps from starting an Activity while they have no
foreground presence, unless the launch goes through one of a specific,
documented list of trusted paths (a notification tap, a foreground service,
etc.). A plain alarm-fired "launch this Activity" `PendingIntent` is **not**
on that list, so once the app is genuinely killed, Android quietly drops the
launch — the alarm still fires on schedule, but nothing visibly happens.
This matches what you're seeing: it can look like it's working while the app
still has some presence, and silently fails once it's truly closed.

There is a specific API built for exactly this case — "wake the device and
reliably show an Activity even though the app is fully in the background" —
which is what real alarm-clock apps use: `AlarmManager.setAlarmClock()`. An
alarm scheduled this way is explicitly exempted from the background-activity
-launch restriction (and from Doze deferral), and needs no extra permission.

## Fix

In `SmartRedialManager.kt`, replace `setExactAndAllowWhileIdle` /
`setAndAllowWhileIdle` with `AlarmManager.setAlarmClock(AlarmClockInfo(fireAtMillis,
showIntent), operation)`, where `operation` is the existing "launch
MainActivity with the token" `PendingIntent` and `showIntent` is a plain
"open the app" `PendingIntent` (shown if the user taps the small alarm-clock
icon Android displays in the status bar while a Smart Redial is pending —
standard, expected behaviour for this API, the same icon a real alarm app
would show).

Side effect: since `setAlarmClock()` doesn't need the exact-alarm
permission, the `SCHEDULE_EXACT_ALARM` manifest permission and the
`canScheduleExactAlarms()` fallback branch added earlier are no longer
needed and will be removed for simplicity.

## Files to change

- `android/app/src/main/kotlin/in/sreerajp/contact_sphere/SmartRedialManager.kt`
- `android/app/src/main/AndroidManifest.xml` (drop `SCHEDULE_EXACT_ALARM`)

## Note on the status bar icon

While a redial is pending, Android will show its standard small alarm-clock
icon in the status bar (tapping it opens the app) — this is normal,
system-level behaviour for any app using this scheduling API, not something
specific to this app, and it's the tradeoff for the OS reliably launching
the app to place the call even when fully closed.

## Verification

- `flutter analyze` and a native Kotlin compile check
  (`./gradlew :app:compileDevDebugKotlin`), same as before.
- On your device: schedule a short redial, fully close the app (swipe it
  away from Recents, not just background it), and confirm the call is
  placed automatically when the timer elapses.
