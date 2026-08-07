# Add font-size control to Appearance settings

**Status:** completed

## Issue

Settings → Appearance lets the user change the font family, theme, and accent
color, but there is **no way to change the app-wide font size**. Users who want
larger (or smaller) text have no control inside the app; they must rely on the
system font-size setting.

## Goal

Add an app-wide "TEXT SIZE" control to the Appearance screen. Picking a size
re-scales all text in the app live (same live-apply pattern as font/theme/accent)
and the choice is persisted.

## Approach

Use Flutter's `MediaQuery` text scaling. The app already wraps every screen in a
single `builder:` on the `MaterialApp` (see [lib/main.dart](../lib/main.dart)),
so overriding the `textScaler` there scales all text app-wide in one place, live,
without touching individual screens.

Offer a small set of named steps (not a raw slider) to keep it simple and match
the app's other discrete pickers:

- Small — 0.85×
- Default — 1.0×
- Large — 1.15×
- Larger — 1.30×

These are relative multipliers on top of the theme's base font sizes.

### Files to change

1. **[lib/state/app_settings.dart](../lib/state/app_settings.dart)**
   - Add an `AppTextScale` enum (`small`, `normal`, `large`, `larger`) with a
     `label` and a `scale` (double) via an extension, mirroring the existing
     `AppFont` pattern.
   - Add a persisted setting: key `_kTextScale` (stored as enum index),
     backing field `_appTextScale` (default `AppTextScale.normal`), getters
     `appTextScale` and `textScaleFactor` (the double), and a
     `setAppTextScale(...)` setter that persists + `notifyListeners()` — copied
     from the `setAppFont` shape.
   - Load it in `load()` alongside the other prefs (bounds-checked index read,
     same as `_kAppFont`).

2. **[lib/main.dart](../lib/main.dart)**
   - In the `MaterialApp.builder`, wrap the existing `child` in a `MediaQuery`
     that overrides `textScaler` with
     `TextScaler.linear(settings.textScaleFactor)` (reading the current
     `MediaQuery` and using `copyWith`). This keeps the existing back-swipe
     `GestureDetector`.

3. **[lib/screens/appearance_screen.dart](../lib/screens/appearance_screen.dart)**
   - Add a new "TEXT SIZE" section (using the existing `_label(...)` helper)
     below the FONT section. Render the four choices — a `SegmentedButton`
     `<AppTextScale>` (matching the THEME segmented control), wired to
     `settings.appTextScale` / `context.read<AppSettings>().setAppTextScale(...)`.
   - Optionally show a one-line live preview of sample text so the effect is
     visible while choosing (kept minimal, in the app's own style).

## Out of scope / notes

- No native/Android changes. This is purely a Flutter `MediaQuery` scale.
- No new dependencies.
- Existing installs default to `Default` (1.0×), so behavior is unchanged until
  the user picks another size.
- The multiplier composes with the *base* theme sizes; it does not disable the
  device's own accessibility font scaling conceptually, but by overriding
  `textScaler` the app becomes the single source of truth for scale (a deliberate
  choice so the in-app control is predictable). If you would prefer to *multiply*
  the device scale instead, say so and I will compose them.
