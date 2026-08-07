# Change log: Tag autocomplete from existing tags (wildcard match)

Implements plan `plans/20260713_190754_tag-autocomplete-suggestions.md`.

## What changed

While adding a tag on the Add/Edit contact screen, the app now suggests tags
that already exist on other contacts. As the user types, existing tag names that
contain the typed text **anywhere** in the name (case-insensitive wildcard
"contains" match) are shown as tappable suggestion chips.

## Files changed

1. `lib/repositories/contact_repository.dart`
   - Added `getDistinctTagNames()` — returns every distinct, non-blank tag name
     across all contacts, ordered case-insensitively (no secret filter).

2. `lib/services/contact_sync_service.dart`
   - Added `allTagNames()` — thin pass-through to
     `ContactRepository.getDistinctTagNames()`.

3. `lib/screens/add_edit_contact_screen.dart`
   - Added `_allTags` field to hold the loaded tag pool.
   - Added `_loadTags()` (called from `initState`) to load existing tag names
     via `_sync.allTagNames()`.
   - Added a `_tagInput` listener (`_onTagInputChanged`) that rebuilds the
     suggestions as the user types.
   - Reworked suggestion logic in `_tagsSection()`:
     - Empty input: unchanged — up to 4 entries from the default `_tagPool`.
     - Typed input: up to 6 existing tags whose name contains the typed text
       anywhere (case-insensitive), excluding already-added tags and an exact
       match of the typed text.
   - Suggestions reuse the existing `_DashedChip` UI and call `_addTag(s)` on
     tap (unchanged behaviour).

## Verification

- `flutter analyze` on the three changed files: **No issues found.**
