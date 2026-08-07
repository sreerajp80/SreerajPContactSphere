# Change log — Contacts display settings

Implements plan `plans/20260710_224027_contacts-display-settings.md`.

## What changed

Added three contacts-list display options to **Settings → Contacts**:

1. **Sort by** — First name (default) or Last name.
2. **Name format** — "First Last" (default) or "Last, First".
3. **Hide contacts without a number** — off by default.

## How

- `lib/state/app_settings.dart`
  - New enums `ContactSortOrder` and `NameDisplayFormat`.
  - New persisted prefs: `contact_sort_order`, `name_display_format`,
    `hide_contacts_without_phone`, with getters, setters, and `load()` wiring
    (same pattern as the existing prefs).
- `lib/models/contact.dart`
  - `displayName(NameDisplayFormat)` — arranges the name per the chosen format
    (`fullName` for First-Last; "Last, First Middle" otherwise, falling back to
    `fullName` when there is no last name).
  - `sortKey(ContactSortOrder)` — a lower-cased key for stable list sorting.
- `lib/repositories/contact_repository.dart`
  - `getContactSummaries` gained `sortByLastName` (dynamic `ORDER BY`) and
    `requirePhone` (an `EXISTS (phone_numbers …)` filter).
  - `countContacts` gained `requirePhone` so paging totals match the filter.
  - Kept enum-agnostic (plain bools) to avoid coupling the data layer to the
    UI-state file.
- `lib/services/contact_sync_service.dart`
  - `localSummaries` / `contactCount` pass the new flags through.
  - `mergedContacts` (first-run path) sorts by `Contact.sortKey` for the chosen
    order and drops numberless contacts when asked, still pinning `is_self`.
- `lib/screens/contact_list_screen.dart`
  - Mirrors the three prefs into state, seeded in `initState`; an `AppSettings`
    listener re-reads the paged list on a sort/hide change and repaints on a
    name-format change.
  - Passes the flags into every list read; renders the row name via
    `contact.displayName(...)`.
- `lib/screens/contacts_settings_screen.dart`
  - Three new cards (`Sort by`, `Name format` choosers; `Hide contacts without a
    number` switch) plus shared `_ChooserCard` / `_ChoiceTile` helpers.

## Deviation from the plan (approved mid-implementation)

The original plan proposed a Dart-side re-sort of the merged list. Because the
list is **paged from SQL**, that would only reorder the loaded page and the
paging count would not match the hide-filter. With the user's approval, the sort
order and hide-filter were instead threaded into the query layer
(`contact_repository.dart` + `contact_sync_service.dart`). Same user-facing
result; the plan file was updated to record this.

## Verification

- `flutter analyze` — no issues.
- `flutter test test/contact_sync_service_test.dart` — 18 passed (incl. the
  case-insensitive summary-sort test).
- `flutter test test/widget_test.dart` — passed.
