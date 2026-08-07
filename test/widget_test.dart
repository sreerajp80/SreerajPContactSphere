// Smoke test for SmartContactsApp.
//
// Verifies the app builds and renders its shell — the HomeShell bottom bar
// with its three tabs, defaulting to the Contacts tab — without needing a
// database (the contact list simply loads empty here). HomeShell draws a
// custom bottom bar (not the Material NavigationBar — see home_shell.dart),
// so the shell is asserted through its tab labels.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_contacts_dialer/main.dart';

void main() {
  testWidgets('SmartContactsApp renders the home shell', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SmartContactsApp());
    await tester.pump();

    // The three primary destinations of the HomeShell's bottom bar.
    expect(find.text('Dialer'), findsWidgets);
    expect(find.text('Recents'), findsWidgets);

    // The default (Contacts) tab renders its header and search field.
    expect(find.text('Contacts'), findsWidgets);
    expect(find.byType(TextField), findsOneWidget);
  });
}
