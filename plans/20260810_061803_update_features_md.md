# Plan: Update `docs/features.md` to include all missing app features

**Date:** 2026-08-10
**Target File:** `docs/features.md`

## Summary of Missing / Outdated Features

An audit of the ContactSphere codebase (`lib/` Dart code and `android/` Kotlin code) revealed several key features present in code that are missing or out of date in `docs/features.md`:

1. **Spoken Caller Announcements (`SpokenAnnouncementsScreen`, `telecom_service.dart`)**:
   - Announces caller's name over ringtone in English ("Amma calling") or Malayalam ("അമ്മ വിളിക്കുന്നു").
   - Quiet-hours range exception to suppress announcements during set hours.
   - In-app test/preview dialog.
2. **Relationship-Tier Quiet Hours (`RelationshipQuietHoursScreen`, `quiet_hours_service.dart`)**:
   - Silences calls during quiet hours except for allowed relationship categories (ICE emergency contacts, starred contacts, custom relationship types), allowed tags, or specific contacts.
   - Shows live allowed active number count.
3. **AirQR Animated Optical Fountain Streaming (`AirQrService`, `AirQrFrame`, `AirQrShareDialog`, `qr_scan_screen.dart`)**:
   - Streams large vCards / multi-contact payloads using animated QR code sequences (LT Fountain parity frames + systematic frames with CRC32 checksums) without Bluetooth or network connections.
4. **Contact QR Safety & Quishing Inspection (`ContactQrSafetyService`, `ContactQrSafetyReport`)**:
   - Automated safety validation for scanned QR contact payloads.
   - Checks for quishing/phishing links, executable file downloads (.apk, .exe, .zip), IP-address URLs, HTML/script injection, and overlong fields.
   - Assigns safety risk score (Safe / Warning / High Risk) and sanitizes contact fields.
5. **ICE Emergency Card PNG Image & Text Export (`EmergencyShareService`)**:
   - Renders a high-resolution branded PNG image of the Emergency Info (ICE) card with blood group highlighting and emergency contacts, or plain text, for sharing via system share sheet.
6. **Notification Scheduler Service (`NotificationSchedulerService` & `NotificationSchedulerManager.kt`)**:
   - `docs/features.md` currently lists notification scheduling under "Known gaps" and "Roadmap", claiming it is missing.
   - In reality, `NotificationSchedulerService` and native `NotificationSchedulerManager.kt` + `ScheduledNotificationReceiver.kt` are fully implemented for scheduling exact system alarms with boot persistence and notification payload delivery.

## Proposed Changes

### [MODIFY] `docs/features.md` (file:///l:/Android/SreerajPContactSphere/docs/features.md)
- Update **Section 1 (Contacts management)**: Add Relationship-tier Quiet Hours filtering and allowed contacts configuration.
- Update **Section 2 (Dialer / calling)**: Add Spoken Caller Announcements (English/Malayalam voice announcements over ringtone with quiet hours exception and test preview).
- Update **Section 4 (Sharing / interoperability)**:
  - Add AirQR optical fountain stream encoding/decoding for sharing large vCards via animated QR sequences.
  - Add Contact QR Safety & Quishing Inspection engine (phishing URL, executable, code injection, and overlong field analysis + sanitization).
- Update **Section 8 (Security / privacy)**: Add ICE Emergency Card PNG card image rendering and text sharing via system share sheet. Add QR Quishing safety inspection.
- Update **Section 12 (Settings screen)**: Add Spoken Caller Announcements and Relationship-tier Quiet Hours to settings options.
- Update **Section 13 (Native Android platform features)**: Add native notification scheduling via `NotificationSchedulerManager` exact alarm manager and boot receiver.
- Update **Known gaps / Roadmap**: Move notification scheduling from Known Gaps / Roadmap to Resolved, noting `NotificationSchedulerService` and native exact alarm handling are implemented.

## Verification Plan
- Inspect `docs/features.md` after changes to ensure clear formatting, accurate representation of codebase features, and zero omitted capabilities.
