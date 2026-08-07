# Focus the new field after "Add phone" / "Add email"

**Status:** completed

## Issue

On the Add / Edit contact screen, tapping **Add phone**, **Add email** (or
**Add social link**) creates a new empty row, but the keyboard focus stays where
it was. The user must tap the new value field before typing. The focus should
move automatically into the new row's value field so the user can type right away.

## Where the code is

- [lib/screens/add_edit_contact_screen.dart](../lib/screens/add_edit_contact_screen.dart)
  - `_LabeledEntry` class (around line 2387) — model for each phone/email/social row.
  - `_bareTextField(...)` (around line 2125) — the shared text field builder.
  - `_repeaterRow(...)` (around line 1492) — builds the value field for a row.
  - `_addEntry(...)` (around line 712) — adds a new row via `setState`.
  - `dispose()` (around line 431) — disposes each entry.

## Plan for the fix

1. **`_LabeledEntry`**: add a `FocusNode valueFocus` field, created in the
   constructor, and dispose it in `_LabeledEntry.dispose()`.

2. **`_bareTextField`**: add an optional `FocusNode? focusNode` parameter and
   pass it to the underlying `TextField`.

3. **`_repeaterRow`**: pass `focusNode: entry.valueFocus` to the value
   `_bareTextField` so each row's value field is wired to its focus node.

4. **`_addEntry`**: after adding the new entry and calling `setState`, request
   focus on the new entry's `valueFocus` using
   `WidgetsBinding.instance.addPostFrameCallback` (so focus is requested after
   the new row is built into the tree).

This covers phones, emails, and social links, since all three use `_addEntry`
and `_repeaterRow`.

## Files to change

- `lib/screens/add_edit_contact_screen.dart`

## Notes / risks

- Low risk: only adds a focus node per row and one post-frame focus request.
- No behaviour change to existing rows other than being focusable by node.
