# Change Log: Emergency card now shows on the lock screen

**Change Date**: 2026-08-06 19:55:00 IST
**Plan Implemented**: [plans/20260806_193322_emergency-card-lockscreen-visibility.md](../plans/20260806_193322_emergency-card-lockscreen-visibility.md)

## The problem

The emergency card notification sat in the notification shade all the time but never
appeared on the lock screen. The shade showed it under the **Silent** section.

Cause: the notification channel was created with `IMPORTANCE_LOW`. Android files anything
below `IMPORTANCE_DEFAULT` as a *silent* notification, and the system setting
*Notifications on lock screen* → "Hide silent conversations and notifications" (the default
on many phones) keeps silent notifications off the lock screen. A channel's importance
cannot be changed after it is created, so a new channel id was needed.

## Changes

1. **`android/app/src/main/kotlin/in/sreerajp/contact_sphere/EmergencyCardNotifier.kt`**
   - Channel id changed from `emergency_info` to `emergency_info_v2`, created at
     `IMPORTANCE_DEFAULT` with sound `null`, vibration off and lights off — quiet, but no
     longer classed as silent, so the lock screen shows it.
   - The old `emergency_info` channel is deleted so it does not linger in system settings.
   - New `notificationStatus()` reports whether notifications are enabled, whether the
     channel is blocked, whether it was turned down to silent, and whether a card is
     published.

2. **`android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt`**
   - Three new calls on the `contact_sphere/emergency` method channel:
     `emergencyNotificationStatus`, `openEmergencyChannelSettings`,
     `openLockScreenNotificationSettings`.
   - Helpers `openEmergencyChannelSettings()`, `openLockScreenNotificationSettings()` and
     `startFirstThatResolves()` — the last tries each candidate settings intent in turn and
     catches failures, because package visibility rules make `resolveActivity` unreliable
     on API 30+.

3. **`lib/services/emergency_card_service.dart`**
   - New `EmergencyNotificationStatus` value class (all-clear defaults, so non-Android
     platforms and bridge failures show no warning).
   - New `status()`, `openChannelSettings()`, `openLockScreenSettings()`.

4. **`lib/screens/emergency_info_screen.dart`**
   - Reads the status on load, after every save, and on app resume (the user fixes things
     in system settings and comes back).
   - Under the "Show on lock screen" switch: a warning row when notifications are off or
     the channel is muted, with a button to the right settings page, plus an always-visible
     "Not seeing it on the lock screen?" link that explains the system setting and can open
     it.

5. **`lib/screens/help/emergency_info_help_screen.dart`**
   - New help section "If the card is missing from the lock screen" with the exact settings
     path, and a note that the shade entry is permanent on purpose.

6. **`docs/feature_analysis_and_roadmap.md`**
   - Lockscreen emergency card row records the channel change and the reason.
   - Note under 5.9 that this fix was a separate bug and does not change 5.9's scope.

## What this cannot do

Android has no API to force a notification onto the lock screen, and no way to read the
"hide silent notifications" choice. If the user sets the lock screen to "Don't show any
notifications", the card cannot appear there — the new warning row and help text exist so
the user is told instead of the feature failing quietly.

## Verification

- `flutter analyze` → **No issues found**.
- `flutter test test/emergency_info_test.dart` → **13/13 passed**.
- `flutter build apk --debug --flavor dev` → built, so the Kotlin changes compile.
- Still to do on device: switch the card off and on again (this creates the new channel),
  lock the phone, and confirm the card is drawn on the lock screen.
