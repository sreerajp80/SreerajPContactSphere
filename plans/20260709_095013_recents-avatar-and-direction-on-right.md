# Recents: avatar before name, call-direction arrow on the right

**Status:** completed

## What the user wants

On the **Recents** (call history) screen, each row currently shows:

- **Left (leading):** a coloured circle holding the call-direction arrow
  (incoming / outgoing / missed / blocked).
- **Title:** the caller name or number.
- **Right (trailing):** the green call-back button.

The user wants two changes:

1. **Show the contact's profile photo (or an initial-letter avatar) on the left,
   before the name** — instead of the direction-arrow circle.
2. **Move the call-direction arrow to the right**, shown together with the
   green dial (call-back) button.

## The issue / why it needs work

The row is built in [`_callCard`](lib/screens/call_history_screen.dart#L230) using
a `ListTile`:
- `leading` = the direction-arrow circle,
- `trailing` = the call button.

`CallRecord` does **not** currently carry the contact's photo path, so the
avatar has no image to show. The photo lives in the `contacts.photo_path`
column but the call-history query
([`recentCalls`](lib/repositories/call_log_repository.dart#L16)) does not select
it, and the model
([`CallRecord`](lib/models/call_record.dart)) has no field for it.

So the work is: carry the photo path through to the row, then re-arrange the
row's leading/trailing widgets.

## Files to change

1. **lib/models/call_record.dart**
   - Add a nullable `final String? photoPath;` field.
   - Add it to the constructor.
   - Read it in `fromJoinedMap` from `map['photo_path']`.

2. **lib/repositories/call_log_repository.dart**
   - In the `recentCalls` query, also select `c.photo_path` (it is null for
     unlinked calls, which is fine). No other query change needed.

3. **lib/screens/call_history_screen.dart** — rework `_callCard`:
   - **Leading (avatar):** reuse the same avatar style the contact list uses
     ([contact_list_screen.dart](lib/screens/contact_list_screen.dart#L1187)):
     a 40×40 rounded square tinted with the accent colour.
     - If `photoPath` is set and the file exists → show the photo
       (`DecorationImage` / `FileImage`).
     - Else, if the call is linked to a named contact → show the first letter
       of the name.
     - Else (unknown number) → show a neutral person icon
       (`Icons.person_outline`), since the "name" is just a phone number and a
       digit avatar reads badly.
   - **Trailing (direction arrow + dial):** replace the single call button with
     a `Row(mainAxisSize: MainAxisSize.min, ...)` holding:
     - a small direction-arrow `Icon` (the existing
       `_typeIcon(call.callType, accent)` icon + colour), then
     - the existing green call-back `IconButton`.
   - Keep the existing `title`, `subtitle`, tap / long-press behaviour, and the
     blocked/missed colouring unchanged.
   - `_typeIcon` stays as-is; it is simply used in the trailing now instead of
     the leading.

## Not changing

- No database schema change (the column already exists).
- No behaviour change to tap / call-back / long-press actions.
- Other screens are untouched.

## Verification

- `flutter analyze` stays clean for these files.
- Run the app and open **Recents**: rows show a photo/initial avatar on the
  left, and on the right the direction arrow sits just left of the green call
  button. Linked contacts with a photo show the photo; unknown numbers show a
  person icon.
