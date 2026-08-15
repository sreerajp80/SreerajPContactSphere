# Plan: Relationship Sphere Group Number Avatar and Clean Relationship Label

## Issue Description
1. **Wrong image for multiple-item sphere**: In `RelationshipScreen` grouped view, when a relationship group contains more than 1 contact (e.g. 7 Colleagues, 2 Friends), it was displaying the photo or initial of just the first contact with a corner badge, which misleadingly represents the category as that single person.
2. **Redundant count in relationship label**: The label on the radial edge was displaying `RelationshipName (count)` (e.g. `Colleague (7)`), which clutters the edge text.

## Proposed Fix

### 1. `lib/screens/relationship_screen.dart`
- **Number as the avatar for multiple items**:
  - Update `_GroupNodeAvatar`:
    - When `count > 1`: Display the number (`count`) directly as the central avatar content of the sphere node (with a large, bold digit, subtle accent background, and border), instead of displaying any individual contact's photo/initial.
    - When `count == 1`: Display the single contact's photo or initial avatar as before.
- **Clean relationship name on edge label**:
  - In `_buildSphere`, set the edge midpoint label to `typeName` (e.g., `Colleague`, `Friend`, `Cousin Brother`), removing the `(count)` suffix from the text label.

## Files to Change
- `lib/screens/relationship_screen.dart`
