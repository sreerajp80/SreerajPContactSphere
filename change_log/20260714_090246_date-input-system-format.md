# Date input now follows the system (device) format

Implements plan
[plans/20260714_090246_date-input-system-format.md](../plans/20260714_090246_date-input-system-format.md).

## What was changed

- `lib/main.dart` — added a `localeListResolutionCallback` to the `MaterialApp`.
  It preserves the device's regional English locale (e.g. `en_IN`, `en_GB`) instead
  of letting Flutter strip it down to bare `en` (which `intl` treats as US English).
  Malayalam devices still resolve to `ml`; anything else falls back to `en`.

## Why

Contact date fields (Date of birth, Anniversary, Meetiversary) open Flutter's
built-in `showDatePicker`. Its keyboard-entry mode formats/parses dates using the
app's resolved locale. Because `supportedLocales` only listed bare `en`/`ml` with no
resolution callback, regional English devices resolved to US English, forcing the
MM/DD/YYYY typed-entry format. Keeping the device's country code makes the picker use
the region's date format (e.g. DD/MM/YYYY for English–India / English–UK).

The on-screen display of a chosen date was already region-neutral (`14 Jul 2026`) and
is unaffected.

## Verification

- `flutter analyze lib/main.dart` — No issues found.
- Runtime check (recommended on device): set the device region to English (India) or
  English (UK), open Add/Edit contact, tap a date field, switch the picker to keyboard
  input, and confirm the format is DD/MM/YYYY; a US-region device still shows MM/DD/YYYY.

## Scope / risk

Single additive change to locale resolution. No schema, data, or UI-string changes.
