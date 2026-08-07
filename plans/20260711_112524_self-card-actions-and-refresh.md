# Self card: hide Call/Email actions & refresh list after Settings

**Status:** completed

## Issues

Two problems with the pinned **Self** ("YOU") contact card:

1. **Wrong action buttons.** When the Self card is expanded in the contact list,
   it shows the same quick-action row as any other contact: **Call**, **Profile**,
   **Email**, **Delete**. Calling or emailing yourself makes no sense, so these
   buttons should not appear on the Self card.

2. **List does not refresh after adding Self in Settings.** When the user creates
   their Self record through **Settings → Contacts → Add Me**, the contact list
   does not show the new "YOU" card on return. It only appears after switching to
   **Favorites** and back — because that toggle triggers a full `_reload()` which
   re-reads the Self record. Opening Settings from the list menu never reloads.

## Root cause

- Issue 1: `_buildContactCard` in `lib/screens/contact_list_screen.dart` renders a
  fixed four-button row (`_QuickAction` Call/Profile/Email/Delete) around
  lines 1394–1434, with no special case for `contact.isSelf`.
- Issue 2: the `'settings'` case of the overflow-menu handler
  (`lib/screens/contact_list_screen.dart`, ~lines 778–782) pushes `SettingsScreen`
  but does **not** call `_reload()` after it returns, unlike other mutating paths.

## Files to change

- `lib/screens/contact_list_screen.dart`
  - In the expanded action row: when `contact.isSelf`, show only the **Profile**
    action (full width) and drop Call, Email, and Delete. For non-self contacts,
    keep the existing Call / Profile / Email / Delete row unchanged.
  - In the overflow-menu handler's `'settings'` case, `await` the navigation and
    call `_reload()` afterwards so a newly added/edited Self is reflected.

## Plan

1. Wrap the four `Expanded(_QuickAction(...))` children so that for
   `contact.isSelf` the row contains a single full-width **Profile** button
   (`Icons.person_outline`, `onTap: () => _openContact(contact)`), and otherwise
   the current four buttons. Keep spacing/style consistent with existing rows.
2. Change the `'settings'` case to `await Navigator...push(...)` then
   `if (mounted) await _reload();` (mirroring the pattern already used elsewhere
   in the handler).

## Testing

- `flutter analyze` clean for the edited file.
- Manual: expand the Self card → only Profile shows. Add Self via
  Settings → Contacts → Add Me → on return the "YOU" card appears without needing
  the Favorites round-trip.

## Notes

- Delete is intentionally removed from the Self card's expanded row; the Self
  record can still be edited via Profile. (If you want to keep a Delete on the
  Self card, say so and I'll include it.)
