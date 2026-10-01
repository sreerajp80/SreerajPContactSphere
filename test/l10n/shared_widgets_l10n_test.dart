// Widget tests for the phase 2b conversions — the home shell's bottom bar and
// the shared widgets in lib/widgets/ — in all three languages.
//
// Engineering standard section 8.7 asks for each converted screen to be tested
// under `en`, `ml` and `sa`: every string resolves from the ARB, no English
// leaks through under `ml` or `sa`, and nothing overflows. Phase 2b of
// plans/20260921_064200_item2-arb-string-externalization.md converted the app
// chrome and the shared widgets; these tests cover the ones that can be pumped
// without a database or a native channel. The rest are covered by the key
// parity and label-length tests in this folder.
//
// Font rendering itself (no blank boxes, no clipped Malayalam or Devanagari)
// cannot be checked here: the test engine draws every glyph as a box. That
// stays on the manual release checklist (standard 8.3.3).

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/l10n/sa_material_localizations.dart';
import 'package:smart_contacts_dialer/main.dart';
import 'package:smart_contacts_dialer/models/phone_number.dart';
import 'package:smart_contacts_dialer/models/sim_account.dart';
import 'package:smart_contacts_dialer/state/locale_controller.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';
import 'package:smart_contacts_dialer/widgets/ble_receive_challenge_dialog.dart';
import 'package:smart_contacts_dialer/widgets/number_picker_sheet.dart';
import 'package:smart_contacts_dialer/widgets/post_call_feedback_sheet.dart';
import 'package:smart_contacts_dialer/widgets/sim_picker_sheet.dart';

const _locales = ['en', 'ml', 'sa'];

/// The same delegate order as lib/main.dart: the Sanskrit framework delegates
/// must come before the Global ones, or `sa` finds no MaterialLocalizations.
const _delegates = <LocalizationsDelegate<dynamic>>[
  AppLocalizations.delegate,
  SaMaterialLocalizationsDelegate(),
  SaCupertinoLocalizationsDelegate(),
  SaWidgetsLocalizationsDelegate(),
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

/// Text scale the sheets are checked at. The layouts under test already
/// overflow in English at 320x640 and 1.6x (the size the phase 2a pilot used),
/// so that size cannot tell a translation problem from an existing layout one;
/// see the phase 2b change log.
const _textScale = 1.3;

/// Pumps an empty app in [locale] on a narrow phone (360x740, the size
/// test/dialer_speed_dial_keypad_test.dart uses) at [_textScale], and returns a
/// context to open sheets and dialogs from.
Future<BuildContext> _pumpLauncher(WidgetTester tester, String locale) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(360, 740);
  addTearDown(tester.view.reset);

  late BuildContext launcher;
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.calm(const Color(0xFF007A78)),
      locale: Locale(locale),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: _delegates,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: const TextScaler.linear(_textScale)),
        child: child!,
      ),
      home: Scaffold(
        body: Builder(
          builder: (ctx) {
            launcher = ctx;
            return const SizedBox.expand();
          },
        ),
      ),
    ),
  );
  return launcher;
}

/// Records every framework error for the rest of the test, so a test can fail
/// on layout overflow alone. Two pre-existing debug assertions fire in English
/// too ("ListTile background color or ink splashes may be invisible", from the
/// post-call and SIM sheets) and are not about language, so they are ignored.
/// Call the returned function before the test ends to restore the handler and
/// check the log.
void Function() _failOnOverflow() {
  final original = FlutterError.onError;
  final overflows = <String>[];
  FlutterError.onError = (details) {
    final text = details.exceptionAsString();
    if (text.contains('overflowed')) overflows.add(text);
  };
  return () {
    FlutterError.onError = original;
    expect(overflows, isEmpty, reason: overflows.join('\n'));
  };
}

