// Tests for phase 2c of plans/20260921_064200_item2-arb-string-externalization.md
// — the core screens (contact list, dialer, call history, contact detail,
// add/edit contact, in-call) — in all three languages.
//
// The screens that open without a database or a phone call are pumped for
// real inside the app shell: Contacts (the start tab), Dialer and Recents.
// Contact detail, add/edit and in-call need a stored contact or a live call, so
// their strings are covered by the ARB parity and label-length tests, and the
// helpers they share with the other screens are unit-tested here.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/l10n/stored_labels.dart';
import 'package:smart_contacts_dialer/main.dart';
import 'package:smart_contacts_dialer/state/locale_controller.dart';
import 'package:smart_contacts_dialer/utils/call_type_mapper.dart';

import '../helpers/tooltip_checks.dart';

const _locales = ['en', 'ml', 'sa'];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('storedLabelText', () {
    test('translates saved presets and keeps everything else', () {
      final ml = lookupAppLocalizations(const Locale('ml'));
      expect(storedLabelText(ml, 'Mobile'), ml.labelTypeMobile);
      expect(storedLabelText(ml, 'Work'), ml.labelTypeWork);
      expect(storedLabelText(ml, 'Female'), ml.labelGenderFemale);
      expect(storedLabelText(ml, 'official'), ml.labelAddressOfficial);
      // A brand name and a label the user typed are shown as saved.
      expect(storedLabelText(ml, 'LinkedIn'), 'LinkedIn');
      expect(storedLabelText(ml, 'Gym buddy'), 'Gym buddy');
    });

    test('English shows the saved word itself', () {
      final en = lookupAppLocalizations(const Locale('en'));
      for (final v in ['Mobile', 'Home', 'Work', 'Personal', 'Male']) {
        expect(storedLabelText(en, v), v);
      }
    });
  });

  group('callOutcomeLabel', () {
    test('is English without l10n, as the unit tests and services expect', () {
      expect(callOutcomeLabel(AppCallOutcome.busy), 'Busy');
    });

    test('follows the language when l10n is given', () {
      final sa = lookupAppLocalizations(const Locale('sa'));
      expect(
        callOutcomeLabel(AppCallOutcome.busy, null, sa),
        sa.labelOutcomeBusy,
      );
      expect(
        callOutcomeLabel(AppCallOutcome.noAnswer, AppCallType.incoming, sa),
        sa.labelOutcomeMissed,
      );
      expect(callOutcomeLabel(AppCallOutcome.answered, null, sa), isNull);
    });
  });

  for (final locale in _locales) {
    testWidgets('[$locale] Contacts, Dialer and Recents show translated text', (
      tester,
    ) async {
      final l10n = lookupAppLocalizations(Locale(locale));
      // The app is portrait-only; a phone-sized window, as in
      // test/dialer_speed_dial_keypad_test.dart, not the 800x600 default.
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(360, 740);
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({'app_language': locale});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        SmartContactsApp(localeController: LocaleController(prefs)),
      );
      await tester.pump();

      // Contacts (start tab): header, search hint, filter chips.
      expect(find.text(l10n.hintSearchContacts), findsOneWidget);
      expect(find.text(l10n.labelAll), findsOneWidget);
      expect(find.text(l10n.labelFavorites), findsWidgets);
      expectAllIconButtonsHaveTooltips(tester);

      // Dialer tab.
      await tester.tap(find.text(l10n.navDialer).last);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text(l10n.hintStartTypingToFind), findsOneWidget);
      expectAllIconButtonsHaveTooltips(tester);

      // Recents tab.
      await tester.tap(find.text(l10n.navRecents).last);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text(l10n.hintSearchCalls), findsOneWidget);
      expectAllIconButtonsHaveTooltips(tester);

      if (locale != 'en') {
        for (final english in [
          'Search contacts',
          'All',
          'Start typing to find a contact',
          'Search calls',
          'Favorites',
        ]) {
          expect(find.text(english), findsNothing, reason: english);
        }
      }

      // Let the shell's one-second start-up timer fire before the tree goes.
      await tester.pump(const Duration(seconds: 2));
    });
  }
}
