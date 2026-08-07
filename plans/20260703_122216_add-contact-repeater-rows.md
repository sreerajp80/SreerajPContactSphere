# Plan — Simplify Add/Edit contact repeater rows (phones, emails, socials)

**Status:** completed

## Issue

On the Add/Edit contact screen, the Phone numbers, Emails, and Social links
sections use a "repeater row" layout that is heavier than needed:

1. **Primary star.** Phone and email rows each show a star button to pick the
   primary entry. The user wants the *first* row to always be the primary — no
   star. Primary should instead be indicated by **colour** on the first row.
2. **Delete button.** Each row (when more than one) shows a `—` square button to
   delete it. The user wants deletion by **swiping the row left to reveal a
   Delete button** (chosen implementation: the `flutter_slidable` package).
3. **Field captions.** Every field box shows a tiny uppercase caption
   (LABEL / CODE / PHONE / EMAIL, and PLATFORM / PROFILE for socials). The user
   wants these removed. Chosen scope: **Phone, Email, and Social** (all repeater
   rows). Captions on other sections (Name, Personal details, addresses, etc.)
   are unchanged.

## Design decisions (from clarification)

- Swipe-to-delete: add **`flutter_slidable`**; swipe left reveals a Delete action.
- Primary indicator: **colour** — the first (primary) row's fields render with the
  accent border + accent-soft fill (via a new `primary` flag on `_shell`), instead
  of a star. Applies only to sections that have a primary concept (phone, email);
  social links have no primary and get no highlight.
- Caption removal applies to all three repeater sections.

## Files to change

- **`pubspec.yaml`** — add `flutter_slidable` dependency (version resolved by
  `flutter pub add`).
- **`lib/screens/add_edit_contact_screen.dart`** — the only code file:
  - Add `import 'package:flutter_slidable/flutter_slidable.dart';`.
  - **`_shell(...)`** — make `caption` nullable (`String? caption`); when null,
    skip rendering the caption line + its spacer. Add `bool primary = false`;
    when true, border = `_t.accent` and background = `_t.accentSoft` (the colour
    cue for the primary row). Non-repeater callers keep passing their captions
    and are visually unchanged.
  - **`_menuButton(...)`** — make `caption` nullable and thread a `primary` flag
    down to `_shell` (used for the label/code fields of the primary row).
  - **`build()`** — drop the now-unused `labelCaption` / `valueCaption` arguments
    from the three `_repeaterSection(...)` calls (Phone, Emails, Social links).
  - **`_repeaterSection(...)`** — remove the `labelCaption` / `valueCaption`
    parameters; wrap the generated rows in a `SlidableAutoCloseBehavior` so
    opening one row's swipe action auto-closes any other; iterate with an index
    so each row knows its position (row 0 = primary).
  - **`_repeaterRow(...)`** — remove `labelCaption` / `valueCaption`; add an
    `index` parameter. Remove the primary **star** `_squareButton` and the
    **remove** `_squareButton`. Compute `isPrimaryRow = hasPrimary && index == 0`
    and pass `primary: isPrimaryRow` to the label menu, code menu, and value
    shell. Pass `caption: null` to those fields (captions removed). When
    `list.length > 1`, wrap the field row in a `Slidable` (keyed by
    `ValueKey(entry.id)`) with an `endActionPane` holding a single
    `SlidableAction` (red background, delete icon, "Delete") whose `onPressed`
    first shows a **confirmation dialog** ("Remove this phone/email/…?" with
    Cancel / Remove) and only calls `_removeEntry(list, entry)` on confirm.
    The last remaining row is not swipeable (can't
    delete the only entry), matching the current `canRemove` rule. The label
    chip-menu (`entry.menuOpen`) stays below the row, outside the Slidable.
  - **`_setPrimary(...)`** — remove (no longer referenced).
  - **`_save()`** — stop reading per-entry `isPrimary`. Build the phone and email
    lists, marking the **first non-empty entry** primary (`isPrimary:
    <list>.isEmpty` as each is added) and all others non-primary. Socials
    unchanged (no primary).
  - **`initState()`** — after loading an existing contact's phones/emails, move
    the stored-primary entry to the front so the colour highlight lands on the
    right row and edits round-trip correctly.

## Not changing

- The label preset menu + "+ Custom", the country-code picker, phone
  splitting/normalisation, and value hints (`valueHint`) all stay.
- Captions on Name, Personal details, Ringtone, addresses, and official sections.
- Data model / DB schema — the `isPrimary` column is still written; only *how*
  it's chosen changes (position instead of a star toggle).

## Verification

- `flutter pub get` succeeds with the new dependency.
- `flutter analyze` — no new issues (watch for unused `_setPrimary` / params).
- `flutter test` — existing tests still pass.
- Manual: add several phones/emails — first row is colour-highlighted; swipe a
  row left to reveal + tap Delete; no captions on phone/email/social boxes;
  edit an existing contact and confirm its primary shows first.
