# Change log — Simplify Add/Edit contact repeater rows

Implements [plans/20260703_122216_add-contact-repeater-rows.md](../plans/20260703_122216_add-contact-repeater-rows.md).
Simplifies the Phone numbers, Emails, and Social links rows on the Add/Edit
contact screen: positional (colour-marked) primary, swipe-to-delete with
confirmation, and no per-field captions.

## Dependency

- **`pubspec.yaml`** — added `flutter_slidable: ^4.0.3` (resolved by
  `flutter pub add`) for swipe-to-reveal delete actions.

## UI — `lib/screens/add_edit_contact_screen.dart`

- Imported `package:flutter_slidable/flutter_slidable.dart`.
- **Primary is now positional + colour-marked.** Removed the per-row primary
  **star** button and the `_setPrimary` method. In sections with a primary
  concept (Phone, Email), row 0 is the primary and is highlighted by colour: its
  fields render with the accent border + accent-soft fill via a new `primary`
  flag on `_shell` (threaded through `_menuButton`). Social links have no
  primary and get no highlight.
  - `initState` now calls the new `_movePrimaryFirst` for phones and emails so an
    existing contact's stored primary is moved to row 0 (highlight + round-trip).
  - `_save` builds the phone/email lists and marks the **first non-empty** entry
    primary (`isPrimary: <list>.isEmpty` as each is added), instead of reading a
    per-entry flag.
- **Swipe-to-delete with confirmation.** Removed the per-row `—` remove button.
  Each row (when the section has more than one) is wrapped in a `Slidable`
  (`endActionPane` + `DrawerMotion`, `extentRatio` 0.28) exposing a red
  `SlidableAction` ("Delete"). Its `onPressed` calls the new
  `_confirmRemoveEntry`, which shows a Cancel/Remove confirmation dialog and only
  removes on confirm. The last remaining row is not swipeable (a section always
  keeps one row). Rows are wrapped in `SlidableAutoCloseBehavior` so opening one
  swipe action closes any other; rows share a `groupTag`.
- **No field captions.** `_shell` and `_menuButton` `caption` params are now
  nullable and skip rendering when null. The three `_repeaterSection` calls no
  longer pass `labelCaption`/`valueCaption`; those params were removed from
  `_repeaterSection`/`_repeaterRow`, which now pass no caption to the label,
  code, and value fields. Captions on all other sections (Name, Personal
  details, Ringtone, addresses, official) are unchanged. Added a `removeNoun`
  param to `_repeaterSection`/`_repeaterRow` for the confirmation prompt wording.

## Verification

- `flutter analyze` — **No issues found.**
- `flutter test` — all suites pass except one **pre-existing, unrelated**
  failure in `test/widget_test.dart` ("renders the home shell" expects a
  `NavigationBar`); this change touches neither the home shell nor navigation.
  The `MissingPluginException` log lines are the usual flutter_contacts test-host
  plugin noise, not test failures.
