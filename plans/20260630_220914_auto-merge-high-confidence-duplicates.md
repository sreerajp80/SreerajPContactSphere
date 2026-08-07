# Auto-merge high-confidence duplicates

**Status:** approval_pending

## Issue / motivation

The Find Duplicates screen ([lib/screens/duplicates_screen.dart](../lib/screens/duplicates_screen.dart))
only supports *manual* merge: the user hand-picks rows, the first pick becomes the primary, and
[mergeContacts()](../lib/repositories/contact_repository.dart) folds the rest into it. There is no
one-tap "auto-merge" because:

1. [findDuplicates()](../lib/repositories/contact_repository.dart) returns a **flat** `List<Contact>`
   matched on name **OR** phone. The UI never learns *which* contacts pair with which, so it has
   nothing to merge automatically.
2. Merge is irreversible (the confirm dialog says "This cannot be undone"), so blindly auto-merging
   loose matches is risky — two different people can share a landline, or "John" / "John Office".

Decision (user): implement **high-confidence only** auto-merge — auto-merge a cluster *only* when its
members share an identical normalized phone number **AND** an identical name (first + last, case-
insensitive). Fuzzier matches stay in the existing manual flow, untouched.

## Approach

Add a grouped, strict duplicate finder plus an auto-merge driver in the repository, and surface a
single "Auto-merge" action on the duplicates screen that previews the count, confirms once, and runs.

### High-confidence rule

Two contacts are high-confidence duplicates iff:
- they share at least one phone number with identical **normalized digits**
  (`ContactRepository.normalizeDigits`), AND
- their names match case-insensitively on `TRIM(first_name)` + `TRIM(last_name)` (empty last name
  allowed, but both must be equal).

Contacts are then clustered transitively (union-find): A~B and B~C ⇒ {A,B,C} is one group. Secret
contacts are **excluded** entirely (consistent with `phoneIndexNonSecret`) so a secret row is never
auto-absorbed or used as a merge target.

### Primary selection within a group

Since names are identical, the choice only affects which scalar fields survive (photo, notes, score).
Pick the primary as: contact **with a non-empty `photoPath`** first, else the one with the
**most child rows** (phones+emails), tie-broken by **lowest id** (oldest / most stable). Deterministic.

## Files to change

1. **lib/repositories/contact_repository.dart**
   - Add `Future<List<List<Contact>>> findHighConfidenceDuplicateGroups()` — one SQL pass to find
     contacts that collide on (normalized phone) AND (lower name), build an id→members map, union-find
     cluster them, return groups of 2+ as slim summaries (reuse `_summarySelect` / `_summaryFromRow`,
     and pull each contact's phone digit-set for the join). Secret contacts excluded.
   - Add `Future<int> autoMergeHighConfidence()` — calls the finder, picks a primary per group by the
     rule above, calls the **existing** `mergeContacts(primary, others)` per group inside the existing
     transaction-per-merge, and returns the number of duplicate contacts removed. No change to
     `mergeContacts` itself (already correct and id-level).

2. **lib/screens/duplicates_screen.dart**
   - Add an app-bar action (e.g. `Icons.auto_awesome` "Auto-merge") that:
     - calls `findHighConfidenceDuplicateGroups()` to compute a preview count,
     - shows a confirm dialog naming how many groups / how many contacts will be removed (reusing the
       "cannot be undone" wording),
     - on confirm calls `autoMergeHighConfidence()`, shows a result snackbar, and `_load()`s.
   - When there are no high-confidence groups, the action reports "No high-confidence duplicates" and
     does nothing destructive.
   - Manual selection/merge flow is left exactly as-is.

3. **test/contact_repository_dedup_test.dart** (new)
   - Unit tests against an in-memory DB: (a) two contacts, same name + same number → one group, merges
     to one; (b) same number but different name → **not** grouped; (c) same name but different number →
     **not** grouped; (d) secret contact never grouped; (e) transitive cluster of 3 merges to 1.

4. **docs/known-gaps.md** (if it lists the duplicates screen as a gap) — note auto-merge now exists.

## Out of scope / explicitly not doing

- No undo/snapshot (that was the alternative option; high-confidence path was chosen instead).
- No "merge all groups regardless of confidence" button.
- No change to the import-time auto-merge-on-sync dedup.

## Risk / rollback

Low: reuses the proven `mergeContacts`. The strict AND rule makes false-positive merges very unlikely.
Rollback = revert the two source files (and the new test). Each group merges in its own transaction, so
a failure mid-run leaves already-merged groups committed and reports the partial count.
