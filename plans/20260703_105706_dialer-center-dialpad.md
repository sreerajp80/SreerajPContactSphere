# Dialer — center the dialpad with balanced top/bottom margins

**Status:** completed

## Issue

On the Dialer the contact strip lives in an `Expanded`, so it stretches to fill all the
space between the number display and the dialpad. With only a couple of contacts, that
leaves a large empty gap directly above the dialpad ("plenty of space at the top"),
while the call button sits with only an 8px margin above the nav bar.

User wants the dialpad **centered** in the leftover space, with **equal** breathing room
above and below it (bottom margin naturally becomes larger than it is now).

## Fix

Restructure the body `Column` in [lib/screens/dialer_screen.dart](../lib/screens/dialer_screen.dart)
so the contact strip is sized to its content (capped + scrollable) and the dialpad block is
centered by two equal flexible spacers.

Current `build` body:
```dart
Column(children: [
  _appBar(colors),
  _numberDisplay(colors),
  Expanded(child: _strip(colors)),   // <- strip stretches, gap piles above the pad
  _dialpad(colors),
  const SizedBox(height: 4),
  _callRow(colors),
  const SizedBox(height: 8),
])
```

New `build` body (wrapped in a `LayoutBuilder` so we can reserve exactly enough room and
avoid overflow on short screens):
```dart
LayoutBuilder(
  builder: (context, constraints) {
    // Derive the dialpad's height from the available width (keys use
    // childAspectRatio 1.9, crossAxisSpacing 12, mainAxisSpacing 8, and the pad
    // has 24px horizontal padding on each side) so we can cap the contact strip
    // to whatever is left and never overflow.
    final keyW = (constraints.maxWidth - 48 - 24) / 3;
    final dialH = keyW / 1.9 * 4 + 8 * 3;
    const chrome = 180.0; // app bar + number display + call row + gap (over-estimate, safe)
    final stripMax =
        (constraints.maxHeight - dialH - chrome).clamp(0.0, constraints.maxHeight);

    return Column(children: [
      _appBar(colors),
      _numberDisplay(colors),
      ConstrainedBox(
        constraints: BoxConstraints(maxHeight: stripMax),
        child: _strip(colors),         // sized to content, scrolls when it exceeds stripMax
      ),
      const Spacer(),                  // equal top gap
      _dialpad(colors),
      const SizedBox(height: 4),
      _callRow(colors),
      const Spacer(),                  // equal bottom gap
    ]);
  },
)
```

Because the strip is now inflexible (definite, content-based height, capped by
`stripMax`), the only flexible children are the two `Spacer`s — so they split the true
remaining space **evenly**, centering the dialpad. When the list is long it fills
`stripMax` and scrolls, the spacers collapse to 0, and the dialpad returns to the bottom.

### Also: make `_strip`'s lists content-sized
So the strip reports its content height (rather than trying to fill), add
`shrinkWrap: true` to the three `ListView`s in `_strip` (the "matches", "no match", and
"favorites + top contacts" branches). The empty-state `Center(...)` branch is left as-is.

## Files to change
- `lib/screens/dialer_screen.dart` — `build` body restructure; `shrinkWrap: true` on the
  `_strip` `ListView`s.

## Notes / tuning
- `chrome = 180` is a deliberate slight over-estimate of the fixed app bar + number
  display + call row heights; it guarantees no bottom overflow (costs at most a few px of
  strip height). If those elements' heights change materially, update this constant.
- No change to queries, card styling, dialpad styling, or the earlier compaction
  (`childAspectRatio: 1.9`, nav bar height/inset).

## Out of scope
- Perfectly matching a specific pixel gap; the goal is an even, centered look.
