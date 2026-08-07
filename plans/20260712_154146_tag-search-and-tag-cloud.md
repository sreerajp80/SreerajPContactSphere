# Tag search + Tag Cloud tab

**Status:** completed

## What the user wants

1. When searching contacts, tags should also be searched (a contact matches if one of
   its tags matches the query).
2. A new **Tag Cloud** page: shows all tags as a "cloud" (bigger chip = used by more
   contacts). Tapping a tag lists the contacts that carry that tag.
3. Add a **Tag Cloud** button as a 4th tab in the bottom navigation bar (currently 3
   tabs: Contacts, Dialer, Recents).

## Current state (what I found)

- Tags live in the `tags` table (`id, contact_id, name`), indexed on `contact_id`
  ([database_helper.dart:299](../lib/database/database_helper.dart#L299)). One row per
  (contact, tag). Loaded per contact by `_getTags`
  ([contact_repository.dart:1557](../lib/repositories/contact_repository.dart#L1557))
  and hydrated onto `Contact.tags`.
- Contact search is `ContactRepository.searchContactSummaries`
  ([contact_repository.dart:888](../lib/repositories/contact_repository.dart#L888)) —
  matches name, phone, email and `name_translit`. It does **not** look at tags.
  Reached from the list via `ContactSyncService.searchSummaries`
  ([contact_sync_service.dart:170](../lib/services/contact_sync_service.dart#L170)) →
  `contact_list_screen.dart`.
- Bottom nav is a custom bar in
  [home_shell.dart](../lib/screens/home_shell.dart): a `_tabs` list of 3 screens in an
  `IndexedStack`, and 3 `_navItem` entries. A left swipe cycles tabs using
  `_tabs.length`, so it already adapts to a 4th tab.
- Contacts are rendered by the private `_buildContactCard` in
  [contact_list_screen.dart:1232](../lib/screens/contact_list_screen.dart#L1232) — it is
  tied to that screen's selection/swipe state, so it is **not** cleanly reusable. The
  new tag-contacts list will use its own lightweight tile built from the same
  `AppColors` tokens so it reads as one product (per the app's own design system).

## Files to change / add

**Change**
1. `lib/repositories/contact_repository.dart`
   - Add a tag branch to `searchContactSummaries` so a contact matches when one of its
     tags matches the query (case-insensitive `LIKE`).
   - Add `Future<List<TagCount>> getTagCounts({bool includeSecret})` — each distinct tag
     name with the number of (non-secret unless included) contacts using it, ordered by
     count desc then name.
   - Add `Future<List<Contact>> getContactSummariesByTag(String tag, {bool includeSecret})`
     — slim `_summarySelect` summaries of contacts carrying an exact tag, ordered like
     the main list.
   - Add a small `TagCount` class (name + count) near the top of the file.
2. `lib/services/contact_sync_service.dart`
   - Thin wrappers `tagCounts(...)` and `contactsByTag(...)` over the two new repo
     methods, so screens keep going through the service and the secret filter is applied
     consistently.
3. `lib/screens/home_shell.dart`
   - Add `TagCloudScreen` as the 4th entry in `_tabs` and a 4th `_navItem` (label
     "Tags", icon `Icons.tag` / `Icons.sell_outlined` — a neutral tag icon, not a
     Google-branded one). No change needed to the swipe logic (already uses
     `_tabs.length`).

**Add**
4. `lib/screens/tag_cloud_screen.dart` — the Tag Cloud tab.
   - Loads `tagCounts()` on init (and reloads when the tab is selected, mirroring how
     Dialer/Recents reload via a `GlobalKey` in `home_shell`).
   - Renders a `Wrap` of tag chips; font/chip size scales with the tag's contact count
     (min→max mapped across the range) to give the "cloud" look. Styled with
     `AppColors` tokens.
   - Empty state when there are no tags yet.
   - Tapping a tag pushes `TagContactsScreen(tag)`.
5. `lib/screens/tag_contacts_screen.dart` — the per-tag contact list.
   - App bar titled with the tag (e.g. `#work`).
   - Loads `contactsByTag(tag)` and lists them with a lightweight contact tile
     (avatar/initials, name, primary number) built from `AppColors`; tapping a row opens
     the existing `ContactDetailScreen`.
   - Empty state if the tag has no contacts (e.g. after edits).

## Notes / decisions

- **Secret contacts:** both new reads respect the same secret filter the rest of the app
  uses, so secret contacts' tags are only counted/listed when secret mode is on. The tag
  cloud and per-tag list will read the current `_showSecretContacts` setting the same way
  the contact list does.
- **Search semantics:** tag search uses substring `LIKE` (consistent with the name/email
  branches), so typing part of a tag also matches. The tag-cloud tap uses an **exact**
  tag match (precise filtering), which is the difference the user asked for.
- No DB schema or migration change — the `tags` table and its `contact_id` index already
  exist. A per-tag list/count does a scan of `tags` filtered by name; fine at this app's
  scale. If needed later we can add an index on `tags(name)`, but not in this change.
- No test changes are strictly required, but I can add a couple of unit tests for the new
  repo methods if you want.

## Out of scope

- Editing/renaming/deleting tags from the cloud (this is view + search only).
- Multi-tag (AND/OR) filtering — tapping one tag filters by that single tag.
