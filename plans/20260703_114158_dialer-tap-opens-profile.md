# Dialer: tap a Favorite / Top contact to open their profile

**Status:** completed

## Issue

On the Dialer screen's empty state (no digits typed), the **Favorites** and
**Top contacts** lists show contact rows. Tapping a row currently calls
`_selectSuggestion(m)`, which just fills the number field. Opening the contact's
profile is only possible via a **long-press** (`_openContact`), which is not
discoverable. The user expects a tap on these rows to navigate to the contact's
profile in Contacts (the row already has a dedicated call button for placing a
call).

The same `_matchRow` widget is also used for the live match suggestions shown
while typing digits. For that case the tap-to-fill behavior is correct (the user
is composing a number), so the change must be scoped to the Favorites/Top
contacts rows only.

## Files to change

- `lib/screens/dialer_screen.dart`

## Plan

`_matchRow(...)` already takes a `favorite` flag that is `true` for the
Favorites / Top-contacts rows and `false` for live suggestion rows. Use it to
branch the tap behavior:

- **Favorite / Top-contact rows** (`favorite == true`): `onTap` opens the
  contact profile via the existing `_openContact(m.contactId)`. The `onLongPress`
  (currently also `_openContact`) becomes redundant; set it to `null` to keep
  the interaction unambiguous. The call button is unchanged.
- **Suggestion rows** (`favorite == false`): keep current behavior — `onTap`
  runs `_selectSuggestion(m)` (fills the number field) and `onLongPress` runs
  `_openContact(m.contactId)`.

Concretely, in `_matchRow` change:

```dart
onTap: () => _selectSuggestion(m),
onLongPress: () => _openContact(m.contactId),
```

to:

```dart
onTap: favorite
    ? () => _openContact(m.contactId)
    : () => _selectSuggestion(m),
onLongPress: favorite ? null : () => _openContact(m.contactId),
```

No other files or logic are affected. `_openContact` already pushes
`ContactDetailScreen(contactId: ...)` and reloads favorites on return.

## Verification

- `flutter analyze` stays clean for this file.
- Manual: on the Dialer tab with no digits typed, tapping a Favorite or Top
  contact opens their profile; the call button still places a call; while typing,
  tapping a suggestion still fills the number field.
