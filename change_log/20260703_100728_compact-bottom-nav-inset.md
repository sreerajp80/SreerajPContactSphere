# Change log — Compact bottom nav bar further (trim gesture inset)

Implements [plans/20260703_100728_compact-bottom-nav-inset.md](../plans/20260703_100728_compact-bottom-nav-inset.md).

## Problem
After the first pass (`height: 62`) the bottom nav still showed a noticeable empty gap
below the labels. That gap is the bottom safe-area inset the Material 3 `NavigationBar`
reserves (the OS gesture zone, `MediaQuery.padding.bottom`) so labels clear the gesture
pill. The visible horizontal line at the bottom is that OS-drawn gesture pill itself
(not app-owned, not removed).

## Changes

### lib/screens/home_shell.dart
- Wrapped the `bottomNavigationBar` in a `MediaQuery` whose `padding.bottom` is clamped
  to `0..8` px (`mq.padding.bottom.clamp(0.0, 8.0)`), so the bar reserves at most a thin
  8px buffer under the labels instead of the full device gesture inset.
- Reduced `NavigationBar` `height: 62 → 56`.

## Result
Most of the empty space below the labels is reclaimed while keeping a small buffer above
the gesture pill. Formatted with `dart format`; `flutter analyze` on the file: no issues.

## Follow-up knobs (if needed on-device)
- Clamp upper bound `8 → 0` for maximum compactness (labels closest to the pill).
- `height` can be nudged if the row feels tight.
