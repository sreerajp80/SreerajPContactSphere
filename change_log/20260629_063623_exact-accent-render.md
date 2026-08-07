# Change log — Exact accent rendering + per-mode accent & reset

Implements plan
[plans/20260629_062630_exact-accent-render.md](../plans/20260629_062630_exact-accent-render.md).

## What changed

### `lib/theme/app_theme.dart`
- In both `calm(accent)` and `midnight(accent)`, the seeded `ColorScheme` now
  also pins `primary: accent` and `onPrimary: contrastOn(accent)` via `.copyWith`.
  This makes `colorScheme.primary` the **exact** picked accent instead of the
  Material-3 seed-remapped tone, so accent-driven UI (avatars, search icon, group
  chips, quick-action buttons, section labels, slider) matches the picker preview
  chip and the FAB/hero gradient.
- Default accent constants (`calmAccent`, `midnightAccent`) unchanged.

### `lib/state/app_settings.dart`
- Replaced the single `_accent` override with per-mode overrides `_lightAccent`
  and `_darkAccent`, persisted under new keys `accent_color_light` /
  `accent_color_dark`.
- Added `accentFor(Brightness)` and `overrideFor(Brightness)` accessors; kept
  `lightAccent` / `darkAccent` getters (now backed by the per-mode fields).
- Replaced `setAccent(color)` → `setAccentFor(Brightness, color)` and
  `resetAccent()` → `resetAccentFor(Brightness)`, each touching only the given
  mode.
- Added one-time migration in `load()`: the legacy `accent_color` key (which
  applied to both themes) is copied into whichever per-mode keys are unset, then
  removed, so an existing user's custom color survives the upgrade.

### `lib/screens/appearance_screen.dart`
- The wheel now re-syncs to the active mode's accent whenever the effective
  brightness changes (Light/Dark/System toggle), via a `_lastBrightness` guard
  replacing the old one-shot `_initialized` flag. Picking a color keeps the same
  brightness, so it no longer clobbers the user's edit.
- `_apply` writes to the current brightness via `setAccentFor`.
- The reset button calls `resetAccentFor(currentBrightness)` and its label is now
  mode-aware: "Reset Dark to default" / "Reset Light to default".

## Not changed (per plan)
- Per-theme default accents (teal for Light, indigo for Dark).
- The score-based mood color system and the Relationship Health hero card.
- `lib/main.dart` (still reads `settings.lightAccent` / `settings.darkAccent`).

## Verification
- `flutter analyze lib/theme/app_theme.dart lib/state/app_settings.dart
  lib/screens/appearance_screen.dart` → "No issues found!".
- Manual device verification (picker matches rendered accent in both modes;
  independent per-mode accents and resets; mood card unchanged) left to the user.
