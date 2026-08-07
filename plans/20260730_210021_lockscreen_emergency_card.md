# Implementation Plan: Lockscreen Emergency Card with High-Contrast QR Code and 1-Tap Emergency Dial Override

**Plan Date**: 2026-07-30 21:00:21 IST
**Target Feature**: Persistent Android Lockscreen Emergency Card with High-Contrast QR Code & 1-Tap Emergency Dial Override

## Overview
The app currently has `EmergencyInfoScreen` (Flutter UI), `EmergencyInfoRepository` (DB & mirror bridge), `EmergencyCardNotifier` (native notification manager), and `EmergencyInfoActivity` (Android lockscreen activity rendered over the keyguard).
To fully satisfy the prompt requirements:
1. Add high-contrast Emergency QR Code generation to `EmergencyInfoActivity` so paramedics/first-responders can scan ICE medical data and emergency contact details straight from the lock screen.
2. Add a 1-tap emergency dial notification action to `EmergencyCardNotifier` and prominent 1-tap dial overrides on `EmergencyInfoActivity`.

## Proposed File Changes

### 1. `android/app/src/main/kotlin/in/sreerajp/contact_sphere/EmergencyQrEncoder.kt` [NEW]
- Create a pure Kotlin helper `EmergencyQrEncoder` that encodes ICE text (vCard / MECARD / ICE summary format) into a high-contrast QR Code `Bitmap` (black & white modules with high contrast border).

### 2. `android/app/src/main/kotlin/in/sreerajp/contact_sphere/EmergencyInfoActivity.kt` [MODIFY]
- Parse the emergency card JSON payload.
- Generate an ICE QR code string (Name, Blood Group, Medical Alerts, ICE Contacts).
- Render a high-contrast Emergency QR Code card at the top of the lockscreen layout using `EmergencyQrEncoder`.
- Ensure 1-tap emergency call action buttons are prominently rendered for each emergency contact.

### 3. `android/app/src/main/kotlin/in/sreerajp/contact_sphere/EmergencyCardNotifier.kt` [MODIFY]
- If emergency contacts exist in the published mirror payload, add a 1-tap Emergency Call `Notification.Action` to the persistent lockscreen notification.

### 4. `lib/screens/emergency_info_screen.dart` [MODIFY]
- Update the preview section to inform users that a high-contrast ICE QR Code and 1-tap call override are published on the lockscreen card.

## Verification Plan
1. Run `flutter analyze` to ensure zero static analysis lint errors.
2. Run `flutter test` to ensure all existing unit tests pass.
3. Validate Kotlin compilation via `flutter build apk` (or `gradlew assembleDebug`).
