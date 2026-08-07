# Favorites filter in the Contacts list

**Status:** completed

## Issue

Contacts can be marked favorite (star toggle on the contact detail screen,
`is_favorite` column in SQLite with an index), but the Contacts tab never
surfaces them. The whole point of favoriting is quick access, so the user
wants a tab/filter in the Contacts section that shows favorites quickly and
first.

## Approach

Add a filter-chip row (**All** / **★ Favorites**) directly under the search
bar in the Contacts screen. Tapping **Favorites** switches the list to a
favorites-only view backed by a dedicated DB query (uses the existing
`idx_contacts_is_favorite` index). Also show a small star on the card of any
favorite contact in the normal list, so favorites are recognizable at a
glance.

No schema change or migration is needed — the `is_favorite` column and index
already exist (DB v8+, current version 12).

Chips follow the app's own design system (accent-tinted selected pill like
the bottom-nav pill in `home_shell.dart`, `AppColors` tokens, no hard-coded
colors). Star iconography follows the established `Icons.star` + amber
pattern from the detail screen.

## Files to change

1. **`lib/repositories/contact_repository.dart`**
   - Add `c.is_favorite` to the `_summarySelect` projection (~line 681) so
     list cards can show the star.
   - Add an optional `favoritesOnly` parameter to `getContactSummaries`
     (~line 716) and `searchContactSummaries` (~line 760) that appends
     `AND c.is_favorite = 1` to the WHERE clause. Sort stays
     `first_name ASC` (search keeps `is_self DESC, first_name ASC`).

2. **`lib/services/contact_sync_service.dart`**
   - Thread the `favoritesOnly` flag through the existing pass-throughs
     `localSummaries` (~line 50) and `searchSummaries` (~line 81), mirroring
     the current signatures. No new service method needed.

3. **`lib/screens/contact_list_screen.dart`**
   - New state field `bool _favoritesOnly = false` next to
     `_showSecretContacts` (~line 58).
   - New `_buildFilterChips()` widget — a row with **All** and
     **★ Favorites** pills — inserted in the body `Column` between
     `_buildSearch` and `_buildHealthHero` (~line 560). Selected pill:
     `accent.withValues(alpha: 0.16)` fill + accent text (matching the
     home-shell nav pill); unselected: `colors.searchFill` + mutedText.
   - Toggling a chip sets `_favoritesOnly` and re-runs `_reload` /
     `_runSearch`, passing `favoritesOnly` through to the service. Search
     continues to work inside the Favorites view (searches favorites only).
   - Paging guard: `_hasMore` (~line 64) also requires
     `!_favoritesOnly` — the favorites view loads in one query (favorites
     are a small set; simpler and avoids offset bookkeeping in two modes).
   - In `_buildContactCard` (~line 818), render a small amber
     `Icons.star` next to the name when the summary's `isFavorite` is true.
   - Empty state: when Favorites is selected and there are none, show a
     short hint ("No favorites yet — star a contact to see it here")
     instead of an empty list.

## Not in scope (can follow up later)

- In-list favorite toggle (star button / swipe action on cards) — favoriting
  stays on the detail screen for now.
- Favorites-first ordering of the *All* list — the filter chip covers the
  quick-access need without changing the familiar alphabetical order.

## Verification

- `flutter analyze` (no new issues beyond documented known gaps).
- `flutter run`: mark 2–3 contacts favorite from detail screen → Favorites
  chip shows exactly those; search within Favorites; secret-contacts toggle
  still respected; empty state shows when no favorites; star appears on
  favorite cards in the All view.
