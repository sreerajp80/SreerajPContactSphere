# Change log — Tag search + Tag Cloud tab

Implements plan `plans/20260712_154146_tag-search-and-tag-cloud.md`.

## What changed

### 1. Tags are now searchable
`ContactRepository.searchContactSummaries`
(`lib/repositories/contact_repository.dart`) gained a tag branch: a contact now
matches the search query when one of its tags contains the query text
(case-insensitive substring, like the name/email branches). No UI change needed —
the Contacts search box already flows through this method.

### 2. New repository reads for tags
Added to `lib/repositories/contact_repository.dart`:
- `TagCount` class (tag `name` + contact `count`).
- `getTagCounts({includeSecret})` — every distinct tag with the number of contacts
  using it, ordered by count desc then name. Respects the secret filter.
- `getContactSummariesByTag(tag, {includeSecret})` — slim summaries of the contacts
  carrying an **exact** tag (case-insensitive), ordered like the main list.

### 3. Sync service wrappers
Added `tagCounts(...)` and `contactsByTag(...)` to
`lib/services/contact_sync_service.dart`, so screens reach the new reads the same way
they reach the rest of the contact data.

### 4. New Tag Cloud tab
- `lib/screens/tag_cloud_screen.dart` (new) — the "Tags" tab. Draws every tag as a
  chip whose font size scales with its contact count (a tag cloud), styled with the
  app's own `AppColors` tokens. Tapping a tag opens the per-tag list. Reloads when the
  tab is selected (via a `GlobalKey`, mirroring Dialer/Recents). Empty state when no
  tags exist.
- `lib/screens/tag_contacts_screen.dart` (new) — lists the contacts for a tapped tag
  with a lightweight contact row (avatar/initials + name + primary number). Tapping a
  row opens the existing `ContactDetailScreen`; the list refreshes on return so a
  contact that lost the tag drops out.

### 5. Bottom navigation now has 4 tabs
`lib/screens/home_shell.dart` — added `TagCloudScreen` as a 4th destination
("Tags", `Icons.sell_outlined` / `Icons.sell`) with its own reload key. The existing
left-swipe tab cycling already keyed off `_tabs.length`, so it now cycles all four.

## Notes
- No DB schema or migration change — the `tags` table and its `contact_id` index
  already existed.
- Search uses substring match; the tag-cloud tap uses an exact match (the precise
  filtering the user asked for).
- Secret contacts stay hidden in the tag cloud and per-tag list (default), so their
  tags neither appear nor pad the counts.
- `flutter analyze` on the five touched/added files: **No issues found.**

## Not done (out of scope, as planned)
- Editing/renaming/deleting tags from the cloud.
- Multi-tag (AND/OR) filtering.
- No new unit tests added (view/search-only change); can be added on request.
