import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_contacts_dialer/core/constants/app_version.g.dart';
import 'package:smart_contacts_dialer/core/constants/build_date.g.dart';
import 'package:smart_contacts_dialer/screens/about_screen.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

void main() {
  group('Build metadata constants', () {
    test('kAppVersion has expected format', () {
      expect(kAppVersion, isNotEmpty);
      expect(RegExp(r'^\d+\.\d+\.\d+(\+\d+)?$').hasMatch(kAppVersion), isTrue);
    });

    test('kBuildDate has YYYY-MM-DD format', () {
      expect(kBuildDate, isNotEmpty);
      expect(RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(kBuildDate), isTrue);
    });
  });

  group('AboutScreen', () {
    testWidgets('displays Build Date row along with Version', (tester) async {
      final theme = AppTheme.calm(const Color(0xFF007A78));

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const AboutScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('About'), findsOneWidget);
      expect(find.text('Version'), findsOneWidget);
      expect(find.text('Build Date'), findsOneWidget);
      expect(find.text(kBuildDate), findsOneWidget);
    });
  });
}
