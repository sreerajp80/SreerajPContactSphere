# Change Log: Specific Relationship Selection for Allowed Contacts

**Date/Time:** 2026-08-07 21:11:11
**Implemented Plan:** [plans/20260807_211037_specific_relationships_allowed_contacts.md](file:///l:/Android/SreerajPContactSphere/plans/20260807_211037_specific_relationships_allowed_contacts.md)

## Summary of Changes

1. **`lib/services/quiet_hours_service.dart`**
   - Updated `resolveAllowedNumbers` to directly match selected specific relationship labels (e.g. `Father`, `Mother`, `Spouse`, `Brother`, `Colleague`, etc.) against relationship records in the database (`s.is_self = 1` AND `r.relationship_type`).

2. **`lib/screens/relationship_quiet_hours_screen.dart`**
   - Removed fixed broad tier groupings ("Immediate Family", "Extended Family", "Friends & Social", "Work & Professional").
   - Added **"+ Add Relationship"** sheet (`_showAddRelationshipSheet`), presenting all available relationship presets (Father, Mother, Spouse, Brother, Sister, Cousin, Colleague, Friend, etc.).
   - Rendered selected specific relationship labels as chips with delete icons to easily add or remove specific relationships.

3. **`test/quiet_hours_service_test.dart`**
   - Added test assertion for specific relationship label string resolution (`'Father'`).

## Verification

- `flutter analyze` completed cleanly with 0 issues.
- `flutter test` passed all 236 tests.
