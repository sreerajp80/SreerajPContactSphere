# Recents card split-tap: left opens contact, right dials

Implements plan
[plans/20260717_185910_recents-split-tap.md](../plans/20260717_085910_recents-split-tap.md).

## What changed

File: [lib/screens/call_history_screen.dart](../lib/screens/call_history_screen.dart)

Each Recents call card now has two tap zones instead of one whole-card tap:

- **Left zone** (avatar + name + subtitle) → opens the contact page. For an
  unknown/unlinked number (no contact page exists) it opens **Add to contact**
  with the number prefilled (`AddEditContactScreen(initialNumber: ...)`).
- **Right zone** (type icon + green call button) → dials (call back).

Details:

- Replaced the single `ListTile` (`onTap: _onTap`, trailing call button) with a
  `Material` + `GestureDetector` wrapping a `Row` of two `InkWell` regions:
  an `Expanded` left region and a fixed right region. The card's rounded
  `Container` now uses `clipBehavior: Clip.antiAlias` so tap ripples stay inside
  the rounded corners.
- Renamed `_onTap` to `_openLeft` (now async): opens `ContactDetailScreen` when
  linked, else pushes `AddEditContactScreen` with the number; reloads the list
  on return so a newly linked/created contact shows on the row.
- Kept the explicit green "Call back" `IconButton` on the right, and the
  whole-card long-press actions (`_showActions`) unchanged.
- Added import of `add_edit_contact_screen.dart`.

The SIM picker and post-call reconciliation still run, because dialing uses the
same `_callBack` → `startCall` path (via `CallLifecycleMixin`) as before.

## Verification

- `flutter analyze lib/screens/call_history_screen.dart` → No issues found.
