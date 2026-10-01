# Item 1 — Sanskrit (`sa`) as the third supported language

**Plan:** `plans/20260921_064100_item1-three-mandatory-languages.md`
**Status:** done.

---

## What this change did

The app now declares the three mandatory languages from engineering standard §8.3, in the fixed
order `en`, `ml`, `sa`. Item 3 (the Sanskrit framework delegates) was already in place, so adding
`Locale('sa')` does not crash Material widgets.

Two gaps that come with Devanagari were closed as well:

- **Dates under Sanskrit.** The `intl` package has no date data for `sa`, so
  `DateFormat(..., 'sa')` throws. A new helper, `formattingLocale(...)`, gives `intl` English
  patterns for Sanskrit (never Hindi) while the UI text stays Sanskrit.
- **Devanagari font.** None of the bundled fonts had Devanagari glyphs. Noto Sans Devanagari is now
  bundled and set as a font fallback in the theme.

---

## Files added

| File | What it is |
|---|---|
| `lib/l10n/formatting_locale.dart` | `formattingLocale(Locale)`. Tries the full locale (`en_IN`), then the language (`ml`), then returns `en`. |
| `assets/fonts/NotoSansDevanagari-Regular.ttf`, `assets/fonts/NotoSansDevanagari-Bold.ttf` | Noto Sans Devanagari static Regular (400) and Bold (700), from the official Noto project release. |
| `assets/fonts/OFL-NotoSansDevanagari.txt` | SIL Open Font License 1.1 text for the font. |
| `test/l10n/formatting_locale_test.dart` | Seven tests (see below). |

## Files changed

| File | Change |
|---|---|
| `lib/main.dart` | `supportedLocales` is now `[en, ml, sa]`. `localeListResolutionCallback` now returns `sa` for a Sanskrit device locale. Before this, a `sa` device fell through to `en`. Regional English (`en_IN`, `en_GB`) is still kept. |
| `lib/theme/app_theme.dart` | New constant `kDevanagariFontFamily`. `ThemeData` now sets `fontFamilyFallback: [kDevanagariFontFamily]`, so Devanagari text uses the bundled font under Roboto, Manjari, Anek Malayalam and Noto Sans Malayalam. |
| `pubspec.yaml` | Declares the `Noto Sans Devanagari` font family. It is only a fallback, not one of the fonts the user can pick. |
| `lib/screens/audit_entry_detail_screen.dart` | The date line uses `formattingLocale(...)`. |
| `lib/screens/audit_log_screen.dart` | The day header and entry time use `formattingLocale(...)` through a small `_formatLocale` getter. |
| `lib/screens/call_history_screen.dart` | The day bucket (weekday / date) and time of day use `formattingLocale(...)` through a `_formatLocale` getter. |
| `lib/widgets/post_call_feedback_sheet.dart` | The follow-up date and time label uses `formattingLocale(...)`. |
| `test/l10n/sanskrit_delegate_test.dart` | Header comment only. It no longer says `sa` is missing from `supportedLocales`. |
| `CLAUDE.md`, `AGENTS.md` | "Localization rules" now names all three locales, the Devanagari fallback font, the `Sa*` delegates and the `formattingLocale` rule. `AGENTS.md` carries the same section, so it was updated too. |

`docs/architecture.md` holds no locale list, so it did not need a change.

`dart format` also re-wrapped some older lines in the four screen and widget files above that were
not formatted before. Only the layout changed.

---

## `DateFormat` / `NumberFormat` survey (plan step 1)

There are no `NumberFormat` calls in `lib/`. Every `DateFormat` call:

