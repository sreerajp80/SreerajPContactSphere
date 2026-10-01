# Item 2 — ARB localization: infrastructure and string externalization

**Status:** done — phase 2a done (see `change_log/20260921_073000_item2a-arb-infrastructure-pilot.md`); phase 2b done (see `change_log/20260921_110000_item2b-app-chrome-and-shared-widgets.md`); phase 2c done (see `change_log/20260921_140000_item2c-core-screens.md`); phase 2d done (see `change_log/20260921_170000_item2d-settings-screens.md`); phase 2e done (see `change_log/20260922_120000_item2e-secondary-screens.md`); phase 2f done (see `change_log/20260922_150000_item2f-help-articles.md`); phase 2g done (see `change_log/20260922_160000_item2g-app-config-and-about.md`)

Part of a five-plan set that brings this project in line with the updated
`docs/guidelines` submodule (commit `eb4b462`). Run order: 2nd, after the Gradle change
(`plans/20260921_064500_item5-bundle-language-split.md`) and before items 3, 1 and 4, all of which
depend on `AppLocalizations` existing.

> **This is by far the largest of the five plans. Read the size estimate before approving.**

## The issue

Engineering standard §8.2 requires every user-visible string to live in
`lib/l10n/app_en.arb`, `app_ml.arb` and `app_sa.arb`, read through `AppLocalizations.of(context)`.
A raw string literal in a widget is not allowed.

This project has none of that:

- no `l10n.yaml`
- no `lib/l10n/` directory
- no `.arb` files
- no `AppLocalizations` usage anywhere
- no `generate: true` in `pubspec.yaml`

`lib/main.dart` registers only the three Global delegates, so today `ml` localizes built-in Material
widgets alone. Every app string is an English literal inside a widget.

## Size estimate

Measured on the current tree. These are counts of candidate strings, not a promise of exact key
count — the real number is known only after extraction.

| Measure | Count |
|---|---|
| Dart files in `lib/` | 203 |
| Lines of Dart in `lib/` | ~62,200 |
| Files containing at least one candidate UI string | 86 |
| `Text(` call sites | ~1,057 |
| Candidate user-facing literals (Text, labels, hints, tooltips) | ~811 |
| Distinct `Text('…')` literals | ~276 |
| Screens | 55 |
| Shared widgets | 21 |
| Help-article screens (long prose) | 24, ~5,200 lines |

Heaviest files: `lib/screens/features_screen.dart` (48), `lib/screens/settings_screen.dart` (42),
`lib/screens/emergency_info_screen.dart` (35), `lib/screens/contact_detail_screen.dart` (34),
`lib/screens/help/help_home_screen.dart` (23), `lib/screens/contact_list_screen.dart` (23).

**Realistically this is on the order of 700–1,000 ARB keys, each needing a real Malayalam and a
real Sanskrit translation.** It cannot be done correctly in one pass, and it should not be one
change log. The phasing below breaks it into reviewable pieces.

## Translation quality is a human gate, not a code gate

Standard §8.5 sets quality rules I can follow but cannot self-certify:

- **Sanskrit must be Sanskrit, not Hindi in Devanagari.** No Hindi copulas, postpositions or verb
  endings (`है`, `करें`, `नहीं`, `सेटिंग्स`), no nukta letters.
- **Malayalam must be natural Malayalam**, not English transliterated into Malayalam script.
- §8.5.4 gives a standard UI glossary both languages must follow.

I will produce translations using that glossary and flag every term I am unsure of. **A fluent
human reader must review the Malayalam and the Sanskrit before release.** This plan does not claim
to replace that review, and the change log will list the flagged terms.

## Files to be changed

**New infrastructure**

| File | Purpose |
|---|---|
| `l10n.yaml` | Project root; `arb-dir: lib/l10n`, template `app_en.arb`, output class `AppLocalizations`, `nullable-getter: false`, `synthetic-package: false` |
| `lib/l10n/app_en.arb` | Template locale, every key with an `@key` description |
| `lib/l10n/app_ml.arb` | Malayalam, full key parity |
| `lib/l10n/app_sa.arb` | Sanskrit, full key parity |
| `pubspec.yaml` | Add `generate: true` under `flutter:` |
| `test/l10n/translation_parity_test.dart` | The §8.7 parity test, copied from the standard |

