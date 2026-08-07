# Fix audit findings (timer leak, flaky picker tests, stale docs, plan status)

Implements [plans/20260805_225735_fix_audit_findings.md](../plans/20260805_225735_fix_audit_findings.md).

## What changed

- `lib/screens/contact_list_screen.dart`: `dispose()` now calls
  `EphemeralContactService().stopMonitoring()` alongside the existing
  subscription cancellations, so the periodic scrub timer no longer outlives
  the screen. Fixes `test/widget_test.dart`'s "Timer is still pending" failure.
- `test/contact_search_picker_sheet_test.dart`:
  - "requirePhone hides contacts without a number" now checks
    `find.widgetWithText(ListTile, 'Nonumber')` instead of `find.text('Nonumber')`
    — the old finder also matched the search field's own `EditableText` once it
    contained the typed query "Nonumber", which is why the assertion failed.
  - `settle()` now polls (up to ~2s in 50ms steps via `tester.runAsync`) until
    the sheet's loading spinner clears, instead of a flat 150ms guess. The
    unawaited DB query fired by the search field's `onChanged` was sometimes
    still in flight when a test ended; the *next* test's `setUp()` then closed
    the DB out from under it, throwing `SqfliteFfiException: database already
    closed` in that next test's own `insertContact` call. Polling for real
    completion removes the race.
- `docs/dependencies.md`, `docs/features.md`, `docs/known-gaps.md`,
  `docs/release_process.md`, `docs/security.md`,
  `android/app/build.gradle.kts`: removed stale `flutter_local_notifications`
  references — the package was already dropped from `pubspec.yaml` in the
  uncommitted Smart Redial work, and has zero remaining usages (all real
  in-app notifications are native Android `NotificationCompat`/
  `NotificationManager`).
- `plans/20260805_100000_fix_incoming_call_duplicate_recents_row.md`: flipped
  `Status` from `approval_pending` to `completed` — the matching change log
  (`20260805_100500_...`) shows it was already implemented.

## Verification

- `flutter analyze` — no issues.
- `flutter test` — 354/355 pass. `widget_test.dart` and 3 of the 4 previously
  failing tests in `contact_search_picker_sheet_test.dart` now pass.

## "tapping a row pops that contact" — investigated, skipped with a reason

Fixing the DB race (above) exposed a *different*, pre-existing problem: the
modal sheet opened via `showContactSearchPickerSheet` (the real
`showModalBottomSheet` codepath — the only test that uses it; the other three
tests pump `ContactSearchPickerSheet` directly as a `Scaffold` body and never
hit this) renders its content **entirely below the test viewport**,
regardless of how long the test waits:

```
view (screen)  = 800 x 600
sheet rect     = (80, 648) → (720, 1068)   // top is already past y=600
Ramesh row     = topLeft (96, 761.2)       // identical whether the test
                                            // pumps 300ms or 1000ms first
```

Traced into Flutter 3.44.8's own `bottom_sheet.dart`:
`_RenderBottomSheetLayoutWithSizeListener` positions its child at
`offset.dy = size.height - childSize.height * animationValue`. Direct
`RenderObject` inspection confirmed `size.height` is correctly 600 (the real
screen height) — so the layout constraints are right. Solving the formula
backwards from the observed offset gives `animationValue ≈ -0.11`, and that
number doesn't move even after `tester.pump(const Duration(seconds: 1))` — a
full second of fake-clock time, far more than any real bottom-sheet
transition takes. The route's entrance `AnimationController` simply never
settles to 1.0 in this test.

Ruled out as the cause (tried each, no change in behavior):
- `showDragHandle: false`
- `autofocus: false` on the picker's search field

Both point at a Flutter-internal ticker/vsync issue specific to
`AutomatedTestWidgetsFlutterBinding` in this nested `Builder`-inside-`Scaffold`
setup, not an app-level bug — the widget's own `MediaQuery` and the render
box's layout constraints are both correct. Chasing it further would mean
debugging Flutter's own route/ticker plumbing, disproportionate for a
secondary "from contacts" picker, and it may not even reproduce on a real
device (no `FakeAsync` there).

Per the user's decision, the test is now `skip: true` with the reasoning
above recorded as a comment directly above it in
`test/contact_search_picker_sheet_test.dart`, rather than left red or deleted.
`flutter test` is fully green: 354 passed, 1 skipped.
