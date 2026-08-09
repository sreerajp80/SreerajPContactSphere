# Plan: Allow Selection of Specific Relationship Types in Allowed Contacts

## Issue
The user specified that they do NOT want broad tier groupings ("Immediate Family", "Extended Family", "Friends & Social", "Work & Professional"). Instead, they want to be able to pick specific **Relationship Types** (e.g. "Father", "Mother", "Brother", "Spouse", "Colleague", etc., as defined in relationship presets/custom relationship names) alongside Emergency (ICE), Starred Contacts, Tags, and Specific Contacts.

## Target Files to Modify
1. `lib/state/app_settings.dart`
   - Store selected specific relationship labels in `_relationshipQuietHoursAllowedTiers` / `_relationshipQuietHoursAllowedRelationships` (e.g. `['emergency', 'starred', 'father', 'mother', 'spouse']`).

2. `lib/services/quiet_hours_service.dart`
   - Update `resolveAllowedNumbers` so that relationship matching matches the specific selected relationship labels directly against `relationships.relationship_type` (case-insensitive) for self-profile links, in addition to supporting `emergency` (ICE) and `starred`.

3. `lib/screens/relationship_quiet_hours_screen.dart`
   - Remove broad category groupings ("Immediate Family", "Extended Family", "Friends & Social", "Work & Professional").
   - Display chips for selected relationship types (plus Emergency ICE and Starred) with an **"+ Add Relationship"** picker sheet that lists available relationship labels (from `settings.relationshipNames` / `RelationshipTypes.presets`).

4. `test/quiet_hours_service_test.dart`
   - Update unit test cases to verify resolving numbers for specific relationship labels like "Father" or "Colleague".

## Verification
1. Run `flutter analyze` to ensure zero static lint errors.
2. Run `flutter test` to ensure all tests pass.
