# Change Log: Update `docs/features.md` to document missing app features

**Date:** 2026-08-10
**Plan Implemented:** [plans/20260810_061803_update_features_md.md](file:///l:/Android/SreerajPContactSphere/plans/20260810_061803_update_features_md.md)

## Summary of Changes

Updated [docs/features.md](file:///l:/Android/SreerajPContactSphere/docs/features.md) to comprehensively document all existing features present in the codebase that were previously missing or listed as unintegrated:

1. **Section 1 (Contacts management)**: Added Relationship-Tier Quiet Hours exception settings (silencing night calls except for allowed emergency/ICE contacts, starred contacts, specified relationship types, allowed tags, or specific contacts).
2. **Section 2 (Dialer / calling)**: Added Spoken Caller Announcements (caller name announced over ringtone in English/Malayalam with quiet-hours exception range and test preview).
3. **Section 4 (Sharing / interoperability)**:
   - Added AirQR optical fountain QR stream encoding/decoding for sharing large vCards/multi-contact payloads via animated QR code sequences over camera.
   - Added Contact QR Safety & Quishing validation engine (validating scanned contact QRs against phishing links, executable file downloads, IP links, code injection, and overlong fields).
4. **Section 8 (Security / privacy)**: Added ICE Emergency Card high-res PNG image rendering and text sharing via system share sheet, and scanned QR quishing/malware safety inspection.
5. **Section 12 (Settings screen)**: Included Spoken Caller Announcements and Relationship-Tier Quiet Hours in the settings list.
6. **Section 13 (Native Android platform features)**: Added native exact alarm notification scheduling (`NotificationSchedulerManager.kt`, `ScheduledNotificationReceiver.kt`) with boot persistence (`BOOT_COMPLETED`).
7. **Known Gaps & Roadmap**: Updated notification scheduling status, noting that `NotificationSchedulerService` in Dart and `NotificationSchedulerManager` in Kotlin are implemented and active.

## Verification
- Verified `docs/features.md` structure and line changes.
