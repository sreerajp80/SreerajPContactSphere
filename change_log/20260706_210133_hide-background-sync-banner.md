# Change log — Hide the sync progress banner for background syncs

Implements plan: `plans/20260706_205526_hide-background-sync-banner.md`.

## What was changed

Only one file was edited: `lib/screens/contact_list_screen.dart`.

The "Syncing contacts… X of Y" progress banner now shows **only** during the
first-run blocking import. On every later launch the device-book sync still runs
in the background, but silently — no banner. This removes the bar that appeared
each time the app was cold-started (for example after clearing recent apps).

Sync behavior itself is unchanged; this is a cosmetic (UI-only) change.

## Edits

1. Added a state flag `bool _showSyncBanner = false;` with a doc comment.
2. `_firstLoad()` now reads `hasCompletedInitialSync()` once into `initialDone`
   and sets `_showSyncBanner = !initialDone` (via `setState`), so the banner is
   allowed only on the first run.
3. The banner render condition changed from
   `if (_syncProgress != null)` to
   `if (_syncProgress != null && _showSyncBanner)`.

## Not changed

- `lib/services/contact_sync_service.dart` — sync logic untouched.
- `lib/screens/contacts_settings_screen.dart` — the manual "Sync now" action
  keeps its own independent progress text.

## Verification

- `flutter analyze lib/screens/contact_list_screen.dart` → "No issues found!"

## Notes

- First ever run: banner still shows.
- Later launches: sync runs silently, no banner.
- If a manual sync is started from Contacts settings and the user returns to the
  list while it is still running, the list banner will not appear (intentional);
  the settings screen shows its own progress text.
