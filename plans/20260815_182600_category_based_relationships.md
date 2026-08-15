# Plan: Category-Based Relationship System (7 Macro Categories)

**Status:** completed

## Issue Description
The current relationship system stores a free-text `relationship_type` (e.g. "Father", "Colleague") on
each relationship row. When a contact has many relationships (20+), the sphere view becomes cluttered because
each distinct relationship type gets its own orbit node. The current grouping is by `relationship_type`,
which doesn't scale.

## Proposed Solution
Restructure the relationship data model so every relationship has:
- A **category** (one of 7 fixed enums: `immediateFamily`, `extendedFamily`, `familyByMarriage`,
  `professional`, `educational`, `social`, `service`)
- A **label** (free-text, like "Father", "Cousin Brother", "Manager")

The sphere always shows at most 7 category nodes. Tapping a category opens a bottom sheet listing all
contacts under that category, each showing their label. Users choose the category first, then type/pick the label.

## Files to Change

### 1. Model Layer

#### [MODIFY] relationship.dart
- Add a `RelationshipCategory` enum with 7 values + display names, icons, and descriptions.
- Add `String? category` field to `Relationship` model, `toMap()`, and `fromMap()`.
- Add `String? category` field to `RelatedContact`.
- Add a static `categoryFor(String label)` migration helper that maps known presets to categories.
- Update `RelationshipTypes.presets` → group by category (for the new picker UI).

### 2. Database Layer

#### [MODIFY] database_helper.dart
- Bump DB version from 28 → 29.
- In `_onCreate`: add `relationship_category TEXT` column to the `relationships` CREATE TABLE.
- In `_onUpgrade` (v28→v29): `ALTER TABLE relationships ADD COLUMN relationship_category TEXT`
  then backfill existing rows using the `categoryFor()` mapping (known labels → category;
  unknown → `social`).

### 3. Repository Layer

#### [MODIFY] relationship_repository.dart
- `setRelationship()`: accept `category` parameter, store it on both directed rows.
- `getRelationsOf()`: SELECT `relationship_category` alongside `relationship_type`, populate
  `RelatedContact.category`.
- `relationshipToSelf()`: no change needed (returns only the type label).

### 4. Widget Layer (Relationship Editor)

#### [MODIFY] relationship_editor.dart
- `RelationshipChoice`: add `String category` field.
- `showRelationshipEditor()`: change the flow from
  `Pick Contact → Pick Type` to `Pick Contact → Pick Category → Type Label`.
  - Step 2: Show 7 category cards (icon + name + description).
  - Step 3: Show a text field for the label, pre-populated with suggested labels for that category
    (e.g. selecting "Immediate Family" suggests Father, Mother, Son, Daughter, Spouse).
    User can type a custom label or pick a suggestion chip.
- `showRelationshipTypePicker()`: update to show category + label editing (category dropdown +
  label text field, or keep the chip grid filtered by the current category).

### 5. Screen Layer

#### [MODIFY] relationship_screen.dart
- Replace `_groupedRelations` (groups by `relationshipType`) with `_categoryGroups` (groups by
  `RelationshipCategory`).
- In `_buildSphere` grouped view: render at most 7 category nodes (using category icon/emoji
  and count) instead of per-type nodes.
- Each node shows the category count number as the avatar (existing `_GroupNodeAvatar` behavior).
- Edge labels show the category display name (e.g. "Immediate Family", "Professional").
- `_showGroupDetailsSheet`: update title to show category name; each list tile shows the contact
  name with their label as subtitle (e.g. "അരു ചേട്ടൻ / Father").
- Remove the grouped/flat toggle (the category view IS the default and only grouped view; the
  flat/individual view remains as the alternative toggle).

#### [MODIFY] contact_detail_screen.dart
- Where `setRelationship()` is called, pass the `category` from the `RelationshipChoice`.
- Where `showRelationshipTypePicker()` is called, pass the current category for context.

#### [MODIFY] add_edit_contact_screen.dart
- Where `setRelationship()` is called, pass the `category` from the `RelationshipChoice`.

#### [MODIFY] relationship_quiet_hours_screen.dart
- If it references relationship types for tier-based quiet hours, update to use categories
  instead of or alongside types.

### 6. Settings Layer

#### [MODIFY] app_settings.dart
- The `relationshipNames` list used by the editor can remain as suggested labels within
  categories, or be restructured as `Map<String, List<String>>` (category → labels). Evaluate
  impact on the `RelationshipNamesScreen`.

#### [MODIFY] relationship_names_screen.dart
- Update to show labels grouped by category, or simplify to a flat list of label suggestions
  that the user can edit (since the category is now structural, not a label).

### 7. Help Section

#### [NEW] relationship_categories_help_screen.dart
- New help screen explaining the 7 categories with examples:
  - 👨‍👩‍👧‍👦 Immediate Family: Spouse, Father, Mother, Son, Daughter
  - 👨‍👩‍👧 Extended Family: Grandfather, Uncle, Aunt, Cousin, Nephew, Niece
  - 💍 Family by Marriage: Father-in-law, Brother-in-law, Step-father, etc.
  - 💼 Professional: Colleague, Manager, Client, Mentor, Business Partner
  - 🎓 Educational: Teacher, Classmate, Professor, Tutor
  - 🤝 Social: Friend, Neighbour, Roommate, Godparent, Partner
  - 🏥 Service: Doctor, Lawyer, Accountant, Caregiver

#### [MODIFY] help_home_screen.dart
- Add a card/link to the new Relationship Categories help screen.

### 8. Sync Layer

#### [MODIFY] sync_bundle_service.dart (if applicable)
- Include `relationship_category` in the P2P sync bundle export/import for relationships.

### 9. Tests

#### [MODIFY] test/relationship_repository_test.dart
- Update existing tests to pass `category` to `setRelationship`.
- Add test for migration backfill logic.

#### [MODIFY] test/phone_normalizer_test.dart
- No change needed.

## Migration Strategy for Existing Data
On upgrade (v28→v29):
1. `ALTER TABLE relationships ADD COLUMN relationship_category TEXT`
2. For each row, compute category from `relationship_type` using the static mapping:
   - Known family labels → `immediateFamily` / `extendedFamily` / `familyByMarriage`
   - Known professional labels → `professional`
   - Friend/Neighbour → `social`
   - Unknown → `social` (safe default)
3. All existing data is preserved with correct categories; no data loss.

## Verification Plan
- `flutter analyze`: 0 issues.
- `flutter test`: all tests pass.
- Manual: create a relationship → verify category picker → type label flow works.
- Manual: open sphere with 20+ relationships → verify at most 7 clean category nodes.
