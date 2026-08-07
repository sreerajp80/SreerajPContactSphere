# Exact accent rendering + per-mode accent & reset

**Status:** completed

## Issues

1. **Picker doesn't match the app.** Accent-driven UI doesn't render the exact
   picked color. The themes seed their `ColorScheme` with
   `ColorScheme.fromSeed(seedColor: accent, ...)`
   ([lib/theme/app_theme.dart](../lib/theme/app_theme.dart) lines 154 and 179);
   Material 3 remaps the seed into a tonal palette, so `colorScheme.primary`
   (avatars, search icon, group chips, quick-action buttons, section labels,
   slider) is a slightly different tone, while the FAB/hero gradient use the raw
   `accent`. Picker preview chip + FAB show the true accent; everything reading
   `colorScheme.primary` shows the remapped tone.

2. **Accent + reset are shared across modes.** Today a single `_accent` override
   applies to both themes (`lightAccent = _accent ?? calmAccent`,
   `darkAccent = _accent ?? midnightAccent` in
   [app_settings.dart:29-32](../lib/state/app_settings.dart#L29-L32)). The user
   wants Light and Dark to each keep their **own** accent and to be able to
   **reset each mode to its own default** independently.

Note: the loud pink/red on the Relationship Health card is the **mood** color
(score 40 → "Fading" → `#FB7185`), intentional and **not** changing.

## Decisions (per user)

- Render the exact chosen accent (override `colorScheme.primary`).
- Store the accent **per mode**: Light and Dark are independent.
- Per-theme defaults stay teal `#0D9488` (Light/Calm) and indigo `#7C8AFF`
  (Dark/Midnight); a mode uses its default until the user deliberately picks a
  color for that mode.
- "Reset to default" resets the **mode currently being edited** to its built-in
  default. Switching the Light/Dark toggle in the picker lets the user reset the
  other mode the same way.
- Do not touch the mood-color system or the hero card design.
- System theme mode is covered automatically: the picker edits whichever
  brightness is currently displayed.

## Files to change

### 1. `lib/theme/app_theme.dart` (exact render)
In both `calm(Color accent)` and `midnight(Color accent)`, extend the existing
`.copyWith(...)` on the seeded `ColorScheme` to also pin:
- `primary: accent`
- `onPrimary: contrastOn(accent)` (keeps text/icons on the accent legible)

Default accent constants (`calmAccent`, `midnightAccent`) are unchanged.

### 2. `lib/state/app_settings.dart` (per-mode storage)
- Replace the single `_accent` with `Color? _lightAccent;` and
  `Color? _darkAccent;`.
- Persistence keys: `accent_color_light` and `accent_color_dark`.
  - **Migration:** on `load()`, if the new keys are absent but the old
    `accent_color` key exists, seed both new values from it (and remove the old
    key) so an existing user's custom color is preserved.
- Getters:
  - `Color get lightAccent => _lightAccent ?? AppTheme.calmAccent;`
  - `Color get darkAccent => _darkAccent ?? AppTheme.midnightAccent;`
  - `Color accentFor(Brightness b) => b == Brightness.dark ? darkAccent : lightAccent;`
  - `Color? overrideFor(Brightness b) => b == Brightness.dark ? _darkAccent : _lightAccent;`
- Replace `setAccent(color)` with
  `setAccentFor(Brightness b, Color color)` — sets and persists only that mode.
- Replace `resetAccent()` with `resetAccentFor(Brightness b)` — clears and
  removes only that mode's key.

`main.dart` is unchanged: it already reads `settings.lightAccent` /
`settings.darkAccent`.

### 3. `lib/screens/appearance_screen.dart` (per-mode editing + reset)
- Track the last seen `Brightness`. In `didChangeDependencies`, when the
  effective brightness changes (including via the Light/Dark/System toggle),
  re-sync `_hsv` from `settings.accentFor(brightness)`. (Picking a color won't
  clobber the wheel: it keeps the same brightness, so the re-sync is skipped.)
- `_apply(hsv)` calls
  `context.read<AppSettings>().setAccentFor(Theme.of(context).brightness, hsv.toColor())`.
- The reset button calls `resetAccentFor(currentBrightness)` and resets `_hsv`
  to that mode's default. Make the label mode-aware, e.g.
  **"Reset Dark to default"** / **"Reset Light to default"**, so it's clear the
  reset is per mode.
- Initialize `_hsv` from `overrideFor(brightness) ?? default-for-brightness`.

## Why this is sufficient
All seven accent consumers read `theme.colorScheme.primary`
(`appearance_screen.dart:190`, `settings_screen.dart:68`,
`permissions_screen.dart:103,142`, `contact_list_screen.dart:284,455,739`);
pinning `primary` makes them match the picker chip and FAB. Per-mode storage gives
Light and Dark independent accents and independent resets. Container roles
(`primaryContainer`, etc.) stay seed-derived; the app builds its own translucent
accent fills (`accent.withValues(alpha: ...)`) and doesn't rely on them.

## Verification
- `flutter analyze` (no new issues).
- Dark mode: indigo preview chip, FAB, search icon, avatars, buttons all the same
  indigo. Pick teal → all become that exact teal. "Reset Dark to default" →
  back to indigo, **Light unaffected**.
- Switch to Light: shows teal (or its own custom pick), independent of Dark.
  "Reset Light to default" → back to teal, Dark unaffected.
- Relationship Health card stays mood-colored (pink/red at score 40).
- Existing custom color (if any) survives the upgrade via migration.
