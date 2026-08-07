# Change log — Move `constants/` under the `core/` layer

Implements plan `plans/20260713_071500_move-constants-to-core.md`.

## What changed

- Moved `lib/constants/app_permissions.dart` → `lib/core/constants/app_permissions.dart`
  using `git mv` (history preserved). Created the new `lib/core/constants/` folder.
- Updated the file's first-line header comment path to
  `// lib/core/constants/app_permissions.dart`.
- Updated the import in `lib/screens/permissions_screen.dart` from
  `package:smart_contacts_dialer/constants/app_permissions.dart`
  to `package:smart_contacts_dialer/core/constants/app_permissions.dart`.
- Removed the now-empty top-level `lib/constants/` folder.

## Why

The folder-structure guideline (`guideline.md` §3) requires technical constants to live
under `lib/core/constants/`, not a top-level `lib/constants/`. `lib/core/` already existed
(config/, errors/, logging/), so only `constants/` was out of place.

## Verification

- `flutter analyze lib/screens/permissions_screen.dart lib/core/constants/app_permissions.dart`
  → **No issues found.**
- `permissions_screen.dart` was the only source importer; other matches were in historical
  `plans/`/`change_log/` docs and were left untouched.

## Notes

- Pure structural move; no behavior change.
- Filename kept as `app_permissions.dart` (the rule governs the `core/constants/` location,
  not a single mandatory filename).
