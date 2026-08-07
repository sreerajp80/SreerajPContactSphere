# App launcher icon for ContactSphere

**Status:** completed

## Issue

The app still ships the stock Flutter launcher icon (default `ic_launcher.png` in every
`mipmap-*` folder). ContactSphere needs its own icon, consistent with the app's design
system, plus a modern Android **adaptive icon** (API 26+) and a **monochrome** layer for
Android 13+ themed icons. Currently there is no `mipmap-anydpi-v26` config at all.

## Design (follows the app's own design system — see lib/theme/app_theme.dart)

- **Background:** the app's brand gradient, derived exactly like `AppTheme._gradientFrom`
  from the Calm accent `#0D9488` (teal) → hue +32°, saturation ×0.95 (a teal→green-cyan
  diagonal gradient, top-left → bottom-right, same as the hero card / FAB).
- **Foreground glyph (white):** a "sphere of contacts" — a central filled disc (the
  contact/person) wrapped by a thin elliptical orbit ring carrying 2–3 small satellite
  dots (the sphere of people around them). Neutral, geometric, no resemblance to the
  Google Contacts/Dialer icons.
- **Monochrome layer:** the same glyph alone (white), used by Android 13+ themed icons.
- Legacy (pre-26) icons get the full-bleed gradient square with rounded corners baked in.

## How the assets are generated

No image tooling (ImageMagick/Inkscape/Pillow) exists on this machine, so the icon is
painted with Flutter's own `dart:ui` `Canvas` inside a throwaway test-harness script and
exported to PNG via `PictureRecorder → toImage → toByteData(png)`. This runs headless with
`flutter test` and keeps everything inside the project toolchain.

Generated sizes:

| Asset | Sizes |
|---|---|
| Legacy `ic_launcher.png` (mipmap-mdpi…xxxhdpi) | 48, 72, 96, 144, 192 px |
| Adaptive foreground `ic_launcher_foreground.png` | 108, 162, 216, 324, 432 px (glyph inside the 66/108 safe zone) |
| Adaptive monochrome `ic_launcher_monochrome.png` | same five sizes |
| Adaptive background | solid-color? **No** — gradient, so `ic_launcher_background.png` at the same five sizes |

## Files to create

1. `tool/generate_app_icon.dart` — the Canvas-painting generator (run once via
   `flutter test tool/generate_app_icon.dart`; kept in the repo so the icon is reproducible).
2. `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml` — adaptive icon XML
   referencing background + foreground + monochrome.
3. `android/app/src/main/res/mipmap-{m,h,x,xx,xxx}hdpi/ic_launcher_foreground.png`
4. `android/app/src/main/res/mipmap-{m,h,x,xx,xxx}hdpi/ic_launcher_background.png`
5. `android/app/src/main/res/mipmap-{m,h,x,xx,xxx}hdpi/ic_launcher_monochrome.png`

## Files to change

6. `android/app/src/main/res/mipmap-{m,h,x,xx,xxx}hdpi/ic_launcher.png` — replaced with the
   new legacy icons (overwrites the stock Flutter icons).

No `pubspec.yaml` change (no `flutter_launcher_icons` dependency needed), no manifest change
(`android:icon="@mipmap/ic_launcher"` already points at the right name).

## Verification

- `flutter analyze` stays clean for the new tool script.
- Re-run the generator to confirm it's deterministic.
- Visually inspect the generated PNGs (view the 432 px foreground/background composites).
- `flutter build apk --debug` to confirm resources link (or at least a Gradle resource merge).

## Out of scope

- Launch/splash screen (`drawable/launch_background.xml`) — unchanged.
- iOS/web icons — Android is the only configured platform.
