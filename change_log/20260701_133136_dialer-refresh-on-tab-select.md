# Dialer: reload Favorites & Top contacts when the tab is selected

Implements
[plans/20260701_133136_dialer-refresh-on-tab-select.md](../plans/20260701_133136_dialer-refresh-on-tab-select.md).

## Problem

After adding the Favorites / Top-contacts sections, the dialer still showed neither.
Cause was a refresh gap: `HomeShell` keeps tabs alive in an `IndexedStack`, and
`DialerScreen` loaded its lists only in `initState` (which runs once, at startup, before
the user has starred anyone or built up interaction scores). Starring a contact on the
Contacts tab and returning to the Dialer never re-queried. `HomeShell` already solved the
identical issue for Recents via a `reload()` on tab select; the dialer lacked the hook.

## What changed

### `lib/screens/dialer_screen.dart`
- Made the state class public: `_DialerScreenState` → `DialerScreenState` (and the
  `createState` return type), mirroring `CallHistoryScreenState`.
- Added a public `reload()` that re-runs `_loadFavorites()` (which loads both Favorites and
  Top contacts), guarded by `mounted`.

### `lib/screens/home_shell.dart`
- Added `_dialerIndex = 1` and a `GlobalKey<DialerScreenState> _dialerKey`.
- Attached `key: _dialerKey` to the `DialerScreen` in `_tabs` (no longer `const`).
- `_onSelect` now calls `_dialerKey.currentState?.reload()` when the Dialer tab is selected,
  alongside the existing Recents reload (refactored to an `if/else if`).

## Verification
- `flutter analyze lib/screens/dialer_screen.dart lib/screens/home_shell.dart`
  → **No issues found.**

## Notes
- If the user has no starred contacts and no contact with `relationship_score > 0`, both
  sections remain legitimately empty (score accrues from interactions). The reload fixes the
  common flow: star on Contacts → switch to Dialer → it now appears without an app restart.
