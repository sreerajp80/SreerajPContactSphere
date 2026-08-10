# Change Log: Audit and Update Features Reference Document (`docs/features.md`)

**Plan Implemented**: [plans/20260810_062107_audit_features_md.md](file:///l:/Android/SreerajPContactSphere/plans/20260810_062107_audit_features_md.md)

## Summary of Changes

1. **Deduplicated "Call recording" Entry**:
   - Removed the duplicate bullet point for "Call recording" in the "Known gaps / not yet implemented" section of [features.md](file:///l:/Android/SreerajPContactSphere/docs/features.md).

2. **Added Audit Entry Detail Screen Documentation**:
   - Updated Section 1 (Audit log) to document tapping an audit entry to view the [audit_entry_detail_screen.dart](file:///l:/Android/SreerajPContactSphere/lib/screens/audit_entry_detail_screen.dart) with before/after JSON payload diffs, timestamp, actor, and hash chain verification details.

3. **Enhanced Notification Scheduling Documentation**:
   - Updated Section 13 (Native Android platform features) to detail how native alarm scheduling interacts with [notification_scheduler_service.dart](file:///l:/Android/SreerajPContactSphere/lib/services/notification_scheduler_service.dart) on the Flutter side.

## Files Changed

- [docs/features.md](file:///l:/Android/SreerajPContactSphere/docs/features.md)
