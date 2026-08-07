# Smart Redial: never record a task unless its OS alarm actually got armed

Implements [plans/20260805_215238_smart_redial_dont_persist_if_arm_fails.md](../plans/20260805_215238_smart_redial_dont_persist_if_arm_fails.md).

## What was wrong (recap of the "why didn't it clear" question)

`SmartRedialManager.schedule()` wrote the task to its persisted list
*before* trying to arm the real OS alarm. When arming failed (the exact-alarm
permission `SecurityException` from the previous fix), the write had already
gone through — so native kept reporting the task as pending forever, with no
real alarm ever able to fire or cancel it. The permission fix stops that
specific cause, but the same drift could still happen from any other future
arming failure (OEM battery/alarm restrictions, a quota, etc.).

## What changed

Arming success is now the gate for persisting, end to end:

`SmartRedialManager.kt`: `armAlarm()` returns `Boolean` instead of swallowing
failure silently. `schedule()` now arms the alarm first and only writes the
task record if that succeeded — nothing is ever persisted for a failed
schedule. `rescheduleAfterBoot()` likewise only keeps a task in the
post-reboot list if re-arming it succeeds.

`MainActivity.kt`: the `scheduleSmartRedial` channel method now returns
`schedule()`'s success/failure instead of always reporting success.

`lib/services/telecom_service.dart`: `scheduleSmartRedial` now returns
`Future<bool>` (previously `Future<void>`, always "succeeded").

`lib/services/smart_redial_service.dart`: `scheduleAutoRedial` now calls the
native schedule first and only adds the task to its own list (what the
Settings UI reads) if native confirms it actually armed; otherwise it throws
so the caller knows nothing was really scheduled.

`lib/widgets/smart_redial_sheet.dart`: catches that failure and shows an
error snackbar instead of the sheet claiming success. This is the backstop —
the permission check added in the previous fix should catch the common case
before it gets this far.

`test/smart_redial_service_test.dart`: stubs the native channel
(`scheduleSmartRedial` → `true`) so the existing list-management test keeps
exercising the Dart-side logic without a real device.

## Verification

- `flutter analyze` — no issues.
- `flutter test test/smart_redial_service_test.dart` — passes.
- `./gradlew :app:compileDevDebugKotlin` — compiles clean.
