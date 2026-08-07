# Plan: tenth gap-fill pass on docs/features.md

**Status:** completed

## Files to change

- `docs/features.md`

## Issue

`docs/features.md` has already had 9 gap-fill passes. A fresh, independent
10th audit (comparing the doc against `lib/screens/`, `lib/services/`,
`lib/state/app_settings.dart`, `pubspec.yaml`, the Android manifest, and the
native Kotlin code) found two real, user-facing features in the code that
are not mentioned anywhere in the doc:

1. **Multi-select / bulk delete on the contact list.** The contact list
   screen (`lib/screens/contact_list_screen.dart`) supports long-press to
   enter a selection mode, a "select all visible" toggle, a selection
   app-bar header, and a bulk-delete flow with a confirmation dialog and a
   result summary ("Deleted N contact(s), M failed"). Section 1's "Contact
   list" bullet only mentions single-row quick actions (call/view/email/
   delete) today.

2. **Salutation field on a contact.** `lib/models/contact.dart` has a
   persisted `salutation` field, with its own input on the Add/Edit Contact
   screen and a round-trip through vCard export/import. Section 1's field
   list (name, formal name, phones, etc.) does not mention it.

Everything else the audit checked — every screen, every service, every
`AppSettings` key, every manifest permission/intent-filter/service/receiver,
every native Kotlin file, and the "Known gaps" section — already matches the
doc. No other change is needed.

## Fix

In `docs/features.md`, section 1 ("Contacts management"):

- In the "Add/edit contact" bullet (currently starts "Add/edit contact:
  name, formal name, phonetic key..."), add "salutation" to the list of
  fields, right after "name, formal name".
- In the "Contact list" bullet, add a sentence describing multi-select:
  long-press a row to enter selection mode, a "select all" toggle, and bulk
  delete with a confirmation prompt and a result summary.

No other section, and no other file, will be touched.
