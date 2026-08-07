# Dialer avatar now shows the contact photo

Implements plan `plans/20260711_111649_dialer-avatar-photo.md`.

## What was wrong

In the dialer, contact rows (Favorites, Top contacts, and match-as-you-type
suggestions) always showed only the name initial, even for contacts that have a
profile photo. The rows are built from `PhoneMatch`, which did not carry the
photo, and the dialer's `_avatar` widget only ever drew the initial.

## What changed

### `lib/repositories/contact_repository.dart`
- Added a nullable `photoPath` field to the `PhoneMatch` class and constructor.
- Added `c.photo_path AS photo_path` to the `findByPhoneFragment` and
  `findByFullNumber` queries and to the shared `_preDialProjection` (which feeds
  Favorites, Top-recent, and Family/Friends lists).
- Populated `photoPath` in `findByPhoneFragment`, `findByFullNumber`, and
  `_preDialMatch`.

### `lib/screens/dialer_screen.dart`
- Added `import 'dart:io' show File;`.
- `_avatar` now takes an optional `photoPath`. When the path is non-null and the
  file exists, it paints the photo as a `DecorationImage` (`BoxFit.cover`) with
  no initial; otherwise it keeps the gradient background + initial. This mirrors
  the existing pattern in `contact_list_screen.dart`.
- Updated the `_matchRow` call site to pass `m.photoPath`.

## Notes

- No database schema change — the `photo_path` column already existed.
- A missing or stale photo path safely falls back to the initial via
  `File(path).existsSync()`.
- `flutter analyze` on both changed files: no issues found.
