# Edit an existing relationship's type

Implements plan
[plans/20260707_073943_edit-relationship-type.md](../plans/20260707_073943_edit-relationship-type.md).

## What changed

Added the ability to change the **type** of an existing relationship (previously only
add/remove was possible). The data layer already supported this via
`RelationshipRepository.setRelationship`; this change adds the UI.

### `lib/widgets/relationship_editor.dart`
- New public `showRelationshipTypePicker(context, {personName, currentType})` — a bottom
  sheet of the preset relationship types with the current type highlighted; returns the
  chosen type or null.
- Extracted the preset chips into a shared `_TypeChipGrid` (now uses `ChoiceChip` so the
  current type can show as selected) and reused it in the existing add flow, removing the
  duplicated `Wrap`/`ActionChip` grid.

### `lib/screens/contact_detail_screen.dart`
- New `_editRelationship(RelatedContact)` opens the picker and, on a changed type, calls
  `setRelationship` and reloads.
- Each relationship row's trailing is now a `Row` of two buttons: a new **edit**
  (`edit_outlined`, "Edit type") button plus the existing **remove** (unlink) button.
- The row tap still navigates to the related contact's sphere (unchanged).

### `lib/screens/relationship_screen.dart`
- New `_editRelationship(RelatedContact)` with the same behaviour, owned by the focus
  contact.
- The relationship type labels on the sphere edges are now tappable: they render as
  positioned `_EdgeLabel` widgets at each edge midpoint (centred with
  `FractionalTranslation`) and open the type picker on tap.
- `_EdgePainter` no longer draws the labels (only the lines); its `labels`, `labelColor`
  and `labelBg` params and the `_drawLabel` method were removed to avoid drawing the text
  twice.
- Added an **"Edit relationship type"** item to the long-press node menu.

## Verification

- `flutter analyze` on the three changed files: **No issues found**.
- Not yet exercised on a device/emulator.
