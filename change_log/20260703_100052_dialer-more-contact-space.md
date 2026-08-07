# Change log — Dialer more contact space

Implements [plans/20260703_100052_dialer-more-contact-space.md](../plans/20260703_100052_dialer-more-contact-space.md).

## Problem
Only ~2 contacts (Favorites / Top contacts) were visible on the Dialer tab. The
contact strip lives in an `Expanded` between the number display and the dialpad, so it
only gets leftover vertical space — which the tall dialpad and 80px bottom nav bar left
too little of.

## Changes

### lib/screens/dialer_screen.dart — `_dialpad` / `build`
- `childAspectRatio: 1.5 → 1.9` (shorter, wider keys).
- `mainAxisSpacing: 10 → 8`.
- Bottom `SizedBox(height: 12) → 8` (below the call row).

These shrink the dialpad's vertical footprint so the `Expanded` contact strip grows.

### lib/screens/home_shell.dart — `NavigationBar`
- Added `height: 62` (Material 3 default is 80px), compacting the bottom nav app-wide.

## Result
Roughly 1–2 more contact rows are visible on the Dialer without scrolling. The strip
remains a scrolling `ListView`, so longer lists scroll as before. No behavioral or
query changes. `flutter analyze` on both files: no issues.
