# Plan: Call history tab on the contact screen (saved and unsaved numbers)

**Status:** completed

## Goal

When the user opens a person — from Contacts, Recents, the dialer, or any
other screen — they should see the call history with that person in its own
tab.

- **Saved contact:** the contact screen gets two tabs: **Details** (what the
  screen shows today) and **History** (calls with this contact only).
- **Unsaved number** (tapping the avatar/name of an unknown caller in
  Recents): today this jumps straight into "Add contact". Instead it opens a
  new number screen with two tabs: **History** (calls with this number) and
  **Add contact** (the existing add-contact form, number pre-filled).

## Current behaviour

- `lib/screens/contact_detail_screen.dart` is one long `ListView`. It has no
  per-contact call list; it only shows a "Before you call" summary.
- `lib/screens/call_history_screen.dart` `_openLeft()` opens
  `ContactDetailScreen` for a linked call, and `AddEditContactScreen` for an
  unknown number.
- `lib/repositories/call_log_repository.dart` can list all calls or search
  them, but cannot list the calls for one contact or one number.

## Design

### 1. Repository — new queries (`CallLogRepository`)

- `callsForContact(int contactId, List<String> numbers, {int limit = 500})`
  Returns calls where `contact_id = contactId`, **plus** calls with no
  `contact_id` whose number matches one of the contact's numbers. Matching
  uses the existing `matchKey()` rule (last 10 digits), so `+91 98…`,
  `098…` and `98…` all count as one number. This catches calls logged
  before the contact was saved.
- `callsForNumber(String number, {int limit = 500})`
  Returns every call whose number matches `matchKey(number)` (linked or not).
- Both return `CallRecord` rows, newest first, with the same joined name /
  photo columns as `recentCalls()`. Number matching is done in SQL on the
  digits-only form of `phone_number` with a suffix `LIKE`, then re-checked in
  Dart with `matchKey()` so a short number can't match a longer one wrongly.
- Read-only. No schema change, no migration.

### 2. Shared widget — `lib/widgets/call_history_list.dart` (new)

A reusable list of calls grouped by day (Today / Yesterday / weekday / date),
with the same row look as Recents: type icon (incoming / outgoing / missed /
blocked), time, duration or outcome, SIM label, call intent, and a call-back
button. Long-press offers **Copy number** and **Remove from history**.

- Takes a `Future<List<CallRecord>> Function()` loader, so both screens reuse
  it.
- Listens to `CallLogEvents` so a new call shows up without leaving the tab.
- Shows an empty message when there are no calls.
- The day-bucket, duration and type-icon helpers now in
  `call_history_screen.dart` move into this widget file as small shared
  functions; Recents is changed to use them, so the two lists never drift
  apart. (Recents keeps its own list, search and paging — only the helpers
  are shared.)

### 3. Contact screen — `lib/screens/contact_detail_screen.dart`

- Wrap the body in a `DefaultTabController` with a `TabBar` under the
  `AppBar`: **Details** | **History**.
- **Details** = the current `ListView`, unchanged.
- **History** = `CallHistoryList` loading `callsForContact(id, numbers)`.
  The call-back button uses the screen's existing `_call()` (via
  `CallLifecycleMixin`), so feedback and scoring keep working.
- New optional parameter `initialTab` (default Details). Recents opens the
  contact on the **History** tab, because the user came from a call; all
  other callers keep opening on Details.
- Secret contacts: this screen is already behind the app's auth for secret
  contacts; the History tab only shows inside it, so nothing new leaks.

### 4. Unsaved-number screen — `lib/screens/number_detail_screen.dart` (new)

- `NumberDetailScreen(number: ...)` with an `AppBar` showing the number and
  a `TabBar`: **History** | **Add contact**.
- **History** = `CallHistoryList` loading `callsForNumber(number)`, with a
  call button in the app bar too.
- **Add contact** = the existing `AddEditContactScreen(initialNumber: number)`
  embedded in the tab.
  - `AddEditContactScreen` gets a new optional flag `embedded` (default
    `false`). When `true` it hides its own back arrow (the outer app bar
    already has one) and does not draw a second full `Scaffold` header. No
    other behaviour changes.
  - After a successful save the form pops with `true`, as it does today.
    Embedded in the number screen, that closes the number screen and the
    user is back on Recents, which reloads and now shows the new name on
    the row. (User choice: go back to Recents, not to the new contact's
    page.)

### 5. Recents — `lib/screens/call_history_screen.dart`

- `_openLeft()`: linked call → `ContactDetailScreen(contactId, initialTab:
  history)`; unknown number → `NumberDetailScreen(number)` (instead of going
  straight to Add contact).
- Use the shared helpers from step 2.

### 6. Text (localization)

New keys in `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb` (then
regenerate with `flutter gen-l10n`):

| Key | English |
|-----|---------|
| `tabDetails` | Details |
| `tabHistory` | History |
| `tabAddContact` | Add contact |
| `emptyNoCallsWithContact` | No calls with this contact yet. |
| `emptyNoCallsWithNumber` | No calls with this number yet. |

Malayalam and Sanskrit get proper translations (no English copies).
Existing keys (`labelCallHistory`, `actionCopyNumber`,
`actionRemoveFromHistory`, `tooltipCallBack`, `labelToday`, …) are reused.

## Decisions confirmed by the user

- Opening a contact from Recents starts on the **History** tab; every other
  entry point starts on **Details**.
- Saving from the **Add contact** tab goes back to **Recents**.

## Files

| File | Change |
|------|--------|
| `lib/repositories/call_log_repository.dart` | Add `callsForContact`, `callsForNumber` |
| `lib/widgets/call_history_list.dart` | **New** — shared per-person call list + helpers |
| `lib/screens/contact_detail_screen.dart` | Details / History tabs, `initialTab` param |
| `lib/screens/number_detail_screen.dart` | **New** — History / Add contact tabs for unsaved numbers |
| `lib/screens/add_edit_contact_screen.dart` | Optional `embedded` flag (hides its own back arrow) |
| `lib/screens/call_history_screen.dart` | New navigation targets; use shared helpers |
| `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb` | 5 new strings |
| `lib/l10n/app_localizations*.dart` | Regenerated |
| `test/repositories/call_log_repository_test.dart` | **New** — tests for the two queries |
| `docs/architecture.md` | Note the new screen and shared widget |

## Out of scope

- The dialer's search results and other screens keep their current tap
  behaviour, but they already open `ContactDetailScreen`, so they get the
  History tab automatically.
- No change to how calls are logged, imported, or linked.

## Verification

1. `flutter gen-l10n`, `dart format .`, `flutter analyze` (zero issues).
2. `flutter test` — new repository tests (in-memory SQLite via
   `sqflite_common_ffi`):
   - linked calls for the contact are returned; another contact's are not;
   - an unlinked call from `+91 98765 43210` matches a contact saved as
     `09876543210`;
   - `callsForNumber` returns linked and unlinked calls for the number;
   - a short code does not match a longer number that ends with it.
3. Manual on device (`flutter run --flavor dev`):
   - Contacts → open a contact → History tab lists only their calls.
   - Recents → tap a saved caller → opens on History tab.
   - Recents → tap an unknown number → History | Add contact tabs; save in
     the Add contact tab → back on Recents, the row shows the new name.
   - Place a call from the History tab → it appears in the list after the
     call ends.
