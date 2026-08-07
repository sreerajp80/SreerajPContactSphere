# Glassmorphism (frosted-glass) dialpad keys

Implements [plans/20260701_115433_dialpad-glass-keys.md](../plans/20260701_115433_dialpad-glass-keys.md).

Replaced the flat card + drop-shadow keypad buttons with a modern frosted-glass
(glassmorphism) treatment that adapts to both the Calm (light) and Midnight (dark) themes.

## Changes

### `lib/screens/dialer_screen.dart`
- Added `import 'dart:ui' show ImageFilter;` for the backdrop blur.
- **`_key`** — each key is now a glass panel:
  - Outer `DecoratedBox` carries the soft glow (ambient black shadow + a faint accent-tinted
    glow) so it isn't clipped.
  - `ClipRRect` (radius 20) + `BackdropFilter(ImageFilter.blur 10)` frosts what's behind.
  - Translucent gradient fill (brighter top-left → dimmer bottom-right) for the sheen —
    white 0.12→0.04 alpha on dark, 0.55→0.28 on light.
  - Bright hairline border as the glass rim — white 0.18 (dark) / 0.60 (light) alpha.
  - `Material`+`InkWell` on top keep the tap ripple and long-press-`0`-for-`+` behavior;
    digit/letters unchanged.
- **`_dialpad`** — wrapped the grid in a `Stack` with two faint radial "ambient glows"
  (accent + `gradientEnd`, low alpha, stronger on dark) positioned behind the keys, so the
  frosted glass has color to refract instead of reading as a flat tint. Added
  `_ambientGlow` helper.

## Out of scope
- The main call button (already gradient + shadow).

## Verification
- `flutter analyze` — No issues found.
- Presentational only; no logic changed and tests don't assert key styling.

## Notes
- 12 keys each use a live `BackdropFilter` (blur sigma 10). Fine for a static keypad; if it
  ever stutters on a low-end device, the fallback is faux-glass (translucent fill without a
  live blur).
