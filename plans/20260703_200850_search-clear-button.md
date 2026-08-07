# Search clear (X) button + keyboard dismiss

**Status:** completed

## Issue

The contact list search field ([lib/screens/contact_list_screen.dart](../lib/screens/contact_list_screen.dart), `_buildSearch`) has no way to clear the typed query other than backspacing it out. There is also no way to dismiss the keyboard from the field itself. The `TextField` currently has neither a `TextEditingController` nor a `FocusNode` attached.

## Files to change

- `lib/screens/contact_list_screen.dart` — only file.

## Plan

1. Add two state fields to `_ContactListScreenState`:
   - `final TextEditingController _searchController = TextEditingController();`
   - `final FocusNode _searchFocusNode = FocusNode();`
   Dispose both in `dispose()`.
2. In `_buildSearch`, attach `controller: _searchController` and `focusNode: _searchFocusNode` to the `TextField`.
3. Add a `suffixIcon` to the `InputDecoration`: an X (`Icons.close`) icon button, shown only while `_searchQuery` is non-empty (hidden when the box is empty, matching the app's clean look). On tap it will:
   - `_searchController.clear()`
   - `_filterContacts('')` — resets `_searchQuery` and restores the full list (existing logic, already calls `setState`)
   - `_searchFocusNode.unfocus()` — moves focus off the search box, which hides the keyboard
4. Ensure the suffix icon visibility updates as the user types: `_filterContacts` already runs through `setState` for both the empty and non-empty paths (the non-empty path via `_runSearch`), but the icon should appear on the *first typed character* immediately — `_runSearch` only calls `setState` after the async DB query returns. To make the X appear/disappear instantly, wrap the `_searchQuery = query` assignment inside `_filterContacts` with `setState`.

Styling: the X icon will use the theme's muted/hint color so it stays secondary to the accent-colored search icon, consistent with the existing design system.

## Out of scope

- No changes to search behavior/results, other screens, or the dialer.
