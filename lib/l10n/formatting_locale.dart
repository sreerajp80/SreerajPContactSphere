// lib/l10n/formatting_locale.dart
//
// Locale for `intl` date and number formatting (engineering standard 8.3.2).
//
// The `intl` package ships no CLDR data for Sanskrit, so
// `DateFormat.yMMMMd('sa')` throws. Every screen that formats a date for the
// user passes its UI locale through [formattingLocale] first: Sanskrit then
// gets English patterns while the UI text stays Sanskrit. The fallback is
// English, never Hindi, so no Hindi month or weekday name can leak into a
// Sanskrit UI.

import 'dart:ui' show Locale;

import 'package:intl/intl.dart';

/// Returns the locale name to hand to `DateFormat` / `NumberFormat` for the
/// UI [locale].
///
/// Tries the full locale first (`en_IN`, so regional English keeps its own
/// date order), then the bare language (`ml`), then falls back to `en`.
///
/// The locale name uses intl's underscore form (`en_IN`), not the BCP-47 tag
/// (`en-IN`): intl keys its date data by the underscore form, so the tag would
/// never match and every regional English user would lose their format.
///
/// If intl's date data has not been loaded yet (it is loaded by the Global
/// Material localizations delegate, so this only happens outside a running
/// app, such as in a plain unit test), intl can answer for `en_US` alone, so
/// that is returned.
String formattingLocale(Locale locale) {
  try {
    final full = locale.toString();
    if (DateFormat.localeExists(full)) return full;
    if (DateFormat.localeExists(locale.languageCode)) {
      return locale.languageCode;
    }
    return 'en';
  } on Exception {
    // intl throws its (unexported) LocaleDataException when asked about any
    // locale other than en_US before date data is loaded.
    return 'en_US';
  }
}
