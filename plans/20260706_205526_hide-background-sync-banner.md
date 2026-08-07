# Hide the sync progress banner for background syncs

**Status:** completed

## The issue

Every time the app is cold-started (for example after clearing recent apps),
the contact list shows the "Syncing contacts… X of Y" progress bar. This runs
on every launch because the app does a full re-pull of the device address book
each time (`main.dart` `_bootstrap()` and the contact list's `_backgroundSync()`).

The sync itself is useful, but showing the progress bar on every launch is
annoying and looks like the app is "loading" each time. The user only wants the
bar to appear on the **first ever run** (the blocking first-time import), and be
hidden for the routine background syncs on later launches.

This is a **cosmetic** change only. The sync keeps running exactly as before;
we just stop drawing the banner for background syncs.

## Files to change

1. `lib/screens/contact_list_screen.dart` — gate the sync banner so it only
   shows during the first-run sync.

No other files change. In particular:
- `lib/services/contact_sync_service.dart` stays the same — sync behavior is unchanged.
- `lib/screens/contacts_settings_screen.dart` stays the same — the manual "Sync
  now" action there has its **own** progress text, independent of this banner.

## The plan

In `lib/screens/contact_list_screen.dart`:

1. Add a new state flag, defaulting to hidden:
   ```dart
   /// Whether the sync progress banner may be shown. Only true for the very
   /// first run's blocking import; background syncs on later launches sync
   /// silently.
   bool _showSyncBanner = false;
   ```

2. In `_firstLoad()`, read the initial-sync flag once and set `_showSyncBanner`
   from it, so the banner is allowed only when this is the first run:
   ```dart
   Future<void> _firstLoad() async {
     final initialDone = await _sync.hasCompletedInitialSync();
     if (mounted) setState(() => _showSyncBanner = !initialDone);
     if (initialDone) {
       await _reload();
       _backgroundSync();
     } else {
       await _firstRunQuickShow();
     }
   }
   ```

3. Change the banner's render condition (currently line 697) from:
   ```dart
   if (_syncProgress != null) _buildSyncBanner(colors),
   ```
   to:
   ```dart
   if (_syncProgress != null && _showSyncBanner) _buildSyncBanner(colors),
   ```

The `_syncProgress` stream subscription and `_buildSyncBanner` stay as they are;
the sync still runs and still fires `onSyncCompleted`, so the list still refreshes
after a background sync — just with no visible bar.

## Consequences / notes

- First ever run: banner still shows (unchanged).
- Every later launch: sync runs silently, no banner.
- Edge case: if the user starts a manual sync from the Contacts settings screen
  and then returns to the list while it is still running, the list banner will
  **not** appear (because the initial sync is already done). This is intentional
  and matches the request; the settings screen shows its own "Syncing X of Y…"
  text while that sync runs.

## Testing

- `flutter analyze` — no new warnings/errors from the edit.
- Manual check: fresh install shows the bar on first launch; relaunch after
  clearing recents shows contacts immediately with no sync bar.
