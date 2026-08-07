# Change log — Selectable app fonts (English + Malayalam)

Implements plan
[plans/20260712_155211_selectable-app-fonts.md](../plans/20260712_155211_selectable-app-fonts.md).

## What changed

Added a **Font** picker in **Settings → Appearance**. The user can now choose the
app-wide UI font from four options. The choice applies live to the whole app and
is saved across restarts. Every option renders both English (Latin) and
Malayalam.

Font choices offered:

- **System default** (Roboto — unchanged out-of-the-box behavior)
- **Manjari**
- **Anek Malayalam**
- **Noto Sans Malayalam**

## Files changed / added

- **`assets/fonts/`** (new) — bundled static Regular + Bold TTFs for the three
  families, plus their SIL OFL license files:
  - `Manjari-Regular.ttf`, `Manjari-Bold.ttf`, `OFL-Manjari.txt`
  - `AnekMalayalam-Regular.ttf`, `AnekMalayalam-Bold.ttf`, `OFL-AnekMalayalam.txt`
  - `NotoSansMalayalam-Regular.ttf`, `NotoSansMalayalam-Bold.ttf`,
    `OFL-NotoSansMalayalam.txt`
  - Anek Malayalam and Noto Sans Malayalam are published only as variable fonts.
    Static Regular (wght 400) and Bold (wght 700) instances were generated from
    the official Google Fonts variable files with `fonttools` (width axis pinned
    to its default). Manjari already ships static Regular/Bold. All three were
    verified to contain both Malayalam (U+0D2E) and Latin glyphs.

- **`pubspec.yaml`** — declared the three font families (`Manjari`,
  `Anek Malayalam`, `Noto Sans Malayalam`) under `flutter: fonts:` with Regular
  (400) and Bold (700) weights.

- **`lib/state/app_settings.dart`**:
  - New `enum AppFont { system, manjari, anekMalayalam, notoSansMalayalam }`
    with an `AppFontInfo` extension exposing `label` and the bundled `family`
    string (null for `system`).
  - New persisted key `_kAppFont = 'app_font'` (stored as the enum index),
    field `_appFont`, getters `appFont` and `fontFamily`, loader in `load()`
    (bounds-checked like the other enum settings), and `setAppFont(AppFont)`
    that persists and `notifyListeners()`.

- **`lib/theme/app_theme.dart`** — `calm()` and `midnight()` take an optional
  `fontFamily`; threaded into `_build()`, which now uses it and falls back to
  `'Roboto'` when null (so System default behaves exactly as before).

- **`lib/main.dart`** — passes `settings.fontFamily` into both `AppTheme.calm`
  and `AppTheme.midnight`, so changing the font re-themes the whole app live.

- **`lib/screens/appearance_screen.dart`** — added a **FONT** section above the
  Theme toggle. Each option is a selectable `_FontTile` showing the font name,
  an English sample line, and a Malayalam sample line, all rendered in that font
  with a radio indicator on the current choice.

## Verification

- `flutter analyze` on the changed files: **No issues found.**
- `flutter build apk --debug --flavor dev`: **build succeeded.**
- Confirmed all six TTFs are bundled inside the built APK under
  `assets/flutter_assets/assets/fonts/`.

## Notes

- APK grows ~0.8 MB from the six bundled TTFs.
- Fonts are fully offline (bundled assets); no `google_fonts` package and no
  runtime download.
