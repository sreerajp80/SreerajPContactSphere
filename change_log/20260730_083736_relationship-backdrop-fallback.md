# Relationship-based in-call backdrop (last fallback)

Implements [plans/20260730_082143_relationship-backdrop-fallback.md](../plans/20260730_082143_relationship-backdrop-fallback.md).

## What changed

The in-call backdrop already used the calling card photo, then the profile photo,
then the plain brand gradient. Contacts with neither photo all looked the same.
One step is now inserted before the brand gradient: a gradient chosen by how the
caller relates to the phone owner.

New chain: calling card photo → profile photo → **relationship gradient** → brand gradient.

## Files

### `lib/theme/caller_backdrop.dart` (new)

- `BackdropMood` enum: `immediateFamily`, `extendedFamily`, `friend`, `work`, `unknown`.
- `moodForRelationship(String?)` maps the ~45 `RelationshipTypes.presets` labels into
  those buckets. Trims and lower-cases first, so case and stray spaces don't matter.
  Null, blank, "Other", and any custom relationship name give `unknown`.
- `gradientFor(mood, now:, isDark:)` returns the `LinearGradient`, or null for
  `unknown`. Mood color pairs are fixed design tokens (warm amber→rose for immediate
  family, peach→clay for extended, teal→indigo for friends, a deliberately flat
  slate→steel for work). The clock shifts **lightness only** — hue and saturation
  are untouched — so an evening family call is a dimmer version of the same warm
  gradient, not a different palette. Dark theme dims a little further. Lightness is
  clamped to 0.08–0.92 so the gradient never flattens to a solid block.
- Both functions are pure (no database, no filesystem), which is what the tests use.

### `lib/repositories/relationship_repository.dart`

- Added `relationshipToSelf(int contactId)`: one query that joins `relationships` to
  the `is_self` contact and returns the label the owner recorded for that contact.
  Read-only, no schema change. Chosen over `getRelationsOf(selfId)` so the in-call
  path doesn't pull the owner's whole relation list to read a single label. Uses
  `MIN(...)` for a deterministic pick if the merge path left duplicate rows, matching
  `getRelationsOf`.

### `lib/screens/in_call_screen.dart`

- New `BackdropMood? _resolvedMood` field, cleared alongside `_resolvedImagePath`
  whenever a new number resolves (and in the no-match branch).
- In the block that already loads the full contact: if no photo path resolves, kick
  off `_resolveMoodBackdrop`. It only runs in the photo-less case, so the common path
  costs nothing extra.
- New `_resolveMoodBackdrop(contactId, number)`: reads the label, maps it to a mood,
  and sets state. Guarded by `_resolvedFor != number` so a number change mid-query
  (add call / swap) can't apply a stale mood; wrapped in try/catch so any failure
  just leaves the brand gradient.
- `build` now computes `gradient = gradientFor(...) ?? colors.brandGradient` and uses
  it in the existing `else` branch. Building it in `build` rather than at resolve time
  means it follows the theme and the clock.
- Foreground color now contrasts against `gradient.colors.first` instead of always
  `colors.gradientStart`, so text stays legible on a mood gradient. Behaviour is
  unchanged when the brand gradient is in use (same color).
- Dropped the three "Google Dialer-style" comments for neutral wording.

### `test/caller_backdrop_test.dart` (new)

13 tests: every label in each bucket, unknown/blank/null/custom handling, case and
space insensitivity, totality over `RelationshipTypes.presets`, two-stop output, moods
being visually distinct, time-of-day changing lightness but not hue, dark-theme
dimming, the lightness clamp, and gradient direction matching the brand gradient.

## Verification

- `flutter analyze` on all four files — no issues.
- `flutter test test/caller_backdrop_test.dart` — 13/13 pass.
- Not yet run on a device; the in-call screen change itself is untested at runtime.

## Notes

- "Family" means family *of the phone owner*, since only relationship rows on the
  `is_self` contact are read. Contacts with no relationship recorded — likely most of
  them — keep the brand gradient exactly as before.
- One tolerance in the tests is 1.5° on hue rather than exact: shading round-trips
  through 8-bit RGB, so the recovered hue drifts under a degree. The hue is not being
  changed on purpose.
- No new dependency, no image assets, no database migration.
