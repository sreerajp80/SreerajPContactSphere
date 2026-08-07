# Fix: "Active Auto-Redials" dialog shows stale, frozen entries

**Status:** completed

## The issue

The "Active Auto-Redials" dialog (opened from the "Active scheduled redials"
row in SIM & calling settings) can keep showing redial entries that have
already fired or been cancelled natively, stuck at "in 0 min" forever.

Two separate gaps cause this, both in
[lib/screens/sim_settings_screen.dart](../lib/screens/sim_settings_screen.dart):

1. `_showActiveRedialsDialog()` (around line 701) reads
   `SmartRedialService().activeTasks` once, when the dialog opens. That list
   is only brought up to date with native truth by
   `SmartRedialService().refresh()`, which today only runs on app resume or
   right after an auto-redial call is placed in the foreground. Opening this
   dialog does not trigger a refresh, so it can show tasks native already
   fired or cancelled.

2. The "in X min" text (`t.remainingDuration.inMinutes`, around line 720) is
   computed once when the dialog builds. There is no timer or listener
   rebuilding the dialog, so the countdown freezes — once it hits zero it
   just stays at "in 0 min" instead of updating or disappearing.

## Files to change

- `lib/screens/sim_settings_screen.dart` — the dialog itself.

## The fix

1. Call `SmartRedialService().refresh()` before showing the dialog (fire and
   forget is not enough since the list must be current when the dialog
   paints, so `await` it, then open the dialog).
2. Wrap the dialog's content in a `ListenableBuilder` listening to
   `SmartRedialService()`, using `StatefulBuilder`/`Timer.periodic` (every
   ~30s, cancelled in `dispose`/when the dialog closes) to force a rebuild so
   the "in X min" countdown ticks down live and the list drops an entry the
   moment `refresh()` (from a resume event while the dialog is open) or a
   manual cancel reconciles it away, without the user needing to close and
   reopen the dialog.
3. If `refresh()` causes the task to be reconciled away before the dialog
   even opens, the dialog should open already showing "No active scheduled
   redials." instead of a stale row.

No changes to native code, `SmartRedialService`, or the settings card badge
— those already reconcile correctly per the two most recent change logs.

## Verification

- `flutter analyze`
- `flutter test test/smart_redial_service_test.dart`
- Manual/on-device check is up to the user, per project convention.
