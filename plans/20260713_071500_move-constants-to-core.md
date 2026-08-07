# Move `constants/` under the `core/` layer

**Status:** completed

## Issue

The folder-structure guideline (`guideline.md` §3) says technical constants MUST live
under `lib/core/constants/` (e.g. `lib/core/constants/app_constants.dart`), not in a
top-level `lib/constants/` folder. This app currently has a top-level `lib/constants/`
holding a single file, `app_permissions.dart`. A `lib/core/` layer already exists
(`core/config/`, `core/errors/`, `core/logging/`), so only the `constants/` folder is out
of place.

## Files to change

- `lib/constants/app_permissions.dart` — move to `lib/core/constants/app_permissions.dart`
  and update its first-line header comment path.
- `lib/screens/permissions_screen.dart` — update the import
  `package:smart_contacts_dialer/constants/app_permissions.dart`
  → `package:smart_contacts_dialer/core/constants/app_permissions.dart`.
- Remove the now-empty `lib/constants/` folder.

(No other source file imports `constants/app_permissions`; the other matches are only in
`plans/` and `change_log/` docs, which are historical and left untouched.)

## Plan for the fix

1. Create `lib/core/constants/`.
2. Move `app_permissions.dart` into it (git mv to preserve history); fix the `// lib/...`
   header comment to the new path.
3. Update the single import in `permissions_screen.dart`.
4. Delete the empty `lib/constants/` folder.
5. Run `flutter analyze` to confirm no broken references.

## Notes

- Pure structural move; no behavior change.
- The guideline's example filename is `app_constants.dart`, but the existing file name
  `app_permissions.dart` is a specific, well-named constants file and is kept as-is — the
  rule is about the `core/constants/` location, not a mandatory single filename.
