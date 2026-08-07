# Emergency card does not appear on the lock screen

**Status:** completed

**Date:** 2026-08-06 19:33:22 IST

## The problem

The user reports: the emergency card notification sits in the notification shade all
the time, but it never shows on the lock screen.

The screenshot confirms it — the card is listed under the **"Silent"** section
(നിശബ്ദം) of the shade.

## Why it happens

In [EmergencyCardNotifier.kt](../android/app/src/main/kotlin/in/sreerajp/contact_sphere/EmergencyCardNotifier.kt):

- The channel `emergency_info` is created with `IMPORTANCE_LOW` (line 157).
- Android treats every `IMPORTANCE_LOW` notification as a **silent** notification.
- The system setting *Settings → Notifications → Notifications on lock screen* has an
  option **"Hide silent conversations and notifications"**. On many devices (including
  near-stock Motorola builds) that is the default. With it on, a silent notification is
  shown in the shade but **never drawn on the lock screen** — exactly what the user sees.

`setVisibility(VISIBILITY_PUBLIC)` does not help here. Public visibility only controls
whether the *content* is hidden behind "sensitive content"; it cannot bring back a
notification the lock screen has filtered out for being silent.

Two smaller contributing points:

- The channel already exists on the device. Changing importance in code does **nothing**
  for an existing channel — Android ignores it after first creation. A new channel id is
  required.
- If the user ever turned the channel down, or denied `POST_NOTIFICATIONS`, the app today
  gives no feedback at all — the switch says "Show on lock screen" and silently does nothing.

## The fix

1. **Move the card off the silent tier.** Create a new channel `emergency_info_v2` with
   `IMPORTANCE_DEFAULT`, but with sound set to `null` and vibration disabled. Result: the
   card makes no noise and does not buzz, yet Android no longer classes it as "silent", so
   it is drawn on the lock screen even under "Hide silent notifications". Delete the old
   `emergency_info` channel so a dead entry does not linger in system settings.
   Keep `VISIBILITY_PUBLIC`, `setOngoing(true)`, and the 1-tap call action as they are.

2. **Tell the user when the system is blocking it.** Add a status check on the native side
   (notifications enabled? channel importance? channel not `IMPORTANCE_NONE`?) and expose it
   over the existing `contact_sphere/emergency` method channel, together with two helpers
   that open (a) this app's channel settings and (b) the system lock-screen notification
   settings.

3. **Show that status in the app.** Under the "Show on lock screen" switch in the emergency
   info screen, show a warning row when notifications are off or the channel is muted, with a
   button that opens the right settings page. Always show a short "Not seeing it on the lock
   screen?" link that opens the lock-screen notification settings, because the
   "Hide silent notifications" toggle is a system-wide choice this app cannot change.

4. **Document the steps** in the emergency info help screen in plain English.

## Files to change

| File | Change |
| --- | --- |
| `android/app/src/main/kotlin/in/sreerajp/contact_sphere/EmergencyCardNotifier.kt` | New `emergency_info_v2` channel at `IMPORTANCE_DEFAULT` with no sound/vibration; delete old channel; add `notificationStatus()` helper |
| `android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt` | New method-channel calls: `emergencyNotificationStatus`, `openEmergencyChannelSettings`, `openLockScreenNotificationSettings` |
| `lib/screens/emergency_info_screen.dart` | Status/warning row + "Not seeing it on the lock screen?" action under the master switch |
| `lib/screens/help/emergency_info_help_screen.dart` | Plain-English steps for the system lock-screen setting |
| `docs/features.md` | Note the new channel behaviour if the feature is described there |

## What this cannot do

Android gives no API to force a notification onto the lock screen. If the user has set
*Notifications on lock screen* to **"Don't show any notifications"**, or has swiped the
lock screen notifications off, nothing in the app can override it — step 3 exists so the
user is told, instead of the feature failing quietly.

## Verification

- `flutter analyze` → 0 errors.
- `flutter test test/emergency_info_test.dart`.
- On device: turn the switch off and on again (this re-publishes and creates the new
  channel), lock the phone, confirm the card is drawn on the lock screen and that tapping
  it opens the card without a PIN.
