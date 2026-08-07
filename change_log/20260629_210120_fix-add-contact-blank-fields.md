# Change log: Fix Add Contact blank fields

Implements plan `plans/20260629_210120_fix-add-contact-blank-fields.md`.

## What changed

- `lib/screens/add_edit_contact_screen.dart`: wrapped the "Add tag" `Row`
  (`crossAxisAlignment: CrossAxisAlignment.stretch`) in an `IntrinsicHeight`.

## Why

The tag Row sits directly inside the body `ListView`, so its incoming height
constraint is unbounded. A horizontal `Row` with `CrossAxisAlignment.stretch`
lays children out with `tightFor(height: maxHeight)`; with an unbounded
`maxHeight` this forced an infinite height, the `SliverList` item failed to get
a size (`child.hasSize` false), and the cascade blanked every field on the Add
Contact screen below the avatar header.

`_squareButton` sets only a fixed `width` and relies on `stretch` for its height,
so removing `stretch` was not an option. `IntrinsicHeight` bounds the Row's
height (matching the existing pattern at line 922), so `stretch` resolves to a
finite value and the button still matches the field height.

## Verification

- `flutter analyze lib/screens/add_edit_contact_screen.dart` → No issues found.
