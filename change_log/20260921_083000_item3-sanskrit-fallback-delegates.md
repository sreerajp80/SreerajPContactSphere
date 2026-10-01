# Item 3 — Sanskrit framework localization delegates

**Plan:** `plans/20260921_064300_item3-sanskrit-fallback-delegates.md`
**Status:** done.

---

## What this change did

`flutter_localizations` ships the three Global localization delegates for many locales, but not for
Sanskrit (`sa`). Without a shim, the first Material widget that needs framework strings under
`Locale('sa')` — a date picker, dialog buttons, the text-selection menu, `Scaffold` semantics
labels — asserts at runtime. Engineering standard §8.3.1 calls this the single most likely Sanskrit
runtime failure.

The app now registers three small delegates that answer only for `sa` and serve the **English**
framework strings. English, not Hindi, so no Hindi text can leak into a Sanskrit UI. The app's own
strings still come from `AppLocalizations` (`lib/l10n/app_sa.arb`), so the visible text stays
Sanskrit while the built-in widgets work.

---

## Files added

| File | What it is |
|---|---|
| `lib/l10n/sa_material_localizations.dart` | `SaMaterialLocalizationsDelegate`, `SaCupertinoLocalizationsDelegate` and `SaWidgetsLocalizationsDelegate`. Each returns `isSupported` only for `locale.languageCode == 'sa'`, loads the matching Global delegate with `const Locale('en')`, and returns `false` from `shouldReload`. Written exactly to the §8.3.1 shape. |
| `test/l10n/sanskrit_delegate_test.dart` | Five widget tests (see below). |

## Files changed

| File | Change |
|---|---|
| `lib/main.dart` | Imported the new file and added the three `Sa*` delegates to `localizationsDelegates`, placed after `AppLocalizations.delegate` and **before** the three Global delegates. Added a comment saying why the order matters. |
| `plans/20260921_064300_item3-sanskrit-fallback-delegates.md` | Status line flipped to completed. |

Nothing else changed. `supportedLocales` is still `[Locale('en'), Locale('ml')]` — adding `sa`
belongs to item 1 (`plans/20260921_064100_item1-three-mandatory-languages.md`).

---

## Why the order matters

The Sanskrit delegates sit ahead of the Global ones because `Localizations` asks each delegate in
list order and takes the first that reports the locale supported. Behind the Global delegates the
`Sa*` ones would not be reached for any locale the Global set already claims, which is the failure
mode the plan warned about.

---

## Tests

`test/l10n/sanskrit_delegate_test.dart` takes its delegate list out of the **real** app — it pumps
`SmartContactsApp` and reads `localizationsDelegates` off the `MaterialApp` — so the tests cannot
drift from the shipping wiring. Sanskrit is not yet in `supportedLocales`, so each test hands `sa`
to a `MaterialApp` of its own using that same list.

| Test | What it proves |
|---|---|
| the app registers each Sanskrit delegate before the Global one | `AppLocalizations.delegate` is first, all three `Sa*` delegates are registered, and each sits before its Global counterpart. |
| a date picker and a dialog open under `sa` without throwing | The mandatory §8.3.1 test. Both open, no exception, and the locale really is `sa`. |
| the text-selection menu builds under `sa` | A long press on a filled `TextField` raises the selection toolbar with no exception. |
| `sa` resolves the English framework strings, never Hindi | `okButtonLabel`, `cancelButtonLabel`, `pasteButtonLabel` and `datePickerHelpText` all equal the values loaded from the Global delegate for `en`; `CupertinoLocalizations` and `WidgetsLocalizations` resolve too; and `AppLocalizations.of(context).localeName` is still `sa`. |
| the Sanskrit delegates do not steal `en` or `ml` | Under each of those locales the framework strings still match that locale's own Global values, and the date picker still opens. |

The ordering test was checked against the failure it guards: with the `Sa*` delegates moved after
the Global ones, it fails with the "must come before the Global one" message. The order was
restored before the run below.

### Results

- `flutter analyze` — No issues found.
- `flutter test` — 545 passed, 2 skipped (both pre-existing skips, unrelated).
