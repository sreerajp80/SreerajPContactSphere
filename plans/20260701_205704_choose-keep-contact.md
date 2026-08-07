# Let the user choose which contact to keep when merging duplicates

**Status:** completed

## Issue

On the Find-duplicates screen the "kept" contact of each set is **fixed** to the
best candidate (highest `relationship_score`, tie-break lowest `id`) and cannot be
changed. See [duplicates_screen.dart](../lib/screens/duplicates_screen.dart):

- `_DupSet.keptId` is `final`, initialised to `set.contacts.first.id!` (line 111).
- A row tap only toggles `excluded` (merge vs. leave alone); there is no way to
  promote a different row to KEEP.

This is wrong for the case in the user's screenshot: three contacts share the same
name ([name]) so they land in one set, but the KEEP contact's number
([phone-1]) differs from the other two ([phone-2]). The merge re-points all
child rows onto the kept contact, so the surviving contact ends up carrying another
person's identity as its "primary". People can share a name but not a phone number,
so the user must be able to override which contact survives (and, as today, exclude
the ones that are genuinely different).

Note: this change is UI-only. The repository merge ([mergeContacts](../lib/repositories/contact_repository.dart#L870))
already operates on whatever `keptId` it is given, so no DB-layer change is needed.

## Files to change

- `lib/screens/duplicates_screen.dart` — make the kept contact user-selectable.

(No change to `contact_repository.dart` or the DB. Existing tests, if any, keep
passing because `mergeContacts(keptId, ids)` is called exactly as before, just with
a possibly different `keptId`.)

## Plan for the fix

1. **Make `_DupSet.keptId` mutable.**
   - Change `final int keptId;` to `int keptId;` (still initialised to the best
     candidate — the default suggestion is unchanged on every load/reload).
   - Add a method `void keep(int id)` that sets `keptId = id` and removes `id` from
     `excluded` (a kept row can't also be excluded). `mergeIds` already skips
     `keptId`, so the previously-kept row automatically becomes a merging row.

2. **Interaction model (recommended).** Separate the two intents that currently
   both live on the row tap:
   - **Tap a row's main area (avatar + name/detail)** → make that contact the KEEP
     for its set (`setState(() => set.keep(id))`). No-op if it is already kept.
   - **Tap the right-hand selection control** → toggle merge/exclude for a non-kept
     row (the behaviour the whole row has today). The kept row's control stays the
     non-interactive filled circle.

   Concretely in `_contactRow`:
   - Remove the exclude-toggle from the row-level `GestureDetector`; instead the
     row-level tap calls `set.keep(id)` (only when the row is not already kept).
   - Wrap `_selectionControl(...)` in its own `GestureDetector` that toggles
     `excluded` for non-kept rows (kept row: no handler).

3. **Copy tweaks** so the new capability is discoverable:
   - Summary caption (line ~371): "Review each set — the starred contact is kept."
     → "Tap a contact to choose which to keep; untick the ones to leave out."
   - Per-set merge confirmation body (line ~179) currently says "Keep the starred
     contact…". Reword to "Keep the selected contact and merge N other(s) into it."

4. **No change** to `mergeIds`, `_mergeSet`, `_mergeAll`, `_totalMerging`, or the
   footer text — they all read `keptId`/`mergeIds` and stay correct.

## Verification

- `flutter analyze` clean for the edited file.
- Manual: open Find-duplicates on a same-name/different-number set, tap the second
  contact → KEEP badge + highlight move to it, the first row becomes a ticked
  "merging" row; untick a row to exclude it; Merge uses the chosen keep.

## Open question (please confirm)

The interaction model in step 2 (row tap = choose keep, checkbox tap = exclude) is
my recommendation because it fits the existing single-control-per-row layout. If you
would rather have an explicit "Keep" button/label on each row, or a long-press to
choose keep, say so and I'll adjust before implementing.
