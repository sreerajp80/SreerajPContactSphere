# Relationship-based in-call backdrop (last fallback)

**Status:** completed

## What already works (no change needed)

The in-call backdrop is already done for the photo cases:

- `lib/screens/in_call_screen.dart:206` — `contact?.cardPhotoPath ?? contact?.photoPath`.
  Calling card photo first, then profile photo.
- `lib/screens/in_call_screen.dart:388-403` — full-bleed `Image.file` plus a dark scrim.
- `lib/screens/in_call_screen.dart:404-407` — if there is no image at all, the screen
  paints the plain brand gradient (`colors.brandGradient`).

So the only gap is the third case: **a contact with neither a calling card photo nor a
profile photo gets the same plain brand gradient as everyone else.**

## The issue

For photo-less contacts the in-call screen carries no signal about who is calling.
Every such call looks identical. We have relationship data in the database that could
tint that screen, so a call from family reads warm and a call from a work contact reads
cool and plain — without needing any photo.

## The fix (in short)

Add one more step to the backdrop fallback chain:

1. calling card photo (already there)
2. profile photo (already there)
3. **new:** a generated gradient backdrop chosen by the caller's relationship to the user
4. brand gradient (already there — still used when the relationship is unknown)

No image assets are shipped. Step 3 draws a gradient built from the app's own theme
colors, so it stays inside our design system (not a copy of any other dialer). Names
used in code will be neutral (`CallerBackdrop`, `BackdropMood`), not vendor names.

### How the relationship is read

- The user's own contact row is found with `ContactSyncService.selfContact()` /
  `ContactRepository.getSelfContact()` (the `isSelf` flag).
- `RelationshipRepository.getRelationsOf(selfId)` returns the user's relations. We look
  for a row whose related contact is the caller and read its `relationshipType`.
- If there is no self contact, or no relationship row for the caller, we skip step 3 and
  the brand gradient shows exactly as today.

### Grouping relationship types into moods

`RelationshipTypes.presets` has ~45 labels. Mapping each one to its own gradient would be
noise, so labels are bucketed into a small set of moods:

| Mood | Relationship labels | Feel |
| --- | --- | --- |
| `immediateFamily` | Father, Mother, Parent, Son, Daughter, Child, Spouse, Partner, Brother, Sister, Elder/Younger Brother, Elder/Younger Sister, Sibling | warm (amber → deep rose) |
| `extendedFamily` | Grandparent/Grandfather/Grandmother, Grandchild/Grandson/Granddaughter, Uncle, Aunt, Nephew, Niece, Cousin (+ Brother/Sister), all `-in-law`, all `Step-`, Relative | soft warm (peach → clay) |
| `friend` | Friend, Neighbour | bright (teal → indigo) |
| `work` | Colleague | plain professional (slate → steel blue), flattest of the set |
| `unknown` | Other, anything not listed, no relationship row | falls through to the existing brand gradient |

Custom relationship names (the user can rename them — `AppSettings._relationshipNames`)
that do not match a preset land in `unknown` and get the brand gradient. That is the safe
default, not a bug.

### Time-of-day shading

The mood gradient is shaded by clock time (morning / day / evening / night) by adjusting
lightness only — the hue stays the mood's hue. This is a small multiplier, not a second
palette, so a family call at night is a darker version of the same warm gradient. Keeps
the code small and the look consistent.

## Files to change

| File | Change |
| --- | --- |
| `lib/theme/caller_backdrop.dart` *(new)* | `BackdropMood` enum, `moodForRelationship(String?)` label→mood mapping, and `gradientFor(mood, AppColors, DateTime)` returning a `LinearGradient` (or `null` for `unknown`). Pure functions, no I/O — easy to unit test. |
| `lib/screens/in_call_screen.dart` | Add a `LinearGradient? _resolvedMoodGradient` field. In the block at ~line 203 (where the contact is already loaded), when no photo path resolves, look up the self contact + relationship and set the mood gradient. In `build`, use `_resolvedMoodGradient ?? colors.brandGradient` in the existing `else` branch at line 404. Also drop the three "Google Dialer-style" comments (lines 72, 201, 386) for neutral wording. |
| `lib/repositories/relationship_repository.dart` | Possibly add a narrow helper `relationshipTypeBetween(int selfId, int otherId)` so the screen does not pull the user's whole relation list on every call. Read-only; no schema change. |
| `test/caller_backdrop_test.dart` *(new)* | Tests for the label→mood mapping (each bucket, unknown label, null), and that time-of-day only changes lightness, not hue. |

No database migration. No new dependency. No change to the photo path, the scrim, or the
foreground color logic — when a mood gradient is used, `hasImage` stays `false` so text
keeps contrasting against the gradient as it does today.

## Risk / things to watch

- The extra lookup runs on the in-call path. It is done once per resolved contact (same
  place the contact is already fetched) and only when there is no photo, so it adds one
  small query at most. Best-effort and wrapped so a failure just leaves the brand gradient.
- The mood buckets are a judgement call. If any label is in the wrong bucket, tell me and
  I will move it — the mapping is a single table in one file.

## Open question (please confirm with your approval)

Relationship rows link **any two contacts**, not only the user. This plan reads only the
rows on the **self contact**, so "family" means family *of the user*. If you would rather
key it off groups/tags (e.g. a "Work" group) instead of, or in addition to, relationships,
say so and I will revise before writing code.
