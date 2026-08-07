# Best-time-to-reach windows (roadmap 5.2) — advice only

Implements [plans/20260806_072406_best-time-to-reach.md](../plans/20260806_072406_best-time-to-reach.md).

## What changed

The app now works out, per contact, **when calls to them actually get answered**, and uses that
only to advise. It never dials.

### New

- **[lib/models/reach_window.dart](../lib/models/reach_window.dart)** — `DayPart` (morning /
  afternoon / evening / night, with `night` wrapping past midnight), `ReachScope`
  (any / weekdays / weekends), and `ReachWindow`, which carries the winning window plus the
  sentence shown to the user. `DayPart.sqlPredicate` keeps the SQL and Dart bucket boundaries
  from drifting apart.
- **[lib/services/reach_window_service.dart](../lib/services/reach_window_service.dart)** —
  the statistics, in one place.
  - `bestWindow(contactId)` for the pre-call summary; `contactIdsLikelyNow()` for the dialer.
  - Answered = `duration > 0`. Missed and zero-duration outgoing calls count against.
    `blocked` rows are skipped. A row with no duration less than 2 minutes old is a call still
    in progress, not an unanswered one.
  - Only the last 180 days count.
  - It returns **null unless the data earns it**: at least 8 calls, at least 3 in the winning
    part of the day, and that part at least 20 percentage points above the contact's own
    average. Then it optionally narrows to weekdays or weekends, but only when each side has
    3+ calls and one clearly beats the other. All four numbers are named constants.
- **[test/reach_window_service_test.dart](../test/reach_window_service_test.dart)** — 9 tests.
  Most assert the service says *nothing*: too few calls, an evenly-spread history, a contact
  who never answers. Plus blocked/provisional/old-call exclusion and the `DayPart` boundaries.

### Modified

- **[lib/models/call_summary.dart](../lib/models/call_summary.dart)** — new `bestTimeToReach`
  field.
- **[lib/services/pre_call_summary_service.dart](../lib/services/pre_call_summary_service.dart)** —
  fills it in.
- **[lib/screens/contact_detail_screen.dart](../lib/screens/contact_detail_screen.dart)** — one
  more line in the "Before you call" card, shown only when the field is non-null.
- **[lib/state/app_settings.dart](../lib/state/app_settings.dart)** — third `DialerTopSource`
  value, `likelyToAnswer`. Appended to the enum, so the persisted indices of the existing two
  are unchanged. `recent` is still the default.
- **[lib/screens/settings_screen.dart](../lib/screens/settings_screen.dart)** — label and
  description for the new option. The chooser already looped over every enum value, so no other
  change was needed. The two label helpers became exhaustive `switch` expressions, so a future
  fourth source cannot be silently mislabelled.
- **[lib/repositories/contact_repository.dart](../lib/repositories/contact_repository.dart)** —
  new `getMatchesForIds`, returning pre-dial rows in the order the caller ranked them
  (non-secret, non-favorite, as the sibling lists do).
- **[lib/screens/dialer_screen.dart](../lib/screens/dialer_screen.dart)** — `_loadFavorites`
  handles the third source through `_loadLikelyToAnswer`, and the section header switches on
  all three.
- **[docs/feature_analysis_and_roadmap.md](../docs/feature_analysis_and_roadmap.md)** and
  **[docs/features.md](../docs/features.md)** — see below.

## The no-auto-dial constraint

The requirement was that Smart Redial stays and the new intelligence must not dial on its own.

- **Smart Redial is untouched.** No edits to `smart_redial_service.dart` or
  `SmartRedialManager.kt`. Its own tests still pass.
- **Nothing new can dial.** `ReachWindowService` imports only `DatabaseHelper` and its own
  model. It reaches no `TelecomService`, no `url_launcher`, no `SmartRedialService` — the only
  mentions of those names in the file are in the comment recording the rule.
- The two surfaces print a sentence and re-order a list. Every call is still a tap.

## An honesty detail worth noting

When "Likely to answer now" is chosen but nobody has enough history to rank, the dialer falls
back to the recency list — and `_loadLikelyToAnswer` returns `DialerTopSource.recent` alongside
it, so the header reads "Top contacts". The section never claims an ordering it did not apply.

## Doc corrections

The roadmap's section 6 row said the Smart Redial scheduler was *"Superseded by 5.2"*, which
read as "it goes away". It now says the scheduler ships and stays, and that only the old
guess-based "office hours" idea was dropped. Section 5.2 gained the advice-only rule in bold and
a "shipped" note.

The 5.1 "nudge now" case remains outstanding, since 5.1 (the unified scheduler) is not built.
Conveniently, that means 5.2 has nothing it could fire through even by accident.

## Verification

- `flutter analyze` — **No issues found.**
- `flutter test test/reach_window_service_test.dart` — 9/9 pass.
- `call_log_search_test.dart`, `interaction_repository_test.dart`, `call_feature_test.dart`,
  `smart_redial_service_test.dart` — all pass.

Test files were run one per `flutter test` invocation: batching sqlite-backed files crashes on
this project's native-assets setup.

Not verified on a device — this was analyzer- and test-level only.
