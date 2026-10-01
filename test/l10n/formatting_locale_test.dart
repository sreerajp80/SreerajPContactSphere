// Tests for the third mandatory locale, Sanskrit (`sa`), and the intl
// formatting-locale fallback (engineering standard sections 8.3 and 8.3.2).
//
// intl ships no CLDR date data for `sa`, so `DateFormat(..., 'sa')` throws.
// formattingLocale() hands intl English patterns for Sanskrit — never Hindi —
// while keeping regional English (en_IN) and Malayalam intact.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'package:smart_contacts_dialer/l10n/formatting_locale.dart';
import 'package:smart_contacts_dialer/main.dart';
import 'package:smart_contacts_dialer/models/audit_entry.dart';
import 'package:smart_contacts_dialer/screens/audit_entry_detail_screen.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

/// The shipping [MaterialApp], read off a pumped [SmartContactsApp].
Future<MaterialApp> _shippingApp(WidgetTester tester) async {
  await tester.pumpWidget(const SmartContactsApp());
  await tester.pump();
  return tester.widget<MaterialApp>(find.byType(MaterialApp));
}

void main() {
  group('formattingLocale', () {
    setUpAll(() async {
      // Loading the Global Material delegate loads intl's date data, exactly
      // as it happens in the running app before any screen builds.
      TestWidgetsFlutterBinding.ensureInitialized();
      await GlobalMaterialLocalizations.delegate.load(const Locale('en'));
    });

    test('Sanskrit falls back to English, never Hindi', () {
      final name = formattingLocale(const Locale('sa'));
      expect(name, 'en');
      expect(name, isNot(startsWith('hi')));
    });

    test('English and Malayalam keep their own locale', () {
      expect(formattingLocale(const Locale('en')), 'en');
      expect(formattingLocale(const Locale('ml')), 'ml');
    });

    test('regional English keeps its region', () {
      expect(formattingLocale(const Locale('en', 'IN')), 'en_IN');
      expect(formattingLocale(const Locale('en', 'GB')), 'en_GB');
    });

    test('the result always formats a date without throwing', () {
      for (final locale in const [
        Locale('en'),
        Locale('en', 'IN'),
        Locale('ml'),
        Locale('sa'),
      ]) {
        final text = DateFormat.yMMMMd(
          formattingLocale(locale),
        ).format(DateTime(2026, 9, 21));
        expect(text, isNotEmpty, reason: '$locale');
      }
    });
  });

  testWidgets('the app declares en, ml and sa in that fixed order', (
    tester,
  ) async {
    final app = await _shippingApp(tester);
    expect(app.supportedLocales.toList(), const [
      Locale('en'),
      Locale('ml'),
      Locale('sa'),
    ]);
  });

  testWidgets('a Sanskrit device resolves to sa, regional English is kept', (
    tester,
  ) async {
    final app = await _shippingApp(tester);
    final resolve = app.localeListResolutionCallback!;
    final supported = app.supportedLocales;

    expect(resolve(const [Locale('sa', 'IN')], supported), const Locale('sa'));
    expect(
      resolve(const [Locale('hi', 'IN'), Locale('sa')], supported),
      const Locale('sa'),
    );
    expect(
      resolve(const [Locale('en', 'IN')], supported),
      const Locale('en', 'IN'),
    );
    expect(resolve(const [Locale('ml', 'IN')], supported), const Locale('ml'));
    expect(resolve(const [Locale('hi', 'IN')], supported), const Locale('en'));
  });

  testWidgets('a date-formatting screen builds under sa without throwing', (
    tester,
  ) async {
    final app = await _shippingApp(tester);
    final entry = AuditEntry(
      id: 1,
      contactId: 1,
      contactName: 'Test',
      action: AuditAction.update,
      source: AuditSource.manual,
      changedAt: DateTime(2026, 9, 21, 14, 30),
      summary: 'Phone numbers',
      isSecret: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('sa'),
        localizationsDelegates: app.localizationsDelegates,
        supportedLocales: app.supportedLocales,
        theme: AppTheme.calm(Colors.teal),
        home: AuditEntryDetailScreen(entry: entry),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // English patterns: the month name is English, not Hindi or blank.
    expect(find.textContaining('21 September 2026'), findsOneWidget);
  });
}
