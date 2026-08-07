# Dialer "Top contacts" source — recency fallback + Family/Friends setting

Implements
[plans/20260701_213810_dialer-top-contacts-source-setting.md](../plans/20260701_213810_dialer-top-contacts-source-setting.md).

## What changed

The dialer's "Top contacts" section is now driven by a persisted Settings choice
(`DialerTopSource`), with a recency fallback so it isn't empty on a fresh app.

### `lib/state/app_settings.dart`
- Added top-level `enum DialerTopSource { recent, relations }`.
- Added the `dialer_top_source` preference: `_dialerTopSource` field (default `recent`),
  `dialerTopSource` getter, index-guarded load in `load()`, and `setDialerTopSource(...)`
  that persists via `SharedPreferences.setInt(index)` and notifies listeners.

### `lib/repositories/contact_repository.dart`
- Extracted the duplicated pre-dial query columns into `static const _preDialProjection`
  and the row→`PhoneMatch` mapping into `PhoneMatch _preDialMatch(row)`; refactored
  `getFavoriteMatches` to use them.
- Replaced `getTopRelationshipMatches` with **`getTopRecentMatches({limit})`**: pass 1
  returns contacts with `relationship_score > 0` (best first); if fewer than `limit`, pass 2
  fills from `call_logs` (`JOIN … GROUP BY c.id ORDER BY MAX(cl.timestamp) DESC`), excluding
  the ids already picked. Non-secret / non-favorite; de-duplicated in Dart.
- Added **`getFamilyFriendsMatches({limit})`**: non-secret, non-favorite contacts that have
  any row in `relationships` (`EXISTS`), ordered by `relationship_score DESC, first_name ASC`.

### `lib/screens/settings_screen.dart`
- Added `_DialerTopContactsCard` (after the post-call card): watches `AppSettings`, shows
  the current choice, and on tap opens a `SimpleDialog` of `_OptionTile`s (Most recent /
  Family & friends) with a check on the current selection; writes via
  `setDialerTopSource(...)`. `_OptionTile` is a small selectable dialog row (avoids the
  deprecated `Radio` group API).

### `lib/screens/dialer_screen.dart`
- Imported `provider` + `app_settings`; added a `DialerTopSource _topSource` field.
- `_loadFavorites` now reads `context.read<AppSettings>().dialerTopSource` and loads
  `_topContacts` from `getFamilyFriendsMatches()` or `getTopRecentMatches()` accordingly,
  storing the source for the header.
- The top section's header shows "Family & friends" in relations mode, else "Top contacts".
- `_openSettings` now awaits the pushed Settings screen and reloads on return (so changing
  the source from the dialer's own ⋮ menu refreshes immediately; the Contacts-menu path is
  already covered by the tab-select `reload()`).

## Verification
- `flutter analyze` (whole project) → **No issues found.**

## Notes
- "Family & friends" = any contact with an explicit `relationships` link (not narrowed to
  specific types like excluding Colleague/Neighbour).
- Recency uses `call_logs`; unknown-number calls (`contact_id IS NULL`) are excluded by the
  join. No DB schema change; no new dependency.
