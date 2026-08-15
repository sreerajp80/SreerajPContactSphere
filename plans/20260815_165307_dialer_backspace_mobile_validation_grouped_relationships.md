# Plan: Dialer Continuous Backspace, Mobile Number Validation, and Grouped Relationships

## Issue Description
1. **Dialer Backspace Press & Hold**: Currently in `DialerScreen`, long-pressing the backspace key immediately clears the entire input field via `_clear()`, rather than continuously auto-repeating backspace deletion character-by-character until released or empty.
2. **Mobile Number Validation & Formatting**: When typing a mobile number, the app should ensure a valid number format is typed based on number length and country code (detecting/checking against country rules via `phone_numbers_parser`).
3. **Relationship Screen Grouping**: When a contact has many relationships (e.g. 15-20), radial spokes and midpoint text labels collide and overlap heavily. The screen needs to group contacts by relationship type (e.g. "Colleagues (4)", "Cousin Brothers (2)"), and allow tapping a relationship category to display/expand all contacts under that relation.

## Proposed Fix

### 1. `lib/screens/dialer_screen.dart`
- Implement continuous backspace repeating timer (`_startContinuousBackspace`, `_stopContinuousBackspace`).
- On tap / pointer down, delete one character immediately; after 300ms, repeat every 70ms while held down.
- Display live country detection and mobile format/validation hint in the number display bar.

### 2. `lib/utils/phone_normalizer.dart`
- Add `validateMobileNumber(String raw, {required String defaultIso})` and `formatMobileNumber(String raw, {required String defaultIso})` using `phone_numbers_parser`.
- Provide validity, possible length check, national/international formatting, and detected ISO/calling code.

### 3. `lib/screens/add_edit_contact_screen.dart`
- Display inline length/format validation helpers for phone inputs matching the selected country code chip.
- Validate mobile format when saving.

### 4. `lib/screens/relationship_screen.dart`
- Group relationships by `relationshipType`.
- Render grouped category nodes in the orbital ring with contact count badges and avatar stacks, eliminating spoke clutter and label collisions.
- When tapping a relationship group, open an expanded sheet / drill-down view showing all contacts in that group with quick actions (Call, View Profile, Center Sphere, Edit, Remove).
- Provide an AppBar toggle between Grouped Mode (default) and All / Flat Mode.

## Files to Change
- `lib/screens/dialer_screen.dart`
- `lib/utils/phone_normalizer.dart`
- `lib/screens/add_edit_contact_screen.dart`
- `lib/screens/relationship_screen.dart`
- `test/phone_normalizer_test.dart` (or new unit tests)
