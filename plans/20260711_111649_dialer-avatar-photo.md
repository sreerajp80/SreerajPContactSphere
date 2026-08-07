# Dialer avatar: show contact photo, not just the initial

**Status:** completed

## The issue

In the dialer's contact rows (Favorites, Top contacts, and match-as-you-type
suggestions), a contact that has a profile photo still shows only the name
initial. The photo never appears.

Cause: the dialer builds each row from a `PhoneMatch` object, but `PhoneMatch`
does not carry the contact's photo. The dialer's `_avatar` widget only ever
draws the initial letter. Other screens (contact list, contact detail) read the
`photo_path` column and render it with `FileImage`, falling back to the initial
when there is no photo. The dialer was never wired to do this.

## The fix

Carry the photo path through `PhoneMatch` and render it in the dialer avatar,
mirroring the existing pattern in `contact_list_screen.dart`
(`FileImage(File(path))` when the file exists, initial otherwise).

### Files to change

1. `lib/repositories/contact_repository.dart`
   - Add `final String? photoPath;` to the `PhoneMatch` class and its
     constructor (optional, defaults to null).
   - `findByPhoneFragment`: add `c.photo_path AS photo_path` to the SELECT and
     set `photoPath:` when building the `PhoneMatch`.
   - `findByFullNumber`: same (add column + set `photoPath:`).
   - `_preDialProjection`: add `c.photo_path AS photo_path` so Favorites,
     Top-recent, and Family/Friends lists carry it.
   - `_preDialMatch`: set `photoPath:` from the row.

2. `lib/screens/dialer_screen.dart`
   - Add `import 'dart:io' show File;`.
   - Change `_avatar(...)` to take the `PhoneMatch` (or its photo path) and,
     when the path is non-null and the file exists, paint the photo as a
     `DecorationImage` (`BoxFit.cover`) with no initial text; otherwise keep the
     current gradient + initial.
   - Update the call site in `_matchRow` to pass the photo through.

### Notes / scope

- Read-only display change plus one nullable field on `PhoneMatch`. No schema
  change (the `photo_path` column already exists).
- The photo check uses `File(path).existsSync()`, exactly as the contact list
  does, so a stale/missing path safely falls back to the initial.
- No change to secret-contact filtering or any query's WHERE clause.

## Verification

- `flutter analyze` clean for the touched files.
- On device: a dialer Favorite/Top contact that has a photo shows the photo;
  one without a photo still shows its initial.
