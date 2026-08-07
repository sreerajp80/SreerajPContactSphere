# Focus the new field after "Add phone" / "Add email"

Implements plan
[plans/20260711_112213_focus-new-phone-email-field.md](../plans/20260711_112213_focus-new-phone-email-field.md).

## What changed

In [lib/screens/add_edit_contact_screen.dart](../lib/screens/add_edit_contact_screen.dart):

1. **`_LabeledEntry`** — added a `FocusNode valueFocus` field for each row's
   value field, and dispose it in `_LabeledEntry.dispose()`.

2. **`_bareTextField(...)`** — added an optional `FocusNode? focusNode`
   parameter, passed through to the underlying `TextField`.

3. **`_repeaterRow(...)`** — the value field now passes
   `focusNode: entry.valueFocus`, wiring each row's value field to its node.

4. **`_addEntry(...)`** — after adding the new row and calling `setState`, it
   requests focus on the new row's `valueFocus` inside a post-frame callback,
   so the keyboard/caret lands in the new field once it is laid out.

## Effect

Tapping **Add phone**, **Add email**, or **Add social link** now moves focus
straight into the new row's value field, so the user can type without an extra
tap. Covers all three repeater sections since they share the same helpers.

## Verification

- `flutter analyze lib/screens/add_edit_contact_screen.dart` — No issues found.
