# Default Country setting + E.164 number normalization for contact identification

**Status:** completed

## Issue

An incoming call from `+919876543210` does not resolve to the saved contact `9876543210`
(name + photo missing on the in-call screen, and the call log entry isn't linked). Root cause:
caller-ID resolution uses `ContactRepository.findByPhoneFragment`, whose SQL requires the
*stored* number to **contain** the full incoming digits (including the `91` country code).
The stored national number is shorter, so nothing matches.

## Chosen approach (user decision)

Do **not** use a trailing-digit heuristic. Instead add a user-configurable **Default country**
setting (like the home-country selector in other dialers, but **not** named "assisted dialing").
Use it to normalize both the stored number and the incoming/dialed number to canonical **E.164**
form, then match on equality. This also improves search and duplicate detection later.

Numbers are normalized **at match time only** — stored data is left exactly as the user typed
it, so there is no DB migration and no risk of rewriting user input.

## Dependency

Add `phone_numbers_parser` (pure-Dart, no platform channel) for parsing/validation and E.164
formatting given a country, plus its `IsoCode` enum + country metadata (dial codes). Requires
`flutter pub add phone_numbers_parser` / `flutter pub get`.

> Note: this is a new pub dependency, not a missing source file. Flagging per the "pause on
> missing dependencies" rule — approving this plan approves adding it.

## Design

### 1. Setting (`lib/state/app_settings.dart`)
- New persisted value `String defaultCountryIso` (ISO 3166-1 alpha-2, e.g. `"IN"`), key
  `default_country`.
- Default when unset: auto-detect from the device region
  (`PlatformDispatcher.instance.locale.countryCode`), falling back to `"US"` if absent.
- Add `get defaultCountryIso`, `setDefaultCountryIso(String)`, and load it in `load()`
  (same try/catch + `notifyListeners()` pattern as the other settings).
- Add a **static** `Future<String> readDefaultCountryIso()` that reads shared_preferences
  directly (with the same auto-detect fallback), so non-widget services can get the value
  without the `provider` tree.

### 2. Normalizer util (`lib/utils/phone_normalizer.dart`, new)
- `static String? toE164(String raw, {required String defaultIso})` — parse `raw` with
  `phone_numbers_parser` using `defaultIso` as the caller country; return `.international`
  (E.164, e.g. `+919876543210`) when parseable, else `null`.
- `static bool sameNumber(String a, String b, {required String defaultIso})` — true when the
  two normalize to the same E.164; **fallback** to exact digit-string equality
  (`normalizeDigits`) when either fails to parse, so a malformed/short number still matches
  itself.
- (Optional, for the picker) expose the country list: `[{IsoCode, displayName, +dialCode}]`
  built from `phone_numbers_parser` metadata + a bundled ISO→name map.

### 3. Repository lookup (`lib/repositories/contact_repository.dart`)
- Add `Future<List<PhoneMatch>> findByFullNumber(String number, {required String defaultIso,
  int limit = 1})`:
  - Normalize `number` to E.164 (`target`); also keep its raw digits for the SQL prefilter.
  - Cheap SQL prefilter: `WHERE <normalized stored digits> LIKE '%<last 7 digits>%'`
    (selective, avoids scanning every row); reuse the existing REPLACE-based digit
    normalization and the same projection/mapping as `findByPhoneFragment`.
  - In Dart, keep a row only when `PhoneNormalizer.sameNumber(stored, number, defaultIso)`;
    cap the result to `limit`.
- Leave `findByPhoneFragment` (dialer live-suggestions) unchanged.

### 4. Wire the three resolution sites
- `lib/screens/in_call_screen.dart` — `_resolveName`: read the default country from
  `AppSettings` via `provider` (the screen is in the widget tree) and call
  `findByFullNumber(number, defaultIso: ...)`. Fixes both the name and the backdrop image.
- `lib/services/call_service.dart` — `_resolveContactId`: get the ISO via
  `AppSettings.readDefaultCountryIso()` and call `findByFullNumber`; drop the now-redundant
  manual `endsWith` check.
- `lib/services/call_event_logger.dart` — `_resolveContactId`: same change.

### 5. Settings UI — **must follow the app's existing design system**, not stock Flutter
Reuse the conventions already established in `sim_settings_screen.dart` / `settings_screen.dart`:
`Card(margin: EdgeInsets.zero)`, the `AppColors` theme extension
(`Theme.of(context).extension<AppColors>()!`, `colors.mutedText`), accent from
`colorScheme.primary`, `ListView` padding `fromLTRB(16, 16, 16, 32)`, section header = title
(16 / w700) + subtitle (13 / mutedText), and the hand-built radio `_optionTile` row style
(`radio_button_checked` in accent for the selection). No `RadioListTile`/`ListTile` stock look.

- New screen `lib/screens/default_country_screen.dart`:
  - `AppBar(title: Text('Default country'))` matching the other settings screens.
  - A themed search field at the top (filled, `colors`-based, rounded) to filter the list.
  - A single `Card(margin: EdgeInsets.zero)` containing the country rows rendered with the
    **same `_optionTile` radio-row pattern** as `sim_settings_screen.dart` (country name as
    title, `+dialCode` as subtitle, current selection checked in the accent color). Tapping a
    row calls `setDefaultCountryIso` and pops.
- `lib/screens/settings_screen.dart`: add a `_SettingsCard` (the existing card component)
  - icon: a neutral globe/flag outline (e.g. `Icons.public_outlined`)
  - title: **"Default country"** (NOT "assisted dialing")
  - subtitle: reflects the current value, e.g. `"India (+91) · used to match numbers to contacts"`
  - routes to `DefaultCountryScreen`, placed near the "SIM & calling" card.

The screen and card will visually match the existing SIM/Appearance settings screens exactly
(same Card, spacing, typography, accent, muted-text treatment).

## Files to change / add

1. `pubspec.yaml` — add `phone_numbers_parser`.
2. `lib/state/app_settings.dart` — default-country get/set/load + static reader.
3. `lib/utils/phone_normalizer.dart` — **new** normalizer util (+ country list helper).
4. `lib/repositories/contact_repository.dart` — add `findByFullNumber`.
5. `lib/screens/in_call_screen.dart` — use `findByFullNumber`.
6. `lib/services/call_service.dart` — use `findByFullNumber`.
7. `lib/services/call_event_logger.dart` — use `findByFullNumber`.
8. `lib/screens/default_country_screen.dart` — **new** country picker.
9. `lib/screens/settings_screen.dart` — add the "Default country" card.

## Out of scope / not changed
- `findByPhoneFragment` and dialer live-suggestion behavior (unchanged).
- No rewriting of stored numbers / no DB migration (normalize at match time only).
- No auto-adding of country codes when placing calls (that's a separate feature; this plan is
  about *identifying* contacts).

## Verification
- `flutter pub get` succeeds; `flutter analyze` clean for touched files.
- Save a contact as `9876543210` with Default country = India (+91); receive a call from
  `+919876543210` → in-call screen shows the name + photo; call log links the contact.
- Reverse: store `+919876543210`, receive/dial `9876543210` → still resolves.
- Change Default country to a different region → the India-specific match no longer applies
  (confirms the setting actually drives normalization).
- Unparseable/short numbers still match themselves via the digit-equality fallback.
