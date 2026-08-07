# Change log — Add font-size control to Appearance settings

Implements plan
[plans/20260714_085510_appearance-font-size.md](../plans/20260714_085510_appearance-font-size.md).

## What changed

Added an app-wide "Text size" control to Settings → Appearance. The user can now
pick Small, Default, Large, or Larger, and all text in the app re-scales live.
The choice is persisted.

### Files changed

1. **lib/state/app_settings.dart**
   - Added the `AppTextScale` enum (`small`, `normal`, `large`, `larger`) with an
     `AppTextScaleInfo` extension giving each a `label` and a `scale` multiplier
     (0.85 / 1.0 / 1.15 / 1.30).
   - Added the persisted setting: key `_kTextScale` (stored as the enum index),
     backing field `_appTextScale` (default `AppTextScale.normal`), getters
     `appTextScale` and `textScaleFactor`, and `setAppTextScale(...)`.
   - `load()` now reads the persisted text scale (bounds-checked, same pattern as
     the font setting).

2. **lib/main.dart**
   - The `MaterialApp.builder` now wraps the app in a `MediaQuery` that overrides
     `textScaler` with `TextScaler.linear(settings.textScaleFactor)`, so the
     in-app Text size setting scales all text in one place. The existing
     back-swipe `GestureDetector` is preserved inside it.

3. **lib/screens/appearance_screen.dart**
   - Added a "TEXT SIZE" section (using the existing `_label` helper) between the
     FONT and THEME sections, rendered as a `SegmentedButton<AppTextScale>` wired
     to `settings.appTextScale` / `setAppTextScale(...)`.

## Notes

- No native/Android changes and no new dependencies.
- Existing installs default to Default (1.0×), so behavior is unchanged until the
  user picks another size.
- The app overrides the device's own font-scale for a predictable in-app control
  (the app is the single source of truth for scale).
- `flutter analyze` on the three changed files reports no issues.
