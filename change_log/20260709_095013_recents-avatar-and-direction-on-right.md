# Change log: Recents — avatar before name, direction arrow on the right

Implements plan
[plans/20260709_095013_recents-avatar-and-direction-on-right.md](../plans/20260709_095013_recents-avatar-and-direction-on-right.md).

## What changed

On the **Recents** (call history) screen, each row was rearranged:

- **Left (leading):** now shows the contact's profile photo, or an
  initial-letter avatar, instead of the call-direction arrow circle. Unknown
  numbers (whose "name" is just the raw digits) show a neutral person icon.
- **Right (trailing):** the call-direction arrow (incoming / outgoing / missed /
  blocked) now sits just left of the green call-back button.

To get the photo into the row, the contact's `photo_path` is now carried
through the call-history read path.

## Files changed

1. **lib/models/call_record.dart**
   - Added a nullable `photoPath` field, its constructor parameter, and read it
     from `map['photo_path']` in `fromJoinedMap`.

2. **lib/repositories/call_log_repository.dart**
   - `recentCalls` query now also selects `c.photo_path AS photo_path` from the
     joined `contacts` row (null for unlinked calls).

3. **lib/screens/call_history_screen.dart**
   - Added `import 'dart:io';` for `File`/`FileImage`.
   - `_callCard`: `leading` now calls a new `_avatar(call, accent)` helper;
     `trailing` is now a `Row` holding the direction-arrow `Icon` followed by the
     green call-back `IconButton`.
   - New `_avatar` helper: shows the photo when the file exists, else the first
     letter of a named contact, else `Icons.person_outline`. Uses the same
     accent-tinted rounded-square style as the contact list avatar.
   - Tap / long-press / call-back behaviour and the blocked/missed colours are
     unchanged. `_typeIcon` is unchanged (now consumed in the trailing).

## Verification

- `flutter analyze` on the three changed files: **No issues found.**
