# Plan: Spoken caller announcement, English and Malayalam (Size S)

## Issue
Feature 5.7 in `docs/feature_analysis_and_roadmap.md` requires announcing the caller's name over the ringtone ("Amma calling" or "അമ്മ വിളിക്കുന്നു") on incoming calls using the contact's own name and script.
The feature must be **off by default**, support a **quiet-hours exception**, and be configurable in the **SIM & calling** settings (`sim_settings_screen.dart`).

## Fix / Architecture Plan

1. **State & Preferences (`lib/state/app_settings.dart`)**:
   - Add keys & state properties:
     - `spokenCallerAnnouncementEnabled` (bool, default `false`).
     - `spokenCallerQuietHoursEnabled` (bool, default `true`).
     - `spokenCallerQuietHoursStart` (String "HH:mm", default `"22:00"`).
     - `spokenCallerQuietHoursEnd` (String "HH:mm", default `"07:00"`).
   - Persist these values in `SharedPreferences`.
   - Update `_mirrorRingerPrefs()` to mirror these settings natively through `TelecomService.setRingerPrefs()`.

2. **Native Platform Bridge (`lib/services/telecom_service.dart` & `MainActivity.kt`)**:
   - Expand `TelecomService.setRingerPrefs()` to send `spokenAnnouncementEnabled`, `quietHoursEnabled`, `quietHoursStart`, `quietHoursEnd`.
   - Add `TelecomService.previewCallerAnnouncement(String name)` for testing announcements from the settings UI.
   - Update `MainActivity.kt` to persist these spoken announcement keys in native `IncomingCallRinger.RINGER_PREFS` `SharedPreferences`.
   - Handle the `previewCallerAnnouncement` method call in `MainActivity.kt` to trigger a preview TTS announcement.

3. **Native Ringing & Text-To-Speech (`IncomingCallRinger.kt`)**:
   - Add native Android `TextToSpeech` engine management in `IncomingCallRinger.kt`.
   - On incoming call `start(number, phoneAccountId)`:
     - Read `spoken_caller_announcement_enabled`, `spoken_caller_quiet_hours_enabled`, `spoken_caller_quiet_hours_start`, `spoken_caller_quiet_hours_end` from `ringerPrefs`.
     - Evaluate quiet-hours exception: check if local time (`Calendar.getInstance()`) is within the quiet-hours range. If within quiet hours, suppress TTS announcement.
     - Look up caller name from mirrored `KEY_CONTACT_NAMES` map for `number`.
     - Detect script: if caller name contains Malayalam Unicode characters (`\u0D00`–`\u0D7F`), phrase = `"$name വിളിക്കുന്നു"` with `Locale("ml", "IN")` (with fallback). Otherwise phrase = `"$name calling"` with `Locale.ENGLISH`.
     - Speak announcement over the ringtone.
   - On call answer/reject/ended `stop()`:
     - Stop and release `TextToSpeech`.

4. **UI Settings (`lib/screens/sim_settings_screen.dart`)**:
   - Add a new "Spoken caller announcement" card to `SimSettingsScreen`.
   - Include:
     - Master switch: "Spoken caller announcement" (off by default).
     - Quiet-hours exception switch (on by default when feature is enabled).
     - Quiet-hours start and end time pickers (default 10:00 PM – 7:00 AM).
     - "Test announcement" button with a dialog to test speaking English and Malayalam sample names.

5. **Documentation (`docs/feature_analysis_and_roadmap.md`)**:
   - Update section 5.7 to mark as `✅ **Shipped (size S)**`.

## Files to Modify
- `lib/state/app_settings.dart`
- `lib/services/telecom_service.dart`
- `android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt`
- `android/app/src/main/kotlin/in/sreerajp/contact_sphere/IncomingCallRinger.kt`
- `lib/screens/sim_settings_screen.dart`
- `docs/feature_analysis_and_roadmap.md`

## Verification Plan
1. `flutter analyze` static analysis clean check.
2. `flutter test` automated test suite execution.
