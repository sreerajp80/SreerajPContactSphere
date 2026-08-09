# Change Log: Refactor Quiet Hours Allowed Tiers to Allowed Contacts

**Date/Time:** 2026-08-07 21:01:44
**Implemented Plan:** [plans/20260807_210022_allowed_contacts_refactor.md](file:///l:/Android/SreerajPContactSphere/plans/20260807_210022_allowed_contacts_refactor.md)

## Summary of Changes

1. **`lib/state/app_settings.dart`**
   - Added SharedPreferences keys `_kRelationshipQuietHoursAllowedTags` and `_kRelationshipQuietHoursAllowedContactIds`.
   - Added private fields `_relationshipQuietHoursAllowedTags` and `_relationshipQuietHoursAllowedContactIds`.
   - Added getters `relationshipQuietHoursAllowedTags` and `relationshipQuietHoursAllowedContactIds`.
   - Added setters `setRelationshipQuietHoursAllowedTags` and `setRelationshipQuietHoursAllowedContactIds` with SharedPreferences persistence and native screening mirror syncing.
   - Updated `_loadSettings` to load saved allowed tags and contact IDs on startup.

2. **`lib/services/quiet_hours_service.dart`**
   - Refactored `resolveAllowedNumbers` to aggregate allowed phone numbers from:
     - Relationships (Emergency ICE, Immediate Family, Extended Family, Friends, Work, Starred).
     - Tags (querying `tags` database table for contacts carrying selected allowed tags).
     - Specific Contact IDs (directly added individual contacts).
   - Updated `syncQuietHoursMirror` to read tags and contact IDs from `AppSettings`.

3. **`lib/screens/relationship_quiet_hours_screen.dart`**
   - Renamed header and descriptions from **"Allowed Tiers"** to **"Allowed Contacts (Ring Through)"**.
   - Structured allowed contacts configuration into three clear categories:
     - **Relationships & Categories**: Filter chips for preset relationship tiers.
     - **Allowed Tags**: Selected tag chips with remove actions + **"+ Add Tag"** bottom sheet picker.
     - **Specific Contacts**: Selected contact chips with avatar initials and remove actions + **"+ Add Contact"** sheet (`ContactMultiPickerSheet`).
   - Dynamic total allowed active numbers counter.

4. **`test/quiet_hours_service_test.dart`**
   - Added automated unit test cases verifying `resolveAllowedNumbers` with allowed tags and specific contact IDs.

## Verification

- `flutter analyze` completed cleanly with 0 issues.
- `flutter test` passed all 236 unit and widget tests.
