# Change log — Custom Relationship Names

Implements [plans/20260716_200855_custom-relationship-names.md](../plans/20260716_200855_custom-relationship-names.md).

## What changed

Added a **Settings → Contacts → Relationship Names** screen that lets the user manage the list
of relationship-type names shown when linking two contacts. The list is fully editable and
seeded from the built-in defaults; the user can add, rename, delete, and reset to defaults.

### Files

1. **[lib/state/app_settings.dart](../lib/state/app_settings.dart)**
   - New pref key `relationship_names` (`_kRelationshipNames`).
   - New field `_relationshipNames` (default `RelationshipTypes.presets`) and getter
     `relationshipNames` (unmodifiable).
   - `load()` now reads the stored list (uses the built-in presets when absent/empty).
   - `setRelationshipNames(List<String>)` — trims, drops blanks, de-dupes case-insensitively,
     persists; falls back to `resetRelationshipNames()` when the cleaned list is empty (so the
     picker is never blank).
   - `resetRelationshipNames()` — removes the key and restores `RelationshipTypes.presets`.
   - Imported `models/relationship.dart` for the seed list.

2. **[lib/widgets/relationship_editor.dart](../lib/widgets/relationship_editor.dart)**
   - `_TypeChipGrid` now renders a passed-in `List<String> types` instead of the static
     `RelationshipTypes.presets`.
   - `_TypePickerSheet` and `_RelationshipEditorSheet` take and forward a `types` list.
   - `showRelationshipEditor` / `showRelationshipTypePicker` read the list from `AppSettings`
     via the passed `context` (helper `_relationshipTypesFrom`, falling back to the built-in
     presets when empty) and pass it down. The 5 call sites are unchanged.
   - Added `provider` and `state/app_settings.dart` imports.

3. **New: [lib/screens/relationship_names_screen.dart](../lib/screens/relationship_names_screen.dart)**
   - Management screen modeled on `quick_replies_screen.dart`: explainer note, "Add a
     relationship" card, a list card with tap-to-edit rows and per-row delete, and a
     "Reset to defaults" app-bar action with a confirm dialog.
   - Rejects blank names and duplicates (case-insensitive) with a snackbar.

4. **[lib/screens/contacts_settings_screen.dart](../lib/screens/contacts_settings_screen.dart)**
   - New `_RelationshipNamesCard` nav card (under Blocked numbers) opening the new screen.
   - Added the screen import.

## Verification

- `flutter analyze` on the four touched files: **No issues found**.
- Not yet exercised on a device (on-device run/verify left to the user per the usual flow).

## Notes

- Editing a name here does **not** rewrite relationships already saved on contacts (their
  stored `relationship_type` strings are untouched). Reciprocal/gender mapping is unchanged;
  a custom name is its own reciprocal (existing fallback behavior).
