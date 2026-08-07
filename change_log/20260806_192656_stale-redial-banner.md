# Stale auto-retry banner, stale redial list, and "No answer" on an incoming call

Implements [plans/20260806_192500_stale-redial-banner.md](../plans/20260806_192500_stale-redial-banner.md).

Found while testing the Smart Redial auto-cancel on the device: the native side cancelled
the alarm correctly the instant the contact called back (`dumpsys alarm`:
`Reason=alarm_cancelled ... SMART_REDIAL_ALARM` at 19:19:07.308, same millisecond the
screening service ran), but the app still showed "Auto-retry scheduled in 5 min".

## What changed

### 1. The confirmation banner (`lib/widgets/smart_redial_sheet.dart`)

- Shows the wall-clock time the retry will run ("Auto-retry at 7:23 PM for X") instead of a
  countdown that goes stale the moment the message outlives its few seconds.
- The `View` action was a dead callback; it now opens SIM & calling settings, which lists
  the pending redials with a cancel action.
- The navigator/messenger are captured before the sheet is popped, so the action works
  after the sheet is gone.

### 2. The redial list during a call (`lib/main.dart`)

- New `_syncRedialsWithCall`, called from `_onCall`:
  - when a call **ends**, refreshes `SmartRedialService` — native may have auto-cancelled
    or fired a task, and the in-call screen is a route in the same activity, so no
    pause/resume happens and the old `resumed`-only refresh never ran;
  - when a call **arrives**, hides any showing SnackBar, so a confirmation cannot sit on
    screen describing a retry that is being cancelled. (A SnackBar's dismiss timer only
    starts once its entry animation completes, and that stalls while the app is
    off-screen — which is why the banner appeared frozen.)
- Edge-detected on "has a call" so it runs on transitions, not on every snapshot.
- `MaterialApp` now carries a `scaffoldMessengerKey` so this can reach the messenger.

### 3. "No answer" on an incoming call (`lib/utils/call_type_mapper.dart`)

An incoming call the caller ended before it was answered was labelled "No answer" —
outgoing-call language. `callOutcomeLabel` now takes the call's direction and reads
**"Missed"** for `no_answer` on an incoming/missed row, keeping "No answer" for outgoing.
Other outcomes (Busy, Declined, Cancelled, Failed) are unchanged either way.

Stored data is untouched (the outcome is the same fact), so old rows re-read correctly with
no migration. `lib/screens/call_history_screen.dart` passes `call.callType`;
`test/call_outcome_test.dart` covers both directions.

## Checks run

- `flutter analyze` — no issues.
- `flutter test test/call_outcome_test.dart` — 24 tests pass.
- `flutter build apk --debug --flavor dev` — builds.

## Still to verify on the device

1. Schedule a retry and leave the app: the banner clears itself after a few seconds, and
   "View" opens SIM & calling settings.
2. Schedule a retry, then have the contact call back before it fires, with the app open:
   the banner goes as the call arrives, and settings shows no pending redial without
   backgrounding the app.
3. A missed incoming call reads "Missed" in Recents; an unanswered outgoing call still
   reads "No answer".
