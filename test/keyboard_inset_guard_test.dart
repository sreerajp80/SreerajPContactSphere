// test/keyboard_inset_guard_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_contacts_dialer/widgets/keyboard_inset_guard.dart';

const _probe = Key('probe');
const _keyboard = 300.0;

/// Mirrors how `main.dart` installs the guard: above the Navigator, via
/// `MaterialApp.builder`.
Widget _app(Widget body) => MaterialApp(
  builder: (context, child) => KeyboardInsetGuard(child: child!),
  home: Scaffold(body: body),
);

/// A window that reports a keyboard-sized bottom inset.
void _windowWithKeyboardInset(WidgetTester tester) {
  addTearDown(tester.view.reset);
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(400, 800);
  tester.view.viewInsets = const FakeViewPadding(bottom: _keyboard);
  tester.view.viewPadding = const FakeViewPadding(bottom: 24);
}

void main() {
  testWidgets('a stale keyboard inset with nothing focused is ignored', (
    tester,
  ) async {
    _windowWithKeyboardInset(tester);

    await tester.pumpWidget(
      _app(const SizedBox.expand(child: ColoredBox(key: _probe, color: Colors.red))),
    );
    await tester.pumpAndSettle();

    // Without the guard the body would be 800 - 300 = 500 high, and the app
    // would look cropped by exactly one keyboard.
    expect(tester.getSize(find.byKey(_probe)).height, 800);
  });

  testWidgets('a real keyboard still shrinks the body while a field is focused', (
    tester,
  ) async {
    _windowWithKeyboardInset(tester);

    final node = FocusNode();
    addTearDown(node.dispose);

    await tester.pumpWidget(
      _app(
        Column(
          children: [
            TextField(focusNode: node),
            const Expanded(child: ColoredBox(key: _probe, color: Colors.red)),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    final unfocused = tester.getSize(find.byKey(_probe)).height;

    node.requestFocus();
    await tester.pumpAndSettle();

    // Focus hands the inset back, so the body loses the keyboard's height.
    expect(unfocused - tester.getSize(find.byKey(_probe)).height, _keyboard);
  });

  testWidgets('the inset comes back when the field is unfocused again', (
    tester,
  ) async {
    _windowWithKeyboardInset(tester);

    final node = FocusNode();
    addTearDown(node.dispose);

    await tester.pumpWidget(
      _app(
        Column(
          children: [
            TextField(focusNode: node),
            const Expanded(child: ColoredBox(key: _probe, color: Colors.red)),
          ],
        ),
      ),
    );
    node.requestFocus();
    await tester.pumpAndSettle();
    final focused = tester.getSize(find.byKey(_probe)).height;

    node.unfocus();
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byKey(_probe)).height - focused, _keyboard);
  });
}
