# Change Log - Call Retry SIM Selection, Unanswered Redial Rescheduling & Settings Reorganization

Implemented call retry SIM selection, auto-redial task rescheduling for unanswered calls, and reorganization of settings navigation (Security screen and SIM & Calling screen).

## Referenced Plan
[plans/20260807_042537_call_retry_sim_and_settings_reorg.md](file:///l:/Android/SreerajPContactSphere/plans/20260807_042537_call_retry_sim_and_settings_reorg.md)

## Changes Made

1. **Security Settings Navigation (`Settings -> Security`)**:
   - Created [lib/screens/security_screen.dart](file:///l:/Android/SreerajPContactSphere/lib/screens/security_screen.dart) (`SecurityScreen`) hosting:
     - `AppLockCard` (App lock preferences)
     - `ScreenshotGuardCard` (Block screenshots toggle)
     - `Audit Log` tile (opens `AuditLogScreen`)
   - Updated [lib/screens/settings_screen.dart](file:///l:/Android/SreerajPContactSphere/lib/screens/settings_screen.dart) to replace direct App lock, Block screenshots, and Audit log cards with a single `Security` card.

2. **SIM & Calling Settings Navigation (`Settings -> SIM & Calling`)**:
   - Created reusable [lib/widgets/default_dialer_card.dart](file:///l:/Android/SreerajPContactSphere/lib/widgets/default_dialer_card.dart) (`DefaultDialerCard`).
   - Integrated `DefaultDialerCard` into [lib/screens/sim_settings_screen.dart](file:///l:/Android/SreerajPContactSphere/lib/screens/sim_settings_screen.dart) under **SIM & Calling**.

3. **Call Retry SIM Selection**:
   - Updated [lib/widgets/smart_redial_sheet.dart](file:///l:/Android/SreerajPContactSphere/lib/widgets/smart_redial_sheet.dart) (`_SmartRedialSheet`) to query available SIM accounts from `SimService` and display a SIM selection widget.
   - Allowed the user to pick/change the target SIM on redial before arming the auto-retry.
   - Passed the selected SIM's `phoneAccountId` into `scheduleAutoRedial`.

4. **Rescheduling Unanswered Retry Calls**:
   - Added `cancelTasksForNumber(String phoneNumber)` to [lib/services/smart_redial_service.dart](file:///l:/Android/SreerajPContactSphere/lib/services/smart_redial_service.dart).
   - Updated `scheduleAutoRedial` to automatically cancel any prior active schedule for the target phone number before arming a new retry task.
   - Added unit test in [test/smart_redial_service_test.dart](file:///l:/Android/SreerajPContactSphere/test/smart_redial_service_test.dart) verifying that rescheduling auto-redial for the same phone number replaces the previous task.

## Verification
- `flutter analyze`: Passed with 0 issues.
- `flutter test test/smart_redial_service_test.dart`: Passed 4/4 tests.
