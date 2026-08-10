# Plan: Audit and Update Features Reference Document (`docs/features.md`)

## Target File
- `docs/features.md`

## Summary of Findings & Issues Identified

1. **Duplicate Entry in Known Gaps**:
   - Lines 500-507 in `docs/features.md` contain duplicate consecutive bullet points for **Call recording** under the "Known gaps / not yet implemented" section.

2. **Audit Entry Detail Screen Documentation**:
   - Section 1 (Audit log) mentions audit log features, but does not explicitly document the `AuditEntryDetailScreen` (`lib/screens/audit_entry_detail_screen.dart`), which enables viewing individual audit entry snapshots, raw JSON payload diffs, timestamp, actor, and hash chain details.

3. **Notification Scheduler Service Clarification**:
   - Section 12 & 13 mention native notification scheduling (`NotificationSchedulerManager.kt`), but can be enhanced by referencing the Dart-side `NotificationSchedulerService` (`lib/services/notification_scheduler_service.dart`) which manages exact alarm notification task reconciliation, scheduling, task persistence, and permission checks across the app.

## Proposed Changes

### `docs/features.md`
- Remove the duplicated "Call recording" bullet point in the "Known gaps / not yet implemented" section.
- Enhance Section 1 (Audit log) to explicitly document the Audit Entry Detail screen for viewing detailed snapshot JSON diffs and verification details.
- Enhance Section 12/13 to include explicit reference to `NotificationSchedulerService` for Dart-side exact notification management and status tracking.

## Verification
- Re-inspect `docs/features.md` to confirm formatting, accuracy, and completeness.
- Run `flutter analyze` if applicable to ensure workspace integrity.
