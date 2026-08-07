# Relation Status page (move Relationship Health off the Contacts list)

**Status:** completed

Companion to `20260705_103343_favorites-filter-contacts.md` (favorites filter).
Together they reshape the Contacts screen: hero card leaves, filter chips
arrive, and relationship info gets its own page.

## Issue

The "RELATIONSHIP HEALTH" hero card occupies prime space at the top of the
Contacts list but is purely presentational (not even tappable). The user
wants it moved to a dedicated **Relation Status** page that shows:

1. the Relationship Health hero (score ring, mood, contact count), and
2. a list of contacts that have relationships defined — tapping a contact
   opens the existing Relationship Sphere screen
   (`RelationshipScreen(focusContactId: id)`) for that contact.

## Approach

New secondary screen `RelationStatusScreen` (own `Scaffold` + `AppBar`,
pushed via `MaterialPageRoute` — same pattern as `GroupsScreen` /
`DuplicatesScreen`). Entry point: a heart/health icon button in the Contacts
header (next to the existing groups icon), plus keeping the screen reachable
even when the list is empty. The hero card is removed from the Contacts list,
freeing vertical space so the contact list (and the new favorites chips)
start higher.

"Has a relationship defined" = the contact appears as `contact_id` in at
least one `relationships` row (links are stored as two reciprocal rows, so
one query direction suffices).

## Files to change

1. **`lib/repositories/relationship_repository.dart`**
   - New method `getContactsWithRelations()`: `contacts c JOIN relationships
     r ON c.id = r.contact_id … GROUP BY c.id`, selecting name parts,
     `photo_path`, `relationship_score`, and
     `COUNT(DISTINCT r.related_contact_id) AS relation_count`, ordered by
     name. Name assembly mirrors the existing `getRelationsOf` (~lines
     73-109). Returns a small DTO (reuse/extend `RelatedContact` or add a
     sibling record with `relationCount`). Excludes secret contacts
     (`c.is_secret = 0`), consistent with other cross-contact views.

2. **New: `lib/screens/relation_status_screen.dart`**
   - `Scaffold` + `AppBar` titled "Relation Status".
   - Top: the Relationship Health hero card — visuals moved from
     `_buildHealthHero` (score ring via `_RingPainter`, mood label, contact
     count), fed by `ContactSyncService.averageScore()` / `contactCount()`
     and `AppTheme.moodFor`.
   - Below: section header ("WITH RELATIONSHIPS", dialer-style header) and a
     `ListView` of contacts from `getContactsWithRelations()` — avatar
     (photo or initial), name, subtitle "N relation(s)", trailing mood icon
     for their `relationship_score`.
   - Row `onTap` → `Navigator.push(MaterialPageRoute(builder: (_) =>
     RelationshipScreen(focusContactId: c.contactId)))`; refresh the list on
     return (relations can be edited in the sphere).
   - Empty state when no contact has relationships yet ("No relationships
     defined yet — add them from a contact's page").
   - All styling from `AppColors` tokens / `theme.colorScheme.primary`.

3. **`lib/screens/contact_list_screen.dart`**
   - Remove `_buildHealthHero` (~664-772) and `_RingPainter` from this file;
     drop the hero from the body `Column`. Keep `_avgScore`/`_moodIcon`
     only as far as contact cards still need them (`_moodIcon` stays — cards
     use it; `_avgScore`/`averageScore` call moves to the new screen).
   - Add a header `IconButton` (e.g. `Icons.favorite_outline` heart-pulse
     style, tooltip "Relation status") in `_buildHeader` (~571-615) next to
     the groups icon, pushing `RelationStatusScreen` and calling `_reload()`
     on return (scores may change after sphere edits).

4. **Shared bits**
   - `_RingPainter` and the mood-icon helper move to the new screen (or a
     small shared widget file `lib/widgets/health_ring.dart` if keeping
     `_moodIcon` in both places would duplicate >~20 lines — decided during
     implementation, whichever stays DRY).

## Interaction with the favorites plan

The favorites filter chips (other plan) sit under the search bar; with the
hero gone the Contacts body becomes: header → search → chips → list. The two
plans touch the same `Column` in `contact_list_screen.dart` but are otherwise
independent; implementing both together in one pass, with one combined change
log referencing both plans.

## Verification

- `flutter analyze` (no new issues beyond documented known gaps).
- `flutter run`: hero gone from Contacts; heart icon opens Relation Status;
  hero renders there with same score/mood/count as before; list shows only
  contacts having relationships with correct counts; tapping a row opens the
  Relationship Sphere focused on that contact; back → list refreshes; empty
  state when no relationships exist; secret contacts excluded.
