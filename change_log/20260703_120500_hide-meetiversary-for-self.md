# Change log: Hide "Meetiversary" for the Self contact

Implements [plans/20260703_120346_hide-meetiversary-for-self.md](../plans/20260703_120346_hide-meetiversary-for-self.md).

## What changed

`lib/screens/add_edit_contact_screen.dart`:
- `_personalSection()`: the Meetiversary date field (and its leading spacing) is now wrapped in
  `if (!_isSelf) ...[ ... ]`, so it is hidden when the "This is me" (Self) toggle is on.
  It shows/hides live because the toggle calls `setState`.
- `_save()`: when `_isSelf` is true, `meetiversary` is persisted as `null` so no hidden value
  is stored on a Self record.

## Verification
- `flutter analyze` — **clean** (no issues).
