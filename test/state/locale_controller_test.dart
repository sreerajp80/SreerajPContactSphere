// Unit tests for LocaleController — the app-language state (engineering
// standard section 8.4): restoring the saved choice, saving a new one, and the
// resolution order the app runs in.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_contacts_dialer/main.dart';
import 'package:smart_contacts_dialer/state/locale_controller.dart';

Future<LocaleController> _controllerWith(Map<String, Object> saved) async {
  SharedPreferences.setMockInitialValues(saved);
  return LocaleController.load();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocaleController restores the saved choice', () {
    test('defaults to system when nothing is saved', () async {
      final c = await _controllerWith({});
      expect(c.isSystem, isTrue);
      expect(c.locale, isNull);
      expect(c.value, LocaleController.systemValue);
    });

    test('restores a saved ml', () async {
      final c = await _controllerWith({LocaleController.prefKey: 'ml'});
      expect(c.isSystem, isFalse);
      expect(c.locale, const Locale('ml'));
      expect(c.value, 'ml');
    });

    test('an explicit saved "system" follows the system', () async {
      final c = await _controllerWith({LocaleController.prefKey: 'system'});
      expect(c.isSystem, isTrue);
    });

    test('ignores a junk saved value and falls back to system', () async {
      final c = await _controllerWith({LocaleController.prefKey: 'fr'});
      expect(c.isSystem, isTrue);
      expect(c.locale, isNull);
    });
  });

  group('LocaleController.setLanguage', () {
    test('persists the choice and notifies listeners', () async {
      final c = await _controllerWith({});
      var notified = 0;
      c.addListener(() => notified++);

      await c.setLanguage('sa');

      expect(c.locale, const Locale('sa'));
      expect(notified, 1);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(LocaleController.prefKey), 'sa');
    });

    test('going back to system clears the locale and saves "system"', () async {
      final c = await _controllerWith({LocaleController.prefKey: 'ml'});
      await c.setLanguage(LocaleController.systemValue);

      expect(c.isSystem, isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(LocaleController.prefKey), 'system');
    });

    test('an unknown value is saved as system', () async {
      final c = await _controllerWith({LocaleController.prefKey: 'ml'});
      await c.setLanguage('xx');

      expect(c.isSystem, isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(LocaleController.prefKey), 'system');
    });

    test('a controller built without prefs still saves', () async {
      SharedPreferences.setMockInitialValues({});
      final c = LocaleController();
      await c.setLanguage('ml');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(LocaleController.prefKey), 'ml');
    });

    test('the saved choice survives a restart', () async {
      final first = await _controllerWith({});
      await first.setLanguage('ml');

      final restarted = await LocaleController.load();
      expect(restarted.locale, const Locale('ml'));
    });
  });

  group('LocaleController.resolve — the section 8.4 resolution order', () {
    // Flutter hands the resolver the saved choice (as a one-item list) when
    // there is one, otherwise the device's language list.

    test('a saved choice beats the device locale', () {
      const device = [Locale('ml', 'IN')];
      expect(
        LocaleController.resolve(const [Locale('sa')], device),
        const Locale('sa'),
      );
      expect(
        LocaleController.resolve(const [Locale('en')], const [Locale('ml')]),
        const Locale('en'),
      );
    });

    test('with no saved choice an ml device gets ml', () {
      const device = [Locale('ml', 'IN')];
      expect(LocaleController.resolve(device, device), const Locale('ml'));
    });

    test('a device in a fourth language gets English', () {
      const device = [Locale('fr', 'FR')];
      expect(LocaleController.resolve(device, device), const Locale('en'));
    });

    test('the first supported language in the device list wins', () {
      const device = [Locale('hi', 'IN'), Locale('sa'), Locale('en', 'GB')];
      expect(LocaleController.resolve(device, device), const Locale('sa'));
    });

    test('regional English on the device is kept', () {
      const device = [Locale('en', 'IN')];
      expect(
        LocaleController.resolve(device, device),
        const Locale('en', 'IN'),
      );
    });

    test('picking English in-app keeps the device regional English', () {
      const device = [Locale('ml', 'IN'), Locale('en', 'GB')];
      expect(
        LocaleController.resolve(const [Locale('en')], device),
        const Locale('en', 'GB'),
      );
    });

    test('a null list resolves to English', () {
      expect(LocaleController.resolve(null, const []), const Locale('en'));
    });
  });

  group('the shipping app is driven by the controller', () {
    testWidgets('MaterialApp.locale follows a saved choice at startup', (
      tester,
    ) async {
      final c = await _controllerWith({LocaleController.prefKey: 'ml'});
      await tester.pumpWidget(SmartContactsApp(localeController: c));
      await tester.pump();
      // AppSettings.load() starts a one-second debounce timer; let it fire.
      await tester.pump(const Duration(seconds: 2));

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.locale, const Locale('ml'));
      final context = tester.element(find.byType(Scaffold).first);
      expect(Localizations.localeOf(context), const Locale('ml'));
    });

    testWidgets('with no saved choice the app follows the system', (
      tester,
    ) async {
      final c = await _controllerWith({});
      await tester.pumpWidget(SmartContactsApp(localeController: c));
      await tester.pump();
      // AppSettings.load() starts a one-second debounce timer; let it fire.
      await tester.pump(const Duration(seconds: 2));

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.locale, isNull);
    });
  });
}
