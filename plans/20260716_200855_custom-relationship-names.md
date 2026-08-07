# Custom Relationship Names (Settings → Contacts → Relationship Names)

**Status:** completed

## Issue / goal

The relationship type picker (chips shown when linking two contacts, e.g. "Father",
"Friend") is driven by a hard-coded `const` list, `RelationshipTypes.presets`
([lib/models/relationship.dart:104](../lib/models/relationship.dart#L104)). The user wants a
new **Settings → Contacts → Relationship Names** screen where they can manage the names that
appear in that picker: add custom ones, and edit/remove the existing ones.

Chosen scope (confirmed with user): **fully editable, seeded list**. The settings screen
manages the *whole* list of relationship names. It is seeded from the current built-in
presets on first use; the user can add, rename, delete, reorder, and reset to defaults. The
picker shows exactly this managed list.

## Design

Follow the existing `quickReplies` string-list pattern already in `AppSettings` (persisted to
`shared_preferences`, live-updates via `notifyListeners`). No database table is needed — these
are just labels.

- **Default / seed:** `RelationshipTypes.presets` stays in code and becomes the default list
  used when the user has never edited the names (key absent) and when they tap "Reset to
  defaults". Nothing about the reciprocal logic changes — `reciprocalOf()` / `forGender()`
  still key off the built-in maps by name; a custom name simply falls back to itself as its
  own reciprocal (already the existing behavior for unknown types).
- **Storage:** new pref key `relationship_names` (a `List<String>`). Absent = use the seed.
- **Picker source:** `_TypeChipGrid` in
  [lib/widgets/relationship_editor.dart](../lib/widgets/relationship_editor.dart) currently
  reads `RelationshipTypes.presets`. It will instead render a list passed in from the caller.
  The two public entry points (`showRelationshipEditor`, `showRelationshipTypePicker`) already
  receive a `BuildContext` inside the app's Provider tree, so they read
  `context.read<AppSettings>().relationshipNames` and pass it down to the sheets/grid. If the
  stored list is empty, fall back to `RelationshipTypes.presets` so the picker is never blank.

## Files to change

1. **[lib/state/app_settings.dart](../lib/state/app_settings.dart)** — add:
   - pref key `static const String _kRelationshipNames = 'relationship_names';`
   - field `List<String> _relationshipNames = RelationshipTypes.presets;`
   - getter `List<String> get relationshipNames` (unmodifiable)
   - load logic in `load()` (`getStringList` → seed default when absent/empty)
   - `Future<void> setRelationshipNames(List<String> names)` — trim, drop blanks,
     de-dupe (case-insensitive, keep first), persist, `notifyListeners`
   - `Future<void> resetRelationshipNames()` — remove key, restore
     `RelationshipTypes.presets`
   - import `package:smart_contacts_dialer/models/relationship.dart` for the seed.

2. **[lib/widgets/relationship_editor.dart](../lib/widgets/relationship_editor.dart)** —
   - `_TypeChipGrid` takes a `List<String> types` param instead of reading the static presets.
   - `_TypePickerSheet` and `_RelationshipEditorSheet` take and forward a `types` list.
   - `showRelationshipEditor` / `showRelationshipTypePicker` read the list from
     `AppSettings` via the passed `context` (fallback to `RelationshipTypes.presets` when
     empty) and hand it to the sheets. No change needed at the 5 call sites.
   - add `provider` import.

3. **New: `lib/screens/relationship_names_screen.dart`** — a management screen styled like the
   app's other settings screens (cards / `AppColors` / accent, matching
   `blocked_numbers_screen.dart` and the quick-replies editor conventions):
   - lists the current names (from `AppSettings.relationshipNames`),
   - add (text field / dialog), edit (rename), delete (per row),
   - optional reorder (drag handles) — nice-to-have, include if it stays simple,
   - overflow / button action "Reset to defaults" (with a confirm), calling
     `resetRelationshipNames()`,
   - blocks saving a blank/duplicate name.

4. **[lib/screens/contacts_settings_screen.dart](../lib/screens/contacts_settings_screen.dart)**
   — add a new `_RelationshipNamesCard` (chevron nav card, same style as `_BlockedNumbersCard`)
   in the `ListView`, e.g. under Blocked numbers, opening `RelationshipNamesScreen`. Add the
   import.

## Verification

- `flutter analyze` clean for the touched files.
- Manually: open Settings → Contacts → Relationship Names; add a custom name, confirm it
  appears as a chip when linking a relationship; rename/delete a seeded name and confirm the
  picker reflects it; "Reset to defaults" restores the full built-in list.

## Notes / non-goals

- Existing stored relationships keep their saved `relationship_type` string regardless of edits
  to this list — renaming a name here does **not** rewrite historical relationship rows. (Call
  out to user; can be a follow-up if they want back-fill.)
- Reciprocal/gender mapping is unchanged; custom names are their own reciprocal.
- No change to the `add_edit_contact_screen` phone/email/social label presets (a different,
  unrelated `presets` mechanism).
