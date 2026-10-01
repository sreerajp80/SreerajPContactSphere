// lib/l10n/sa_material_localizations.dart
//
// Sanskrit framework-string fallback (engineering standard section 8.3.1).
//
// `flutter_localizations` ships GlobalMaterialLocalizations,
// GlobalCupertinoLocalizations and GlobalWidgetsLocalizations for a long list of
// locales, but *not* for `sa`. Without a shim, the first Material widget that
// needs framework strings under Locale('sa') — a date picker, the dialog
// buttons, the text-selection menu, Scaffold's semantics labels — asserts at
// runtime.
//
// Each delegate below answers only for `sa` and loads the *English* framework
// strings. English, not Hindi: the app's own text stays Sanskrit (served by
// AppLocalizations from lib/l10n/app_sa.arb), and no Hindi can leak into a
// Sanskrit UI.
//
// Register these before the Global delegates in MaterialApp so they win for
// `sa`; see lib/main.dart. Order matters — behind the Global delegates they
// would never be asked, and the crash would come back.

import 'package:flutter/cupertino.dart' show CupertinoLocalizations;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Serves the English [MaterialLocalizations] for Sanskrit.
class SaMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const SaMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'sa';

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(const Locale('en'));

  @override
  bool shouldReload(covariant LocalizationsDelegate old) => false;
}

/// Serves the English [CupertinoLocalizations] for Sanskrit.
class SaCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const SaCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'sa';

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(const Locale('en'));

  @override
  bool shouldReload(covariant LocalizationsDelegate old) => false;
}

/// Serves the English [WidgetsLocalizations] for Sanskrit.
class SaWidgetsLocalizationsDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
  const SaWidgetsLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'sa';

  @override
  Future<WidgetsLocalizations> load(Locale locale) =>
      GlobalWidgetsLocalizations.delegate.load(const Locale('en'));

  @override
  bool shouldReload(covariant LocalizationsDelegate old) => false;
}
