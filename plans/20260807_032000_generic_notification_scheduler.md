# Implementation Plan - Generic Notification Scheduler

**Date:** 2026-08-07
**Task:** Implement generic notification scheduler (native Android exact AlarmManager + boot receiver + Dart service) as specified in section 4 of `docs/feature_analysis_and_roadmap.md`.

## Overview
ContactSphere requires a generic "wake up later and notify" foundation that operates natively via exact `AlarmManager` alarms, persists across app restarts, re-arms upon system reboots, and provides a clean Flutter interface via `MethodChannel`.

This plan implements the pure generic notification scheduler infrastructure without introducing feature-specific nudge UI or automated date alert logic, while ensuring complete synergy with existing native alarm mechanisms (`SmartRedialManager`, `EmergencyBootReceiver`).

## Files to Create / Modify

### 1. Native Android Foundation
- **[NEW] `android/app/src/main/kotlin/in/sreerajp/contact_sphere/NotificationSchedulerManager.kt`**
  - Singleton object to manage persistent generic scheduled notifications in `SharedPreferences` (`contact_sphere_scheduled_notifications`).
  - Sets exact `AlarmManager` alarms targeting `ScheduledNotificationReceiver`.
  - Implements task scheduling, cancellation, `rescheduleAfterBoot`, and permission check helpers (`canScheduleExactAlarms`).
- **[NEW] `android/app/src/main/kotlin/in/sreerajp/contact_sphere/ScheduledNotificationReceiver.kt`**
  - `BroadcastReceiver` listening for `in.sreerajp.contact_sphere.SCHEDULED_NOTIFICATION_ALARM`.
  - Fires system notifications on notification channel `"scheduled_notifications"` ("Reminders & Notifications").
  - Configures `PendingIntent` to bring up `MainActivity` with payload extras when tapped.
- **[MODIFY] `android/app/src/main/kotlin/in/sreerajp/contact_sphere/EmergencyBootReceiver.kt`**
  - Re-arm generic notifications after reboot by invoking `NotificationSchedulerManager.rescheduleAfterBoot(context)`.
- **[MODIFY] `android/app/src/main/AndroidManifest.xml`**
  - Register `<receiver android:name=".ScheduledNotificationReceiver" android:exported="false" />`.
- **[MODIFY] `android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt`**
  - Add MethodChannel bridge methods: `scheduleNotification`, `cancelNotification`, `getPendingNotificationIds`, `hasExactAlarmPermission`, `requestExactAlarmPermission`, and `getPendingNotificationPayload`.
  - Handle notification tap intents to park payload for Dart collection.

### 2. Flutter / Dart Layer
- **[NEW] `lib/services/notification_scheduler_service.dart`**
  - `ScheduledNotificationItem` model class.
  - `NotificationSchedulerService` (`ChangeNotifier`) for managing scheduled notifications from Dart, storing state in `SharedPreferences`, and reconciling against native pending IDs.
- **[MODIFY] `lib/services/telecom_service.dart`**
  - Add MethodChannel bindings to invoke `scheduleNotification`, `cancelNotification`, `getPendingNotificationIds`, etc.

### 3. Unit Tests
- **[NEW] `test/notification_scheduler_service_test.dart`**
  - Unit tests for scheduling, cancelling, expiration, and method channel integration using mock binary messenger.

### 4. Documentation Update
- **[MODIFY] `docs/feature_analysis_and_roadmap.md`**
  - Update Section 4 & Section 5.1 reflecting the completion and shipping of the Generic Notification Scheduler.

## Verification Plan
1. Run `flutter analyze` to ensure zero lints or static analysis errors.
2. Run `flutter test` to verify all tests (including new `notification_scheduler_service_test.dart`) pass cleanly.
