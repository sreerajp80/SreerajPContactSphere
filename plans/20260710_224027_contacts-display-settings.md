# Contacts display settings (sort order, name format, hide numberless)

**Status:** completed

## What the issue is

The Settings section covers almost everything the app's features expose, but three
display options that users of any contacts app expect are missing. There is no way to:

1. **Sort order** — choose whether the contact list sorts by **first name** or **last name**.
   Today every list/search query hardcodes `ORDER BY ... first_name ASC`
   (`contact_repository.dart` lines 103, 160, 758, 804, 981, …).
2. **Name display format** — choose whether names show as **"First Last"** or **"Last, First"**.
   Today names always render via `Contact.fullName`
   (`contact.dart:150`), which is fixed to `salutation first middle last`.
3. **Hide contacts without a phone number** — a common filter for a dialer-first app.

## Plan for the fix

Add three persisted preferences to `AppSettings`, surface them in **Settings → Contacts**,
and apply them where the main contact list is built and rendered. To stay consistent across
the app+device **merged** list, sorting and filtering are applied in Dart on the merged list
(not by editing every SQL `ORDER BY`), so both app and device contacts obey the setting.

### Preferences (in `AppSettings`)

- `enum ContactSortOrder { firstName, lastName }` — key `contact_sort_order` (int index),
  default `firstName` (matches today's behavior).
- `enum NameDisplayFormat { firstFirst, lastFirst }` — key `name_display_format` (int index),
  default `firstFirst` (matches today's behavior).
- `bool hideContactsWithoutPhone` — key `hide_contacts_without_phone` (bool), default `false`.

Each gets a getter, a `set...()` persisting through `shared_preferences`, loading in
`load()`, and `notifyListeners()` — following the exact pattern already used for
`dialerTopSource` / `includeSecretInExport`.

### Display + sort helpers (in `Contact`)

- Add `String displayName(NameDisplayFormat format)` that returns the existing `fullName`
  for `firstFirst`, and a `"Last, First Middle"` arrangement for `lastFirst`
  (falling back to `fullName` when `lastName` is empty). `fullName` stays unchanged so
  nothing else breaks; `NameDisplayFormat` is imported from `app_settings.dart`.
- Add `String sortKey(ContactSortOrder order)` returning a lower-cased key
  (`firstName`-then-`lastName`, or `lastName`-then-`firstName`) for stable comparison.

### Apply in the list (query layer)

**Deviation from the first draft (approved 2026-07-10):** the list is paged from SQL, so a
Dart-side re-sort of the merged list would only reorder the loaded page, and the paging count
must agree with the hide-filter. The sort order and hide-numberless filter are therefore
threaded into the query layer instead of applied in Dart:

- `contact_repository.dart` — `getContactSummaries` and `countContacts` gain
  `bool sortByLastName` and `bool requirePhone`; the summary query builds its `ORDER BY`
  from `sortByLastName` (last_name → first_name, else first_name) and appends an
  `EXISTS (phone_numbers …)` clause when `requirePhone`. The repository stays enum-agnostic
  (plain bools) to avoid coupling it to the UI-state file.
- `contact_sync_service.dart` — `localSummaries` / `contactCount` pass the two bools through;
  `mergedContacts` (first-run path) sorts by the chosen order and drops numberless contacts
  when asked, still pinning `is_self` first.
- `contact_list_screen.dart` — reads `AppSettings`, translates the enum/flag into the bools,
  and reloads when they change; renders the row name (line ~1223) via
  `contact.displayName(settings.nameDisplayFormat)` instead of `contact.fullName`.

### Settings UI (`contacts_settings_screen.dart`)

Add three cards, styled like the existing cards there:

- **Sort by** — chooser dialog (First name / Last name), reusing the `SimpleDialog`
  pattern from `_DialerTopContactsCard`.
- **Name format** — chooser dialog (First Last / Last, First).
- **Hide contacts without a number** — a `Switch` card like `_IncludeSecretInExportCard`.

## Files to be changed

- `lib/state/app_settings.dart` — two enums, three keys + getters/setters + load wiring.
- `lib/models/contact.dart` — `displayName(format)` and `sortKey(order)` helpers.
- `lib/repositories/contact_repository.dart` — `sortByLastName`/`requirePhone` on
  `getContactSummaries` + `countContacts` (added per the approved deviation).
- `lib/services/contact_sync_service.dart` — pass the two flags through `localSummaries`/
  `contactCount`; sort + filter in `mergedContacts` (added per the approved deviation).
- `lib/screens/contact_list_screen.dart` — pass the flags from settings; reload on change;
  render name via `displayName`.
- `lib/screens/contacts_settings_screen.dart` — three new setting cards.

## Out of scope (kept deliberately)

- Re-writing the SQL `ORDER BY` clauses (Dart-side sort on the merged list is simpler and
  covers device contacts too).
- Applying the name format inside the dialer suggestion strip, Recents, and share/export —
  can follow later; this plan targets the main contacts list where it matters most.

## After implementation

Run `flutter analyze`, then write a change log to `change_log/` referencing this plan.
