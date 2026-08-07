# Change log — Default country setting + E.164 number normalization

Implements plan `plans/20260701_221932_default-country-number-normalization.md`
(supersedes the dropped `plans/20260701_221400_incoming-call-caller-id-country-code.md`).

## Problem

Incoming call from `+919876543210` did not resolve to the saved contact `9876543210`
(no name / photo on the in-call screen; call-log entry unlinked). Caller-ID resolution used
`ContactRepository.findByPhoneFragment`, whose SQL requires the *stored* number to **contain**
the full incoming digits (incl. the `91` country code). The stored national number is shorter,
so nothing matched.

## What changed

- **New dependency:** `phone_numbers_parser: ^9.0.24` (pure Dart) — added to `pubspec.yaml`.

- **`lib/data/country_names.dart` (new, generated):** ISO alpha-2 → English display-name map
  (242 entries), generated offline from .NET `RegionInfo`. Backs the country picker; codes not
  in the map (AC/TA/XK) fall back to their raw ISO code.

- **`lib/utils/phone_normalizer.dart` (new):** `PhoneNormalizer` with `toE164`, `sameNumber`
  (E.164 equality under a default country, with a digit-equality fallback for unparseable
  input), `isoFromString`, `dialCodeFor`, `nameFor`, and `allCountries()` (sorted
  `CountryOption` list for the picker).

- **`lib/state/app_settings.dart`:** added the persisted `defaultCountryIso` setting
  (key `default_country`), auto-detected from the device region (`PlatformDispatcher` locale,
  fallback `US`). Added `get defaultCountryIso`, `setDefaultCountryIso`, load handling, and a
  static `readDefaultCountryIso()` for non-widget consumers (services).

- **`lib/repositories/contact_repository.dart`:** added `findByFullNumber(number,
  {required defaultIso, limit})` — prefilters candidates by the last 7 digits in SQL, then
  confirms each with `PhoneNormalizer.sameNumber`. `findByPhoneFragment` (dialer suggestions)
  left unchanged.

- **Caller-ID resolution now uses `findByFullNumber`:**
  - `lib/screens/in_call_screen.dart` — `_resolveName` (fixes name + backdrop image).
  - `lib/services/call_service.dart` — `_resolveContactId` (dropped the redundant manual
    `endsWith` check).
  - `lib/services/call_event_logger.dart` — `_resolveContactId` (same).

- **Settings UI (matches the app's existing design):**
  - `lib/screens/default_country_screen.dart` (new): themed search field over a list of
    hand-built radio rows (name + `+dialCode`), mirroring `sim_settings_screen.dart`.
  - `lib/screens/settings_screen.dart`: added a **"Default country"** `_SettingsCard`
    (`Icons.public_outlined`) whose subtitle reflects the current selection, routing to the
    new screen. Deliberately **not** named "assisted dialing".

## Verification

- `flutter analyze` on all touched files + the generated data file: no issues.
- `test/phone_normalizer_test.dart` (new): 6 cases incl. the exact reported case
  (`9876543210` ↔ `+919876543210` under IN), symmetry, formatting tolerance, negative match,
  wrong-country non-match, and `toE164` canonicalization.
- Full suite: 33 tests pass.

## Notes / scope

- Stored numbers are never rewritten — normalization is match-time only; no DB migration.
- No auto-adding of country codes when *placing* calls (out of scope; this is about
  *identifying* contacts).
