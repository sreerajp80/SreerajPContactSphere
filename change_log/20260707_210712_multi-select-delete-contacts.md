# Change log: Multi-select and bulk delete contacts

Implements [plans/20260707_210131_multi-select-delete-contacts.md](../plans/20260707_210131_multi-select-delete-contacts.md).

## What changed

All changes are in `lib/screens/contact_list_screen.dart`. No services, models, or
database changes; no new dependencies.

Added an Android-style multi-select mode to the contacts list so several contacts
can be deleted in one action.

### State
- `bool _selectionMode` — whether multi-select is active.
- `Set<String> _selectedKeys` — selected contacts, keyed by a stable string
  (`_keyFor`): `id:<id>` for stored contacts, else `dev:<deviceId>`. This survives
  paging and reloads.

### New methods
- `_keyFor`, `_isSelected` — selection key/lookup helpers.
- `_enterSelection` — long-press enters selection mode with that contact selected.
- `_toggleSelected` — tap/long-press toggles a contact; deselecting the last one
  leaves selection mode.
- `_exitSelection` — clears the selection and leaves the mode.
- `_selectAllVisible` — selects every visible (filtered) contact, or clears if all
  are already selected.
- `_selectedContacts` — resolves selected keys back to loaded `Contact` objects.
- `_confirmDeleteSelected` — one "Delete N contacts?" confirmation, then loops
  `ContactSyncService.deleteContact` (removes from app DB and, when linked, the
  device address book), counts successes/failures, shows a summary snackbar,
  exits selection mode, and reloads.
- `_buildSelectionHeader` — contextual header: cancel (X), "N selected",
  select-all, and the bulk-delete action.

### Behaviour changes
- **Long-press a card** now enters selection mode (was: single-delete confirm).
  Single delete is still available from the expanded card's Delete button.
- **Tap in selection mode** toggles that card's selection instead of
  expanding/opening.
- Selected cards show a leading check indicator and an accent border/tint.
- Card expansion is suppressed while selecting (`isOpen` is forced false).
- `_buildHeader` renders `_buildSelectionHeader` while selecting.
- The add (+) FAB is hidden while selecting.
- The pinned **Self** contact is not selectable (passed `selectable: false`); its
  long-press keeps the original single-delete confirmation.

## Verification
- `flutter analyze lib/screens/contact_list_screen.dart` — no issues found.
