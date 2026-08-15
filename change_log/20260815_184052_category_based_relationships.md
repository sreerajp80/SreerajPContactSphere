# Change log: Category-based relationships (7 macro categories)

Implements [plans/20260815_182600_category_based_relationships.md](../plans/20260815_182600_category_based_relationships.md).

## What changed

A relationship now has two parts instead of one:

- a **category** — one of seven fixed buckets (Immediate Family, Extended Family,
  Family by Marriage, Professional, Educational, Social, Service),
- a **label** — the free text as before ("Father", "Cousin Brother", "Manager").

The sphere view groups by category, so it never draws more than seven orbit nodes no
matter how many contacts are linked. Tapping a node opens a sheet listing everyone in
that category with their own label.

## Files changed

### Model

- `lib/models/relationship.dart`
  - New `RelationshipCategory` enum: seven values, each with a `storageKey` (the value
    written to the DB), `displayName`, `emoji` and a one-line `description`.
  - `RelationshipCategory.categoryFor(label)` maps a known label to its bucket;
    anything unknown or blank falls back to `social`.
  - `RelationshipCategory.fromStorageKey(key)` reads a stored value back.
  - `suggestedLabels` gives the chips offered once a category is picked.
  - `Relationship` gained a `category` field, carried in `toMap()`/`fromMap()`.
  - `RelatedContact` gained `categoryKey` plus a `category` getter that falls back to
    deriving the category from the label, so a row the migration missed still lands
    somewhere sensible.
  - `RelationshipTypes` (reciprocals, gendering, presets) is untouched — labels and
    their reverse-row logic work exactly as before.

### Database

- `lib/database/database_helper.dart`
  - DB version 28 → 29 (both the plain and the SQLCipher open).
  - `_onCreate`: `relationships` now has a `relationship_category TEXT` column.
  - New `_ensureRelationshipCategoryColumn()`: adds the column when missing, then
    backfills every row with no category by mapping its label through
    `categoryFor()`. Driven by the *distinct* labels present, so it is a handful of
    UPDATEs regardless of row count.
  - Called from `_onUpgrade` (`oldVersion < 29`) **and** from `_onOpen`. The PRAGMA
    existence check makes it safe to re-run, and it self-heals a development DB whose
    version was bumped before the migration existed.

### Repository

- `lib/repositories/relationship_repository.dart`
  - `setRelationship()` takes an optional `category`; when omitted it is derived from
    the label. Both directed rows get the same category, so a reverse label ("Son" for
    a "Father" link) stays in the same bucket on both spheres.
  - `getRelationsOf()` also selects `relationship_category` and fills
    `RelatedContact.categoryKey`.
  - `relationshipToSelf()` unchanged — it returns only the label.

### Widgets

- `lib/widgets/relationship_editor.dart` (largely rewritten)
  - Add flow is now **pick contact → pick category → type the label**. The category
    step shows seven cards (emoji, name, description); the label step is a text field
    plus suggestion chips, with Back and Change buttons.
  - `RelationshipChoice` carries the `category` alongside the label.
  - `showRelationshipTypePicker()` now returns a `RelationshipTypeChoice`
    (category + label) instead of a plain `String`, takes `currentCategory`, and opens
    straight on the label step so fixing a label is still one tap.
  - Label chips = the category's built-in suggestions plus any user-managed name from
    Settings that maps to the same category (case-insensitive de-duplication).

### Screens

- `lib/screens/relationship_screen.dart`
  - `_groupedRelations` (grouped by label) replaced by `_categoryGroups` (grouped by
    category, in enum order, empty categories dropped).
  - Orbit nodes and edge labels are per-category; edge labels show the category name.
  - Tapping a node always opens the category sheet, whose header shows the category
    emoji + name and whose rows show each contact's own label.
  - Node menu subtitle now reads "Label · Category"; "Edit relationship type" renamed
    to "Edit relationship"; the view toggle tooltip says "Group by category".
  - The grouped ↔ individual toggle is kept: category view is the grouped view, the
    flat one-node-per-contact view is the alternative.
- `lib/screens/contact_detail_screen.dart` — passes the category on add and on edit.
- `lib/screens/add_edit_contact_screen.dart` — `_PendingRel` carries the category
  (loaded from the DB for existing links, from the picker for new ones) and passes it
  to `setRelationship()`; the chips show the category emoji.
- `lib/screens/relationship_names_screen.dart` — each name now shows which category it
  falls under; the explainer says these are label chips inside a category.

### Sync

- `lib/services/sync_bundle_service.dart` — the relationships import writes
  `relationship_category`, deriving it from the label when the incoming row has none.
  Export is a whole-table dump, so the new column travels automatically.

### Help

- **New** `lib/screens/help/relationship_categories_help_screen.dart` — plain-English
  guide: why categories exist, the add flow, all seven categories with examples, how
  both sides of a link share a category, and what happens to relationships saved
  before this change.
- `lib/screens/help/help_home_screen.dart` — added the card that opens it.

### Docs and tests

- `docs/architecture.md` — sphere description updated; a new paragraph documents the
  `relationships` label/category split and the backfill.
- `test/relationship_repository_test.dart` — new tests for `categoryFor` mapping and
  its `social` fallback, `fromStorageKey` round-trips, every category having
  suggestions, the category landing on both directed rows, derivation when no category
  is given, an explicit category overriding the label, and the v29 backfill running on
  reopen for known / unknown / null labels.

## Not changed (and why)

- `lib/screens/relationship_quiet_hours_screen.dart` and `QuietHoursService` still map
  the **label** to their own quiet-hours tiers. Those tiers are a different axis from
  the seven categories, and labels are preserved untouched, so quiet hours behaves
  exactly as before. Switching it to categories would change who gets through at night
  — out of scope here.
- `AppSettings.relationshipNames` stays a flat `List<String>`. Each name is filed under
  a category by its wording at display time, so no settings migration is needed and the
  Relationship names screen keeps working.

## Verification

- `flutter analyze` — no issues found.
- `flutter test` — 436 passed, 1 skipped (the pre-existing skip), 0 failed.
- Not yet exercised on a device; the migration path (existing v28 database with real
  relationship rows) is covered by a test that reopens the DB, but an on-device run is
  still worth doing.
