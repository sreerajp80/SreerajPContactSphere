# Item 2, phase 2g — trilingual `app_config.json` and the About screen

**Plan:** `plans/20260921_064200_item2-arb-string-externalization.md` (phase 2g of 2a–2g)
**Status:** done. This is the last phase of item 2.

---

## What this phase did

The About screen now shows everything in the app's language. Its text comes from two places, and
both are now translated:

1. **`assets/config/app_config.json`** (the About screen's data). Its display values are now
   `{"en", "ml", "sa"}` maps, as §8.7 of the standard and §1.2 of the guideline require.
2. **The screen's own labels** ("About", "Version", "Build Date", and the row labels). These now
   come from the ARB files.

- **8 new keys**, so each ARB file now holds **1921 keys**. The three files have the same key set.

---

## Files changed

| File | Change |
|---|---|
| `assets/config/app_config.json` | New schema, explained below. |
| `lib/core/config/app_config.dart` | Adds `LocalizedText` (guideline §1.4); `appName`, `description` and each `details` value are now `LocalizedText`. |
| `lib/l10n/about_labels.dart` | **New.** `aboutDetailLabel` maps a config key to its ARB label; an unknown key is shown as it is. |
| `lib/screens/about_screen.dart` | Resolves every config value against the active language; all labels come from the ARB files; two fixes explained below. |
| `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb` | +8 keys: `aboutDetailAuthor`, `aboutDetailEmail`, `aboutDetailLicense`, `aboutDetailAiUsed`, `aboutDetailIdeUsed`, `labelVersion`, `labelBuildDate`, `labelVersionBuild`. The existing `titleAbout` is reused. |
| `lib/l10n/app_localizations*.dart` | Regenerated with `flutter gen-l10n`. |
| `test/l10n/translation_parity_test.dart` | The "app_config.json has all three languages" test is no longer skipped. |
| `test/l10n/about_screen_l10n_test.dart` | **New.** Tests described under Verification. |
| `test/build_metadata_test.dart` | Its `MaterialApp` now loads the localization delegates. |
| `plans/20260921_064200_item2-arb-string-externalization.md` | Status line updated. |

`lib/core/config/config_service.dart` is unchanged.

---

## The new config schema

```json
{
  "appName":     { "en": "…", "ml": "…", "sa": "…" },
  "description": { "en": "…", "ml": "…", "sa": "…" },
  "version": "…",
  "build": "…",
  "details": {
    "author":  { "en": "…", "ml": "…", "sa": "…" },
    "email":   "…",
    "license": { "en": "…", "ml": "…", "sa": "…" },
    "aiUsed":  { "en": "…", "ml": "…", "sa": "…" },
    "ideUsed": { "en": "…", "ml": "…", "sa": "…" }
  }
}
```

- The `details` keys were display labels in Title Case ("Author", "AI used"). They are now
  `lowerCamelCase` identifiers, and the visible label comes from the ARB key
  `aboutDetail<Key>`, as guideline §1.6 requires. The parity test checks that every detail key has
  its ARB label.
- The email address stays a plain string: it reads the same in every language.
- The app name, author and tool names are transliterated into Malayalam and Sanskrit, as guideline
  §1.2 requires for those fields.
- A value that is still a plain string, or a language missing from a map, falls back to English
  (`LocalizedText.resolve`), so an older or partly filled config still shows something.

---

## Two fixes on the About screen

### Long values no longer break the row

Each row put its value in the `ListTile`'s `trailing` slot. In Sanskrit, the "AI used" value is
long enough to take the whole row width, and the row then could not be laid out at all (an
assertion, not just an overflow). The value now sits under the label, in `subtitle`, where it can
wrap. This is also how the guideline's reference About screen lays out its rows.

### The screen can take a config loader in tests

`AboutScreen` has a new optional `configService` parameter. The app passes nothing and gets the
same `ConfigService()` as before. Tests pass a `ConfigService` with an injected asset loader
(already supported, guideline §1.5), so they can read the real config file without the asset
bundle.

---

## Not in this phase

The guideline's §1.7 "Made with ❤️ from India" badge (`madeWithLove`, `madeWithLoveA11y`, and
`lib/widgets/made_with_love.dart`) is not on the About screen yet. It is not part of item 2's plan,
so it was not added here. The parity test's `madeWithLove` check passes today only because the key
does not exist. Adding the badge would be a small separate change.

---

## Sanskrit gate

The gate finds nothing in `lib/l10n/app_sa.arb` or `assets/config/app_config.json`.

---

## Verification

- `flutter analyze` → No issues found.
- `flutter test` (full run after phases 2f and 2g) → 738 passed, 1 skipped, 1 failed. The failure
  was `test/t9_dialing_help_screen_test.dart`, which had no localization delegates (a phase 2f
  side effect, fixed as listed in the 2f change log). After the fix that test passes, and
  `flutter analyze` is still clean.
- `test/l10n/about_screen_l10n_test.dart` (new, 7 tests):
  - `LocalizedText`: a plain string reads the same in every language; a map resolves the exact
    language, then English; a wrong type falls back instead of throwing.
  - The real config file parses, with a translated app name and a plain email.
  - The About screen with the real config, in `en`, `ml` and `sa`, on a 360-pixel-wide screen at
    1.3× text: the translated title, labels, app name and author are shown; English labels and the
    English description do not appear in `ml`/`sa`; and no Flutter error of any kind is reported.
    (The earlier phase tests only counted overflow messages; this one counts every error, which is
    how the `trailing` problem above was found.)
- `test/l10n/translation_parity_test.dart`: the About config test now runs and passes.
- Key parity: the three ARB files each have the same 1921 keys.
