# Recents tab not refreshing after a call

**Status:** completed

## Issue

After placing a call (e.g. from the Dialer) and disconnecting, the call does not
appear in the **Recents** tab until the app is relaunched.

### Root cause

- `HomeShell` hosts the three tabs inside an `IndexedStack`
  ([lib/screens/home_shell.dart:39](../lib/screens/home_shell.dart#L39)), which keeps
  `CallHistoryScreen` alive across tab switches.
- `CallHistoryScreen` loads its data only once, in `initState → _load()`
  ([lib/screens/call_history_screen.dart:29-53](../lib/screens/call_history_screen.dart#L29-L53)).
- After that, it re-queries only via `onCallReconciled()`, which fires **only for
  calls placed from within the Recents tab** (the call-back button, through
  `CallLifecycleMixin`).
- A call placed from the Dialer/Contact screens reconciles on *that* screen's state,
  so the Recents screen never re-queries. The provisional `call_logs` row is written
  at placement (`CallService.placeCall`), so the data exists in the DB — the list just
  never reloads until a fresh `initState` (app relaunch).

## Fix

Reload the Recents list whenever the user switches to the Recents tab.

- Expose a public `reload()` on `CallHistoryScreen`'s state (rename the private state
  class `_CallHistoryScreenState` → `CallHistoryScreenState`, add `reload()` that calls
  the existing `_load()`).
- In `HomeShell`, hold a `GlobalKey<CallHistoryScreenState>` for the Recents tab and,
  in `onDestinationSelected`, call `reload()` when the selected index is the Recents tab.

This is minimal and reliable: it always reflects current DB state at the moment the
user actually views Recents, and does not disturb the existing `onCallReconciled`
call-back-from-Recents path.

## Files to change

1. `lib/screens/call_history_screen.dart`
   - Make the state class public (`CallHistoryScreenState`).
   - Add a public `reload()` method wrapping `_load()`.
2. `lib/screens/home_shell.dart`
   - Add a `GlobalKey<CallHistoryScreenState>` and attach it to the `CallHistoryScreen`.
   - Move the `_tabs` list off `const`/static so it can carry the key.
   - In `onDestinationSelected`, trigger `reload()` when the Recents tab is selected.

## Out of scope / notes

- Duration/type back-fill (reconcile) still happens on the screen that placed the call;
  the provisional row already shows in Recents, and a later visit to the tab will pick up
  the reconciled duration. No change needed there for this bug.
