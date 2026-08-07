# Dialer: reload Favorites & Top contacts when the tab is selected

**Status:** completed

## The issue

After the previous change, the Dialer still shows neither Favorites nor Top contacts.

Root cause is a **refresh gap**, not a query bug:
[home_shell.dart](../lib/screens/home_shell.dart) hosts the tabs in an `IndexedStack`
(line 55), which builds and keeps every tab alive. `DialerScreen` loads its Favorites and
Top-contacts lists only in `initState` (via `_loadFavorites`), plus after actions taken
*inside* the dialer (opening/adding a contact). `initState` runs once — at app startup,
before the user has starred anyone or accumulated any interaction score.

So when the user stars a contact (or builds up call history) on the **Contacts** tab and
switches back to the **Dialer**, the dialer never re-queries and stays empty. This is the
exact same problem `HomeShell` already solves for the **Recents** tab: it calls
`_recentsKey.currentState?.reload()` in `_onSelect` (lines 43–45) because the Recents list
"only loads once (IndexedStack keeps it alive)". The dialer has no equivalent hook.

## Plan for the fix

Mirror the existing Recents pattern for the dialer.

### `lib/screens/dialer_screen.dart`
- Make the state class public: rename `_DialerScreenState` → `DialerScreenState` (so a
  `GlobalKey<DialerScreenState>` can reach it), and update the `createState` return type.
  This mirrors `CallHistoryScreenState`.
- Add a public `void reload()` that re-runs the pre-dial loads (`_loadFavorites()`, which
  already loads both Favorites and Top contacts). Guard with `mounted`.

### `lib/screens/home_shell.dart`
- Add `static const _dialerIndex = 1;` and a `final _dialerKey = GlobalKey<DialerScreenState>();`.
- Pass `key: _dialerKey` when constructing `DialerScreen` in `_tabs` (it can no longer be
  `const`).
- In `_onSelect`, when `i == _dialerIndex`, call `_dialerKey.currentState?.reload()` —
  alongside the existing Recents reload.

## Files to change

1. `lib/screens/dialer_screen.dart` — public state class + `reload()`.
2. `lib/screens/home_shell.dart` — dialer GlobalKey + reload on tab select.

## Notes / verification

- This fixes visibility for the normal flow (star on Contacts → open Dialer). If the user
  genuinely has **no** starred contacts and **no** contact with `relationship_score > 0`,
  both sections are still legitimately empty and the "Star a contact to see it here" hint
  shows — that is correct, not a bug. (Top contacts require accumulated interactions, since
  the score starts at 0.)
- `flutter analyze` must stay clean.
- Manual check: star a contact on the Contacts tab → switch to Dialer → it appears under
  FAVORITES without restarting the app.