| Call site | Result |
|---|---|
| `lib/screens/audit_entry_detail_screen.dart` — `'d MMMM yyyy, h:mm a'` | Routed through `formattingLocale`. |
| `lib/screens/audit_log_screen.dart` — `DateFormat.jm()` and `'d MMMM yyyy'` | Routed through `formattingLocale`. |
| `lib/screens/audit_log_screen.dart` — `'yyyy-MM-dd'` | **Left as is.** It is an internal key that groups entries by day, and the user never sees it. It must not change with the language. |
| `lib/screens/call_history_screen.dart` — `'EEEE'`, `'MMM d, yyyy'`, `DateFormat.jm()` | Routed through `formattingLocale`. |
| `lib/widgets/post_call_feedback_sheet.dart` — `'EEE, MMM d · h:mm a'` | Routed through `formattingLocale`. |
| `lib/services/caller_context_service.dart` — `'EEEE'` in "Birthday next Monday" | **Left as is.** A service has no `BuildContext`, and the sentence around the weekday is still English. A Malayalam weekday inside an English sentence would read badly. It stays on intl's default (`en_US`), which never throws under `sa`. It should move to `formattingLocale` when item 2 translates the sentence. |
| `lib/services/pre_call_summary_service.dart` — `DateFormat.jm()` in "5:30 PM (Asia/Kolkata)" | **Left as is**, for the same reason. |
| `lib/screens/blocked_numbers_screen.dart` | Already uses `MaterialLocalizations.formatShortDate`, not `DateFormat`. No change. |

Nothing in the app sets `Intl.defaultLocale`, so the calls that were left as is still format with
`en_US` whatever the UI language is.

---

## Where this differs from the plan

- **Underscore locale name, not the language tag.** The plan's sketch used
  `locale.toLanguageTag()` (`en-IN`). `intl` keys its date data by `en_IN`, so the tag never matches,
  and every regional English user would silently drop to plain `en`. The helper uses
  `locale.toString()` and then tries the bare language code.
- **Safe before date data is loaded.** `DateFormat.localeExists` throws for any locale other than
  `en_US` until the date data is loaded. The Global Material delegate loads it, so this never happens
  in the running app, but it can happen in a plain unit test. In that case the helper returns
  `en_US`, the only locale `intl` can use at that point.
- **Font subset.** Following "subset where practical", the font was cut down with `fonttools` to the
  Devanagari, Devanagari Extended and Vedic Extensions blocks, plus ZWJ / ZWNJ, the dotted circle,
  the rupee sign and spaces. All OpenType layout features were kept. Latin is dropped because the
  primary font supplies it. This saves only about 15 KB per file (roughly 243 KB to 228 KB for
  Regular, 250 KB to 236 KB for Bold), because nearly all the glyphs are Devanagari.
- **Services left alone.** See the survey above.

---

## Tests

`test/l10n/formatting_locale_test.dart`:

| Test | What it proves |
|---|---|
| Sanskrit falls back to English, never Hindi | `formattingLocale(sa)` is `en` and does not start with `hi`. |
| English and Malayalam keep their own locale | `en` gives `en`, `ml` gives `ml`. |
| regional English keeps its region | `en_IN` and `en_GB` pass through unchanged. |
| the result always formats a date without throwing | `DateFormat.yMMMMd` works for `en`, `en_IN`, `ml` and `sa`. |
| the app declares en, ml and sa in that fixed order | Read off the real `SmartContactsApp`. |
| a Sanskrit device resolves to sa, regional English is kept | Exercises the real `localeListResolutionCallback`: `sa_IN` gives `sa`, `hi_IN` then `sa` gives `sa`, `en_IN` stays `en_IN`, `ml_IN` gives `ml`, and `hi_IN` alone gives `en`. |
| a date-formatting screen builds under sa without throwing | Pumps `AuditEntryDetailScreen` under `sa` with the app's delegates. No exception, and the date reads `21 September 2026` (English month name). |

### Results

- `flutter analyze` — No issues found.
- `flutter test` — 552 passed, 2 skipped (both skips were already there and are unrelated).

---

## Manual check still needed (standard §8.3.3)

A widget test cannot check how the font renders. Before release, open every screen in `ml` and in
`sa` on a clean device. Confirm there are no blank boxes, no clipped tops or bottoms of letters,
and no overflow. Today the only way to see the app in `sa` is a device set to Sanskrit. The in-app
picker comes in item 4.
