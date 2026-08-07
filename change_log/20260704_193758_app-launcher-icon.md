# App launcher icon for ContactSphere

Implements [plans/20260704_192623_app-launcher-icon.md](../plans/20260704_192623_app-launcher-icon.md).

## What changed

Replaced the stock Flutter launcher icon with a ContactSphere icon drawn from the app's
own design system: the Calm-accent brand gradient (`#0D9488` teal → hue +32°, mirroring
`AppTheme._gradientFrom`) behind a white "sphere of contacts" glyph — a central disc
wrapped by a tilted orbit ring carrying three satellite dots.

### New files

- `tool/generate_app_icon.dart` — reproducible icon generator. Paints the icon with
  `dart:ui` Canvas and exports PNGs headlessly; re-run with
  `flutter test tool/generate_app_icon.dart`. Also writes `build/icon_preview.png`
  (circle-masked adaptive-icon composite) for visual inspection.
- `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml` — adaptive icon
  (API 26+) wiring background + foreground + monochrome (Android 13+ themed icons).
- `android/app/src/main/res/mipmap-{m,h,x,xx,xxx}hdpi/ic_launcher_background.png`
  (full-bleed gradient), `ic_launcher_foreground.png` (white glyph inside the 66/108dp
  safe zone), `ic_launcher_monochrome.png` (same glyph; byte-identical to foreground).

### Modified files

- `android/app/src/main/res/mipmap-{m,h,x,xx,xxx}hdpi/ic_launcher.png` — legacy
  (pre-API-26) icons: rounded gradient square with the glyph, replacing the stock
  Flutter icons.

No `pubspec.yaml` or manifest changes; `android:icon="@mipmap/ic_launcher"` already
resolves to the new adaptive/legacy resources.

## Design iteration

The first draft's glyph (disc r=0.42g inside a 0.44g-flat ellipse) read as an eye;
final proportions (disc 0.33g, ring ry 0.58g) read clearly as a sphere with an orbit.

## Verification

- `flutter analyze` — no issues.
- Generator re-run — all 20 PNGs byte-identical (deterministic).
- `flutter build apk --debug` — Gradle assembled both flavors successfully and all 21
  icon resources are present in `app-prod-debug.apk`. Note: the flutter CLI itself
  reports "Gradle build failed to produce an .apk file" because this project uses
  `dev`/`prod` flavors and the tool looks for an unflavored `app-debug.apk`; the APKs
  are at `build/app/outputs/flutter-apk/app-{dev,prod}-debug.apk`. Pre-existing
  behavior, unrelated to this change — use `flutter build apk --flavor prod` instead.
- Visual check of the 432px preview and the 48px mdpi legacy icon (legible).
