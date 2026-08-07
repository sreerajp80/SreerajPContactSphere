# Plan: Hide "Meetiversary" when the contact is Self ("This is me")

**Status:** completed

## Issue

Meetiversary means "the day you met this person" — meaningless for your own (Self) record.
When the "This is me" toggle is on, the Meetiversary field should not be shown.

## Files to change

- **`lib/screens/add_edit_contact_screen.dart`**
  - In `_personalSection()`, only render the Meetiversary `_dateField` (and its leading
    `SizedBox(height: 10)`) when `!_isSelf`. Because the toggle calls `setState`, the field
    appears/disappears live as it's flipped.
  - In `_save()`, when `_isSelf` is true, persist `meetiversary` as `null` (don't save a value
    that the user can no longer see/edit).

## Verification

- `flutter analyze` clean.
- Manual: toggle "This is me" on → Meetiversary field disappears; toggle off → it reappears.
  Saving a Self contact stores no meetiversary.
