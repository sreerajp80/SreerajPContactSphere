# Dialer: tapping a saved contact falsely shows "Add to contacts"

**Status:** completed

## Issue

On the Dialer screen, tapping a suggestion / favorite / top-contact row (e.g. [name] ·
JIO · [phone]) fills the number field correctly, but the strip below then shows the
**"Add to contacts"** card and the text **"No saved contact for this number yet."** —
even though that number *is* saved to a contact.

### Root cause

In [`_selectSuggestion`](../lib/screens/dialer_screen.dart#L180-L192) the tap handler
does:

```dart
setState(() {
  _number = match.number;
  _linkedContactId = match.contactId;
  _linkedName = ...;
  _suggestions = const [];   // <-- clears the match list
});
```

Then [`_strip`](../lib/screens/dialer_screen.dart#L364-L398) decides what to render
purely from `_number` and `_suggestions`:

- `_number` non-empty **and** `_suggestions` non-empty → show matches.
- `_number` non-empty **and** `_suggestions` empty → show "Add to contacts" +
  "No saved contact for this number yet." ← we land here after a tap.

Because the tap clears `_suggestions` and never re-queries, the "no match" branch fires
despite `_linkedContactId` being set to a real contact. The database and
`findByPhoneFragment` are correct; this is purely a UI state bug.

## Fix

Make the tap keep showing the matched contact instead of clearing the list. In
`_selectSuggestion`, after filling the number and setting the linked contact, re-run the
suggestion query instead of blanking `_suggestions`:

- Set `_number`, `_linkedContactId`, `_linkedName` as today.
- Replace `_suggestions = const []` by calling `_refreshSuggestions()` (which queries
  `findByPhoneFragment(_number)` and repopulates the strip with the matching contact).

This keeps the tapped contact visible as a match, links it for the call button, and
removes the false "Add to contacts" prompt. The stale-response guard (`_queryToken`) in
`_refreshSuggestions` already handles ordering.

Edge case preserved: the existing early-return for a favorite with an empty number
(opens `ContactDetailScreen`) stays unchanged.

## Files to change

- `lib/screens/dialer_screen.dart` — rewrite the body of `_selectSuggestion` to
  re-query suggestions rather than clearing them.

## Verification

- `flutter analyze` clean for the edited file.
- Manual: on Dialer, tap a favorite/top contact with a saved number → number fills, the
  contact still appears as a match, **no** "Add to contacts" card. Tap the call button →
  call is placed against the linked contact.
