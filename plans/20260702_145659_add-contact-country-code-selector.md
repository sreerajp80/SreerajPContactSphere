# Add-contact phone field: country-code selector defaulting to home country

**Status:** completed

## Issue

In the Add/Edit contact screen the phone field ([lib/screens/add_edit_contact_screen.dart:797](../lib/screens/add_edit_contact_screen.dart#L797)) is a
plain text box (hint `+1 555 0123`). Whatever the user types is stored verbatim as
`PhoneNumber.number` ([add_edit_contact_screen.dart:696](../lib/screens/add_edit_contact_screen.dart#L696)). A user in
India typically types a bare national number (e.g. `9876543210`) with no country code.

Caller-ID matching (`PhoneNormalizer.sameNumber`, [lib/utils/phone_normalizer.dart](../lib/utils/phone_normalizer.dart)) only
back-fills the country code from the **Default country** when a number has *no* `+` prefix.
So a bare national number is assumed to be in the home country. When the saved contact is a
**foreign** number stored without its `+code`, an incoming international call (which arrives in
full E.164, e.g. `+1…`) will **not** match — the stored number is mis-read as a home-country
number. This is the "Case B" failure discussed with the user.

**Fix goal:** capture a per-phone country in the Add/Edit UI, defaulting to the user's home
country, and store every number in canonical E.164 (`+<dialCode><national>`) so matching is
reliable regardless of the Default country setting.

## Decisions (agreed with user)

1. **Storage format:** store full E.164 (`+<code><national>`) in the existing `number` column.
   No DB schema change. Consistent with existing match-time normalization.
2. **Editing existing contacts:** parse the stored value into `[country][national]`; when it
   can't be parsed as E.164, fall back to leaving it in the plain value field with the home
   country selected (nothing is lost / rewritten unless the user edits that row).
3. **Paste / dialer seed:** a value that already carries a `+<code>` is detected and split so the
   country code is not duplicated.
4. **Validation:** best-effort — normalize on save, do not block saving on an "invalid" number.

## Files to change

- **`lib/utils/phone_normalizer.dart`** — add two helpers:
  - `({IsoCode iso, String national})? split(String raw, {required String defaultIso})`:
    parse `raw`; when it carries a country code use the parsed `isoCode` + national significant
    number (`nsn`); when it has no country code, return `(defaultIso, digits-of-raw)`; when it is
    empty/unparseable, return null so the caller keeps the raw text.
  - `String compose({required IsoCode iso, required String national})`: build `+<dialCode>` +
    national digits, returning canonical E.164 (reuse `dialCodeFor`). If `national` is empty,
    return empty string (an empty row is dropped on save as today).

- **`lib/screens/add_edit_contact_screen.dart`** — the UI + wiring:
  - Add `import '../state/app_settings.dart';` and (already imports `phone_normalizer` indirectly?
    no) `import '../utils/phone_normalizer.dart';`.
  - `_LabeledEntry`: add an optional, mutable `String? countryIso` field (used only by phone rows;
    null for email/social rows so their rendering is unchanged).
  - New state field `String _homeCountryIso = 'US';` loaded asynchronously in `initState`
    via `AppSettings.readDefaultCountryIso()` (then `setState` to apply it to phone rows that
    don't already have a country). Keeps the sync init path intact.
  - When building phone rows (existing contact, dialer seed, or a fresh empty row), set
    `countryIso` using `PhoneNormalizer.split(storedValue, defaultIso: home)`:
    - split succeeds → put the national part in the value controller and the detected ISO on the
      entry.
    - split returns null (empty) → value stays empty, `countryIso = home`.
    - unparseable non-empty (rare) → keep the raw text in the value field, `countryIso = home`.
  - `_repeaterSection` / `_repeaterRow`: add an optional `bool showCountryCode` (default false).
    For the phones section pass `true`. When true, render a compact country-code menu button
    (label `+<dialCode>`) immediately left of the value field, reusing the existing `_menuButton`
    styling so it matches the app's design. Tapping it opens the shared country picker
    (`PhoneNormalizer.allCountries()`), same list used by
    [lib/screens/default_country_screen.dart](../lib/screens/default_country_screen.dart);
    selection updates `entry.countryIso` + `setState`. Email/social rows (flag false) are
    visually unchanged.
  - Save block ([add_edit_contact_screen.dart:692-701](../lib/screens/add_edit_contact_screen.dart#L692)):
    for each phone row build `number` via
    `PhoneNormalizer.compose(iso: entry.countryIso, national: entry.value.text)` instead of the
    raw `p.value.text.trim()`. Empty rows are still skipped.

- **`test/phone_normalizer_test.dart`** — add cases for the new helpers:
  - `split('+15551234567', defaultIso: 'IN')` → iso US, national `5551234567`.
  - `split('9876543210', defaultIso: 'IN')` → iso IN, national `9876543210`.
  - `compose(iso: US, national: '5551234567')` → `+15551234567`.
  - Round-trip: `compose(split(x))` yields the same E.164 for a `+1` US number under an IN home
    country — proving a US contact now stores/matches correctly despite the `+91` default.

## Out of scope

- No change to the dialer, contact detail, or matching logic — those already normalize at match
  time and will simply see cleaner (E.164) stored values.
- No bulk migration of existing stored numbers (decision #2: only rewritten when the user edits
  that row).
- No hard validation / save-blocking (decision #4).

## Verification

- `flutter analyze` on the touched files — no issues.
- `flutter test` — full suite green, including the new `phone_normalizer_test.dart` cases.
- Manual: add a US contact with the `+1` chip while home country is India; confirm it stores as
  `+1…`. Confirm an existing bare national contact opens with the home country pre-selected and
  the national number in the field.
