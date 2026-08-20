# Suppress Incoming Call Notification Banner Above Full-Screen Caller Screen

**Implemented Plan:** [plans/20260820_072500_incoming_call_heads_up_notification_suppression.md](../plans/20260820_072500_incoming_call_heads_up_notification_suppression.md)

## Summary of Changes

Suppressed the intrusive Android Heads-Up Notification (HUN) banner from appearing over the full-screen incoming call UI.

### 1. `ContactSphereInCallService.kt`
- In `startRinging()`: Posted the ringing notification with `forceQuiet = true` onto `QUIET_INCOMING_CHANNEL_ID` (`IMPORTANCE_LOW`, silent, no heads-up banner) while `launchInCallUi()` brings the full-screen incoming call UI to the front.
- In `onUiVisibilityChanged()`:
  - When `uiVisible == false` (screen minimized / user navigated to another app), posts the high-importance notification on `CHANNEL_ID` with Answer/Decline buttons so the heads-up banner appears over the other app.
  - When `uiVisible == true` (user returned to the caller UI), cancels `CALL_NOTIFICATION_ID` and re-posts the quiet notification on `QUIET_INCOMING_CHANNEL_ID` so any active heads-up window is cleanly and immediately dismissed.
- In `buildCallNotification()`, `buildCallStyleNotification()`, and `buildLegacyNotification()`: Propagated `uiVisible` state (including `forceQuiet`) to select between quiet and high-importance channels and full-screen intent.

### 2. `MainActivity.kt`
- In `onCreate()` and `onNewIntent()`: Immediately invoked `applyShowWhenLocked(true)` upon receiving `ACTION_SHOW_IN_CALL` so lock-screen display flags are applied without waiting for async call-state stream events.

## Verification
- Verified with `flutter analyze` (0 issues found).
- Ran flutter tests (`test/contact_search_picker_sheet_test.dart` and suite).
