# Item 1 — Add Sanskrit (`sa`) as a third supported language

**Status:** completed (see `change_log/20260921_090000_item1-sanskrit-third-locale.md`)

Part of a five-plan set that brings this project in line with the updated
`docs/guidelines` submodule (commit `eb4b462`).

| Plan | Item | Run order |
|---|---|---|
| `plans/20260921_064500_item5-bundle-language-split.md` | Gradle language split | 1st (independent) |
| `plans/20260921_064200_item2-arb-string-externalization.md` | ARB + string externalization | 2nd (foundation) |
| `plans/20260921_064300_item3-sanskrit-fallback-delegates.md` | Sanskrit framework delegates | 3rd |
| **this plan** | Third locale `sa` | **4th** |
| `plans/20260921_064400_item4-in-app-language-picker.md` | Settings language picker | 5th |

**This plan must not be implemented before item 3.** Adding `Locale('sa')` to `supportedLocales`
without the Sanskrit framework delegates throws at runtime the first time a Material widget needs
framework strings (date picker, dialog buttons, text-selection menu). Standard §8.3.1 calls this
"the single most likely Sanskrit runtime failure".

## The issue

Engineering standard §8.3 now fixes three mandatory languages for every app:

| Locale | Language | Script | Role |
|---|---|---|---|
| `en` | English | Latin | Template ARB, ultimate fallback |
| `ml` | Malayalam | Malayalam | Full UI translation |
| `sa` | Sanskrit | Devanagari | Full UI translation |

This project declares only two. `lib/main.dart` line 996 reads:

```dart
supportedLocales: const [Locale('en'), Locale('ml')],
```

`CLAUDE.md` also states "Supported locales: `en` (base) and `ml` (Malayalam)".

Two further gaps follow from adding Devanagari:

- **No Devanagari font is bundled.** `pubspec.yaml` bundles Manjari, Anek Malayalam and Noto Sans
  Malayalam. All three cover Latin and Malayalam only. Standard §8.3.3 requires the app to either
  bundle a font covering Devanagari or declare an explicit `fontFamilyFallback` chain and verify
  rendering on a clean device. A missing glyph renders as a blank box.
- **`intl` has no `sa` data.** `DateFormat.yMMMMd('sa')` throws. §8.3.2 requires a
  `formattingLocale(...)` helper that falls back to English patterns while UI text stays Sanskrit.
  The fallback must be English, never Hindi.

## Files to be changed

| File | Change |
|---|---|
| `lib/main.dart` | Add `Locale('sa')` to `supportedLocales`; keep the existing `localeListResolutionCallback` behaviour for regional English and extend it to handle `sa` |
| `lib/l10n/formatting_locale.dart` | New — the `formattingLocale(Locale)` helper from §8.3.2 |
| `pubspec.yaml` | Bundle a Devanagari-covering font (Noto Sans Devanagari, SIL OFL) under `flutter: fonts:` |
| `assets/fonts/NotoSansDevanagari-Regular.ttf`, `-Bold.ttf` | New font binaries |
| `assets/fonts/OFL-NotoSansDevanagari.txt` | New — licence text, per §17.4 font-licensing rules |
| `lib/theme/app_theme.dart` | Add `fontFamilyFallback` so Devanagari resolves under every bundled font family |
| Call sites of `DateFormat(...)` / `NumberFormat(...)` | Route the locale argument through `formattingLocale(...)` |
| `CLAUDE.md` | Update the "Localization rules" section to name all three locales |
| `docs/architecture.md` | Update any locale list it carries |

A survey of `DateFormat` / `NumberFormat` call sites is the first implementation step; the exact
file list goes into the change log.

## The plan for the fix

1. Survey every `DateFormat(`, `DateFormat.`, and `NumberFormat(` call site in `lib/`. Record the
   list.
2. Add `lib/l10n/formatting_locale.dart` with the §8.3.2 helper:

   ```dart
   /// Locale to hand to `intl`. Sanskrit has no CLDR data, so dates and numbers
   /// are formatted with English patterns while the UI text stays Sanskrit.
   String formattingLocale(Locale locale) =>
       DateFormat.localeExists(locale.toLanguageTag())
           ? locale.toLanguageTag()
           : 'en';
   ```

3. Change every surveyed call site to pass `formattingLocale(Localizations.localeOf(context))`
   instead of a hard-coded or implicit locale. Never fall back to `hi`.
4. Source Noto Sans Devanagari Regular and Bold (SIL OFL), subset where practical, add to
   `assets/fonts/` with the licence file, and declare them in `pubspec.yaml`.
5. In `lib/theme/app_theme.dart`, add `fontFamilyFallback` to the text theme so a Devanagari
   glyph resolves even when the user has picked Manjari or Anek Malayalam in Appearance.
6. Add `Locale('sa')` to `supportedLocales` in `lib/main.dart`, in the fixed order
   `en`, `ml`, `sa`.
7. Review `localeListResolutionCallback` at `lib/main.dart` line 1001. Its current job is to keep
   regional English (`en_IN`, `en_GB`) instead of collapsing to bare `en`. Confirm it does not
   swallow a `sa` device locale, and extend it if it does.
8. Update `CLAUDE.md` and `docs/architecture.md` to list all three locales.
9. Run `flutter analyze` (zero warnings) and `flutter test`.

## Tests

- Unit test for `formattingLocale`: returns `'en'` for `Locale('sa')`, returns the tag for
  `Locale('en')` and `Locale('ml')`.
- Widget test: pump the app with `locale: Locale('sa')` and assert a date-formatting screen builds
  without throwing.
- Font rendering cannot be asserted in a widget test. It goes on the manual release checklist
  (§8.3.3): open every screen in `ml` and in `sa` on a clean device, confirm no blank boxes, no
  clipped ascenders or descenders, no overflow.

## Risk

Medium. Adding a locale is small, but the Devanagari font adds APK weight and the `intl` fallback
touches every date and number the user sees. A missed `DateFormat` call site throws only when a
user actually switches to Sanskrit, so the survey in step 1 must be exhaustive.

## Explicitly out of scope

- Translating any string (item 2).
- The Sanskrit framework delegates (item 3) — a hard prerequisite, planned separately.
- The in-app picker (item 4).
