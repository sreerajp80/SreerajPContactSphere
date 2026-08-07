# Change log — Contact Relationships + Ego-Sphere View

Implements plan `plans/20260629_211454_contact-relationships-sphere.md`
(Status: completed).

## Summary

Built the app's headline feature: linking contacts to one another and viewing the web of
relationships as an ego-centric "relationship sphere". The previously-empty `relationships`
table is now fully used. No new pub dependency and no DB schema/version change.

## Files added

- `lib/models/relationship.dart`
  - `Relationship` data class (mirrors the `relationships` columns).
  - `RelatedContact` lightweight view-model (related contact's identity + the relationship
    type) used by the detail section and the sphere.
  - `RelationshipTypes` — preset type list + `reciprocalOf(type)` for the auto-reciprocal map
    (Father↔Child, Daughter↔Parent, Uncle↔Nephew, Spouse↔Spouse, Friend↔Friend, …; unknown
    types fall back to themselves).
- `lib/repositories/relationship_repository.dart`
  - Stores each link as **two reciprocal directed rows** (A→B and B→A) in a transaction.
  - `setRelationship` (replaces any existing pair first; ignores self-links),
    `removeRelationship` (clears both rows), `getRelationsOf` (JOIN to `contacts`, ordered by
    name), `mostConnectedContactId` (default focus for the global entry point).
- `lib/widgets/relationship_editor.dart`
  - Shared bottom sheet: pick a contact (searchable, excludes self + already-linked) → pick a
    type. Returns a `RelationshipChoice`. Used by the detail, add/edit and sphere screens.
- `lib/screens/relationship_screen.dart`
  - The ego-sphere: focus contact centred, related contacts orbiting on a ring; `CustomPaint`
    (`_EdgePainter`) draws edges with the relationship type at each midpoint, tappable
    `_NodeAvatar` widgets sit on top. Tap an orbit node → re-centre (push); long-press →
    menu (centre / open profile / remove). FAB adds a link. Empty state when unlinked.
- `test/relationship_repository_test.dart`
  - Covers `reciprocalOf` mapping, both-direction storage, replace-no-duplicate, removal,
    self-link guard, and `mostConnectedContactId`.
- `dart_test.yaml`
  - `concurrency: 1` — the two DB-backed test files share the singleton sqflite DB path and
    raced ("database is locked") when run in parallel isolates; pinning concurrency fixes it.

## Files changed

- `lib/models/contact.dart` — added display-only `List<RelatedContact> relationships`
  (not part of `toMap`/`fromMap`).
- `lib/repositories/contact_repository.dart` — hydrates relationships in `_hydrate`; kept
  `relationships` out of the wholesale child-delete in `updateContact` so edits never wipe
  links; `mergeContacts` now drops self-referential relationship rows a merge can create.
- `lib/screens/contact_detail_screen.dart` — new "Relationships" section (list with type +
  remove, tap to open that contact's sphere) plus add-link and "view sphere" actions.
- `lib/screens/add_edit_contact_screen.dart` — inline "Relationships" section; stages links in
  form state and persists them after the contact id is known (`_persistRelationships`),
  reconciling removals against what was loaded.
- `lib/screens/contact_list_screen.dart` — "Relationship Sphere" overflow-menu item opening
  the sphere on the most-connected contact (falls back to the first contact; prompts when
  there's nothing to show).
- `docs/architecture.md`, `docs/known-gaps.md` — documented the repository, screen, and the
  two-row reciprocal storage convention; moved the relationship map from "unbuilt" to
  implemented.

## Verification

- `flutter analyze` — No issues found.
- `flutter test` — all 12 tests pass (8 new relationship tests + existing interaction/widget
  tests).
- Manual device testing (dialer, lifecycle reconciliation, biometric gating) remains as the
  project's standard manual pass; the sphere's navigation/add/remove are UI-only and were not
  automated.

## Notes / out of scope

- Visualization is the ego sphere (tap-to-recenter for traversal); a full multi-hop
  force-directed network graph was explicitly out of scope.
- Edges carry the relationship type only (no strength/weighting).
