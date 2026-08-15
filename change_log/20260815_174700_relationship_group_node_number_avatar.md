# Change Log: Relationship Sphere Group Number Avatar and Clean Relationship Label

## Summary
Updated the grouped relationship sphere presentation in `RelationshipScreen`:
1. **Number Avatar for Multi-Contact Nodes**:
   - For relationship groups with more than 1 contact, the sphere node avatar now displays the count number (`count`) in the center of the node instead of showing a single individual's photo or initial.
   - For single-contact relationships (`count == 1`), the individual contact's avatar is displayed as usual.
2. **Clean Relationship Labels**:
   - Removed the `(count)` suffix from the edge midpoint labels so they cleanly show only the relationship type name (e.g. `Colleague`, `Friend`, `Cousin Brother`).

## Implemented Plan Reference
- Implements [plans/20260815_174300_relationship_group_node_number_avatar.md](../plans/20260815_174300_relationship_group_node_number_avatar.md)

## Modified Files
- `lib/screens/relationship_screen.dart`

## Verification
- `flutter analyze`: 0 issues found.
- `flutter test`: 428 tests passed.
