# Search clear (X) button + keyboard dismiss

Implements [plans/20260703_200850_search-clear-button.md](../plans/20260703_200850_search-clear-button.md).

## Changed

- `lib/screens/contact_list_screen.dart` (only file):
  - Added `_searchController` (`TextEditingController`) and `_searchFocusNode` (`FocusNode`)
    state fields; both disposed in `dispose()`.
  - Attached the controller and focus node to the search `TextField` in `_buildSearch`.
  - Added a `suffixIcon` clear button (`Icons.close`, muted color) that is shown only while
    the search query is non-empty. Tapping it clears the field, restores the full contact
    list via `_filterContacts('')`, and unfocuses the search box so the keyboard hides.
  - `_filterContacts` now assigns `_searchQuery` inside `setState` so the X button
    appears/disappears immediately on the first typed/deleted character instead of after
    the async DB search returns.

## Verification

- `flutter analyze` reports no issues for `contact_list_screen.dart`.
