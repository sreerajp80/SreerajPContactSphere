# Date input should follow the system (device) format

**Status:** completed

## The issue

When entering dates in contact fields (Date of birth, Anniversary, "Meetiversary"),
the date picker's keyboard-entry mode forces the US format **MM/DD/YYYY**, even on
devices whose region uses DD/MM/YYYY (e.g. English–India, English–UK).

### Why it happens

- The date fields open Flutter's built-in `showDatePicker`
  ([lib/screens/add_edit_contact_screen.dart](../lib/screens/add_edit_contact_screen.dart#L747)).
- Its keyboard-input mode formats and parses dates with
  `MaterialLocalizations.formatCompactDate`, which uses the **app's resolved locale**.
- In [lib/main.dart](../lib/main.dart#L523), `MaterialApp` declares:
  ```dart
  supportedLocales: const [Locale('en'), Locale('ml')],
  ```
  with **no country codes** and **no locale-resolution callback**.
- Flutter's default resolution strips the device's country code. So a device set to
  `en_IN` / `en_GB` resolves to bare `en`, which `intl` treats as **US English**,
  giving MM/DD/YYYY.

The on-screen display of a chosen date is unaffected — `_fmtDate` already shows
`14 Jul 2026` style ([add_edit_contact_screen.dart:2432](../lib/screens/add_edit_contact_screen.dart#L2432)).
Only the *typed-entry* format is wrong.

## Files to change

- `lib/main.dart` — the `MaterialApp` locale configuration only.

## The fix

Add a `localeListResolutionCallback` to the `MaterialApp` that **preserves the
device's country code for English** (and keeps `ml` for Malayalam). This makes the
built-in date picker use the device's regional date format, while all app strings
stay English.

```dart
supportedLocales: const [Locale('en'), Locale('ml')],
// Keep the device's regional English (e.g. en_IN, en_GB) so built-in widgets
// like the date picker use the system's date format. App strings stay English.
localeListResolutionCallback: (deviceLocales, supportedLocales) {
  if (deviceLocales != null) {
    for (final locale in deviceLocales) {
      if (locale.languageCode == 'en') return locale; // keep en_IN / en_GB / ...
      if (locale.languageCode == 'ml') return const Locale('ml');
    }
  }
  return const Locale('en');
},
```

### Why this works

- `GlobalMaterialLocalizations` / `intl` ship date patterns for English regional
  variants (`en_IN`, `en_GB`, `en_AU`, ...). Returning the full device locale lets
  `formatCompactDate` use the region's pattern (DD/MM/YYYY where that's the norm).
- Unknown `en_XX` variants gracefully fall back to English text, so no app strings break.
- Malayalam devices still get `ml` for Material widgets, unchanged.

## Verification

1. `flutter analyze` — no new issues.
2. On a device/emulator set to **English (India)** or **English (United Kingdom)**:
   open Add/Edit contact → tap a date field → switch the picker to keyboard input →
   confirm the hint/format is **DD/MM/YYYY**.
3. On a device set to **English (United States)**: confirm it still shows MM/DD/YYYY.
4. Confirm the chosen date still displays as `14 Jul 2026` on the field.

## Risk

Very low. Single, additive change to locale resolution; no schema, data, or UI-string
changes. Fallbacks keep behaviour safe for any locale.
