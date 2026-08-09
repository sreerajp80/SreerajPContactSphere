# Plan: Relationship-Tier Quiet Hours (Feature 5.4)

## Issue
Feature 5.4 requires night-time silencing where only chosen relationship tiers (e.g. immediate family) and emergency contacts ring through, while everyone else is silenced (not rejected) and logged in system call logs and recents.

This must be enforced by the native `ContactSphereCallScreeningService` so that it works seamlessly even when the app is closed or after a cold boot, with zero runtime dependency on the Flutter engine during an incoming call.

## Proposed Fix

### 1. New `QuietHoursService` (`lib/services/quiet_hours_service.dart`)
- Defines relationship tier categories and mapping helper:
  - `emergency`: ICE contacts from `emergency_contacts` table.
  - `immediate_family`: Father, Mother, Son, Daughter, Child, Parent, Brother, Sister, Elder Brother, Younger Brother, Elder Sister, Younger Sister, Sibling, Spouse, Partner.
  - `extended_family`: Grandfather, Grandmother, Grandparent, Grandchild, Grandson, Granddaughter, Uncle, Aunt, Nephew, Niece, Cousin, Cousin Brother, Cousin Sister, Father-in-law, Mother-in-law, Son-in-law, Daughter-in-law, Brother-in-law, Sister-in-law, Step-father, Step-mother, Step-son, Step-daughter, Step-brother, Step-sister, Relative.
  - `friends`: Friend, Neighbour.
  - `work`: Colleague.
  - `starred`: Contacts where `is_starred = 1`.
- Method `resolveAllowedNumbers(Set<String> allowedTiers)`: queries SQLite (`relationships`, `contacts`, `phone_numbers`, `emergency_contacts`) and returns all normalized digit strings for matching contacts.
- Method `syncQuietHoursMirror()`: computes allowed numbers and pushes them via `TelecomService.setScreeningMirror()`.

### 2. State & Mirroring (`lib/state/app_settings.dart` & `lib/services/telecom_service.dart`)
- In `AppSettings`:
  - `relationshipQuietHoursEnabled` (bool, default `false`).
  - `relationshipQuietHoursStart` (String "HH:mm", default `"22:00"`).
  - `relationshipQuietHoursEnd` (String "HH:mm", default `"07:00"`).
  - `relationshipQuietHoursAllowedTiers` (List<String>, default `['emergency', 'immediate_family']`).
  - Persistence via `SharedPreferences`.
  - Trigger `QuietHoursService().syncQuietHoursMirror()` whenever quiet hours settings or relationships change.
- In `TelecomService.setScreeningMirror()`:
  - Pass `quietHoursEnabled`, `quietHoursStart`, `quietHoursEnd`, and `quietHoursAllowedNumbers`.

### 3. Native Screening Logic (`MainActivity.kt` & `ContactSphereCallScreeningService.kt`)
- `MainActivity.kt`: update `setScreeningMirror` method channel handler to write `quiet_hours_enabled`, `quiet_hours_start`, `quiet_hours_end`, and `quiet_hours_allowed_numbers` (JSON string array) to native `SCREENING_PREFS`.
- `ContactSphereCallScreeningService.kt`:
  - Helper `isTimeInQuietHours(now: Calendar, start: String, end: String): Boolean` to accurately handle overnight spans (e.g. 22:00 to 07:00).
  - In `screen()`:
    - If non-blocked call arrives and `quiet_hours_enabled` is true:
      - Check if system local time is within quiet hours span.
      - If active, read `quiet_hours_allowed_numbers` array.
      - If incoming number digits match any allowed number via `sameNumber()`, allow it to ring through.
      - Otherwise, return `silence()`. (`setSilenceCall(true)` on API 29+ so the call does not ring but is logged in call log/recents).

### 4. Settings UI (`lib/screens/sim_settings_screen.dart`)
- Add a new "Relationship-Tier Quiet Hours" section under SIM & Calling settings:
  - Master switch to enable/disable.
  - Quiet hours start and end time pickers.
  - Interactive FilterChips / selection tiles for allowed tiers: Emergency Contacts (ICE), Immediate Family, Extended Family, Friends & Social, Work & Professional, Starred Contacts.
  - Live summary of allowed contact/number count.

### 5. Automated Tests & Documentation
- Unit tests in `test/quiet_hours_service_test.dart` for tier mapping, time range checking, and allowed numbers resolution.
- Update `docs/feature_analysis_and_roadmap.md` section 5.4 to ✅ **Shipped (size M)**.

## Target Files
1. `lib/services/quiet_hours_service.dart` [NEW]
2. `lib/state/app_settings.dart` [MODIFY]
3. `lib/services/telecom_service.dart` [MODIFY]
4. `android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt` [MODIFY]
5. `android/app/src/main/kotlin/in/sreerajp/contact_sphere/ContactSphereCallScreeningService.kt` [MODIFY]
6. `lib/screens/sim_settings_screen.dart` [MODIFY]
7. `test/quiet_hours_service_test.dart` [NEW]
8. `docs/feature_analysis_and_roadmap.md` [MODIFY]
