// Widget tests for the Sanskrit framework-string fallback.
//
// Engineering standard section 8.3.1 makes this test mandatory: pump with
// `Locale('sa')`, open a date picker and a dialog, and assert nothing throws.
// flutter_localizations has no `sa`, so without the delegates in
// lib/l10n/sa_material_localizations.dart the first Material widget that needs
// framework strings asserts — the single most likely Sanskrit runtime failure.
//
// Every test takes the delegate list out of the *real* app (SmartContactsApp)
// rather than declaring its own, so the ordering these tests prove is the
// ordering that ships. Ordering is the whole risk: behind the Global delegates
// the Sa* ones are never asked, and the crash comes back.
//
// These tests hand `sa` to a MaterialApp of their own, so each one can pin the
// locale directly. That the shipping app lists `sa` in `supportedLocales` is
// covered in formatting_locale_test.dart.

import 'package:flutter/cupertino.dart' show CupertinoLocalizations;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/l10n/sa_material_localizations.dart';
import 'package:smart_contacts_dialer/main.dart';

/// The `localizationsDelegates` the shipping app registers.
///
/// Pumps [SmartContactsApp] and reads the list off its [MaterialApp], so the
/// tests below cannot drift from the production wiring.
Future<List<LocalizationsDelegate<dynamic>>> _appDelegates(
  WidgetTester tester,
) async {
  await tester.pumpWidget(const SmartContactsApp());
  await tester.pump();
  final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
  final delegates = app.localizationsDelegates;
  expect(delegates, isNotNull, reason: 'the app must register delegates');
  return delegates!.toList();
}

/// A minimal screen whose buttons open the two widgets section 8.3.1 names.
class _Harness extends StatelessWidget {
  const _Harness({required this.onContext});

  /// Called during build with the context under the tested locale.
  final void Function(BuildContext context) onContext;

  @override
  Widget build(BuildContext context) {
    onContext(context);
    return Scaffold(
      body: Column(
        children: [
          // A text field with content, so a long press can raise the
          // text-selection menu (its labels are framework strings).
          TextField(controller: TextEditingController(text: 'contact')),
          ElevatedButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (context) => AlertDialog(
                content: const Text('body'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      MaterialLocalizations.of(context).okButtonLabel,
                    ),
                  ),
                ],
              ),
            ),
            child: const Text('dialog'),
          ),
          ElevatedButton(
            onPressed: () => showDatePicker(
              context: context,
              initialDate: DateTime(2026, 1, 15),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            ),
            child: const Text('date'),
          ),
        ],
      ),
    );
  }
}

/// Wraps [_Harness] in a MaterialApp fixed to [locale] with the app's delegates.
Widget _appUnderLocale(
  String locale,
  List<LocalizationsDelegate<dynamic>> delegates,
  void Function(BuildContext context) onContext,
) {
  return MaterialApp(
    locale: Locale(locale),
    localizationsDelegates: delegates,
    supportedLocales: const [Locale('en'), Locale('ml'), Locale('sa')],
    home: _Harness(onContext: onContext),
  );
}

void main() {
  testWidgets(
    'the app registers each Sanskrit delegate before the Global one',
    (tester) async {
      final delegates = await _appDelegates(tester);

      // The app's own strings answer first.
      expect(
        delegates.indexOf(AppLocalizations.delegate),
        0,
        reason: 'AppLocalizations.delegate must be first',
      );

      final pairs = <String, List<int>>{
        'Material': [
          delegates.indexWhere((d) => d is SaMaterialLocalizationsDelegate),
          delegates.indexOf(GlobalMaterialLocalizations.delegate),
        ],
        'Cupertino': [
          delegates.indexWhere((d) => d is SaCupertinoLocalizationsDelegate),
          delegates.indexOf(GlobalCupertinoLocalizations.delegate),
        ],
        'Widgets': [
          delegates.indexWhere((d) => d is SaWidgetsLocalizationsDelegate),
          delegates.indexOf(GlobalWidgetsLocalizations.delegate),
        ],
      };

      for (final entry in pairs.entries) {
        final sa = entry.value[0];
        final global = entry.value[1];
        expect(
          sa,
          isNonNegative,
          reason: 'Sa${entry.key}LocalizationsDelegate must be registered',
        );
        expect(
          global,
          isNonNegative,
          reason: 'Global${entry.key}Localizations.delegate must be registered',
        );
        expect(
          sa,
          lessThan(global),
          reason:
              'Sa${entry.key}LocalizationsDelegate must come before the Global '
              'one, or the Global delegate answers first and `sa` crashes',
        );
      }
    },
  );

  testWidgets('a date picker and a dialog open under sa without throwing', (
    tester,
  ) async {
    final delegates = await _appDelegates(tester);
    BuildContext? captured;

    await tester.pumpWidget(
      _appUnderLocale('sa', delegates, (context) => captured = context),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(Localizations.localeOf(captured!), const Locale('sa'));

    // The dialog — its buttons are framework strings.
    await tester.tap(find.text('dialog'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // The date picker — the widget that reads the most framework strings.
    await tester.tap(find.text('date'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(DatePickerDialog), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('the text-selection menu builds under sa', (tester) async {
    final delegates = await _appDelegates(tester);

    await tester.pumpWidget(_appUnderLocale('sa', delegates, (_) {}));
    await tester.pumpAndSettle();

    await tester.longPress(find.byType(TextField));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('sa resolves the English framework strings, never Hindi', (
    tester,
  ) async {
    final delegates = await _appDelegates(tester);
    final english = await GlobalMaterialLocalizations.delegate.load(
      const Locale('en'),
    );
    BuildContext? captured;

    await tester.pumpWidget(
      _appUnderLocale('sa', delegates, (context) => captured = context),
    );
    await tester.pumpAndSettle();

    final material = MaterialLocalizations.of(captured!);
    expect(material.okButtonLabel, english.okButtonLabel);
    expect(material.cancelButtonLabel, english.cancelButtonLabel);
    expect(material.pasteButtonLabel, english.pasteButtonLabel);
    expect(material.datePickerHelpText, english.datePickerHelpText);

    // Cupertino and Widgets resolve too — the other two delegates.
    expect(
      CupertinoLocalizations.of(captured!).datePickerHourSemanticsLabel(9),
      isNotEmpty,
    );
    expect(WidgetsLocalizations.of(captured!).reorderItemUp, isNotEmpty);

    // The app's own strings stay Sanskrit — that is the point of the shim.
    expect(AppLocalizations.of(captured!).localeName, 'sa');
  });

  testWidgets('the Sanskrit delegates do not steal en or ml', (tester) async {
    final delegates = await _appDelegates(tester);

    for (final code in const ['en', 'ml']) {
      final expected = await GlobalMaterialLocalizations.delegate.load(
        Locale(code),
      );
      BuildContext? captured;

      await tester.pumpWidget(
        _appUnderLocale(code, delegates, (context) => captured = context),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$code must still build');

      expect(
        MaterialLocalizations.of(captured!).okButtonLabel,
        expected.okButtonLabel,
        reason: '$code must keep its own framework strings',
      );

      // The screens section 8.3.1 names still open in these locales.
      await tester.tap(find.text('date'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(DatePickerDialog), findsOneWidget);

      // Close it before the next locale: the MaterialApp is reused across
      // iterations, so a left-open route would block the next tap.
      Navigator.of(captured!, rootNavigator: true).pop();
      await tester.pumpAndSettle();
    }
  });
}
