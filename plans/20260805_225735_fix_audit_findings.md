# Fix audit findings (timer leak, flaky picker tests, stale docs, plan status)

**Status:** completed

**Addendum (approved):** the "tapping a row" test failure turned out to be a
real modal-bottom-sheet positioning bug (see change log), not the DB race.
Traced into Flutter's own `_ModalBottomSheetLayout` far enough to know its
`RenderBox` is laid out with `size.height ≈ 1068` instead of the real 600px
test screen height, but not far enough to know why. User approved trying a
few cheap experiments (toggle `showDragHandle`, drop the sheet's own
`SizedBox(height: 0.7 * screenHeight)`, pass explicit `constraints:` to
`showModalBottomSheet`) to isolate the trigger before deciding on a real fix.

## Issue

A full-project audit turned up four separate problems:

1. **Timer leak in `ContactListScreen`.** `initState` calls
   `EphemeralContactService().startMonitoring()` (starts a periodic 1-minute
   timer) but `dispose()` never calls the matching `stopMonitoring()`. In
   production this is harmless today — the screen lives inside `home_shell.dart`'s
   `IndexedStack`, so it is never actually disposed until the app itself closes.
   But it fails `test/widget_test.dart` ("A Timer is still pending even after the
   widget tree was disposed") and is a correctness gap if that screen's lifecycle
   ever changes.

2. **Two distinct bugs inside `test/contact_search_picker_sheet_test.dart`,**
   both traced by re-running the file in isolation:
   - **Test-authoring bug** in "requirePhone hides contacts without a number":
     after typing "Nonumber" into the search box, `expect(find.text('Nonumber'),
     findsNothing)` fails — but the widget it finds is the search `TextField`'s
     own `EditableText` (which now literally contains the typed text
     "Nonumber"), not a contact row. The assertion needs to be scoped to the
     contact list only.
   - **Real DB race**: `_onQueryChanged` (fired synchronously by
     `tester.enterText`) kicks off an *unawaited* `_run()` that does a real
     `sqflite_common_ffi` query. The test only waits a flat 150 ms
     (`settle()`) before moving on. If that wall-clock guess is too short, the
     query is still in flight when the test function returns. The *next*
     test's `setUp()` then calls `DatabaseHelper().close()` and reopens a
     fresh DB file while the old query is still resolving — which is exactly
     what produces `SqfliteFfiException: This database has already been
     closed` in the *following* test's own `insertContact` call. This matches
     the observed failure pattern: only tests that immediately follow a
     `type()` call fail.

3. **Stale docs** — the currently-uncommitted change removes
   `flutter_local_notifications` from `pubspec.yaml` entirely (and it has zero
   remaining usages in `lib/`/`test/` — all real notifications, missed-call,
   emergency card, in-call, are handled natively via Android's
   `NotificationCompat`/`NotificationManager` in Kotlin, confirmed by grep of
   `android/app/src/main/kotlin/.../*.kt`). But five docs and one Gradle
   comment still describe it as an active dependency:
   - `docs/dependencies.md:12`
   - `docs/features.md:485` (a line *added* in this same diff)
   - `docs/known-gaps.md:210`
   - `docs/release_process.md:246`
   - `docs/security.md:116`
   - `android/app/build.gradle.kts:27` (comment only; desugaring itself stays
     enabled since removing it is out of scope and unrelated to this cleanup)

4. **Process gap** — `plans/20260805_100000_fix_incoming_call_duplicate_recents_row.md`
   is still `**Status:** approval_pending`, but
   `change_log/20260805_100500_fix_incoming_call_duplicate_recents_row.md`
   shows it was implemented and logged. The status line was never updated per
   this project's own mandatory workflow rule.

## Files to change

- `lib/screens/contact_list_screen.dart` — call `stopMonitoring()` in `dispose()`.
- `test/contact_search_picker_sheet_test.dart` — scope the "Nonumber" assertion
  to the contact list (not the search field), and replace the fixed 150 ms
  `settle()` wait with a poll that waits until the sheet's loading indicator
  clears (bounded, e.g. up to ~2 s in 50 ms steps) so a real DB round trip is
  guaranteed to finish before the test returns.
- `docs/dependencies.md` — drop `flutter_local_notifications` from the
  Notifications line; note `timezone` is used for the pre-call summary's
  timezone lookup, not notification scheduling.
- `docs/features.md` — rewrite the paragraph around the removed dependency:
  say plainly that no notification-scheduling library is wired in yet (native
  Android notifications cover missed-call/emergency-card alerts; nothing
  schedules the `reminders` rows or relationship-decay nudges).
- `docs/known-gaps.md` — drop the `flutter_local_notifications` mention from
  the "Notifications / reminders" bullet.
- `docs/release_process.md` and `docs/security.md` — drop
  `flutter_local_notifications` from the R8/keep-list mentions.
- `android/app/build.gradle.kts` — fix the stale comment on
  `isCoreLibraryDesugaringEnabled` (desugaring itself is left on, since other
  code/plugins in this project may still need Java 8+ APIs; just correct what
  it's attributed to, or note it's currently unused pending confirmation).
- `plans/20260805_100000_fix_incoming_call_duplicate_recents_row.md` — flip
  `**Status:**` to `completed`.

## Plan for the fix

1. `contact_list_screen.dart`: add `EphemeralContactService().stopMonitoring();`
   alongside the existing subscription cancellations in `dispose()`.
2. `contact_search_picker_sheet_test.dart`:
   - Replace `expect(find.text('Nonumber'), findsNothing);` with a finder
     scoped to `ListTile` (e.g. `find.widgetWithText(ListTile, 'Nonumber')`),
     so it only checks the contact list, not the search field's own text.
   - Add a `waitForIdle(tester)` helper that repeatedly does
     `tester.runAsync(() => Future.delayed(50ms))` + `tester.pump()` until
     `CircularProgressIndicator` is gone (capped at ~40 iterations / ~2s), and
     call it from `settle()` instead of the flat 150 ms sleep.
3. Update the five docs + Gradle comment listed above to stop describing
   `flutter_local_notifications` as an active dependency.
4. Flip the one stale plan's `Status:` line to `completed`.
5. Run `flutter analyze` and `flutter test` to confirm everything is clean
   (including the previously-failing `widget_test.dart` and
   `contact_search_picker_sheet_test.dart`).

## Verification

- `flutter analyze` — no issues.
- `flutter test` — full suite green, in particular `widget_test.dart` and
  `contact_search_picker_sheet_test.dart`.
- Manual read-through of the five doc files + Gradle comment to confirm no
  remaining `flutter_local_notifications` references outside `pubspec.lock`
  (which will self-correct on the next `flutter pub get` and isn't hand-edited).
