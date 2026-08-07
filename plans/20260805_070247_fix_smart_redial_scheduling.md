# Fix Smart Redial: callbacks don't fire, and no auto-cancel on call-back

**Status:** completed

## The issue

The app's "call back later" feature is called **Smart Redial** (Settings → SIM &
calling → "Smart Redial & Reach Me"). The user reported two problems and two
questions:

1. Scheduled callbacks are not actually happening.
2. When the contact calls back before the scheduled time, the schedule should
   cancel itself automatically, but it doesn't.
3. Where to view scheduled callbacks (already works — see below).
4. How to cancel one manually (already works — see below).

Questions 3 and 4 are already implemented and need no code change:
- View: Settings → SIM & calling → "Smart Redial & Reach Me" → "Active
  scheduled redials" ([lib/screens/sim_settings_screen.dart:596-722](lib/screens/sim_settings_screen.dart#L596-L722)).
- Cancel: red cancel button next to each item in that same list.

### Root cause of problem 1 (callback doesn't fire)

[lib/services/smart_redial_service.dart](lib/services/smart_redial_service.dart)
schedules the reminder with a plain in-memory Dart `Timer`
([smart_redial_service.dart:113](lib/services/smart_redial_service.dart#L113))
and only shows the notification by calling `.show()` (an immediate
notification) once that timer fires
([smart_redial_service.dart:149](lib/services/smart_redial_service.dart#L149)).

A Dart `Timer` only exists while the app process is alive. Android routinely
kills backgrounded apps to free memory, which destroys the timer silently —
so if the app isn't in the foreground when the delay elapses, the reminder
never fires. This matches the known limitation already written down in
[docs/features.md:141-144](docs/features.md#L141-L144).

The list of scheduled tasks (`_tasks`) is also only in memory, so even the
"Active scheduled redials" list forgets everything if the app process
restarts before the reminder fires.

### Root cause of problem 2 (no auto-cancel on call-back)

`cancelTask()` ([smart_redial_service.dart:120-129](lib/services/smart_redial_service.dart#L120-L129))
works, but nothing calls it automatically. No code listens for an incoming
call and checks it against pending Smart Redial tasks.

## The fix

### 1. Make the reminder survive the app being closed

Use `flutter_local_notifications`' `zonedSchedule` (the plugin is already a
dependency, as is the `timezone` package it needs) instead of a Dart `Timer` +
immediate `.show()`. `zonedSchedule` hands the exact fire time to Android's
own AlarmManager via the plugin, so the notification fires even if the app
process has been killed.

- Use `AndroidScheduleMode.inexactAllowWhileIdle` (not the exact variant).
  Exact alarms need the `SCHEDULE_EXACT_ALARM`/`USE_EXACT_ALARM` permission,
  which isn't in the manifest and is heavily scrutinized on Play Store
  submission; for a "call them back in ~15/30/60 minutes" reminder, being off
  by up to a few minutes is fine and avoids adding that permission.
- Initialize the `timezone` package the same way
  [lib/services/pre_call_summary_service.dart:93-97](lib/services/pre_call_summary_service.dart#L93-L97)
  already does elsewhere in this codebase.
- `RECEIVE_BOOT_COMPLETED` and `POST_NOTIFICATIONS` are already declared in
  `AndroidManifest.xml`, and `flutter_local_notifications` merges its own
  boot-rescheduling receiver automatically — no manifest changes needed.

### 2. Persist the task list

Save the active-task list to `SharedPreferences` (already a dependency, same
pattern `AppSettings` already uses) whenever a task is scheduled, fired, or
cancelled. On app start, reload it so:
- the "Active scheduled redials" list is correct even after the app process
  was restarted,
- a task can still be found and cancelled by id after a restart,
- tasks whose fire time has already passed while the app was closed are
  reconciled (marked completed; the OS notification already fired for them).

### 3. Auto-cancel when the contact calls back

Add a subscription inside `SmartRedialService` to `TelecomService().callEvents`
(the existing call-state stream also used in
[lib/main.dart:139](lib/main.dart#L139)). Whenever a `CallState` update reports
an **incoming** call (`CallDirection.incoming`), compare its number against
every active task's number using the existing
`PhoneNormalizer.sameNumber()` helper ([lib/utils/phone_normalizer.dart](lib/utils/phone_normalizer.dart))
with the user's default country
(`AppSettings.readDefaultCountryIso()`, already used elsewhere in this
service). On a match, cancel that task: cancel its pending OS notification
(`_notifications.cancel(id)`) and mark it cancelled in the persisted list.

Start this subscription once, from `main.dart`'s existing `_bootstrap()`
(alongside where `SmartRedialService` gets its persisted tasks reloaded), so
it runs for the lifetime of the app rather than only while the Smart Redial
sheet/settings screen is open.

## Files to change

- `lib/services/smart_redial_service.dart` — replace `Timer` + immediate
  `.show()` with `zonedSchedule`; add `SharedPreferences`-backed persistence
  (load/save/reconcile); add the incoming-call listener and auto-cancel
  matching.
- `lib/main.dart` — call a new `SmartRedialService().init()` during
  `_bootstrap()` to restore persisted tasks and start the auto-cancel
  listener.
- `test/` — the plan does not add a dedicated new test file, but if an
  existing test exercises `SmartRedialService`, it will be checked/updated so
  `flutter test` still passes. (A quick check during implementation will
  confirm whether one exists.)

## Out of scope

- Changing the delay options, notification text/wording, or the "Reach Me"
  SMS feature — untouched.
- The separate, unrelated `ReminderRepository` "nudge" gap documented in
  `docs/known-gaps.md:210-211` — that is a different, already-tracked issue.
