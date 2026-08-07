# Stale "Auto-retry scheduled" banner, and "No answer" on an incoming call

**Status:** completed

## The issue

Seen on the device on 2026-08-06: a retry was scheduled for 5 minutes, the contact called
back at 19:19:07, and the native alarm was cancelled correctly in the same millisecond
(`dumpsys alarm`: `Reason=alarm_cancelled ... SMART_REDIAL_ALARM`, from
`ContactSphereCallScreeningService`). But the app still showed
**"Auto-retry scheduled in 5 min for <name>"** on the Recents screen afterwards.

Two causes, both in the Flutter layer.

### 1. The banner is a SnackBar that can freeze on screen

It is shown when scheduling succeeds ([smart_redial_sheet.dart:108](lib/widgets/smart_redial_sheet.dart#L108))
with no explicit `duration`. A SnackBar's auto-dismiss timer only starts once its entry
animation completes, and that animation's ticker is muted while the app is off-screen. A
call arriving moments after scheduling therefore leaves the SnackBar sitting there
indefinitely, still claiming a retry is coming. Its `View` action is also a dead button
(empty `onPressed`, [smart_redial_sheet.dart:116](lib/widgets/smart_redial_sheet.dart#L116)).

### 2. The Dart task list isn't refreshed when a call happens

Native cancels the task on its own. Dart only reconciles in `SmartRedialService.init()` and
on `AppLifecycleState.resumed` ([main.dart:590](lib/main.dart#L590)). The in-call screen is
a route inside the same activity, so an incoming call while the app is open produces **no**
pause/resume — `refresh()` never runs and "Active scheduled redials" keeps listing a task
that no longer exists, until the app is backgrounded and reopened.

## The fix

1. **`lib/main.dart`** — in `_onCall`, refresh the Smart Redial mirror when a call ends
   (the same edge that already tears down the in-call route). That is exactly when native
   may have auto-cancelled a task, and it costs one cheap native call per call.
   Also hide any showing SnackBar when a call arrives, so a frozen one from step 1 cannot
   outlive the event it describes.
2. **`lib/widgets/smart_redial_sheet.dart`** — give the confirmation SnackBar an explicit
   short `duration`, state the actual time the retry will run ("Auto-retry at 7:23 PM for
   <name>") instead of a countdown that goes stale, and either wire `View` to the pending
   redials list in SIM & calling settings or drop the action. Wiring it is preferred; if the
   settings screen can't be opened from that context, the action is removed rather than left
   dead.

## Second issue: an incoming call that was never answered reads "No answer"

The 7:19 PM row in Recents is an incoming call the caller ended before it was picked up.
The device call log agrees (`type=3` MISSED, `duration=0`), and the app maps it to
`call_type = missed` — the red arrow is right. But the outcome is stored as `no_answer`
([call_type_mapper.dart:88](lib/utils/call_type_mapper.dart#L88)) and rendered as
**"No answer"** ([call_type_mapper.dart:110](lib/utils/call_type_mapper.dart#L110)).

"No answer" is outgoing-call language: *you* rang someone and they didn't pick up. For a
call that came in, the same fact reads as **"Missed"**. The stored value is fine (it is the
same fact); only the label is direction-blind.

**Fix:** `callOutcomeLabel` takes the call's direction (`call_type`) and returns "Missed"
for `no_answer` on an `incoming`/`missed` row, "No answer" on an outgoing one. Recents
passes `call.callType` at the one call site
([call_history_screen.dart:411](lib/screens/call_history_screen.dart#L411)); any other
caller of the label is updated the same way. No stored data changes, so old rows re-read
correctly with no migration.

## Files to change

| File | Change |
| --- | --- |
| `lib/main.dart` | refresh the redial mirror when a call ends; clear a showing SnackBar when a call arrives |
| `lib/widgets/smart_redial_sheet.dart` | explicit SnackBar duration, honest wording, working (or removed) `View` action |
| `lib/utils/call_type_mapper.dart` | `callOutcomeLabel` becomes direction-aware ("Missed" vs "No answer") |
| `lib/screens/call_history_screen.dart` | pass the call type to `callOutcomeLabel` |
| `test/call_outcome_test.dart` | cover both directions (the only other caller) |
| `change_log/` | change log after implementation |

## How to verify

1. Schedule a retry, then have the contact call back before it fires, all with the app open:
   the banner must not linger, and SIM & calling settings must show no pending redial
   without needing to background the app.
2. Schedule a retry and leave the app alone: the banner disappears on its own after a few
   seconds, and the pending redial is listed in settings.
