# Change Log: Lockscreen Emergency Card with High-Contrast QR Code and 1-Tap Emergency Dial Override

**Change Date**: 2026-07-30 21:06:00 IST
**Plan Implemented**: [plans/20260730_210021_lockscreen_emergency_card.md](../plans/20260730_210021_lockscreen_emergency_card.md)

## Summary of Changes

1. **`android/app/build.gradle.kts`**:
   - Added `com.google.zxing:core:3.5.3` dependency to enable native Android QR code encoding.

2. **`android/app/src/main/kotlin/in/sreerajp/contact_sphere/EmergencyQrEncoder.kt`** (New File):
   - Created pure Kotlin helper `EmergencyQrEncoder` that generates a high-contrast QR code `Bitmap` (pure white modules on dark background) from ICE medical and contact details.

3. **`android/app/src/main/kotlin/in/sreerajp/contact_sphere/EmergencyInfoActivity.kt`**:
   - Integrated `EmergencyQrEncoder` to draw a high-contrast Emergency QR Code section on the Android lockscreen card overlay (rendered over keyguard without PIN).
   - Added high-contrast "1-Tap Call" emergency dial buttons for each emergency contact.

4. **`android/app/src/main/kotlin/in/sreerajp/contact_sphere/EmergencyCardNotifier.kt`**:
   - Added a direct 1-tap Emergency Call `Notification.Action` to the persistent lockscreen notification when emergency contacts are present in the mirror payload.

5. **`lib/screens/emergency_info_screen.dart`**:
   - Updated the subtitle text to clarify that a persistent notification with 1-tap call action and high-contrast Emergency QR code is published on the lock screen.

## Verification
- `flutter analyze` completed with 0 errors / 0 warnings.
- `flutter test test/emergency_info_test.dart` passed all 13 unit tests.
