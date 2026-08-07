# Selectable app fonts (English + Malayalam)

**Status:** completed

## What the user wants

In **Settings → Appearance**, let the user pick the app's font from a small set
of beautiful, readable typefaces. Each font must render both **English (Latin)**
and **Malayalam** well. The choice applies live to the whole app and is saved.

## Decisions already made (with the user)

- **Delivery:** bundle the font files inside the app as assets. Fully offline,
  instant, reliable. I will download the open-license (SIL OFL) font files and
  wire them up — no runtime download, no `google_fonts` package.
- **Fonts offered:** System default (Roboto) + **Manjari**, **Anek Malayalam**,
  **Noto Sans Malayalam**. All three cover Latin + Malayalam. System default
  stays the out-of-the-box choice.

## Current behavior (for reference)

- `AppTheme.calm()` / `AppTheme.midnight()` build the themes and hardcode
  `fontFamily: 'Roboto'` in `_build()` ([lib/theme/app_theme.dart:243](lib/theme/app_theme.dart#L243)).
- `main.dart` builds the two themes from the accent only
  ([lib/main.dart:490-491](lib/main.dart#L490-L491)).
- Malayalam currently renders through the Android system fallback font.
- No `assets/` folder or bundled fonts exist yet.

## Files to change / add

1. **`assets/fonts/`** (new folder) — bundle static TTFs (Regular + Bold each):
   - `Manjari-Regular.ttf`, `Manjari-Bold.ttf`
   - `AnekMalayalam-Regular.ttf`, `AnekMalayalam-Bold.ttf`
   - `NotoSansMalayalam-Regular.ttf`, `NotoSansMalayalam-Bold.ttf`
   - Also add each font's `OFL.txt` license file next to them (OFL requires the
     license ship with the fonts).
   - Downloaded from the official Google Fonts / SMC repositories. If a static
     Bold weight is not published for a family, I will bundle Regular only and
     let the framework synthesize bold (and note it in the change log).

2. **`pubspec.yaml`** — declare the three font families under `flutter: fonts:`
   with their Regular (400) and Bold (700) files.

3. **`lib/state/app_settings.dart`**:
   - Add `enum AppFont { system, manjari, anekMalayalam, notoSansMalayalam }`.
   - Add each enum value a `fontFamily` (null for `system`) and a display
     `label` (via a small extension or a helper map).
   - Add persisted key `_kAppFont = 'app_font'`, field `_appFont`, getter
     `appFont`, getter `fontFamily` (the resolved family string or null), and
     `setAppFont(AppFont)` that persists the index and `notifyListeners()`.
   - Load `_appFont` in `load()` with the same bounds-checked pattern used for
     the other enum settings.

4. **`lib/theme/app_theme.dart`**:
   - Change `calm(Color accent)` → `calm(Color accent, {String? fontFamily})`
     and `midnight(...)` the same way; thread `fontFamily` into `_build()`.
   - In `_build()`, use the passed family, falling back to `'Roboto'` when null
     (so System default behaves exactly as today).

5. **`lib/main.dart`** — pass `fontFamily: settings.fontFamily` into
   `AppTheme.calm(...)` and `AppTheme.midnight(...)`.

6. **`lib/screens/appearance_screen.dart`** — add a new **"FONT"** section
   (above or below Accent Color) that lists the four choices as selectable
   cards/tiles. Each tile shows a live preview using that font — one English
   line and one Malayalam line (e.g. "The quick brown fox" /
   "മലയാളം സുന്ദരം") — with a check mark on the selected one. Tapping a tile
   calls `settings.setAppFont(...)` so the whole app re-themes live.

## Plan for the fix

1. Download the six TTFs + OFL license files into `assets/fonts/`.
2. Declare the families in `pubspec.yaml`; run `flutter pub get`.
3. Add the `AppFont` enum + persistence to `AppSettings`.
4. Thread `fontFamily` through `AppTheme` and `main.dart`.
5. Build the font picker UI in the Appearance screen with per-font previews.
6. Verify: `flutter analyze` clean, and build/run to confirm each font renders
   both scripts and the selection persists across restarts.

## Notes / risks

- Font family **name** in `pubspec.yaml` must exactly match the string passed to
  `ThemeData(fontFamily: ...)`. I will keep them identical (`Manjari`,
  `AnekMalayalam`, `NotoSansMalayalam`).
- Anek Malayalam and Noto Sans Malayalam are published as **variable** fonts;
  I will bundle static instances (Regular/Bold) so Flutter's simple
  `fontFamily` weight mapping works without extra `fontVariations` wiring.
- APK grows by roughly 1–2 MB for the bundled fonts. Acceptable per the
  offline-first delivery decision.
- No change to how contact data, search keys, or the accent system work.

## Change log

On completion, write `change_log/<ts>_selectable-app-fonts.md` referencing this
plan.
