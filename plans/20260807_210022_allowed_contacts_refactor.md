# Plan: Refactor Quiet Hours Allowed Tiers to Allowed Contacts (Tags, Relationships, & Specific Users)

## Issue
The current Quiet Hours exception logic only filters callers by pre-defined relationship tiers. The user requested that:
1. The section "Allowed Tiers" be renamed to "Allowed Contacts".
2. Users can select and combine **Relationships**, **Tags**, and **Specific Contacts/Users** to define who is allowed to ring through during quiet hours.

## Target Files to Modify
1. `lib/state/app_settings.dart`
   - Add state and SharedPreferences persistence for allowed tags (`_relationshipQuietHoursAllowedTags`) and allowed contact IDs (`_relationshipQuietHoursAllowedContactIds`).
   - Add setters `setRelationshipQuietHoursAllowedTags` and `setRelationshipQuietHoursAllowedContactIds` which trigger `QuietHoursService().syncQuietHoursMirror()`.

2. `lib/services/quiet_hours_service.dart`
   - Update `resolveAllowedNumbers` to accept `allowedTiers`, `allowedTags`, and `allowedContactIds`.
   - Resolve contact IDs matching allowed tags from the `tags` database table.
   - Include direct contact IDs from `allowedContactIds`.
   - Update `syncQuietHoursMirror` to pass tiers, tags, and contact IDs.

3. `lib/screens/relationship_quiet_hours_screen.dart`
   - Rename UI heading "Allowed Tiers (Ring Through)" to "Allowed Contacts (Ring Through)".
   - Add sub-sections under Allowed Contacts:
     - **Relationships** filter chips (ICE, Immediate Family, Extended Family, Friends, Work, Starred).
     - **Tags** section with chip list and "+ Add Tag" sheet/picker.
     - **Specific Contacts** section with chip list and "+ Add Contact" multi-picker sheet using `ContactMultiPickerSheet`.
   - Display total calculated active allowed numbers.

## Verification
1. Run `flutter analyze` to ensure zero static lint errors.
2. Run `flutter test` to ensure existing tests pass.
