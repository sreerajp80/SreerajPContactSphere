# Dialer: fixed false "Add to contacts" after tapping a saved contact

Implements [plans/20260703_091109_dialer-tap-false-add-to-contacts.md](../plans/20260703_091109_dialer-tap-false-add-to-contacts.md).

## Problem

Tapping a suggestion / favorite / top-contact row on the Dialer filled the number field
but then showed the "Add to contacts" card and "No saved contact for this number yet.",
even though the tapped number belongs to a saved contact.

## Change

`lib/screens/dialer_screen.dart` — `_selectSuggestion`:

- Removed `_suggestions = const []` from the `setState`.
- After filling the number and setting the linked contact, call `_refreshSuggestions()`
  so `findByPhoneFragment(_number)` repopulates the strip with the matching contact
  instead of leaving it empty.

The empty-list state was what pushed `_strip` into its "no match → Add to contacts"
branch; re-querying keeps the contact visible and removes the false prompt. The
call-button linkage (`_linkedContactId` / `_linkedName`) and the existing early-return
for a favorite with no number (opens `ContactDetailScreen`) are unchanged.

## Verification

- `flutter analyze lib/screens/dialer_screen.dart` → no issues.
