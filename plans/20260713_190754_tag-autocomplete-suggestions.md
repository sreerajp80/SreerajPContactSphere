# Plan: Tag autocomplete from existing tags (wildcard match)

**Status:** completed

## Issue

On the Add/Edit contact screen, the "Tags" section only offers a fixed list of
six hard-coded suggestions (`_tagPool`: VIP, Mentor, Client, ...). When the user
types a tag, the app does not look at tags that already exist on other contacts.

The user wants: while typing a tag, show the already-existing tags whose name
matches the typed letters. The match must be a **wildcard "contains" match** —
the typed text can appear anywhere inside the tag name (case-insensitive), not
just at the start.

## Files to change

1. `lib/repositories/contact_repository.dart`
   - Add `Future<List<String>> getDistinctTagNames()` — returns every distinct,
     non-blank tag name across all contacts, ordered case-insensitively. (No
     secret filter: tag *names* are not sensitive and we want the full pool for
     suggestions. This mirrors how the tag text itself is free-form.)

2. `lib/services/contact_sync_service.dart`
   - Add a thin pass-through `Future<List<String>> allTagNames()` that calls
     `_repo.getDistinctTagNames()`.

3. `lib/screens/add_edit_contact_screen.dart`
   - Add a field `final List<String> _allTags = [];` to hold the pool loaded
     from the DB.
   - Add `_loadTags()` (called from `initState`, next to `_loadGroups()`), which
     loads `await _sync.allTagNames()` into `_allTags` inside `setState`.
   - Add a listener on `_tagInput` in `initState` that calls `setState` so the
     suggestion list rebuilds as the user types. Remove the listener / it is
     disposed with the controller in `dispose` (controller already disposed).
   - Rework the suggestion logic in `_tagsSection()`:
     - When the input box is **empty**: keep current behaviour — show up to 4
       entries from `_tagPool` that are not already added (unchanged default).
     - When the input has text: filter `_allTags` (the existing tags) with a
       case-insensitive "contains" match on the typed text, excluding tags
       already added to this contact and excluding an exact case-insensitive
       match of what is typed (so the chip is not a duplicate of the text).
       Show up to a small cap (e.g. 6) as the same `_DashedChip` suggestions,
       each calling `_addTag(s)` on tap (existing behaviour).

## Fix details / notes

- Reuses the existing `_sync` (`ContactSyncService`) instance and the existing
  `_DashedChip` suggestion UI — no new widgets or visual redesign, matching the
  app's own design.
- Matching is done in Dart on the already-loaded `_allTags` list (small data),
  so no per-keystroke DB queries.
- `_addTag` already de-dupes against `_tags`, so no extra guarding needed there.

## Testing

- `flutter analyze` on the three changed files.
- Manual: on Add/Edit contact, existing tags on other contacts appear as
  suggestions when typing a substring that appears anywhere in their name;
  empty input still shows the default pool; tapping a suggestion adds it.
