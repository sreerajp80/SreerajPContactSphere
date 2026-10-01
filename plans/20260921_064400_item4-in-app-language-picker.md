# Item 4 — In-app language picker in Settings

**Status:** done — option A chosen; see change_log/20260921_100000_item4-in-app-language-picker.md

Part of a five-plan set that brings this project in line with the updated
`docs/guidelines` submodule (commit `eb4b462`). Run order: 5th and last — it needs the ARB strings
(item 2), the Sanskrit delegates (item 3) and the third locale (item 1) already in place.

## The issue

Engineering standard §8.4 makes an in-app language picker mandatory: "The language is the user's
choice, not the device's alone."

This project has no such setting. The locale follows the device only, resolved by
`localeListResolutionCallback` at `lib/main.dart` line 1001.

§8.4 sets a required resolution order:

1. the language the user saved inside the app, if any;
2. otherwise the system locale, when its language code is `en`, `ml` or `sa`;
3. otherwise English.

And these rules:

- Persist across restarts in `SharedPreferences` under key `app_language`, values
  `system` | `en` | `ml` | `sa`.
- Read **before the first frame**, so the app never flashes the wrong language at startup.
- Apply **immediately and app-wide**, without restarting and without popping the user back to the
  home screen.
- Live in Settings, offer **System default** as an explicit first option, and list each language in
  its own script:

  | Option | Shown as |
  |---|---|
  | System default | localized label |
  | English | `English` |
  | Malayalam | `മലയാളം` |
  | Sanskrit | `संस्कृतम्` |

- Mark the current selection visibly (radio or check), and give the settings row a screen-reader
  label describing the current value.
- Keep locale state in **one place**, with `MaterialApp.locale` driven by it. Screens must not read
  the language from anywhere else.

## A conflict to resolve first

§8.4's reference implementation is a standalone `LocaleController extends ChangeNotifier`. This
project already has `AppSettings extends ChangeNotifier` (`lib/state/app_settings.dart` line 229),
provided at the app root, which owns theme, accent colour, fonts and SIM choices and follows a
settled `SharedPreferences` load/save pattern.

Two options:

| Option | For | Against |
|---|---|---|
| **A. Separate `LocaleController`** | Matches the standard's reference code exactly; single-responsibility; locale state is unambiguous | A second provider at the root; two places that read `SharedPreferences` at startup |
| **B. Add locale to `AppSettings`** | One settings provider, matching this project's existing architecture; one startup read | Diverges from the reference snippet; `AppSettings` grows further |

**I recommend option A**, a separate `LocaleController`. §8.4 says locale state must live in one
place and that screens must not read the language from anywhere else; a dedicated controller makes
that boundary obvious, and it matches the standard's wording rather than only its spirit. I will
not implement either until you pick.

Note the startup constraint: `AppSettings.load()` (line 607) is already async, and today
`runApp(const SmartContactsApp())` is called **without awaiting it** — `lib/main.dart` deliberately
paints first so a dialer opens instantly. §8.4 requires the language to be read before the first
frame. That means one small `await SharedPreferences.getInstance()` in `main()` before `runApp`,
reading only `app_language`. I will keep that read to the single key so the "paint first" behaviour
is preserved.

## Files to be changed

| File | Change |
|---|---|
| `lib/state/locale_controller.dart` | New (option A) — the §8.4 controller |
| `lib/main.dart` | Read `app_language` before `runApp`; provide the controller; drive `MaterialApp.locale`; add the §8.4 `localeResolutionCallback` |
| `lib/screens/language_settings_screen.dart` | New — the picker screen |
| `lib/screens/settings_screen.dart` | New row linking to the picker, showing the current value |
| `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb` | Keys for the settings row, screen title and the "System default" label. The four language names are endonyms and stay untranslated, so they go in the parity test's `sameAsEnglishAllowed` set |
| `test/state/locale_controller_test.dart` | New |
| `test/screens/language_settings_screen_test.dart` | New |
| `CLAUDE.md`, `docs/architecture.md` | Document the new state holder and the setting |

## The plan for the fix

1. Confirm option A or B with you.
2. Add `LocaleController` per §8.4: `prefKey = 'app_language'`, `systemValue = 'system'`,
   `supported = ['en', 'ml', 'sa']`, a nullable `Locale? locale` where `null` means follow the
   system, `bool get isSystem`, and `Future<void> setLanguage(String)` that saves and calls
   `notifyListeners()`.
3. In `main()`, read the one pref key, build the controller, and pass it into the app. Keep the
   existing paint-first ordering for everything else.
4. Provide the controller at the root alongside `AppSettings`, and set `MaterialApp.locale` from it.
5. Add the §8.4 `localeResolutionCallback`, which matches the device language against the supported
   list and falls back to `Locale('en')`.
6. Reconcile with the existing `localeListResolutionCallback` at line 1001, which preserves regional
   English (`en_IN`, `en_GB`) for date formats. Only one of the two callbacks can be authoritative —
   keep the regional-English behaviour while honouring a saved choice. This is the fiddliest part of
   the change and the change log will record exactly how it was resolved.
7. Build the picker screen: a radio list with System default first, then `English`, `മലയാളം`,
   `संस्कृतम्`, each in its own script, the current one marked, each row carrying a semantics label.
8. Add the settings row showing the current value as its subtitle.
9. Run `flutter analyze` (zero warnings) and `flutter test`.

## Tests

- `LocaleController`: defaults to system when nothing is saved; restores a saved `ml`; ignores a
  junk saved value and falls back to system; `setLanguage` persists and notifies.
- Picker widget test: all four options render, the current one is marked, tapping one changes
  `MaterialApp.locale` without a restart, and the user stays on the picker screen rather than being
  popped home.
- Resolution order test: a saved choice beats the device locale; with no saved choice an `ml` device
  gets `ml`; a device set to a fourth language (say `fr`) gets `en`.
- Per §8.7, the picker's own widget test runs in all three locales.

## Risk

Medium. The logic is small, but three things are easy to get wrong:

- **Startup flash** — if the pref is read after the first frame the user sees English then a switch.
  Covered by reading it before `runApp`.
- **Callback conflict** — `localeResolutionCallback` and the existing `localeListResolutionCallback`
  both want to decide. Getting this wrong silently breaks either the saved choice or the regional
  English date formats.
- **Losing the user's place** — §8.4 forbids popping back to home on change. Rebuilding from a
  provider at the root satisfies this, but it must be verified, not assumed.

## Explicitly out of scope

- Any translation work (item 2).
- Changing the Android system-level per-app language setting (`android:localeConfig`). The standard
  does not require it here; if you want it, it needs its own plan.
