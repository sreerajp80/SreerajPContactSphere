# Fix: Add Contact screen shows no fields (infinite-height layout crash)

**Status:** completed

## Issue

Opening **Add Contact** renders only the avatar / "Add photo" header; every form
field below is blank. The console floods with:

- `RenderBox was not laid out: RenderFlex#... NEEDS-PAINT`
- `'package:flutter/.../sliver_multi_box_adaptor.dart': ... 'child.hasSize': is not true.`
- repeated `Null check operator used on a null value`

### Root cause

In `lib/screens/add_edit_contact_screen.dart`, the **"Add tag" Row** (around
line 1034) uses `crossAxisAlignment: CrossAxisAlignment.stretch`:

```dart
Row(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    Expanded(child: _shell(... _bareTextField ...)),
    const SizedBox(width: 8),
    _squareButton(icon: Icons.add, width: 48, ...),
  ],
)
```

This Row is a direct child of a `Column` (`_section`) inside the body `ListView`
(see `build` ~line 565). In that context the Row's incoming **height constraint
is unbounded** (`0.0<=h<=Infinity`, matching the error's reported constraints).

A horizontal `Row` with `CrossAxisAlignment.stretch` lays its children out with
`tightFor(height: constraints.maxHeight)`. With an unbounded `maxHeight` that
forces an **infinite height**, the layout throws, the `SliverList` item never
gets a size (`child.hasSize` is false), and the failure cascades so the whole
list paints nothing.

`_squareButton` only sets `width: 48` (no height), so it depends on the Row's
cross-axis to get its height — hence the original `stretch`.

The analogous label Row near line 922 uses the same `stretch` but is wrapped in
`IntrinsicHeight`, which bounds the height — so it does **not** crash. The tag
Row is simply missing that wrapper.

## Files to change

- `lib/screens/add_edit_contact_screen.dart` — wrap the "Add tag" Row (~line 1034)
  in `IntrinsicHeight`.

## Fix

Wrap the tag Row in `IntrinsicHeight`, matching the existing pattern already used
at line 922:

```dart
IntrinsicHeight(
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [ ... unchanged ... ],
  ),
)
```

`IntrinsicHeight` gives the Row a bounded (max-intrinsic) height, so `stretch`
resolves to a finite value and `_squareButton` still matches the field height.

## Verification

- `flutter analyze` clean for the file.
- Run the app, open Add Contact: all sections (name, personal, phones, emails,
  tags, groups, ...) render; no layout exceptions in the console.
