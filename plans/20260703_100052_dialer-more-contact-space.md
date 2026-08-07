# Dialer — give the contact list more vertical space

**Status:** completed

## Issue

On the Dialer tab only ~2 contacts (Favorites / Top contacts) are visible at once.
The screen is a fixed vertical `Column`:

```
_appBar → _numberDisplay → Expanded(_strip) → _dialpad → _callRow
```

The contact list (`_strip`) sits in the `Expanded`, so it only gets the space left
over after the dialpad and call button. The dialpad is the main consumer: its
`GridView.count` uses `childAspectRatio: 1.5` (tall keys) with `mainAxisSpacing: 10`,
which on a typical phone leaves the strip only tall enough for ~2 rows.

## Fix

Shrink the dialpad's vertical footprint so the `Expanded` strip grows. No structural
change — only sizing constants in `_dialpad` and a couple of surrounding gaps.

In [lib/screens/dialer_screen.dart](../lib/screens/dialer_screen.dart), `_dialpad`:
- `childAspectRatio: 1.5` → `1.9` (keys become shorter/wider; ~4 rows shrink by ~50–60px total).
- `mainAxisSpacing: 10` → `8`.

In `build`, trim the small fixed gaps around the call button that pad the bottom:
- `const SizedBox(height: 4)` (between dialpad and call row) → keep at 4 (or 2).
- `const SizedBox(height: 12)` (bottom) → `8`.

Net effect: roughly one extra contact row becomes visible without scrolling, and the
strip remains a scrolling `ListView` so longer lists still scroll as before. Keys stay
comfortably tappable (aspect 1.9 is still wider-than-tall, well above a square).

### Tuning note
`childAspectRatio` is the main lever. If 1.9 makes keys look too short, 1.75 is a
milder step. I'll start at 1.9 and we can nudge after you see it on-device.

## Fix — part 2: compact the bottom navigation bar

The bottom nav is a Material 3 `NavigationBar` in
[lib/screens/home_shell.dart](../lib/screens/home_shell.dart), which defaults to **80px**
tall — spent across the app on every tab, not just the dialer.

- Add `height: 62` to the `NavigationBar` (keeps icon + label comfortably, saves ~18px).
- Keep labels visible (default `alwaysShow` behavior is fine at 62px). If it feels tight,
  the fallback is `height: 64`.

This shrinks the bar app-wide (Contacts, Dialer, Recents all gain the space), and on the
Dialer it stacks with part 1 to give the contact strip noticeably more room.

## Files to change
- `lib/screens/dialer_screen.dart` — sizing constants in `_dialpad` and `build`.
- `lib/screens/home_shell.dart` — `height` on the `NavigationBar`.

## Out of scope
- No change to which contacts are queried or their order.
- No change to the strip's scroll behavior, cards, or the dialpad's glass styling.
