# Glassmorphism (frosted-glass) dialpad keys

**Status:** completed

## Request

Make the dialpad buttons' 3D effect more beautiful/modern using a **glass / frosted**
(glassmorphism) style, in **both light and dark** themes. Replaces the current flat
card + single drop shadow.

## Design approach

Glassmorphism = translucent frosted fill + backdrop blur + a bright hairline edge + a soft
glow. On a *flat* background frosting has little to refract, so to make the effect actually
read we also add a **subtle ambient backdrop** behind the keypad for the glass to pick up.

### Per key (`_key`)
Rebuild the tile as a real glass panel:
- **`ClipRRect`** (radius ~20) wrapping a **`BackdropFilter(ImageFilter.blur ~10)`** so
  whatever is behind the key is frosted (needs `dart:ui`).
- Translucent **gradient fill** (top-left brighter → bottom-right dimmer) for the glass sheen:
  - Light: white ~0.55 → ~0.28 alpha.
  - Dark: white ~0.12 → ~0.04 alpha.
- **Hairline border** as the glass edge highlight: white ~0.6 (light) / ~0.18 (dark) alpha.
- **Soft outer glow** (a `boxShadow` on an outer `DecoratedBox`, outside the clip so it isn't
  cut off): a soft ambient shadow (black, low alpha, large blur) + a faint accent-tinted glow.
- Digit + letters unchanged; `Material` + `InkWell` sit on top of the glass so the tap ripple
  and long-press-`0`-for-`+` behavior are preserved.

### Ambient backdrop (`_dialpad`)
Wrap the grid in a `Stack` with 1–2 **faint radial glows** (accent + the theme's
`gradientEnd`) positioned behind the keys at low alpha (~0.15 light / ~0.22 dark). This gives
the frosted keys color to refract so the glass looks intentional rather than a flat tint.
Kept subtle and contained to the keypad area.

All colors come from existing `AppColors`/`colorScheme` tokens and branch on `colors.isDark`,
so light and dark each get appropriate translucency, border, and glow.

## Files to change
- `lib/screens/dialer_screen.dart` — `_key` (glass tile) and `_dialpad` (ambient backdrop
  Stack); add `import 'dart:ui'` for `ImageFilter`.

## Out of scope
- The main call button (already gradient + shadow).
- Suggestion/favorite rows and other screens.

## Performance note
- 12 keys each use a `BackdropFilter`. For a static keypad this is acceptable; blur sigma is
  kept modest (~10). If it feels heavy on a low-end device we can drop to a faux-glass
  (translucent fill without a live blur) — noted as a fallback.

## Testing
- `flutter analyze` clean.
- `flutter test` still green (presentational only; no asserted key styling).
- Manual: keys read as frosted glass with a bright edge + soft glow, legible and pressable in
  **both** Calm (light) and Midnight (dark).

## Notes
- Low risk, confined to two private helpers in one file.
