# Smart Redial & "Reach Me" Mode Implementation Plan

**Date**: 2026-07-27 20:16:54
**Plan**: Implement Smart Redial / "Reach Me" mode on failed or unanswered calls.

## Overview
When a call fails, goes unanswered, or is rejected/missed (e.g. 0-second duration or busy/unanswered state), ContactSphere will offer:
1. **One-tap Auto-Retry after X minutes**: Schedules an automatic timer with local notification/1-tap auto-redial after X minutes (default 5 min, or pick 1m, 3m, 5m, 10m, 15m).
2. **One-tap "Trying to reach you" Message**: Sends a pre-configured text message ("Hi, I tried reaching you just now. Please call or text back when you see this!") via SMS/Telecom channel.

---

## Proposed Changes

### Core Services & Logic

#### [NEW] [smart_redial_service.dart](file:///l:/Android/SreerajPContactSphere/lib/services/smart_redial_service.dart)
- Singleton/Service to manage active auto-redial tasks (`SmartRedialTask`).
- Methods to schedule auto-retry after `X` minutes, fire notification via `flutter_local_notifications`, execute or cancel scheduled redials.
- Methods to send pre-set "Trying to reach you" message via SMS channel / `url_launcher`.
- Reads and updates settings: `smartRedialEnabled`, `defaultRedialDelayMinutes`, `presetReachMeMessage`.

#### [MODIFY] [app_settings.dart](file:///l:/Android/SreerajPContactSphere/lib/state/app_settings.dart)
- Add preferences keys and state for:
  - `smartRedialEnabled`: bool (default `true`).
  - `smartRedialDefaultDelayMinutes`: int (default `5`).
  - `presetReachMeMessage`: String (default `"Hi, I tried reaching you just now. Please call or text back when you see this!"`).

---

### UI Components & Sheets

#### [NEW] [smart_redial_sheet.dart](file:///l:/Android/SreerajPContactSphere/lib/widgets/smart_redial_sheet.dart)
- Glassmorphic modal bottom sheet (`showSmartRedialSheet`).
- Displays caller name/number with warning badge ("Call Unanswered / Failed").
- **Section 1**: Auto-retry delay picker chips (1m, 3m, 5m, 10m, 15m) + "Schedule Auto-Redial in X min" button.
- **Section 2**: "Send Preset Message" preview tile + 1-tap Send button + edit icon.

#### [MODIFY] [call_lifecycle_mixin.dart](file:///l:/Android/SreerajPContactSphere/lib/widgets/call_lifecycle_mixin.dart)
- In `_reconcilePendingCall()`, when a call ends with 0 duration or failed/unanswered state, offer `showSmartRedialSheet(...)` if `smartRedialEnabled` is true.

#### [MODIFY] [recents_screen.dart](file:///l:/Android/SreerajPContactSphere/lib/screens/recents_screen.dart)
- Add a "Smart Redial / Reach Me" quick option to unanswered/missed/failed call log entries.

#### [MODIFY] [settings_screen.dart](file:///l:/Android/SreerajPContactSphere/lib/screens/settings_screen.dart)
- Add "Smart Redial & Reach Me" setting tile under SIM & calling section.
- Allows toggling prompt, changing default delay X, editing preset "trying to reach you" text, and viewing active auto-redial tasks.

---

### Tests

#### [NEW] [smart_redial_service_test.dart](file:///l:/Android/SreerajPContactSphere/test/smart_redial_service_test.dart)
- Unit tests for scheduling auto-redial tasks, canceling tasks, formatting default message, and validating settings.

---

## Verification Plan

### Automated Tests
```bash
flutter analyze
flutter test test/smart_redial_service_test.dart
flutter test
```

### Manual Verification
1. Place a call that goes unanswered or ends immediately (0 sec).
2. Observe the Smart Redial & Reach Me sheet offering 1-tap auto-retry and 1-tap SMS message.
3. Test scheduling auto-retry for 1 minute and verify notification/redial workflow.
4. Test sending preset message.
5. Check Settings screen to customize preset message and default retry delay.
