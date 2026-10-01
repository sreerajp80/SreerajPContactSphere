# Item 4 — In-app language picker in Settings

**Plan:** `plans/20260921_064400_item4-in-app-language-picker.md`
**Status:** done.

---

## What this change did

The user can now choose the app language inside the app (engineering standard §8.4). The phone
language is no longer the only thing that decides it. Settings has a new **Language** row. It opens a
picker with four options: System default, `English`, `മലയാളം`, `संस्कृतम्`.

## Decision: option A (a separate `LocaleController`)

The plan offered two options. Option A was the recommended one and is the one built. The app
language lives in its own `LocaleController`, not inside `AppSettings`. Two reasons:

- §8.4 says locale state must live in one place. A dedicated class makes that boundary clear.
- The language must be read **before** the first frame. `AppSettings.load()` runs **after** the
  first frame (the dialer paints first on purpose). Keeping the two apart lets `main()` read only
  the one language key before `runApp`, so the "paint first" behaviour stays.

## Files changed

| File | Change |
|---|---|
| `lib/state/locale_controller.dart` | New. `LocaleController`: key `app_language`, values `system` / `en` / `ml` / `sa`. `null` locale means "follow the system". An unknown saved value is treated as `system`. Also holds `LocaleController.resolve`, the one locale resolver. |
| `lib/main.dart` | `main()` reads `app_language` before `runApp`. If that read fails, it logs a warning (no personal data) and follows the system. `SmartContactsApp` takes an optional `localeController`. A `MultiProvider` supplies it next to `AppSettings`. `MaterialApp.locale` is driven by it. The old inline `localeListResolutionCallback` now calls `LocaleController.resolve`. |
| `lib/screens/language_settings_screen.dart` | New. The picker: a `RadioGroup` with `RadioListTile` rows, System default first, each language name in its own script. The current choice is marked, and a screen reader announces it as checked. Each language name is tagged with its own locale, so a screen reader speaks it in that language. |
| `lib/screens/settings_screen.dart` | New **Language** row above Appearance. The subtitle shows the current value. A screen reader hears one label, for example "Language, currently മലയാളം". `_SettingsCard` got an optional `semanticsLabel` for this. |
| `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb` | New keys: `titleLanguage`, `labelSystemDefault`, `descLanguageSystemDefault`, `semanticsLanguageSetting`, and the three language names `languageNameEn` / `languageNameMl` / `languageNameSa`. Generated `app_localizations*.dart` files were rebuilt with `flutter gen-l10n`. |
| `test/l10n/translation_parity_test.dart` | The three language-name keys are added to `sameAsEnglishAllowed`. They are names of languages written in their own script, so they read the same in every language. |
| `test/state/locale_controller_test.dart` | New. 18 tests. |
| `test/screens/language_settings_screen_test.dart` | New. 11 tests, run under `en`, `ml` and `sa`. |
| `CLAUDE.md`, `AGENTS.md`, `docs/architecture.md` | Document `LocaleController`, the picker, and the single resolver. `AGENTS.md` mirrors `CLAUDE.md`, so it got the same edit. |

## How the callback conflict was resolved (plan step 6)

The plan flagged this as the hardest part. Flutter asks `localeListResolutionCallback` first. A
`localeResolutionCallback` is only asked if the first one returns `null`. So only one resolver can
really decide. The app keeps **only** `localeListResolutionCallback` and does not add the §8.4
reference `localeResolutionCallback`.

This works because of how Flutter calls the resolver:

- When `MaterialApp.locale` is set (the user saved a language), Flutter passes `[savedLocale]`.
- When it is `null` (System default), Flutter passes the device's language list.

`LocaleController.resolve(preferred, deviceLocales)` then applies the §8.4 order:

1. The first entry of `preferred` whose language is `en`, `ml` or `sa`. So a saved choice always wins.
   With no saved choice, the first supported device language wins.
2. Otherwise, English.

Regional English is kept in both cases. If the result is English and the device has a regional
English (`en_IN`, `en_GB`), that regional locale is returned. Without it, `intl` would treat bare
`en` as US English. So the date picker keeps the phone's date format, **even when English is picked
in the app**. The old callback could not do that, because it never saw a saved choice.

The existing test `a Sanskrit device resolves to sa, regional English is kept` in
`test/l10n/formatting_locale_test.dart` reads the resolver off the real app. It still passes
unchanged.

## Checks for the three risks in the plan

- **Startup flash**: the key is read in `main()` before `runApp`. A test pumps the real
  `SmartContactsApp` with a saved `ml` and checks that the very first frame is already in `ml`.
- **Callback conflict**: resolved as above. Covered by 7 resolver tests: saved beats device;
  `ml` device gets `ml`; `fr` device gets `en`; first supported device language wins; regional
  English is kept; English picked in the app keeps the device region; a null list gives `en`.
- **Losing the user's place**: a widget test pushes the picker on top of a home route. It taps
  `മലയാളം` and checks four things: `MaterialApp.locale` is now `ml`, the title redrew in Malayalam,
  the picker is still on top, and the home route is hidden. It then switches back to System default
  and checks the same.

## Verification

- `flutter analyze`: no issues.
- `flutter test`: all 581 tests pass (2 skipped, as before).

## Notes

- Out of scope, as the plan says: Android's system-level per-app language setting
  (`android:localeConfig`), and translating the rest of the Settings screen. The other Settings
  rows are still English literals until item 2 converts that screen.
- During this work, `dart format` was run on the whole `lib/` folder by mistake and reformatted 70
  unrelated files. That was fully reverted. `git diff` shows no change to any of those files.
