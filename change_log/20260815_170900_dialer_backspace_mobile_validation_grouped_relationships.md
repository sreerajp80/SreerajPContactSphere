# Change Log: Dialer Continuous Backspace, Mobile Number Validation, and Grouped Relationships

## Summary
Implemented three major user-requested improvements across the Dialer, Contacts Add/Edit, and Relationship screens:
1. **Continuous Backspace on Press & Hold**: In `DialerScreen`, pressing and holding the backspace button triggers an immediate deletion followed by continuous auto-repeating deletion character by character until touch release or the text field is empty.
2. **Mobile Number Validation & Formatting**:
   - Extended `PhoneNormalizer` with `validateNumber` and `formatForDisplay` powered by `phone_numbers_parser` to check length and mobile format against country codes.
   - Updated `DialerScreen` with live formatting and validation status indicator below the dialed digits.
   - Updated `AddEditContactScreen` with inline validation warnings when typing phone numbers and pre-save validation against country code rules.
3. **Grouped Relationships Sphere**:
   - Grouped related contacts by `relationshipType` in `RelationshipScreen` to eliminate spoke and label collisions for contacts with large numbers of relationships.
   - Designed grouped category nodes with count badges (`_GroupNodeAvatar`) and tap-to-expand details sheet (`_showGroupDetailsSheet`) listing all contacts under that relation with direct Call, Profile, Recenter, and Edit actions.
   - Added an AppBar action toggle allowing smooth switching between Grouped Mode (default) and Flat / Individual View.

## Implemented Plan Reference
- Implements [plans/20260815_165307_dialer_backspace_mobile_validation_grouped_relationships.md](../plans/20260815_165307_dialer_backspace_mobile_validation_grouped_relationships.md)

## Modified Files
- `lib/utils/phone_normalizer.dart`
- `lib/screens/dialer_screen.dart`
- `lib/screens/add_edit_contact_screen.dart`
- `lib/screens/relationship_screen.dart`
- `test/phone_normalizer_test.dart`

## Verification
- `flutter analyze`: 0 issues found.
- `flutter test`: 425 unit and widget tests passed.