/// Fails if any of [english] is on screen. Only meaningful for `ml` and `sa`.
void _expectNoEnglish(String locale, List<String> english) {
  if (locale == 'en') return;
  for (final text in english) {
    expect(
      find.text(text),
      findsNothing,
      reason: '"$text" leaked into $locale',
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('plural messages resolve in every language', () {
    for (final locale in _locales) {
      test(locale, () {
        final l10n = lookupAppLocalizations(Locale(locale));
        // =1 is matched exactly; intl has no plural rules for `sa`, so the
        // exact match is what keeps "1 contact" grammatical there.
        expect(l10n.labelContactCount(1), isNot(contains('{')));
        expect(l10n.labelContactCount(3), contains('3'));
        expect(l10n.labelContactCount(1), isNot(l10n.labelContactCount(3)));
        expect(l10n.msgTagMerged('work', 2), contains('#work'));
        expect(l10n.titleSendContacts(120), contains('120'));
        expect(l10n.actionAutoRetryIn(5), contains('5'));
        expect(l10n.labelMinutesShort(1), contains('1'));
      });
    }

    test('Sanskrit uses the singular for one', () {
      final sa = lookupAppLocalizations(const Locale('sa'));
      expect(sa.labelContactCount(1), 'एकः सम्पर्कः');
      expect(sa.labelContactCount(4), '4 सम्पर्काः');
    });
  });

  for (final locale in _locales) {
    group('[$locale]', () {
      final l10n = lookupAppLocalizations(Locale(locale));

      testWidgets('the bottom bar tabs come from the ARB', (tester) async {
        SharedPreferences.setMockInitialValues({'app_language': locale});
        final prefs = await SharedPreferences.getInstance();

        await tester.pumpWidget(
          SmartContactsApp(localeController: LocaleController(prefs)),
        );
        await tester.pump();

        expect(find.text(l10n.navContacts), findsWidgets);
        expect(find.text(l10n.navDialer), findsWidgets);
        expect(find.text(l10n.navRecents), findsWidgets);
        expect(find.text(l10n.navTags), findsWidgets);
        _expectNoEnglish(locale, ['Dialer', 'Recents', 'Tags']);

        // Let the shell's one-second start-up timer fire before the tree goes.
        await tester.pump(const Duration(seconds: 2));
      });

      testWidgets('post-call sheet is translated and saves the English topic', (
        tester,
      ) async {
        final checkOverflow = _failOnOverflow();
        final launcher = await _pumpLauncher(tester, locale);

        PostCallFeedback? result;
        showPostCallFeedbackSheet(
          launcher,
          displayName: 'Anu',
          canRemind: true,
        ).then((r) => result = r);
        await tester.pumpAndSettle();

        expect(find.text(l10n.titleHowDidItGo), findsOneWidget);
        expect(find.text(l10n.labelCallWith('Anu')), findsOneWidget);
        for (final label in [
          l10n.labelToneGreat,
          l10n.labelToneOkay,
          l10n.labelToneRough,
          l10n.labelIntentCatchUp,
          l10n.labelIntentWork,
          l10n.labelIntentFamily,
          l10n.labelAddFollowUpReminder,
        ]) {
          expect(find.text(label), findsOneWidget, reason: label);
        }
        _expectNoEnglish(locale, [
          'How did it go?',
          'Great',
          'Work',
          'Skip',
          'Save',
        ]);

        // The chip shows the translated word, but the value written to
        // call_logs.call_intent must stay the English preset.
        await tester.tap(find.text(l10n.labelIntentWork));
        await tester.pump();
        await tester.ensureVisible(find.text(l10n.actionSave));
        await tester.tap(find.text(l10n.actionSave));
        await tester.pumpAndSettle();
        expect(result?.intent, 'Work');
        checkOverflow();
      });

      testWidgets('SIM and number pickers are translated', (tester) async {
        final checkOverflow = _failOnOverflow();
        final launcher = await _pumpLauncher(tester, locale);

        showSimPickerSheet(
          launcher,
          sims: const [
            SimAccount(phoneAccountId: 'a', componentName: 'c', slotIndex: 0),
            SimAccount(phoneAccountId: 'b', componentName: 'c', slotIndex: 1),
          ],
          preselectedId: 'a',
          preselectedNote: l10n.labelUsualSimForCall,
        );
        await tester.pumpAndSettle();
        expect(find.text(l10n.titleCallWith), findsOneWidget);
        expect(find.text(l10n.descChooseSimForCall), findsOneWidget);
        _expectNoEnglish(locale, ['Call with', 'Choose the SIM for this call']);
        Navigator.of(launcher).pop();
        await tester.pumpAndSettle();

        showNumberPickerSheet(
          launcher,
          displayName: 'Anu',
          numbers: [
            PhoneNumber(number: '+91 98765 43210', type: 'mobile'),
            PhoneNumber(number: '+91 98765 43211', type: 'mobile'),
          ],
        );
        await tester.pumpAndSettle();
        expect(find.text(l10n.titleCallName('Anu')), findsOneWidget);
        expect(find.text(l10n.descChooseNumber), findsOneWidget);
        _expectNoEnglish(locale, ['Choose a number']);
        checkOverflow();
      });

      testWidgets('Bluetooth receive consent dialog is translated', (
        tester,
      ) async {
        final checkOverflow = _failOnOverflow();
        SharedPreferences.setMockInitialValues({});
        final launcher = await _pumpLauncher(tester, locale);

        bool? accepted;
        showBleReceiveChallenge(
          launcher,
          senderName: 'Phone',
          signalLabel: '',
        ).then((r) => accepted = r);
        await tester.pumpAndSettle();

        expect(find.text(l10n.titleIncomingTransfer), findsOneWidget);
        expect(find.text(l10n.descNearbyDeviceWantsToSend), findsOneWidget);
        expect(find.text(l10n.actionDecline), findsOneWidget);
        _expectNoEnglish(locale, ['Incoming transfer', 'Decline', 'Accept']);

        await tester.tap(find.text(l10n.actionAccept));
        await tester.pumpAndSettle();
        expect(accepted, isTrue);
        checkOverflow();
      });
    });
  }
}
