# Change log — Let the user choose which contact to keep when merging

Implements [plans/20260701_205704_choose-keep-contact.md](../plans/20260701_205704_choose-keep-contact.md).

## What changed

Only [lib/screens/duplicates_screen.dart](../lib/screens/duplicates_screen.dart) was
touched. No repository/DB change — [ContactRepository.mergeContacts](../lib/repositories/contact_repository.dart#L870)
already merges into whatever `keptId` it is given.

1. **`_DupSet.keptId` is now mutable** (`final int` → `int`). It still initialises to
   the best candidate (`contacts.first.id`), so the default suggestion is unchanged
   on every load/reload. Added `void keep(int id)` which sets `keptId = id` and drops
   `id` from `excluded`. The previously-kept row folds back into the merge
   automatically because `mergeIds` only skips the current `keptId`.

2. **Split the two row intents** in `_contactRow`:
   - Row-body tap now calls `set.keep(id)` (choose the survivor) instead of toggling
     exclusion. No-op on the already-kept row.
   - The right-hand `_selectionControl` is wrapped in its own `GestureDetector` that
     toggles `excluded` for non-kept rows (the old row-tap behaviour). The kept row's
     control stays a non-interactive filled circle.

3. **Copy tweaks:**
   - Summary caption: "Review each set — the starred contact is kept." →
     "Tap a contact to choose which to keep; untick the rest."
   - Per-set merge confirmation: "Keep the starred contact…" →
     "Keep the selected contact…".

## Why

Duplicate sets are grouped by shared name *or* shared phone digits, so a set can
contain same-name/different-number people (per the reported case: KEEP=[phone-1] vs.
two others at [phone-2]). The merge re-points all child rows onto the kept
contact, so a wrong default keep made the survivor carry another person's identity.
The user can now re-point KEEP to the correct contact and untick the ones that are
genuinely different people.

## Verification

- `flutter analyze lib/screens/duplicates_screen.dart` → **No issues found**.
- Manual check to perform on device: tapping a non-kept row moves the KEEP badge +
  highlight to it and turns the old keep into a ticked merging row; the checkbox
  still excludes a non-kept row; Merge uses the chosen keep.
