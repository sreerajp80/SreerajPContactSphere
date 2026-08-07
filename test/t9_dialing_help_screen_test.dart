import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_contacts_dialer/screens/help/t9_dialing_help_screen.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

void main() {
  testWidgets('T9DialingHelpScreen displays Malayalam vowel mappings and T9 instructions',
      (WidgetTester tester) async {
    final theme = AppTheme.calm(const Color(0xFF007A78));

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: const T9DialingHelpScreen(),
      ),
    );

    expect(find.text('T9 Dialing & Malayalam'), findsOneWidget);
    expect(find.text('Malayalam Vowels Mapping (അ to അഃ)'), findsOneWidget);
    expect(find.textContaining('Key 2 (ക-ങ): Vowels അ, ആ'), findsOneWidget);
    expect(find.textContaining('Key 3 (ച-ഞ): Vowels ഉ, ഊ'), findsOneWidget);
    expect(find.textContaining('Key 4 (ട-ണ): Vowels എ, ഏ'), findsOneWidget);
    expect(find.textContaining('Key 5 (ത-ന): Vowels ഒ, ഓ'), findsOneWidget);
  });
}
