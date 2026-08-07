# Change log — Add-contact phone country-code selector

Implements plan `plans/20260702_145659_add-contact-country-code-selector.md`.

## Problem

The Add/Edit contact phone field was a plain text box that stored whatever was typed
verbatim. A home-country user typically entered a bare national number (no country code), so a
**foreign** contact saved without its `+code` would fail caller-ID matching: an incoming
international call arrives in full E.164 (e.g. `+1…`) but the stored national number is assumed
to be in the home country (the "Case B" mismatch).

## What changed

- **`lib/utils/phone_normalizer.dart`** — three new helpers:
  - `dialCodeForIso(String iso)` — `"US" -> "1"` for the chip label.
  - `split(String raw, {required String defaultIso})` — returns `({String iso, String national})`;
    honors an embedded `+code` (parsed **without** country hints, since passing hints makes
    `phone_numbers_parser` mis-read a `+1…` number under a foreign default), else treats the
    number as national in `defaultIso`. Null for empty input; digit fallback on parse failure.
  - `compose({required String iso, required String national})` — builds canonical E.164
    (`+<dialCode><national>`); empty when no digits; bare digits when `iso` is unknown.

- **`lib/screens/add_edit_contact_screen.dart`**:
  - Added imports for `AppSettings` and `PhoneNormalizer`.
  - `_LabeledEntry` gained an optional `countryIso` (phone rows only; null for email/social).
  - New state: `_homeCountryIso` (provisional `US`, replaced async in `_loadHomeCountry` via
    `AppSettings.readDefaultCountryIso`) and `_phoneSeeds` (raw + derived per row, so untouched
    rows are re-split once the real home country loads).
  - `_buildPhone` / `_applyPhoneSplit` build phone rows by splitting the stored/seeded value into
    a country chip + national number (used for existing contacts and the dialer "Add to contacts"
    seed).
  - `_repeaterSection` / `_repeaterRow` gained a `showCountryCode` flag; when set (phones only) a
    compact `+<dialCode>` `_menuButton` chip renders left of the number field and opens the new
    picker. Email/social sections are visually unchanged. Phone value hint changed
    `+1 555 0123` -> `555 0123`.
  - Save composes each phone into E.164 via `PhoneNormalizer.compose` instead of storing the raw
    text; empty rows still dropped.
  - New `_CountryPickerSheet` (bottom sheet): searchable country list with ISO badges, pops the
    chosen ISO. Mirrors `default_country_screen.dart`'s design (not a flag-emoji list).

- **`test/phone_normalizer_test.dart`** — 6 new cases: `split` honors an embedded `+1` over an IN
  home country, treats a bare number as home, returns null on empty; `compose` builds E.164 and
  is empty for digitless input; and a `compose(split(x))` round-trip proving a US number stays
  US E.164 and still matches an incoming US caller ID under an IN default.

## Verification

- `flutter analyze` (whole project): no issues.
- `flutter test` (whole suite): **39 tests pass**, including the 6 new normalizer cases.
- Not driven in an emulator in this environment (Android UI change); manual check recommended:
  add a US contact via the `+1` chip while home country is India and confirm it stores as `+1…`,
  and that an existing bare national contact opens with the home country pre-selected.

## Notes / scope

- Storage stays in the existing `number` column as full E.164 — no DB schema change, no bulk
  migration (old numbers are only rewritten when the user edits that row).
- Matching logic (`toE164` / `sameNumber`) was intentionally left unchanged; both sides normalize
  under the same default at match time, so the now-`+code` stored values still resolve correctly.
- Best-effort: save is not blocked on an "invalid" number.
