// lib/state/locale_controller.dart
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Single source of truth for the app language (engineering standard §8.4).
///
/// A `null` [locale] means "follow the system". `MaterialApp.locale` is driven
/// by this controller and nothing else; screens must not read the language
/// from anywhere other than here (or `Localizations.localeOf`).
///
/// Kept separate from `AppSettings` on purpose: the saved language must be
/// read **before** the first frame (so the app never flashes the wrong
/// language), while `AppSettings.load()` runs after the first frame.
class LocaleController extends ChangeNotifier {
  static const String prefKey = 'app_language';
  static const String systemValue = 'system';

  /// The three supported languages, in the standard's fixed order (§8.3).
  static const List<String> supported = ['en', 'ml', 'sa'];

  /// Every option the picker offers, System default first.
  static const List<String> options = [systemValue, ...supported];

  /// Null only for the no-argument form used by tests and the smoke test; the
  /// first save then fetches the shared instance itself.
  final SharedPreferences? _prefs;
  Locale? _locale;

  /// Restores the saved language from [prefs]. A missing or unknown value
  /// means "follow the system".
  LocaleController([this._prefs]) {
    final saved = _prefs?.getString(prefKey) ?? systemValue;
    _locale = supported.contains(saved) ? Locale(saved) : null;
  }

  /// Reads the one saved key and builds the controller. Called from `main()`
  /// before `runApp`.
  static Future<LocaleController> load() async =>
      LocaleController(await SharedPreferences.getInstance());

  /// null => follow the system locale.
  Locale? get locale => _locale;

  bool get isSystem => _locale == null;

  /// The stored value for the current choice: `system`, `en`, `ml` or `sa`.
  String get value => _locale?.languageCode ?? systemValue;

  /// Saves [value] (`system`, `en`, `ml` or `sa`) and applies it app-wide.
  /// An unknown value is treated as `system`.
  Future<void> setLanguage(String value) async {
    final next = supported.contains(value) ? value : systemValue;
    _locale = next == systemValue ? null : Locale(next);
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(prefKey, next);
    notifyListeners();
  }

  /// Resolves the locale the app actually runs in (§8.4 resolution order).
  ///
  /// [preferred] is what Flutter hands to `localeListResolutionCallback`: the
  /// saved choice as a one-item list when there is one, otherwise the device's
  /// language list. [device] is the device's language list, used only to keep
  /// a regional English (e.g. `en_IN`, `en_GB`) when English is chosen, so the
  /// date picker and other built-in widgets keep the phone's date format
  /// instead of falling back to US-style `en`.
  static Locale resolve(List<Locale>? preferred, List<Locale> device) {
    for (final locale in preferred ?? const <Locale>[]) {
      switch (locale.languageCode) {
        case 'en':
          if (locale.countryCode != null) return locale;
          for (final d in device) {
            if (d.languageCode == 'en' && d.countryCode != null) return d;
          }
          return const Locale('en');
        case 'ml':
          return const Locale('ml');
        case 'sa':
          return const Locale('sa');
      }
    }
    return const Locale('en');
  }
}
