# Edit an existing relationship's type by tapping it

**Status:** completed

## The issue

Right now the app can only **add** or **remove** a relationship. There is no way to
**change the type** of an existing one (e.g. fix "Friend" to "Brother"). To change a
type today the user has to remove the link and add it again.

The data layer already supports an in-place change:
[`RelationshipRepository.setRelationship`](../lib/repositories/relationship_repository.dart#L21)
deletes the old pair and writes the new pair (and recomputes the gendered reverse
label). Only the UI is missing.

The user wants:
- **Contact profile** — tapping a relationship row opens an editor to change its type.
- **Relationship Sphere** — tapping the relationship *name* (the type label drawn on
  the edge between the centre and an orbit node) opens the same editor.

## Current behaviour that will change

- **Contact profile** ([contact_detail_screen.dart:632](../lib/screens/contact_detail_screen.dart#L632)):
  tapping a relationship row currently **navigates to that related contact's sphere**.
  This navigation **stays unchanged**. Instead, a new **edit (pencil) button** is added
  to the row's trailing area, next to the existing unlink (remove) button. Tapping the
  edit button opens the type editor.
- **Relationship Sphere** ([relationship_screen.dart:319-323](../lib/screens/relationship_screen.dart#L319)):
  the type label is currently **painted** inside `_EdgePainter`, so it cannot receive
  taps. We will draw the label as a real positioned widget at the edge midpoint and
  wrap it in a tap handler. The painter keeps drawing the connecting lines only.
  Orbit-node tap (re-centre) and long-press (node menu) are unchanged.

## The plan

### 1. `lib/widgets/relationship_editor.dart` — add a reusable type picker

Add a public function:

```dart
Future<String?> showRelationshipTypePicker(
  BuildContext context, {
  required String personName,   // e.g. related contact's first name
  String? currentType,          // highlighted as the current selection
});
```

- Shows a modal bottom sheet titled `How is <personName> related?`.
- Renders `RelationshipTypes.presets` as chips (the same grid the add flow already
  uses in `_buildTypePicker`).
- The chip matching `currentType` is visually marked as selected.
- Tapping a chip pops the sheet returning that type string; dismissing returns `null`.
- To avoid duplicating the chip grid, extract the existing `Wrap` of chips from
  `_RelationshipEditorSheet._buildTypePicker` into a small shared widget and use it in
  both the add flow and the new picker.

### 2. `lib/screens/contact_detail_screen.dart` — add an edit button to each row

- Add `_editRelationship(RelatedContact r)`:
  - call `showRelationshipTypePicker(context, personName: r.firstName, currentType: r.relationshipType)`.
  - if it returns a non-null type that differs from the current one, call
    `_relationships.setRelationship(contactId: widget.contactId, relatedContactId: r.contactId, type: newType)` then `_load()`.
- Keep the relationship `ListTile.onTap` (line ~632) as-is (navigates to the related
  contact's sphere).
- Change the row's `trailing` from a single unlink `IconButton` into a
  `Row(mainAxisSize: MainAxisSize.min, ...)` holding two buttons:
  a new **edit** button (`Icons.edit_outlined`, tooltip "Edit type", calls
  `_editRelationship(r)`) followed by the existing **remove** unlink button.

### 3. `lib/screens/relationship_screen.dart` — tap the edge label to edit

- Add `_editRelationship(RelatedContact r)` with the same logic as above, using
  `widget.focusContactId` as the owner, then `await _load()`.
- In `_buildSphere`, for each orbit node compute the edge midpoint
  (`(center + positions[i]) / 2`) and add a `Positioned` tappable label widget
  (a small rounded pill matching the current painted style) wrapped in a
  `GestureDetector`/`InkWell` that calls `_editRelationship(_relations[i])`.
- Stop `_EdgePainter` from drawing labels: remove its label rendering (and the now
  unused `labels`/`labelColor`/`labelBg` params, or keep the struct but skip
  `_drawLabel`) so the text is not drawn twice. The painter keeps drawing the lines.
- Add an **"Edit relationship type"** item to the existing `_nodeMenu` (long-press) for
  discoverability, calling the same `_editRelationship`.

## Files to change

- `lib/widgets/relationship_editor.dart` — new `showRelationshipTypePicker`, shared chip grid.
- `lib/screens/contact_detail_screen.dart` — `_editRelationship`, add edit button to the row trailing.
- `lib/screens/relationship_screen.dart` — `_editRelationship`, tappable edge labels,
  painter label removal, node-menu item.

## Out of scope

- The add/edit contact screen's relationship list (a separate surface the request did
  not mention).
- No database/schema/model changes — `setRelationship` already does the work, including
  the gendered reverse label.

## Testing

- `flutter analyze` clean for the changed files.
- Manual check on device: in a contact profile, tap a relationship row → still opens the
  related contact's sphere. Tap the row's **edit** button → picker opens with the current
  type marked → pick a new type → row and reverse side both update. Repeat in the sphere
  by tapping the edge label. Confirm remove and re-centre still work.
