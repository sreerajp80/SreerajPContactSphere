# Plan: Multi-select and bulk delete contacts

**Status:** completed

## Issue

The contacts list only lets you delete one contact at a time. A long-press on a
card opens the single-delete confirmation, and the expanded card has a per-contact
Delete button. There is no way to pick several contacts and delete them together.
The user needs a way to select multiple contacts and delete them in one action.

## Files to change

- `lib/screens/contact_list_screen.dart` — add a selection mode to the list and a
  bulk-delete action. This is the only file that needs changing; the delete path
  (`ContactSyncService.deleteContact`, which removes from both the app DB and the
  device book) already exists and works per contact, so bulk delete just loops over
  it.

## The fix (design)

Add a standard Android-style "selection mode" to `_ContactListScreenState`.

### New state
- `bool _selectionMode = false` — whether the list is in multi-select mode.
- `Set<String> _selectedKeys = {}` — keys of the currently selected contacts.
- `String _keyFor(Contact c)` — a stable key per contact:
  `id:<id>` when it has an app id, else `dev:<deviceId>`. This covers both stored
  and device-only contacts. Contacts with neither id (should not happen in the
  list) are treated as not selectable.

### Entering / leaving selection mode
- **Long-press a card** now enters selection mode and selects that contact
  (replacing the current long-press → single-delete). Single delete is still
  available from the expanded card's Delete button, so no capability is lost.
- Provide `_exitSelection()` that clears `_selectedKeys` and sets
  `_selectionMode = false`. Called by the close (X) button and after a bulk delete.
- The **Self** pinned contact is excluded from selection (deleting the phone-owner
  record is a special action). Long-press on Self keeps today's single-delete
  confirmation. Its card shows no checkbox.

### Tapping while in selection mode
- In `_buildContactCard`, when `_selectionMode` is true a card tap toggles its
  selection (`_toggleSelected(contact)`) instead of expanding/opening. Toggling the
  last selected contact off exits selection mode.

### Visual changes to a card in selection mode
- Show a leading circular check indicator (checked/unchecked) in place of the
  normal tap-to-expand behavior cue.
- Selected cards get an accent-tinted border/background so the selection is clear.
- Quick-action expansion is disabled while selecting (tap toggles instead).

### Selection header
- When `_selectionMode` is true, `_buildHeader` renders a contextual header instead
  of the normal title row:
  - a close (X) button → `_exitSelection()`,
  - the selected count ("N selected"),
  - a "select all" toggle that selects/clears every currently loaded, selectable
    contact in the filtered view,
  - a delete (trash) action → `_confirmDeleteSelected()`.
- The add (+) FAB is hidden while in selection mode to avoid clutter.

### Bulk delete
- `_confirmDeleteSelected()` shows one confirmation dialog: "Delete N contacts?"
  with a short note that linked contacts are also removed from the device address
  book (matching the single-delete wording).
- On confirm, resolve the selected keys back to `Contact` objects from the current
  `_filteredContacts` (plus loaded `_contacts`), then loop calling
  `_sync.deleteContact(c)`. Count successes and failures.
- Show a summary snackbar ("Deleted N contacts", and if any failed, "N failed").
- `_exitSelection()` then `_reload()` to refresh the list.

### Notes / edge cases
- Deletion is sequential (await each) to reuse the existing per-contact path and
  keep device-book writes serialized; the selected set is small in practice.
- If a reload/paging changes the loaded contacts, selection is keyed by id/deviceId
  so it survives; keys that no longer resolve to a loaded contact are simply skipped
  at delete time.
- No new dependencies, no DB/schema changes, no changes to services.

## Testing
- `flutter analyze` for the changed file.
- Manual: long-press to enter selection, tap several contacts, use select-all,
  delete, confirm the list refreshes and the count/summary are correct; verify
  exiting selection restores the normal header and FAB.
