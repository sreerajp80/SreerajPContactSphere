# Change Log: Relationship-Tier Quiet Hours (Feature 5.4)

Implements plan: [`plans/20260807_025205_relationship_tier_quiet_hours.md`](file:///l:/Android/SreerajPContactSphere/plans/20260807_025205_relationship_tier_quiet_hours.md)

## Summary of Changes

1. **`lib/services/quiet_hours_service.dart` (NEW)**
   - Implemented `QuietHoursTiers` to categorize relationship types into `emergency`, `immediate_family`, `extended_family`, `friends`, `work`, and `starred`.
   - Created `resolveAllowedNumbers()` to query SQLite (`relationships`, `contacts`, `phone_numbers`, `emergency_contacts`) for all active phone numbers belonging to enabled tiers.
   - Created `syncQuietHoursMirror()` to push settings and resolved allowed digit list to native SharedPreferences (`SCREENING_PREFS`).

2. **`lib/state/app_settings.dart`**
   - Added settings keys and properties: `relationshipQuietHoursEnabled`, `relationshipQuietHoursStart`, `relationshipQuietHoursEnd`, `relationshipQuietHoursAllowedTiers`.
   - Persisted settings using `SharedPreferences`.
   - Added automatic native mirror sync on app startup (`load()`) and on setting edits.

3. **`lib/services/telecom_service.dart`**
   - Updated `setScreeningMirror()` method signature and map payload to pass quiet hours parameters (`quietHoursEnabled`, `quietHoursStart`, `quietHoursEnd`, `quietHoursAllowedNumbers`).

4. **`android/.../MainActivity.kt`**
   - Updated `setScreeningMirror` channel handler to receive quiet hours parameters and persist them to native `ContactSphereCallScreeningService.SCREENING_PREFS`.

5. **`android/.../ContactSphereCallScreeningService.kt`**
   - Added companion object constants for quiet hours keys (`KEY_QUIET_HOURS_ENABLED`, `KEY_QUIET_HOURS_START`, `KEY_QUIET_HOURS_END`, `KEY_QUIET_HOURS_ALLOWED_NUMBERS`).
   - Implemented `isTimeInQuietHours()` helper supporting overnight time spans (e.g. 22:00 to 07:00).
   - In `screen()`, evaluated quiet hours during incoming calls: non-allowed callers during active quiet hours are silenced (`silence()`), preserving system and in-app call logs while silencing the ringer native-side.

6. **`lib/screens/sim_settings_screen.dart`**
   - Added "Relationship-tier quiet hours" section under SIM & Calling settings.
   - Built master toggle, quiet hours start/end time pickers, selectable FilterChips for allowed relationship tiers, and live count indicator for allowed numbers.

7. **`lib/repositories/relationship_repository.dart`**
   - Triggered `QuietHoursService().syncQuietHoursMirror()` whenever relationships are added, updated, or deleted.

8. **`test/quiet_hours_service_test.dart` (NEW)**
   - Added comprehensive unit tests for `QuietHoursTiers` category mapping and `QuietHoursService.resolveAllowedNumbers()` database resolution.

9. **`docs/feature_analysis_and_roadmap.md`**
   - Marked section 5.4 as ✅ **Shipped (size M)** with full implementation summary and file links.
