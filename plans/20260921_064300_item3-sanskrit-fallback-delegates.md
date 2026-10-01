# Item 3 — Sanskrit framework localization delegates

**Status:** completed (see `change_log/20260921_083000_item3-sanskrit-fallback-delegates.md`)

Part of a five-plan set that brings this project in line with the updated
`docs/guidelines` submodule (commit `eb4b462`). Run order: 3rd — after the ARB infrastructure
(`plans/20260921_064200_item2-arb-string-externalization.md`, at least phase 2a) and **before**
item 1 adds `Locale('sa')` to `supportedLocales`.

## The issue

`flutter_localizations` ships `GlobalMaterialLocalizations`, `GlobalWidgetsLocalizations` and
`GlobalCupertinoLocalizations` for a long list of locales, **but not for `sa`**.

Adding `Locale('sa')` to `supportedLocales` without handling this throws at runtime the first time
a Material widget needs framework strings — a date picker, dialog buttons, the text-selection menu,
or `Scaffold` semantics labels. Standard §8.3.1 calls this "the single most likely Sanskrit runtime
failure".

The fallback must be **English, not Hindi**, so no Hindi text can ever leak into a Sanskrit UI.

This project currently registers only the three Global delegates, at `lib/main.dart` lines 991-995.

## Files to be changed

| File | Change |
|---|---|
| `lib/l10n/sa_material_localizations.dart` | New — three delegate classes for `MaterialLocalizations`, `CupertinoLocalizations` and `WidgetsLocalizations` |
| `lib/main.dart` | Register the Sanskrit delegates **before** the Global ones, and `AppLocalizations.delegate` first |
| `test/l10n/sanskrit_delegate_test.dart` | New — the widget test §8.3.1 makes mandatory |

## The plan for the fix

1. Create `lib/l10n/sa_material_localizations.dart` with the three delegates exactly as §8.3.1
   specifies. Each one reports `isSupported` for `locale.languageCode == 'sa'` and loads the
   English framework strings:

   ```dart
   class SaMaterialLocalizationsDelegate
       extends LocalizationsDelegate<MaterialLocalizations> {
     const SaMaterialLocalizationsDelegate();

     @override
     bool isSupported(Locale locale) => locale.languageCode == 'sa';

     @override
     Future<MaterialLocalizations> load(Locale locale) =>
         GlobalMaterialLocalizations.delegate.load(const Locale('en'));

     @override
     bool shouldReload(covariant LocalizationsDelegate old) => false;
   }
   ```

   The Cupertino and Widgets delegates follow the same shape.

2. Update the `localizationsDelegates` list in `lib/main.dart`. Order matters — the Sanskrit
   delegates must come before the Global ones so they win for `sa`:

   ```dart
   localizationsDelegates: const [
     AppLocalizations.delegate,
     SaMaterialLocalizationsDelegate(),
     SaCupertinoLocalizationsDelegate(),
     SaWidgetsLocalizationsDelegate(),
     GlobalMaterialLocalizations.delegate,
     GlobalWidgetsLocalizations.delegate,
     GlobalCupertinoLocalizations.delegate,
   ],
   ```

3. Keep the existing comment block at `lib/main.dart` lines 987-990 accurate — it currently says
   app strings are English and `ml` is listed only for Material widgets. That statement stops being
   true once item 2 lands, so update it in whichever plan lands last.
4. Run `flutter analyze` (zero warnings) and `flutter test`.

## Tests

§8.3.1 makes one test mandatory: pump the app with `locale: Locale('sa')`, open a date picker and a
dialog, and assert no exception is thrown. I will also assert:

- `MaterialLocalizations.of(context)` resolves under `sa` and returns English framework strings
  (for example the `okButtonLabel`).
- The text-selection menu builds under `sa`.
- The same screens still build under `en` and `ml`, so the new delegates have not stolen those
  locales.

## Risk

Low. Three small classes and one list reorder, with a test that directly covers the failure mode.

The one subtlety is delegate ordering: if the Sanskrit delegates are placed after the Global ones,
the Global delegates answer first, report `sa` unsupported, and the crash returns. The test covers
this.

## Explicitly out of scope

- Adding `Locale('sa')` to `supportedLocales` — item 1. Until that lands, these delegates are
  registered but never exercised outside the test.
- The `formattingLocale(...)` helper for `intl` — item 1, §8.3.2.
- Any translation work — item 2.
