# Default same-name-only duplicate sets to nothing ticked for merge

**Status:** completed

## Issue

Duplicate sets are grouped by shared name **or** shared phone digits. A set whose
members are linked *only* by name (reason "Same name") can easily be different people
who happen to share a name — exactly the reported [name] case. Today every
non-kept member of every set starts **ticked** for merge, so a quick "Merge all sets"
(or per-set Merge) can silently combine different people. Sets that have a real phone
link ("Same phone number" / "Same name & number") are far more likely to be true
duplicates and should keep starting ticked.

We want: for a set with **no shared phone number**, default every non-kept member to
**unticked** (excluded), so the user must deliberately opt them in. The kept
suggestion is unchanged; the user can still tick rows and merge.

## Files to change

- `lib/repositories/contact_repository.dart` — expose whether a set is phone-linked
  on `DuplicateSet` (robust signal instead of string-matching the reason text).
- `lib/screens/duplicates_screen.dart` — when building `_DupSet`, pre-exclude all
  non-kept members for a set that is not phone-linked.

## Plan for the fix

1. **`DuplicateSet` (repository):** add a `final bool linkedByPhone;` field
   (required in the const constructor). In `findDuplicateGroups`, compute it per set
   from the same signal `_reasonFor` already uses — a phone-digit string shared by
   two members. Concretely, factor the "shared phone?" test out so both `_reasonFor`
   and the new flag use it (or compute a small `sharedPhone` bool in the set loop and
   pass it to both `_reasonFor` and `DuplicateSet`). `linkedByPhone` is true for
   reasons "Same phone number" and "Same name & number", false for "Same name".

2. **`_DupSet` (screen):** in the constructor, when `!set.linkedByPhone`, seed
   `excluded` with every member id except `keptId`:

   ```dart
   if (!set.linkedByPhone) {
     for (final c in set.contacts) {
       final id = c.id;
       if (id != null && id != keptId) excluded.add(id);
     }
   }
   ```

   Everything downstream already reacts correctly: `mergeIds` returns empty →
   the per-set footer shows "Nothing selected", the set's Merge button disables, and
   the row checkboxes render unticked. Ticking a row (or choosing a different keep,
   which un-excludes that row) opts it back in. `keep(id)` already removes `id` from
   `excluded`, so re-pointing KEEP inside a defaulted-off set works.

3. **Copy:** no change required, but optionally the summary caption could hint that
   name-only matches start off. Leaving copy as-is for this change unless you ask.

## Behavioural summary

| Set reason              | Default keep | Non-kept members default |
|-------------------------|--------------|--------------------------|
| Same phone number       | best score   | ticked (merge) — unchanged |
| Same name & number      | best score   | ticked (merge) — unchanged |
| Same name (no phone)    | best score   | **unticked (excluded)** — new |

## Verification

- `flutter analyze` clean for both edited files.
- Manual: a name-only set opens with all checkboxes empty, footer "Nothing selected",
  set Merge disabled, and "to merge" total excluding it; a phone-linked set is
  unchanged (all ticked). Ticking a row or switching KEEP re-enables merging.

## Note

`contact_repository.dart` is stored as UTF-16 on disk; edits must preserve that
encoding so the file isn't rewritten as UTF-8.
