# Change log — Center the bottom nav content, fix dialpad overflow, bring dialpad down

Implements [plans/20260703_111810_nav-bar-center-dialpad-down.md](../plans/20260703_111810_nav-bar-center-dialpad-down.md).

## Problem

- **Bottom nav bar:** empty gap above the icons and labels pressed against the bottom edge on the
  unselected tabs. Root cause is Material 3 `NavigationBar`'s layout — it centers only the icon and
  hangs the label below it for unselected destinations, so at the compact `height: 56` the label
  bottom fell ~8 px past the box (clipped) and the icon sat ~12 px down from the top. No stock
  `height` fixes both; a larger height only enlarges the top gap.
- **Dialer body:** "BOTTOM OVERFLOWED BY 14 PIXELS" under the dialpad — the strip-cap `chrome`
  estimate (180) underestimated the real fixed chrome, and the dialpad/call block was centered by two
  equal `Spacer`s (floated mid-screen rather than sitting lower).

## Changes

### lib/screens/home_shell.dart
- Replaced the Material `NavigationBar` (+ `NavigationBarTheme` + the `MediaQuery` inset clamp) with a
  compact custom bottom bar: a `Material(color: cardSurface)` → `SafeArea(top:false)` →
  `Padding(6,8)` → `Row` of three `Expanded` `_navItem`s.
- Added `_navItem(...)`: a pill-wrapped icon (`60x32`, `primary @16%` rounded highlight when selected)
  over a 12 px/w700 label, both centered as one group (`Column(mainAxisSize.min)`), tinted
  `primary`/`mutedText` by selection. Tap still routes through `_onSelect` (keeps the dialer/recents
  `reload()` behaviour). Result: even, small top/bottom margins and a little space below the labels.
- Updated the class doc comment (no longer a Material `NavigationBar`).

### lib/screens/dialer_screen.dart
- `chrome` estimate `180.0 → 200.0` so the contact-strip cap always leaves enough room and the fixed
  children can't overflow (removes the 14 px overflow).
- Biased the dialpad/call block downward: `Spacer()` → `Spacer(flex: 3)` (top) and `Spacer(flex: 2)`
  (bottom), so the dialpad sits lower in the leftover space.

## Verification

- `dart format` both files; `flutter analyze` on both files → **No issues found**.
- **Runtime screenshot not captured this session:** `flutter run` on the connected moto g54 failed at
  the build step because the `sqlite3` package's native-asset hook could not download
  `libsqlite3.arm64.android.so` from GitHub (`SocketException`, OS Error 121 — network unreachable).
  This is an environment/network issue unrelated to the change; re-run `flutter run` once GitHub is
  reachable to confirm the layout on-device.
