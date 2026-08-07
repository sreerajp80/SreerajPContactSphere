# Smart Redial alarm fires but the call-back screen never opens (BAL block)

**Status:** done

## The issue

The user set a 1-minute Smart Redial and nothing happened. Device
investigation (`adb dumpsys alarm`, `adb logcat`) shows the alarm **did**
fire on time:

```
ActivityTaskManager: START u0 {act=...SMART_REDIAL_FIRE ...} ... (PendingIntentRecord)
ActivityTaskManager: Background activity launch blocked! goo.gle/android-bal
  ... balRequireOptInByPendingIntentCreator: true; resultIfPiCreatorAllowsBal: BAL_BLOCK
```

The app's `MainActivity` launch (which `SmartRedialManager.armAlarm` wires up
as the alarm's operation `PendingIntent`) was silently dropped by Android's
background-activity-launch (BAL) restriction — the call was never dialed.

Cause: the app now targets SDK 36 (Android 16). Starting with Android 15, an
app that creates a `PendingIntent` no longer automatically grants it
background-activity-launch privileges when it's sent later by someone else
(here, the system `AlarmManager`) — even for `setAlarmClock()`, which used to
be exempt. The creator must now explicitly opt in per-`PendingIntent` via
`ActivityOptions.setPendingIntentCreatorBackgroundActivityStartMode(
MODE_BACKGROUND_ACTIVITY_START_ALLOWED)`, passed as the options bundle when
building the `PendingIntent`. `SmartRedialManager` doesn't do this, so on
Android 15+ the alarm always fires but the activity launch that's supposed to
place the call is always blocked.

## Fix

In `SmartRedialManager.firePendingIntent` (the "fire" `PendingIntent` used as
the alarm's operation intent — not the `showIntent` tap target, which is a
foreground user tap and isn't affected), build an `ActivityOptions` bundle
with `setPendingIntentCreatorBackgroundActivityStartMode(
MODE_BACKGROUND_ACTIVITY_START_ALLOWED)` on API 34+ (that method doesn't
exist below it — app's `minSdk` is 24) and pass it as the `options` argument
to `PendingIntent.getActivity(...)`.

## Files to change

- `android/app/src/main/kotlin/in/sreerajp/contact_sphere/SmartRedialManager.kt`

## Verification

- `flutter build apk` (or `flutter run`), install on device.
- Schedule a 1-minute Smart Redial and confirm the call is actually placed
  when the alarm fires, including with the app fully closed (swiped away).
- `adb logcat` around the fire time should no longer show "Background
  activity launch blocked" for `SMART_REDIAL_FIRE`.
