# Change log — Center the dialpad with balanced margins

Implements [plans/20260703_105706_dialer-center-dialpad.md](../plans/20260703_105706_dialer-center-dialpad.md).

## Problem
The contact strip sat in an `Expanded`, stretching to fill all space between the number
display and the dialpad. With few contacts this piled a large empty gap above the dialpad
while the call button had only an 8px margin above the nav bar. User wanted the dialpad
centered with even top/bottom breathing room.

## Changes — lib/screens/dialer_screen.dart

### `build` body restructured
- Wrapped the body `Column` in a `LayoutBuilder`.
- Derived the dialpad height from the available width (keys `childAspectRatio 1.9`,
  `crossAxisSpacing 12`, `mainAxisSpacing 8`, 24px side padding) and reserved a fixed
  `chrome = 180` (safe over-estimate of app bar + number display + call row + gap) to
  compute `stripMax`.
- Replaced `Expanded(child: _strip(...))` with
  `ConstrainedBox(maxHeight: stripMax, child: _strip(...))` — the strip is now sized to
  its content and capped.
- Added a `Spacer()` above the dialpad and replaced the trailing `SizedBox(height: 8)`
  with a second `Spacer()`. Since the strip is now inflexible, the two `Spacer`s are the
  only flexible children and split the leftover space evenly, centering the dialpad.

### `_strip` lists
- Added `shrinkWrap: true` to the three `ListView`s (matches, no-match, favorites+top) so
  they report content height. The empty-state `Center(...)` branch is unchanged.

## Result
With a short list the dialpad is centered with equal gaps above and below (bottom margin
now much larger than the old 8px). With a long list the strip fills `stripMax` and scrolls,
the spacers collapse, and the dialpad returns to the bottom — no overflow. `dart format`
applied; `flutter analyze` on the file: no issues.

## Follow-up
- `chrome = 180` is coupled to the app bar / number display / call row heights; if those
  change materially, update the constant.
