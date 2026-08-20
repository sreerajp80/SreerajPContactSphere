import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_contacts_dialer/screens/features_screen.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

void main() {
  testWidgets('FeaturesScreen displays feature titles and highlights', (WidgetTester tester) async {
    final theme = AppTheme.calm(const Color(0xFF007A78));

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: const FeaturesScreen(),
      ),
    );

    expect(find.text('Features'), findsOneWidget);
    expect(find.text('SreerajP Contacts Sphere Features'), findsOneWidget);
    expect(find.text('Smart Redial & "Reach Me" Mode'), findsOneWidget);
    expect(find.text('Editable Dialer & Precision Editing'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -1000));
    await tester.pump();

    expect(find.text('Relationship Context Cards'), findsOneWidget);
  });
}
