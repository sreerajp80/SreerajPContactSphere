# Change log: Call history tab on the contact screen (saved and unsaved numbers)

**Plan:** [plans/20260922_194903_contact-call-history-tab.md](../plans/20260922_194903_contact-call-history-tab.md)

## What changed

Opening a person now shows the calls with that person in their own tab.

- **Saved contact:** the contact screen has two tabs, **Details** (the old
  screen) and **History** (calls with this contact).
- **Unsaved number:** tapping an unknown caller in Recents opens a new screen
  with **History** and **Add contact** tabs. Saving from Add contact goes back to
  Recents.

Decisions confirmed by the user:

- Opening from Recents starts on **History**; every other entry point starts
  on **Details**.
- Saving from the **Add contact** tab goes back to **Recents**.

## Files

| File | Change |
|------|--------|
| `lib/repositories/call_log_repository.dart` | New `callsForContact(contactId, numbers)` and `callsForNumber(number)`. Numbers match on the last 10 digits (`matchKey`), so `+91…`, `0…` and the bare number are one number. The query first narrows the rows in SQL, then each row is checked again in Dart so a short code can't match a longer number. Read-only; no schema change. |
| `lib/widgets/call_history_list.dart` | **New.** Shared per-person call list, grouped by day, with a call-back button. A long press lets you copy the number or remove the call. Reloads on `CallLogEvents` and keeps its state when the user switches tabs. Also holds the row helpers (`callTypeIcon`, `callDayBucket`, `callTimeOfDay`, `formatCallDuration`) that were private to Recents. |
| `lib/screens/contact_detail_screen.dart` | Adds the **Details** and **History** tabs, a `ContactDetailTab` enum and an `initialTab` parameter (default Details). The spinner now shows only on the first load, so a reload after an edit or a call doesn't reset the tabs. |
| `lib/screens/number_detail_screen.dart` | **New.** History and Add contact tabs for an unsaved number, plus a call button in the app bar. Calls go through `CallLifecycleMixin`. The form tab stays loaded, so a half-filled form survives a switch to History. |
| `lib/screens/add_edit_contact_screen.dart` | New optional `embedded` flag. When set, the form hides its own back arrow. Nothing else changes. |
| `lib/screens/call_history_screen.dart` | A saved caller opens the contact on the History tab. An unknown number opens `NumberDetailScreen`. The private row helpers are replaced by the shared ones, and the unused `intl` and `formatting_locale` imports are removed. |
| `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb` | New keys: `tabDetails`, `tabHistory`, `tabAddContact`, `emptyNoCallsWithContact`, `emptyNoCallsWithNumber` (translated into Malayalam and Sanskrit). |
| `lib/l10n/app_localizations*.dart` | Regenerated with `flutter gen-l10n`. |
| `test/call_log_for_person_test.dart` | **New.** 8 tests for the two queries. |
| `docs/architecture.md`, `docs/project_structure.md` | Describe the new tabs, the new screen and the shared widget. |

## Verification

- `flutter gen-l10n`: OK.
- `dart format`: all changed files formatted.
- `flutter analyze`: no issues found.
- `flutter test`: all 747 tests passed (1 test was already skipped). This
  includes the 8 new ones:
  - A contact's linked calls are returned; another contact's are not.
  - An unlinked call from `+91 98765 43210` matches a contact saved as
    `09876543210`.
  - A same-number call linked to a different contact is left out.
  - Calls come newest first.
  - A contact with no numbers still gets its linked calls.
  - `callsForNumber` returns linked and unlinked calls.
  - A short code does not match a longer number that ends with it.
  - A number with no digits matches nothing.
- Manual check on a device: not done in this session (see the plan's steps).

## Differences from the plan

- The new test is at `test/call_log_for_person_test.dart`, not
  `test/repositories/`. All the existing repository tests (for example
  `test/call_log_search_test.dart`) sit directly in `test/`, so this one
  follows them.
- No `onSaved` callback was added to `AddEditContactScreen`. With Option B
  (return to Recents), the form's normal save-and-close already closes the
  number screen.
