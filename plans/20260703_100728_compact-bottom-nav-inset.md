# Compact the bottom nav bar further (reclaim the safe-area inset)

**Status:** completed

## Issue / explanation

Two things in the screenshot:

1. **The horizontal line at the very bottom** is Android's gesture-navigation pill
   (the home handle), drawn by the OS — not part of the app. It stays regardless.
2. **The gap below the labels** is the bottom safe-area inset the Material 3
   `NavigationBar` reserves so labels aren't hidden under that gesture pill. `height: 62`
   only sizes the icon+label row; the bar additionally adds `MediaQuery.padding.bottom`
   (the device gesture inset, ~24–48px) beneath it. That inset is the visible empty space.

So to compact further we (a) shrink the row a bit more and (b) trim the reserved bottom
inset rather than leave the full OS gesture zone.

## Fix

In [lib/screens/home_shell.dart](../lib/screens/home_shell.dart):

- Reduce `NavigationBar` `height: 62 → 56`.
- Wrap the nav bar in a `MediaQuery` that **clamps the bottom padding** to a small value
  (e.g. `bottom: mq.padding.bottom.clamp(0, 8)`), so the bar reserves at most ~8px below
  the labels instead of the full gesture inset. This keeps a thin buffer above the gesture
  pill while removing most of the empty space.

Implementation sketch (bottomNavigationBar):

```dart
bottomNavigationBar: Builder(
  builder: (context) {
    final mq = MediaQuery.of(context);
    return MediaQuery(
      data: mq.copyWith(
        padding: mq.padding.copyWith(bottom: mq.padding.bottom.clamp(0.0, 8.0)),
      ),
      child: NavigationBarTheme( ... NavigationBar(height: 56, ...) ),
    );
  },
),
```

### Tuning note
The `clamp(0, 8)` upper bound is the lever for how close labels sit to the gesture pill.
`0` removes the buffer entirely (most compact, labels nearest the pill); `8` keeps a small
gap. I'll use `8` and we can drop to `0` or raise it after you see it on-device.

## Files to change
- `lib/screens/home_shell.dart` — wrap nav bar in inset-trimming `MediaQuery`; `height: 56`.

## Out of scope
- The gesture pill itself (OS-owned) is not removed.
- No change to destinations, theming, or tab behavior.
