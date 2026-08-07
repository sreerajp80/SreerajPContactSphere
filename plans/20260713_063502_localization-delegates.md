# Add localization delegates (standard §8.1)

**Status:** completed

## Issue

`lib/main.dart`'s root `MaterialApp` declares no `localizationsDelegates` and no
`supportedLocales`. This violates engineering standard §8.1 ("Minimum Setup — All Apps"),
which every user-facing app MUST meet even when it ships a single UI language. Without the
Global Material/Widgets/Cupertino delegates, built-in Material widgets — date pickers,
number inputs, dialog buttons, tooltips — can render incorrectly (wrong text, wrong layout)
on devices whose system locale is not English.

`intl` is already in `pubspec.yaml`, but the `flutter_localizations` SDK package is not.

## Files to change

1. `pubspec.yaml` — add the `flutter_localizations` SDK dependency.
2. `lib/main.dart` — import `flutter_localizations`, add `localizationsDelegates` and
   `supportedLocales` to the root `MaterialApp`.

## Plan for the fix

### 1. `pubspec.yaml`
Under `dependencies:`, add:

```yaml
  flutter_localizations:
    sdk: flutter
```

(`intl: ^0.20.2` already present, so no change there.)

### 2. `lib/main.dart`
- Add import: `import 'package:flutter_localizations/flutter_localizations.dart';`
- In the root `MaterialApp` (build method), add:

```dart
localizationsDelegates: const [
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
],
supportedLocales: const [
  Locale('en'),
  Locale('ml'), // Malayalam — the app's primary audience (bundled Malayalam fonts)
],
```

**Locale choice.** The app's own UI strings are hardcoded English, so `en` is the base.
`ml` (Malayalam) is added because this app is clearly Malayalam-focused (three bundled
Malayalam fonts, Malayalam-safe avatar/section logic). Listing `ml` makes Flutter serve
Malayalam Material localizations when the device locale is Malayalam; the app's own English
strings are unaffected. If you prefer the bare standard minimum, we drop the `ml` line and
keep only `en`.

## Verification
- `flutter pub get`
- `flutter analyze` (expect no new errors from this change)

## After implementation
Write a change log to `change_log/` referencing this plan.
