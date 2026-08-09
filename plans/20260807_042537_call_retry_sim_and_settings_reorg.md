# Implementation Plan - Call Retry SIM Selection, Unanswered Redial Rescheduling & Settings Reorganization

Enable explicit SIM selection for Call Retry Scheduler, handle rescheduling unanswered call retries (cancel previous schedule when user reschedules), move App lock, Block Screenshots, and Audit log to a new Security settings screen, and move Default Phone App card to SIM & Calling settings screen.

## User Review Required

> [!IMPORTANT]
> **Settings Navigation Reorganization**:
> - **Settings -> Security**: Houses **App lock**, **Block screenshots**, and **Audit log**.
> - **Settings -> SIM & Calling**: Houses **Default phone app** alongside SIM preferences and Smart Redial.

> [!NOTE]
> **Call Retry Behavior**:
> - Users will see the target SIM on the Smart Redial sheet (with carrier label if available) and can pick a different SIM before scheduling.
> - If an auto-retry call goes unanswered, the Smart Redial sheet allows the user to schedule again. Arming a new schedule automatically cancels any existing schedule for that number. If dismissed without scheduling, no new retry is scheduled.

## Proposed Changes

---

### Security Settings & Settings Screen Reorganization

#### [NEW] [security_screen.dart](file:///l:/Android/SreerajPContactSphere/lib/screens/security_screen.dart)
- Create `SecurityScreen` (`lib/screens/security_screen.dart`).
- Move/integrate the following cards:
  - `_AppLockCard` (App lock settings: Off, Device lock, App PIN)
  - `_ScreenshotGuardCard` (Block screenshots switch)
  - `Audit Log` card (navigates to `AuditLogScreen`)

#### [MODIFY] [settings_screen.dart](file:///l:/Android/SreerajPContactSphere/lib/screens/settings_screen.dart)
- Remove direct cards for `_AppLockCard`, `_ScreenshotGuardCard`, `Audit Log`, and `_DefaultDialerCard` from the main `SettingsScreen` list.
- Add a new `Security` card navigating to `SecurityScreen`.
- Move `_DefaultDialerCard` definition/usage so it can be rendered inside `SimSettingsScreen`.

#### [MODIFY] [sim_settings_screen.dart](file:///l:/Android/SreerajPContactSphere/lib/screens/sim_settings_screen.dart)
- Integrate `_DefaultDialerCard` into `SimSettingsScreen` so "Default phone app" resides under **Settings -> SIM & Calling**.

---

### Call Retry Scheduler SIM Selection & Rescheduling

#### [MODIFY] [smart_redial_service.dart](file:///l:/Android/SreerajPContactSphere/lib/services/smart_redial_service.dart)
- Add `cancelTasksForNumber(String phoneNumber)` to cancel any active pending smart redial task matching the target phone number.
- In `scheduleAutoRedial(...)`, invoke `cancelTasksForNumber(...)` before creating and arming the new retry task to ensure previous schedules for that number are cancelled when a new one is scheduled.

#### [MODIFY] [smart_redial_sheet.dart](file:///l:/Android/SreerajPContactSphere/lib/widgets/smart_redial_sheet.dart)
- Load available SIM accounts via `SimService().list()`.
- Add a SIM selection section showing the currently selected SIM (defaulting to the original call's SIM or default SIM) and allowing the user to select/change SIM before arming auto-retry.
- Pass the user-selected `simId` into `scheduleAutoRedial(...)`.

---

## Verification Plan

### Automated Tests
- Run static analysis: `flutter analyze`
- Run existing widget and unit tests: `flutter test`

### Manual Verification
- Verify navigation:
  - `Settings` -> `Security` -> App lock, Block screenshots, Audit log.
  - `Settings` -> `SIM & Calling` -> Default phone app.
- Verify Smart Redial sheet:
  - Check that SIM selector displays SIM options.
  - Change SIM and verify scheduled task receives chosen `simId`.
  - Re-schedule retry after an unanswered retry and verify previous schedule is replaced.
