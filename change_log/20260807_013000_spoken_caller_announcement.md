# Change Log: Spoken caller announcement, English and Malayalam (Size S)

- **Date:** 2026-08-07
- **Plan Implemented:** [plans/20260807_012830_spoken_caller_announcement.md](file:///l:/Android/SreerajPContactSphere/plans/20260807_012830_spoken_caller_announcement.md)

## Summary of Changes

Implemented **5.7 Spoken caller announcement, English and Malayalam**, allowing the app to speak the caller's name over the ringtone ("Amma calling" or "അമ്മ വിളിക്കുന്നു") on incoming calls using the contact's own name and script. Off by default with a quiet-hours exception and full configuration controls in **SIM & calling** settings.

### Details of Code Modifications

1. **`lib/state/app_settings.dart`**:
   - Added persisted preferences & getters/setters: `spokenCallerAnnouncementEnabled` (default `false`), `spokenCallerQuietHoursEnabled` (default `true`), `spokenCallerQuietHoursStart` (`"22:00"`), and `spokenCallerQuietHoursEnd` (`"07:00"`).
   - Updated `_mirrorRingerPrefs()` to push these spoken announcement settings natively to Android `SharedPreferences`.

2. **`lib/services/telecom_service.dart`**:
   - Expanded `setRingerPrefs()` method signature to pass spoken announcement & quiet hours settings.
   - Added `previewCallerAnnouncement(String name)` method to trigger native TTS previews.

3. **`android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt`**:
   - Handled spoken announcement parameters in `setRingerPrefs` method channel handler, persisting them to native `IncomingCallRinger.RINGER_PREFS` `SharedPreferences`.
   - Handled `previewCallerAnnouncement` method channel call.

4. **`android/app/src/main/kotlin/in/sreerajp/contact_sphere/IncomingCallRinger.kt`**:
   - Integrated Android `TextToSpeech` engine via `CallerAnnouncer` class into `IncomingCallRinger`.
   - Checks if spoken announcement is enabled and evaluates quiet-hours window (`isInQuietHours`) before speaking.
   - Script detection (`isMalayalamScript`): uses `Locale("ml", "IN")` and phrase `"$name വിളിക്കുന്നു"` for Malayalam script names, and `Locale.ENGLISH` and `"$name calling"` for English/Latin script names.
   - Cleanly stops TTS on call answer/reject/end.

5. **`lib/screens/sim_settings_screen.dart`**:
   - Added **Spoken caller announcement** section card under SIM & calling settings.
   - Features: master switch (off by default), quiet-hours exception switch (on by default), quiet hours time range pickers (10:00 PM – 7:00 AM), and a test announcement preview dialog with English and Malayalam presets.

6. **`docs/feature_analysis_and_roadmap.md`**:
   - Updated section 5.7 to mark Spoken caller announcement as `✅ **Shipped (size S)**` and updated the roadmap Gantt chart.

## Verification
- `flutter analyze` clean (0 issues).
- `flutter test` clean (405 tests passing).
