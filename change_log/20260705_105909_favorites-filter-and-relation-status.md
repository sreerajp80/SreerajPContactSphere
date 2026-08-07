# Favorites filter + Relation Status page

Implements both approved plans in one pass (they touch the same screen):

- `plans/20260705_103343_favorites-filter-contacts.md`
- `plans/20260705_104030_relation-status-page.md`

## What changed

### Favorites filter in the Contacts list

- `lib/repositories/contact_repository.dart`
  - `_summarySelect` now also selects `c.is_favorite`, so slim list summaries
    carry the favorite flag (cards can show the star).
  - `getContactSummaries` and `searchContactSummaries` gained an optional
    `favoritesOnly` parameter appending `AND c.is_favorite = 1` to the WHERE
    clause (uses the existing `idx_contacts_is_favorite` index).
- `lib/services/contact_sync_service.dart`
  - `localSummaries` and `searchSummaries` thread `favoritesOnly` through to
    the repository.
- `lib/screens/contact_list_screen.dart`
  - New `_favoritesOnly` state + `_setFavoritesOnly` toggle, wired into
    `_reload`, `_loadMore`, and `_runSearch` (search works inside the
    Favorites view).
  - New filter-chip row (**All** / **★ Favorites**) under the search bar,
    rendered by `_buildFilterChips` + the new `_FilterChipPill` widget
    (accent-tinted selected pill matching the bottom-nav pill; amber star
    when the Favorites chip is selected).
  - Favorites view loads unpaged (`limit: null`) and `_hasMore` is gated off
    while it is active; the Self pin is hidden in the favorites view.
  - Favorite contacts show a small amber `Icons.star` next to their name in
    all list views.
  - Dedicated empty state: "No favorites yet. Star a contact to see it here."

### Relation Status page (Relationship Health moved off the Contacts list)

- `lib/models/relationship.dart`
  - New `RelationOverview` DTO (contactId, fullName, photoPath,
    relationshipScore, relationCount).
- `lib/repositories/relationship_repository.dart`
  - New `getContactsWithRelations()`: contacts joined to `relationships`
    grouped by contact, with `COUNT(DISTINCT related_contact_id)`; secret
    contacts excluded; ordered by name.
- New `lib/screens/relation_status_screen.dart`
  - Secondary page (Scaffold + AppBar "Relation Status", pushed via
    `MaterialPageRoute` like Groups/Duplicates).
  - Hosts the Relationship Health hero card and `_RingPainter` (moved from
    the contacts list), fed by `ContactSyncService.averageScore()` /
    `contactCount()`.
  - Lists contacts with relationships (avatar/initial, name, "N relations",
    mood ring + score); tapping a row opens
    `RelationshipScreen(focusContactId: …)` and refreshes on return.
  - Empty hint when no relationships are defined yet.
- `lib/screens/contact_list_screen.dart`
  - `_buildHealthHero`, `_RingPainter`, `_avgScore`/`_averageScore`, and the
    `averageScore()` call in `_reload` removed (with the now-unused
    `dart:math` import); the filter-chip row takes the hero's slot in the
    body Column.
  - New heart icon (`Icons.favorite_outline`, tooltip "Relation status") in
    the header next to the Groups icon opens the new page and reloads on
    return.

## Verification

- `flutter analyze`: **No issues found.**
- `flutter test`: 59 passed, 1 failed — `test/widget_test.dart` "renders the
  home shell". **Pre-existing failure**, unrelated to this change: the test
  asserts `find.byType(NavigationBar)` but `home_shell.dart` deliberately
  uses a custom bottom bar (see comment at home_shell.dart:65). No file
  touched by this change participates in that assertion.

No DB schema change; `is_favorite` column/index and the `relationships`
table already existed (DB version stays 12).
