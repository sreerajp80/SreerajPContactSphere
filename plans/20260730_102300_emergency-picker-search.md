# Emergency info "From contacts" picker: use the real contact search

**Status:** done

## The issue

On **Settings → Emergency info → People to call → From contacts**, the picker sheet has a
search box, but it is a much weaker search than the one on the Contacts screen.

`_ContactPickerSheet` in [lib/screens/emergency_info_screen.dart](../lib/screens/emergency_info_screen.dart#L694-L752)
filters an in-memory list with one test:

```dart
c.fullName.toLowerCase().contains(q)
```

So in the emergency picker you **cannot** find a person by:

- **phone number** (typing digits finds nothing),
- **Malayalam name typed in English** (no `name_translit` / `searchKey` match — a name
  stored in Malayalam script won't come up for its Latin spelling),
- **sound-alike / Manglish spelling** (no `name_phonetic` match — e.g. the `sreeraj` /
  `sriraj` pair of spellings),
- **email**, **tag**, or **formal name**.

The Contacts screen does all of these, because it calls
`ContactSyncService.searchSummaries` → `ContactRepository.searchContactSummaries`
([contact_repository.dart:1173](../lib/repositories/contact_repository.dart#L1173)), which is a
DB query over name, phone digits, email, tags, formal name, translit key and phonetic code.
It also has a **voice search** mic and a **clear (X)** button, which the emergency picker lacks.

Second, smaller problem: the picker loads the whole address book with
`ContactRepository().getAllContacts()`, which fully hydrates every contact (numbers, emails,
tags, groups, …) just to show a name list. On a big address book that is slow for no reason.

## The fix

Move the sheet into its own reusable widget and give it exactly the Contacts-screen search.

**New file — `lib/widgets/contact_search_picker_sheet.dart`**

A single-select contact picker sheet, the sibling of the existing
[contact_multi_picker_sheet.dart](../lib/widgets/contact_multi_picker_sheet.dart):

- Empty query → the light `getContactSummaries(requirePhone: true)` list (summaries, not
  hydrated aggregates).
- Non-empty query → `ContactSyncService.searchSummaries(query)`, i.e. **the same DB search the
  Contacts screen runs**, so the two agree on what "matches". Results are then filtered to
  contacts that have a number (the emergency card needs one).
- Debounced by a stale-token check on the query, same guard style as
  `ContactListScreen._runSearch`, so an out-of-order DB reply can't overwrite a newer one.
- Search field reuses `VoiceInputButton` for the mic and an X to clear, styled with
  `AppColors.searchFill` like the Contacts search bar (our own design system, not a new look).
- `includeSecret` stays **false** (the default), matching both the Contacts list and the
  current `getAllContacts()` call — a secret contact is not silently publishable to the
  lock screen.
- Rows show name + primary number; tapping pops the picked `Contact` summary.
- Empty states: "No contacts with a number yet." when the book has none, and
  `No contacts match "<query>"` while searching.

**Changed — `lib/screens/emergency_info_screen.dart`**

- Delete the private `_ContactPickerSheet` / `_ContactPickerSheetState` classes.
- `_addFromContacts()` no longer pre-loads all contacts; it just opens
  `ContactSearchPickerSheet`.
- Because the sheet now returns a *summary* (only the primary number), after a pick load the
  full aggregate with `ContactRepository().getContactById(picked.id!)` before offering
  `showNumberPickerSheet`, so a contact with several numbers still lets the user choose which
  one goes on the card. Fall back to the summary's primary number if the reload fails.
- Keep the existing snackbar error handling.

## Files to change

- **New:** `lib/widgets/contact_search_picker_sheet.dart`
- **Modified:** `lib/screens/emergency_info_screen.dart`
- **New test:** `test/contact_search_picker_sheet_test.dart` — widget test with a seeded
  in-memory DB: a Malayalam-named contact is found by its English spelling, a contact is found
  by typing digits of its number, a contact with no number never appears, and tapping a row
  pops that contact.

## Out of scope (flagged, not changed)

`ContactMultiPickerSheet` (add members to a group or tag) has the same weakness in a milder
form — it uses `nameMatches()`, so translit and phonetic work, but **number, email and tag
search do not**. Fixing that is a separate change; say the word and I will plan it.

## Verification

- `flutter analyze` — expect no new issues.
- `flutter test test/contact_search_picker_sheet_test.dart` (its own invocation — sqlite-backed
  suites must run one file per run).
- `flutter test test/emergency_info_test.dart` — unchanged behaviour of the mirror payload.
- On device: open Emergency info → From contacts, search by number and by an English spelling
  of a Malayalam name, pick a multi-number contact and confirm the number picker still appears.
