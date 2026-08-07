# Change log — Add localization delegates (standard §8.1)

Implements plan `plans/20260713_063502_localization-delegates.md`.

## What changed

Made the app satisfy engineering standard §8.1 (Minimum Localization Setup — All Apps).
Previously the root `MaterialApp` declared no localization delegates or supported locales,
so built-in Material widgets (date/number pickers, dialogs, tooltips) could misrender on
devices with a non-English system locale.

### `pubspec.yaml`
- Added the `flutter_localizations` SDK dependency (`sdk: flutter`). `intl` was already
  present. `flutter pub get` resolved cleanly.

### `lib/main.dart`
- Added `import 'package:flutter_localizations/flutter_localizations.dart';`.
- Added to the root `MaterialApp`:
  - `localizationsDelegates`: `GlobalMaterialLocalizations.delegate`,
    `GlobalWidgetsLocalizations.delegate`, `GlobalCupertinoLocalizations.delegate`.
  - `supportedLocales`: `Locale('en')` and `Locale('ml')`. English is the app's UI language;
    Malayalam is listed so Material widgets localize on Malayalam devices (the app bundles
    Malayalam fonts and has Malayalam-aware avatar/section logic).

## Verification
- `flutter pub get` — succeeded.
- `flutter analyze lib/main.dart` — "No issues found!".
