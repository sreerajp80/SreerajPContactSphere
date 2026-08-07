# Smart Redial: never record a task unless its OS alarm actually got armed

**Status:** completed

## The issue (recap)

The permission bug just fixed showed a deeper ordering problem:
`SmartRedialManager.schedule()` wrote the task to its persisted list
*before* trying to arm the real OS alarm. When arming failed (the
`SecurityException`), the write had already gone through — so native kept
reporting the task as "pending" forever, even though no alarm existed to
ever fire or be cancelled. The permission fix stops that *specific* cause,
but the same drift could happen again from any other future arming failure
(OEM battery/alarm restrictions, an alarm quota, etc.) — the record and the
real alarm can still get out of sync.

## Fix

Make arming success the gate for persisting, in both directions:

- `SmartRedialManager.armAlarm()` returns `Boolean` (false on any failure to
  arm, instead of swallowing it silently).
- `SmartRedialManager.schedule()` only writes the task record if `armAlarm`
  returned true; on failure, nothing is persisted — no phantom entry.
- `SmartRedialManager.rescheduleAfterBoot()` (which also calls `armAlarm`)
  only keeps a task in the reboot-restored list if re-arming it succeeded.
- The `scheduleSmartRedial` channel method returns that success/failure to
  Dart (was previously void, always "succeeded").
- `TelecomService.scheduleSmartRedial` returns `Future<bool>`.
- `SmartRedialService.scheduleAutoRedial` only adds the task to its own
  (UI-facing) list if native confirms it actually armed; on failure it
  throws, so the sheet can show an error instead of a snackbar claiming
  success.
- `smart_redial_sheet.dart`'s `_scheduleAutoRetry` shows an error snackbar if
  scheduling reports failure (belt-and-suspenders — the permission check
  already added should prevent this in the common case).

## Files to change

- `android/app/src/main/kotlin/in/sreerajp/contact_sphere/SmartRedialManager.kt`
- `android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt`
- `lib/services/telecom_service.dart`
- `lib/services/smart_redial_service.dart`
- `lib/widgets/smart_redial_sheet.dart`

## Verification

- `flutter analyze`, `flutter test test/smart_redial_service_test.dart`,
  `./gradlew :app:compileDevDebugKotlin`.
