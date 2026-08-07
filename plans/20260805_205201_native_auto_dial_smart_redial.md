# Smart Redial: call automatically, and stop the reminder firing after a callback

**Status:** completed

## The issue

Two bugs, both in the "Smart Redial" feature (the bottom sheet that appears after
an unanswered call, offering "Auto-Retry in N min"):

1. **No call is ever placed.** Today, when the timer elapses, the app only posts
   an Android notification ("Time to call back... Tap to dial") — it does not
   place the call by itself. You confirmed you want the app to actually place
   the call automatically, without you tapping anything.

2. **The reminder still goes off even after the person calls you back.** The
   code that is supposed to cancel the reminder when they call back only runs
   while the app process is alive (it listens on a Dart stream). If Android has
   killed the app in the background — which it does routinely, and is exactly
   the scenario this feature needs to survive — that listener isn't running, so
   the callback is never noticed and the reminder still fires later.

Both bugs share the same root cause: the whole feature currently lives in the
Flutter/Dart side of the app, which is not reliably running in the background.
Android can and does kill the app process while a 1-30 minute timer is
counting down. The fix is to move the scheduling, the auto-cancel check, and
the actual call-placing into native Android code, which keeps running (via the
OS's own alarm and call-screening systems) even when the app process is dead.

## How the fix works

The app already has a proven, security-reviewed way to auto-place a call from
a "cold" app process: the missed-call notification's "Call back" button. It
works like this (see `PendingCallback.kt`, `MainActivity.kt`):
- A one-shot secret token is created for the number.
- Tapping "Call back" launches `MainActivity` carrying that token.
- `MainActivity` only auto-dials if the token matches — so no other app can
  forge a "call this number now" request and steal the app's call permission.

Smart Redial will use the same idea, but the token must survive the app being
killed (the missed-call flow's token lives only in memory, which is fine
there because it is normally consumed within seconds; Smart Redial needs it to
survive up to 30 minutes of being killed), so it will be stored on disk
instead of in memory.

**Scheduling and firing the call (fixes bug 1):**
- When you tap "Auto-Retry in N min", the app tells native Android code to
  remember the task (number, name, fire time, a fresh one-shot token) in a
  small on-device settings file, and to set an Android alarm for that time
  using `AlarmManager`, pointing directly at `MainActivity` with the token
  attached.
- Android's alarm system keeps this armed even if the app is killed, and
  (via `setExactAndAllowWhileIdle`, falling back to a slightly less precise
  mode if the "Alarms & reminders" permission isn't granted on newer Android
  versions) fires it close to on time even while the phone is idle/dozing.
- When it fires, Android launches `MainActivity` with the token.
  `MainActivity` checks the token against the on-disk record, and if it
  matches, places the call automatically — reusing the exact same "auto-call"
  path the missed-call "Call back" button already uses. No tap needed.
- The Settings screen's "Active scheduled redials" list still works the same
  way from your side; it now also double-checks with native Android on
  startup so it can't show a task as "active" when it has actually already
  fired or been auto-cancelled.

**Cancelling on callback (fixes bug 2):**
- The app already has a native component that inspects every incoming call
  *before it rings* — the call-screening service that also handles the
  blocked/spam number lists. It runs natively and works even when the Flutter
  side of the app isn't running.
- This will be extended: on every incoming call, it also checks whether the
  caller's number matches any pending Smart Redial task, and if so cancels
  that task's Android alarm and deletes the on-disk record — before the phone
  even rings. This works no matter whether the app is open, backgrounded, or
  killed, which is what today's Dart-only listener could not guarantee.

**After a reboot:** Android clears alarms on reboot, so the existing
"re-post the emergency-info shortcut after reboot" native code will also
re-arm any Smart Redial tasks that are still in the future (any that were due
to fire while the phone was off are simply dropped, so you never get a
surprise call for a very stale reminder).

## Files to change

- `android/app/src/main/kotlin/in/sreerajp/contact_sphere/SmartRedialManager.kt`
  (new) — owns the on-disk task list, arms/cancels the Android alarm, and the
  one-shot token check.
- `android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt` —
  handles the alarm-fired intent (checks the token, auto-dials via the
  existing pending-dial path), and adds three small methods the Flutter side
  calls: schedule, cancel, and "which tasks are still pending".
- `android/app/src/main/kotlin/in/sreerajp/contact_sphere/ContactSphereCallScreeningService.kt`
  — on every incoming call, also cancels any matching pending Smart Redial task.
- `android/app/src/main/kotlin/in/sreerajp/contact_sphere/EmergencyBootReceiver.kt`
  — also re-arms not-yet-fired Smart Redial tasks after a reboot (it already
  runs on every boot for the emergency-info shortcut).
- `android/app/src/main/AndroidManifest.xml` — adds the "schedule exact alarms"
  permission (auto-granted on the versions that need it; on the newest Android
  versions the app falls back to an approximate alarm if it isn't granted, the
  same best-effort approach already used for notifications elsewhere in this
  app).
- `lib/services/smart_redial_service.dart` — stops using
  `flutter_local_notifications` for this feature; instead calls the three new
  native methods above. Drops the now-unnecessary `notificationId` field and
  the in-app "listen for a callback while running" logic (native handles it
  now, reliably).
- `pubspec.yaml` — removes the `flutter_local_notifications` dependency (only
  used by this feature; the `timezone` package stays, it's also used by the
  pre-call summary feature).
- `test/smart_redial_service_test.dart` — updated for the changed
  `SmartRedialTask` fields and the new native calls.
- `docs/features.md` — updates the Smart Redial bullet to describe the new,
  automatic behaviour.

## Not changing

- The "Reach Me" SMS option (Option 2 in the sheet) is unaffected.
- The delay choices (1/3/5/10/15/30 min) and the on/off setting are unaffected.
- The missed-call "Call back" notification and its existing token system
  (`PendingCallback.kt`) are not modified — Smart Redial gets its own,
  disk-backed token store alongside it, for the reasons explained above.

## Verification

- `flutter analyze` and `flutter test`.
- On your connected device (adb): schedule a short (1-2 min) auto-retry after
  an unanswered call, then background/kill the app, and confirm the call is
  placed automatically at the scheduled time.
- Separately: schedule a redial, then call back from that number within the
  window (with the app killed), and confirm no automatic call-back is placed
  and the reminder no longer fires.
