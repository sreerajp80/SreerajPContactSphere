# Recents tab now refreshes after a call

Implements [plans/20260701_120505_recents-not-refreshing.md](../plans/20260701_120505_recents-not-refreshing.md).

## Problem

A call placed from the Dialer (or Contact screens) did not appear in the **Recents**
tab until the app was relaunched. The `IndexedStack` in `HomeShell` keeps
`CallHistoryScreen` alive, so it loaded its data only once (`initState`) and re-queried
only via `onCallReconciled()` — which fires only for calls placed from the Recents tab
itself. The provisional `call_logs` row was written, but the list never re-queried it.

## Changes

- `lib/screens/call_history_screen.dart`
  - Renamed the state class `_CallHistoryScreenState` → `CallHistoryScreenState` (public)
    so it can be reached via a `GlobalKey`.
  - Added a public `reload()` method that calls the existing `_load()`.
- `lib/screens/home_shell.dart`
  - Added a `GlobalKey<CallHistoryScreenState>` attached to the Recents `CallHistoryScreen`.
  - Moved `_tabs` off `static const` to a `late final` instance list so it can carry the key.
  - Added `_onSelect(int)` wired to `onDestinationSelected`, which reloads the Recents
    screen whenever the Recents tab (index 2) is selected.

## Verification

- `flutter analyze` on both changed files: no issues.

## Notes

Duration/type reconciliation still occurs on the screen that placed the call; the
provisional row shows immediately in Recents on tab selection, and the reconciled
duration is picked up on the next visit to the tab.
