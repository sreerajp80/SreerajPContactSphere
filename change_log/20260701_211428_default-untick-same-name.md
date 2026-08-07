# Change log — Default same-name-only duplicate sets to nothing ticked

Implements [plans/20260701_211428_default-untick-same-name.md](../plans/20260701_211428_default-untick-same-name.md).

## What changed

### `lib/repositories/contact_repository.dart`
- Added `final bool linkedByPhone;` to `DuplicateSet` (required constructor arg):
  true when two members share a phone number's digits, false for name-only sets.
- Added static helper `_sharedPhone(members, phonesById)` that returns whether any
  digit-normalized number is owned by two members.
- `findDuplicateGroups` now passes `linkedByPhone: _sharedPhone(members, phonesById)`
  when constructing each `DuplicateSet`.
- File remains UTF-8 (no BOM); the two pre-existing stray NUL bytes (in the search
  placeholder on the phone-search query and the name-key separator) were left intact.

### `lib/screens/duplicates_screen.dart`
- `_DupSet` now stores `linkedByPhone` from the source set.
- Constructor: when `!linkedByPhone`, seeds `excluded` with every non-kept member, so
  a name-only set opens with nothing ticked, the footer shows "Nothing selected", and
  the set's Merge button is disabled.
- `keep(id)`: early-returns if `id` is already kept; for a name-only set it now pushes
  the previously-kept id into `excluded` (preserving the "default off" stance) before
  switching, so re-pointing KEEP never silently ticks a different person. Phone-linked
  sets keep the prior behaviour (old keep folds back into the merge).

## Why

Duplicate sets group by shared name OR shared phone. Name-only sets are frequently
different people who share a name (the reported [name] case), so defaulting them
to "all ticked" risked merging distinct people via "Merge all sets". They now require
a deliberate opt-in. Phone-linked sets, which are much more likely true duplicates,
are unchanged.

## Verification

- `flutter analyze lib/screens/duplicates_screen.dart lib/repositories/contact_repository.dart`
  → **No issues found**.
- Post-edit byte check: `contact_repository.dart` still UTF-8, no BOM, both NUL bytes
  present (offsets shifted only by inserted content).
- Manual check to perform on device: a "Same name" set opens with empty checkboxes /
  disabled Merge; ticking a row or switching KEEP behaves per the rules above; a "Same
  phone number" / "Same name & number" set still opens fully ticked.
