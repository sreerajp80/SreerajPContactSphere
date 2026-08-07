# Smart Redial: the app now calls back automatically, and stops if they call first

Implements [plans/20260805_205201_native_auto_dial_smart_redial.md](../plans/20260805_205201_native_auto_dial_smart_redial.md).

## What was wrong

1. When a Smart Redial delay elapsed, the app only posted a notification
   ("Tap to dial") — it never placed the call by itself.
2. The check for "did this contact call back before the timer went off?"
   only ran while the app process was alive (a Dart stream listener). Since
   Android routinely kills the app in the background during the 1-30 minute
   wait, a callback often wasn't noticed, and the reminder still fired later.

Both came from the same root cause: the whole feature lived in Flutter/Dart,
which isn't reliably running in the background for the length of the delay.

## What changed

Scheduling, firing, and the callback check now all live in native Android
code, which keeps running via the OS's own alarm and call-screening systems
even when the app process is dead.

**New:** `android/app/src/main/kotlin/in/sreerajp/contact_sphere/SmartRedialManager.kt`
— persists each scheduled task (id, a one-shot token, number, display name,
fire time) to its own settings file, arms an `AlarmManager` alarm
(`setExactAndAllowWhileIdle`, falling back to the approximate
`setAndAllowWhileIdle` if the "Alarms & reminders" permission isn't granted
on Android 13+) that launches `MainActivity` directly at the scheduled time,
and exposes cancel/reschedule/lookup for the rest of the app.

**`MainActivity.kt`:** handles the alarm firing (`ACTION_SMART_REDIAL_FIRE`)
by checking the intent's token against `SmartRedialManager`'s on-disk record
— the same trusted, token-guarded shape the missed-call notification's "Call
back" already uses (`PendingCallback`), except this token survives the app
process being killed, since it's stored on disk rather than only in memory.
On a match, it feeds the number into the exact same "place this call now"
path the missed-call callback uses — no tap needed. Also adds three methods
to the existing `contact_sphere/telecom` channel: `scheduleSmartRedial`,
`cancelSmartRedial`, `getPendingSmartRedialIds`.

**`ContactSphereCallScreeningService.kt`:** every incoming call is now also
checked against pending Smart Redial tasks (digit-suffix match, same rule the
blocked/spam list already uses) and cancels a match before the phone even
rings — this is the part that fixes "the reminder still fires after they
call back," and it works even when the app isn't running, since this service
is bound natively by the OS.

**`EmergencyBootReceiver.kt`:** also re-arms any still-pending Smart Redial
alarms after a reboot (Android clears alarms on reboot the same way it clears
notifications); anything that was due while the phone was off is dropped
instead of firing late.

**`AndroidManifest.xml`:** added the `SCHEDULE_EXACT_ALARM` permission.

**`lib/services/smart_redial_service.dart`:** no longer uses
`flutter_local_notifications`/`zonedSchedule`. `scheduleAutoRedial` and
`cancelTask` now call the new native methods (via `TelecomService`) instead;
the Dart-side task list (used for the Settings screen's "Active scheduled
redials") is now reconciled against the native pending-task list on `init()`,
so a task the native side already fired or auto-cancelled doesn't linger as
"active" in the UI. Dropped `notificationId` (no longer meaningful) and the
in-process call-event listener (native handles the callback check now,
reliably, including while the app is dead).

**`lib/services/telecom_service.dart`:** added `scheduleSmartRedial`,
`cancelSmartRedial`, `pendingSmartRedialIds` wrapping the new channel methods.

**`pubspec.yaml`:** removed the `flutter_local_notifications` dependency (it
was only used by this feature). `timezone` stays — the pre-call summary
feature also uses it.

**`test/smart_redial_service_test.dart`:** updated for the dropped
`notificationId` field and the now-`async` `cancelTask`.

**`docs/features.md`:** updated the Smart Redial bullet to describe the new
automatic-call behaviour and the native, always-on callback check.

## Not changed

- The "Reach Me" SMS option, the delay choices, and the on/off setting are
  untouched.
- The missed-call notification's own token system (`PendingCallback.kt`) was
  not modified — Smart Redial uses its own disk-backed token store
  (`SmartRedialManager`) for the reasons explained in the plan (its token
  must survive the app process being killed for up to 30 minutes, not just
  the few seconds a notification tap takes).

## Verification

- `flutter analyze` — no issues.
- `flutter test test/smart_redial_service_test.dart` and
  `test/contact_sync_service_test.dart` — all pass.
- `./gradlew :app:compileDevDebugKotlin` — compiles clean (new/changed Kotlin
  files only produce the build's pre-existing, unrelated deprecation
  warnings).
- Not installed/run on a device in this session, at the user's request (they
  will build and test on-device themselves). Still to confirm on-device: the
  automatic call firing on schedule while the app is killed, and the reminder
  being suppressed when the contact calls back first.
