// lib/utils/phone_normalizer.dart
//
// Phone-number normalization used for *identifying* which contact a full
// number (an incoming caller ID or a dialed number) belongs to. Both the
// stored number and the incoming number are converted to canonical E.164 form
// using the user's Default country (see AppSettings.defaultCountryIso), then
// compared for equality — so a national number (9876543210) matches the same
// number carrying a country code (+919876543210) and vice versa.
//
// Backed by phone_numbers_parser (pure Dart). Normalization happens at match
// time only; stored numbers are never rewritten.

import 'package:phone_numbers_parser/phone_numbers_parser.dart';

import 'package:smart_contacts_dialer/data/country_names.dart';

/// A selectable country for the Default country picker: its ISO code, English
/// display name, and international dial code (e.g. IN / India / 91).
class CountryOption {
  final IsoCode iso;
  final String name;
  final String dialCode;

  const CountryOption({
    required this.iso,
    required this.name,
    required this.dialCode,
  });

  /// The ISO alpha-2 code as a string (e.g. "IN"), as persisted in settings.
  String get isoString => iso.name;

  /// e.g. "India (+91)".
  String get label => '$name (+$dialCode)';
}

class PhoneNormalizer {
  const PhoneNormalizer._();

  /// Resolves an ISO alpha-2 string (e.g. "IN") to an [IsoCode], or null if it
  /// isn't a recognised code.
  static IsoCode? isoFromString(String? iso) {
    if (iso == null) return null;
    final up = iso.trim().toUpperCase();
    if (up.isEmpty) return null;
    for (final v in IsoCode.values) {
      if (v.name == up) return v;
    }
    return null;
  }

  /// International dial code (country calling code) for [iso], e.g. "91" for IN.
  static String dialCodeFor(IsoCode iso) =>
      PhoneNumber(isoCode: iso, nsn: '').countryCode;

  /// English display name for [iso], falling back to the raw ISO code when the
  /// name map doesn't cover it.
  static String nameFor(IsoCode iso) => kCountryNames[iso.name] ?? iso.name;

  /// Canonical E.164 form of [raw] (e.g. "+919876543210"), interpreting a
  /// national number as belonging to [defaultIso]. Returns null when the input
  /// is empty or can't be parsed.
  static String? toE164(String raw, {required String defaultIso}) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    final iso = isoFromString(defaultIso);
    try {
      final parsed = iso == null
          ? PhoneNumber.parse(trimmed)
          : PhoneNumber.parse(
              trimmed,
              callerCountry: iso,
              destinationCountry: iso,
            );
      return parsed.international;
    } catch (_) {
      return null;
    }
  }

  /// True when [a] and [b] denote the same phone number once normalized to
  /// E.164 under [defaultIso]. Falls back to exact digit-string equality when
  /// either side can't be parsed, so a malformed/short number still matches an
  /// identical raw value.
  static bool sameNumber(String a, String b, {required String defaultIso}) {
    final ea = toE164(a, defaultIso: defaultIso);
    final eb = toE164(b, defaultIso: defaultIso);
    if (ea != null && eb != null) return ea == eb;
    if (ea != null || eb != null) return false;
    final da = _digits(a);
    return da.isNotEmpty && da == _digits(b);
  }

  /// International dial code for an ISO alpha-2 string (e.g. "US" -> "1"), or
  /// null when the code isn't recognised. Backs the Add/Edit country chip.
  static String? dialCodeForIso(String iso) {
    final code = isoFromString(iso);
    return code == null ? null : dialCodeFor(code);
  }

  /// Splits [raw] into its country (ISO alpha-2) and national parts for the
  /// Add/Edit contact phone field. When [raw] carries a country code (e.g.
  /// "+15551234567") the parsed country wins; otherwise the number is treated as
  /// national in [defaultIso]. Returns null for an empty input so the caller can
  /// leave the field untouched. On an unparseable non-empty input, falls back to
  /// [defaultIso] with the raw digits, so nothing the user typed is lost.
  static ({String iso, String national})? split(
    String raw, {
    required String defaultIso,
  }) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    final fallbackIso = isoFromString(defaultIso) ?? IsoCode.US;
    try {
      // A "+" number carries its own country code — passing country hints makes
      // phone_numbers_parser mis-read it (e.g. "+1…" under IN). Only supply the
      // default country for a bare national number that lacks a code.
      final parsed = trimmed.startsWith('+')
          ? PhoneNumber.parse(trimmed)
          : PhoneNumber.parse(
              trimmed,
              callerCountry: fallbackIso,
              destinationCountry: fallbackIso,
            );
      return (iso: parsed.isoCode.name, national: parsed.nsn);
    } catch (_) {
      return (iso: fallbackIso.name, national: _digits(trimmed));
    }
  }

  /// Composes a canonical E.164 number (`+<dialCode><national>`) from a picked
  /// ISO alpha-2 [iso] and a [national] number as typed in the Add/Edit contact
  /// field. Returns an empty string when [national] has no digits, so an empty
  /// row is still dropped on save; falls back to the bare national digits when
  /// [iso] isn't a recognised country.
  static String compose({required String iso, required String national}) {
    final nsn = _digits(national);
    if (nsn.isEmpty) return '';
    final code = isoFromString(iso);
    return code == null ? nsn : '+${dialCodeFor(code)}$nsn';
  }

  /// All known countries as [CountryOption]s, sorted by display name. Backs the
  /// Default country picker.
  static List<CountryOption> allCountries() {
    final out = <CountryOption>[
      for (final iso in IsoCode.values)
        CountryOption(iso: iso, name: nameFor(iso), dialCode: dialCodeFor(iso)),
    ];
    out.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return out;
  }

  static String _digits(String s) => s.replaceAll(RegExp(r'\D'), '');
}
