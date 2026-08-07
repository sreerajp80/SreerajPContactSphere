# Dialer "Top contacts" source — recency fallback + Family/Friends setting

**Status:** completed

## What the user asked for

The dialer's "Top contacts" section is empty on a fresh app because it only shows
contacts with `relationship_score > 0`, and the score accrues from interactions. Two
requests:

1. **Fallback so it's never needlessly empty** — when there aren't enough scored contacts,
   fill with the **most-recently contacted** people (user's chosen default).
2. **A Settings choice** — let the user switch the section to show **Family & friends**
   (contacts they've explicitly linked as relations) instead of the recency-based list.

## Design

A new persisted preference, `DialerTopSource`, with two values:

- `recent` **(default)** — rank by `relationship_score` (desc), then fill remaining slots
  with the most-recently contacted contacts (by latest `call_logs.timestamp`). This is the
  "smart, never-empty once you've made a call" list.
- `relations` — show contacts that have at least one explicit link in the `relationships`
  table (the people in your relationship sphere — family, friends, etc.), highest
  `relationship_score` first, then by name.

The **screen** reads the setting and calls the matching repository method; the repository
stays unaware of the setting (clean layering). The dialer's section header reflects the
mode ("Top contacts" vs "Family & friends").

## Files to change

### 1. `lib/state/app_settings.dart`
- Add a top-level `enum DialerTopSource { recent, relations }`.
- Add `_kDialerTopSource` pref key, `_dialerTopSource` field (default `recent`), a
  `dialerTopSource` getter, load-from-prefs in `load()` (index-guarded like `themeMode`),
  and `setDialerTopSource(...)` that persists via `SharedPreferences.setInt(index)` and
  `notifyListeners()`. Mirrors the existing preference methods.

### 2. `lib/repositories/contact_repository.dart`
- Extract the repeated pre-dial projection + row→`PhoneMatch` mapping (currently duplicated
  in `getFavoriteMatches` and `getTopRelationshipMatches`) into a shared
  `static const String _preDialProjection` (the `contact_id` / assembled name / primary
  number / primary label columns, selected from `contacts c`) and a `PhoneMatch
  _preDialMatch(Map row)` helper. Refactor `getFavoriteMatches` to use them.
- Replace `getTopRelationshipMatches` with **`getTopRecentMatches({int limit = 5})`**:
  1. Query scored contacts (`is_secret = 0 AND is_favorite = 0 AND relationship_score > 0`,
     `ORDER BY relationship_score DESC, first_name ASC`, `LIMIT limit`).
  2. If fewer than `limit`, fill the rest from `call_logs`: `JOIN call_logs cl ON
     cl.contact_id = c.id`, same secret/favorite filters, `AND c.id NOT IN (…already
     picked…)`, `GROUP BY c.id`, `ORDER BY MAX(cl.timestamp) DESC`, `LIMIT remaining`.
  De-dup by contact id in Dart; both use `_preDialProjection` / `_preDialMatch`.
- Add **`getFamilyFriendsMatches({int limit = 5})`**: contacts with
  `is_secret = 0 AND is_favorite = 0 AND EXISTS (SELECT 1 FROM relationships r WHERE
  r.contact_id = c.id)`, `ORDER BY relationship_score DESC, first_name ASC`, `LIMIT limit`.

### 3. `lib/screens/settings_screen.dart`
- Add a `_DialerTopContactsCard` (StatelessWidget, same card styling as
  `_PostCallFeedbackCard`) after the post-call card. It `watch`es `AppSettings`, shows the
  current choice as its subtitle, and on tap opens a `SimpleDialog` with two options
  (Most recent / Family & friends) — each a `ListTile` that pops its value and shows a
  check on the current selection (avoids the deprecated `Radio` group API). The chosen
  value is written via `context.read<AppSettings>().setDialerTopSource(...)`.

### 4. `lib/screens/dialer_screen.dart`
- Import `provider` and `app_settings`.
- Add a `DialerTopSource _topSource` field (for the header label).
- In `_loadFavorites`, read `context.read<AppSettings>().dialerTopSource` (before any
  await), store it in `_topSource`, and load `_topContacts` from either
  `getFamilyFriendsMatches()` or `getTopRecentMatches()` accordingly.
- Header for the top section becomes "Family & friends" when `_topSource == relations`,
  else "Top contacts".
- Make `_openSettings` `await` the pushed `SettingsScreen` and then call `_loadFavorites()`
  on return, so changing the setting from the dialer's own ⋮ menu refreshes the list. (The
  Contacts-menu entry point is already covered by the tab-select `reload()` added earlier.)

## Notes / decisions

- **"Family & friends"** is implemented as *any contact with an explicit relationship
  link* (the relationship sphere). The preset types are overwhelmingly family/social; I did
  not special-case excluding Colleague/Neighbour. Say so if you want it narrowed to
  specific types.
- Recency uses `call_logs` (the direct "contacted" signal; `interactions` is a subset fed
  by post-call feedback). Contacts with `contact_id IS NULL` calls (unknown numbers) are
  naturally excluded by the join.
- No DB schema change. No new dependency (`provider` / `shared_preferences` already used).

## Verification
- `flutter analyze` clean.
- Manual: fresh app, place a call → the callee appears under "Top contacts"; switch the
  Settings choice to Family & friends → the section shows linked relations and the header
  changes; toggle back → recency list returns.
