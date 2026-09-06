import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_contacts_dialer/models/relationship.dart';
import 'package:smart_contacts_dialer/screens/features_screen.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

/// The Features screen is a `ListView`, which builds only what fits on screen.
/// A tall viewport builds the whole page in one pass so a `find.text` for a
/// later category still works.
Future<void> _pumpTall(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(1000, 12000);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.calm(const Color(0xFF007A78)),
      home: const FeaturesScreen(),
    ),
  );
}

/// The page's own source. The claims this file guards are `const` strings, so
/// reading the file is the cheapest way to assert on all of them at once —
/// including the ones that must NOT be there.
String _source() => File('lib/screens/features_screen.dart').readAsStringSync();

void main() {
  testWidgets('FeaturesScreen renders every category', (tester) async {
    await _pumpTall(tester);

    expect(find.text('Features'), findsOneWidget);
    expect(find.text('SreerajP Contacts Sphere Features'), findsOneWidget);

    for (final category in const [
      'Smart Dialer & Calling',
      'In-Call & Caller Intelligence',
      'Contact Management & Relations',
      'Privacy, Security & Vault',
      'Instant Contact Sharing & Scanning',
      'Data Sync & Backup',
      'Call Defense & Spam Blocking',
      'Personalization & Accessibility',
    ]) {
      // The header renders the name in upper case.
      expect(
        find.text(category.toUpperCase()),
        findsOneWidget,
        reason: 'missing $category',
      );
    }

    expect(tester.takeException(), isNull);
  });

  test(
    'the seven relationship categories are named as the code defines them',
    () {
      final source = _source();
      for (final category in RelationshipCategory.values) {
        expect(
          source.contains(category.displayName),
          isTrue,
          reason:
              '"${category.displayName}" is one of the seven categories in '
              'RelationshipCategory but is not named on the Features screen',
        );
      }
    },
  );

  test('the page does not advertise features the app does not have', () {
    final source = _source().toLowerCase();

    // Each of these was claimed on this page but has no implementation.
    // If one is ever built, delete its line here and put the claim back.
    //
    // 'speed dial' and 'per-contact default sim' used to be on this list. Both
    // are now built (keypad keys 1-9, and `contacts.preferred_sim_id`), so they
    // moved to the "documented features are listed" test below.
    const unbuilt = {
      'carrier detection': 'nothing in the app detects a carrier',
      'headset-only': 'spoken announcements have no headset-only mode',
      'prefix/suffix': 'the announcement prefix cannot be customised',
      'conflict resolution':
          'contact sync skips matches, it does not merge them',
      'automatic backups': 'cloud backup is a manual upload',
      'custom labels & fields':
          'there are no custom fields, only custom labels',
      'color-coded tags': 'tags carry no colour',
      'wi-fi direct':
          'device sync uses the local Wi-Fi network, not Wi-Fi Direct',
    };

    unbuilt.forEach((claim, why) {
      expect(
        source.contains(claim),
        isFalse,
        reason: 'Features screen claims "$claim", but $why',
      );
    });
  });

  test('newly documented features are listed', () {
    final source = _source();
    for (final title in const [
      'Speed Dial',
      'Per-contact preferred SIM',
      'Voice Dial',
      'Temporary (Ephemeral) Contacts',
      'Connected Messaging Apps',
      'AirQR Animated Code Streaming',
      'CSV & vCard Import / Export',
      'Block Unknown Callers',
      'Caller Identification & Spam Filter',
      'App Lock: Off, Device Lock or App PIN',
      'Contact Counts & Search Index',
      'In-App Help & Guides',
    ]) {
      expect(
        source.contains(title),
        isTrue,
        reason: '"$title" should be listed on the Features screen',
      );
    }
  });

  // Kept from the original version of this test: individual feature cards
  // render, including one reached only after scrolling.
  testWidgets('FeaturesScreen displays feature titles and highlights', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.calm(const Color(0xFF007A78)),
        home: const FeaturesScreen(),
      ),
    );

    expect(find.text('Features'), findsOneWidget);
    expect(find.text('SreerajP Contacts Sphere Features'), findsOneWidget);
    expect(find.text('Smart Redial & "Reach Me" Mode'), findsOneWidget);
    expect(find.text('Editable Dialer & Precision Editing'), findsOneWidget);

    // Scroll until it appears rather than dragging a fixed distance, so adding
    // a feature above it does not break this test.
    await tester.scrollUntilVisible(
      find.text('Relationship Context Cards'),
      400,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Relationship Context Cards'), findsOneWidget);
  });
}
