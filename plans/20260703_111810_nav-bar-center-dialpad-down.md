# Plan — Center the bottom nav content, fix dialpad overflow, bring dialpad down

**Status:** completed

## The issue (root cause)

Two separate problems are visible in the Dialer screenshot:

### 1. Bottom nav bar: big empty gap above the icons, labels touching the bottom edge

This is **inherent to Material 3 `NavigationBar`**, not a stray padding. Flutter's
`_NavigationDestinationLayoutDelegate.performLayout`
(`packages/flutter/lib/src/material/navigation_bar.dart`) positions each destination like this:

- **Unselected** tab → it centers only the **icon**, then hangs the **label directly below** it.
- **Selected** tab → it centers the icon **and** label together.

With the current `height: 56` (set in the last pass), for an *unselected* tab:

- icon top  = `height/2 − iconHeight/2` = `28 − 16` = **12 px gap at top**
- label bottom = `height/2 − 16 + iconHeight(32) + labelHeight(~20)` = **~64 px** → 8 px **below** the
  56 px box, so the label is clipped / pressed against the bottom edge.

The selected tab (Dialer) looks fine because its icon+label are centered as a group; the unselected
tabs (Contacts, Recents) show the gap-on-top / label-on-bottom. **No stock `height` value fixes
this**: the top gap is always larger than the bottom margin by the label's height, and raising the
height (e.g. back to the default 80) only makes the top gap bigger. The `MediaQuery` inset clamp from
the previous pass is unrelated to this and stays.

### 2. Dialer body: "BOTTOM OVERFLOWED BY 14 PIXELS" under the dialpad

In [lib/screens/dialer_screen.dart](../lib/screens/dialer_screen.dart) `build()` caps the contact
strip with `const chrome = 180.0` (an estimate of app bar + number display + call row + gaps). The
real fixed chrome is ~178–192 px, so on some sizes the fixed children exceed the available height and
the two `Spacer`s can't absorb it → 14 px overflow. The dialpad + call button are also centered by
two equal `Spacer`s, so they float mid-screen instead of sitting lower.

## The fix

### A. Replace the stock `NavigationBar` with a compact custom bar — [lib/screens/home_shell.dart](../lib/screens/home_shell.dart)

Build a small bottom bar that **vertically centers the icon+label group** for every tab, so top and
bottom margins are equal and small, and nothing is clipped. The Material pill-indicator look is
preserved (rounded highlight behind the selected icon), themed from the same `AppColors`
(`cardSurface`, `mutedText`, `colorScheme.primary`) so it reads identically to today — just correctly
spaced.

- A `Row` of three `Expanded` items; each item a `Column(mainAxisSize.min, mainAxisAlignment.center)`
  of: pill-wrapped icon (rounded container, `primary @16%` when selected) → `SizedBox(2)` → label
  (12 px, w700, primary/muted).
- Wrap the bar in `SafeArea(top:false)` with a small bottom pad (~6 px) so labels clear the gesture
  pill **with a little breathing room below the label** (addresses "put more space below the label").
- Top pad ~6 px, bottom pad ~6 px → content is tightly centered, top gap ≈ bottom gap, total bar
  ≈ 56–58 px. This removes the wasted top space.
- Keep tap handling identical: `_onSelect(i)` with the existing dialer/recents `reload()` calls; keep
  the selected/unselected icons (`people`/`people_outline`, `dialpad`, `history`).
- The now-unused `NavigationBar`/`NavigationBarTheme` imports/usages are removed. The `MediaQuery`
  inset clamp is no longer needed (the custom `SafeArea` handles the inset) and is removed.

### B. Fix the dialer overflow + bring the dialpad down — [lib/screens/dialer_screen.dart](../lib/screens/dialer_screen.dart)

- Raise the `chrome` estimate `180 → 200` so the strip cap always leaves enough room and the fixed
  children can't overflow (kills the 14 px overflow with margin to spare).
- Change the two equal `Spacer`s around the dialpad/call block to bias downward — top `Spacer(flex:
  3)`, bottom `Spacer(flex: 2)` — so the dialpad sits lower in the leftover space ("bring the dialpad
  down") without touching the call row/nav bar.

## Files to change

- `lib/screens/home_shell.dart` — replace `NavigationBar` with the compact centered custom bar.
- `lib/screens/dialer_screen.dart` — `chrome 180 → 200`; bias the dialpad `Spacer` flexes downward.

## Verification

- `flutter analyze` on both files → no new issues.
- `dart format` both files.
- Re-run on device: no overflow stripe; nav icons+labels centered as a tight group with a small even
  margin top and bottom and a little space below the labels; dialpad sits lower.

## Alternative considered (not chosen)

Keep the stock `NavigationBar` and just raise `height`. Rejected: as shown above it cannot remove the
top gap — it only trades a clipped label for an even larger top gap. The custom bar is the only way to
satisfy "cut down the top free space" **and** "more space below the label" at once, and it matches the
app's own design system.
