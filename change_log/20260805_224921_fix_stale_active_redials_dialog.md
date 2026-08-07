# Fix: "Active Auto-Redials" dialog shows stale, frozen entries

Implements [plans/20260805_224921_fix_stale_active_redials_dialog.md](../plans/20260805_224921_fix_stale_active_redials_dialog.md).

## What was wrong

The "Active Auto-Redials" dialog (SIM & calling settings → "Active scheduled
redials") could keep showing entries stuck at "in 0 min" long after the
redial had already fired or been auto-cancelled natively.

Two gaps in `lib/screens/sim_settings_screen.dart`:

- `_showActiveRedialsDialog()` read `SmartRedialService().activeTasks` once
  when the dialog opened, without first reconciling against native truth.
  `SmartRedialService.refresh()` (added in an earlier fix) only ran on app
  resume or right after an auto-redial call fired in the foreground —
  opening this dialog wasn't one of those triggers.
- The "in X min" countdown was computed once at dialog build time. With no
  timer or listener rebuilding it, the text froze the moment it hit zero
  instead of updating or the entry disappearing.

## What changed

- `_showActiveRedialsDialog()` now `await`s `SmartRedialService().refresh()`
  before opening the dialog, so it starts from current native state.
- The dialog's content is now a new `_ActiveRedialsDialogContent` stateful
  widget that wraps itself in a `ListenableBuilder` on `SmartRedialService()`
  and runs a 30-second periodic timer (cancelled in `dispose()`) to force a
  rebuild. This means the countdown keeps ticking, and cancelling a task (or
  a resume-triggered reconcile) removes it from the list immediately without
  needing to close and reopen the dialog. The cancel button no longer closes
  the dialog itself — the list just updates live.

## Verification

- `flutter analyze lib/screens/sim_settings_screen.dart` — no issues.
- `flutter test test/smart_redial_service_test.dart` — all 3 tests pass.
- Not verified on-device in this session (user builds/installs themselves):
  please confirm that opening the dialog after a redial has already fired
  shows it correctly removed, and that the countdown ticks down / the entry
  drops out live while the dialog stays open.