**Changed per phase:** the 86 files that hold user-visible strings, plus `lib/main.dart` to
register `AppLocalizations.delegate`.

**Also in scope per §8.7:** `assets/config/app_config.json` prose fields (`appName`, `description`,
`details`) must carry `{"en","ml","sa"}` entries, and `lib/core/config/config_service.dart` plus
`lib/screens/about_screen.dart` must resolve the active language. This changes the config schema, so
it gets its own phase.

## Phasing

Each phase is implemented, analyzed, tested and logged separately. I stop for approval between
phases.

| Phase | Scope | Rough key count |
|---|---|---|
| 2a | Infrastructure only: `l10n.yaml`, `generate: true`, three empty-but-valid ARB files, `AppLocalizations.delegate` in `lib/main.dart`, parity test wired into `flutter test`. One pilot screen converted end to end to prove the loop. | ~20 |
| 2b | App chrome: navigation labels, tab titles, app bar titles, common buttons, common error and empty states, shared widgets in `lib/widgets/` | ~120 |
| 2c | Core flows: contact list, contact detail, add/edit contact, dialer, call history, in-call | ~200 |
| 2d | Settings tree: all `*_settings_screen.dart` plus `lib/screens/settings/` | ~180 |
| 2e | Features, sync, backup, groups, tags, emergency info, duplicates, audit | ~180 |
| 2f | Help articles (24 screens, long prose) — the heaviest translation load, deliberately last | ~150 |
| 2g | `app_config.json` trilingual prose + About screen resolution | ~15 |

## The plan for the fix (per phase)

1. Extract the user-visible literals in the phase's files. Skip the §8.2 narrow exceptions: log and
   debug messages, exception messages never shown in the UI, asset paths, route names, map and JSON
   keys, `Semantics` test tags.
2. Name keys in `lowerCamelCase`, grouped by screen (`contactDetailTitle`, `contactDetailCallButton`).
3. Add each key to `app_en.arb` with an `@key` description. Where a key is chrome rather than prose,
   say so in the description, because §8.6 drives a length budget off it.
4. Add the same key to `app_ml.arb` and `app_sa.arb` with a real translation from the §8.5.4
   glossary. Never copy the English value across as a placeholder — the parity test fails on that.
5. Replace the literal with `AppLocalizations.of(context).<key>`.
6. Handle interpolation with ARB placeholders. Several existing strings interpolate
   (`'$mins minutes'`, `'$what copied'`, `'${entry.number} unblocked'`); each becomes a placeholder
   with a declared `type`.
7. Run `flutter gen-l10n`, then `flutter analyze` (zero warnings) and `flutter test`.
8. Write the phase change log.

## Tests

- `test/l10n/translation_parity_test.dart` from §8.7: identical key sets across the three ARB files,
  and no translated value equal to its English value.
- Per §8.7, widget tests for converted screens run in all three locales (`en`, `ml`, `sa`),
  asserting no overflow and no English leaking through.
- Existing widget tests that match on hard-coded English text will break as strings move. Each phase
  fixes the tests it breaks.

## Risk

High, mostly from volume rather than difficulty.

- **Test breakage:** any test asserting on literal English text breaks when that string moves.
- **Overflow:** Malayalam and Devanagari are wider and taller than Latin. §8.6 caps label length and
  §7.4 forbids hard-coded text container heights. Some layouts will need fixing; those fixes are in
  scope for the phase that surfaces them.
- **Translation correctness:** cannot be verified by CI. Human review gate, as above.
- **`context` availability:** some strings are built outside a widget context (services, notification
  text, exported file headers). Each needs either a passed-in `AppLocalizations` or a refactor. These
  are found during extraction and listed in the phase change log.

## Explicitly out of scope

- Adding `Locale('sa')` to `supportedLocales` (item 1) and the Sanskrit framework delegates
  (item 3). This plan creates `app_sa.arb` but does not switch the app to Sanskrit.
- The in-app language picker (item 4).
- Rewriting any UI layout beyond what overflow in `ml` or `sa` forces.
