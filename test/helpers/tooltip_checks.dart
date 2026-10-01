// test/helpers/tooltip_checks.dart
//
// Engineering standard §7.8: every icon-only control carries a tooltip. Call
// [expectAllIconButtonsHaveTooltips] after pumping a screen, in each of the
// three locales, so a button added without one fails the screen's test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fails when an [IconButton], [FloatingActionButton] or [PopupMenuButton] on
/// screen has no tooltip, or an empty one.
void expectAllIconButtonsHaveTooltips(WidgetTester tester) {
  bool filled(String? text) => text != null && text.trim().isNotEmpty;

  for (final button in tester.widgetList<IconButton>(find.byType(IconButton))) {
    expect(
      filled(button.tooltip),
      isTrue,
      reason: 'IconButton with icon ${button.icon} has no tooltip',
    );
  }
  for (final fab in tester.widgetList<FloatingActionButton>(
    find.byType(FloatingActionButton),
  )) {
    // An extended FAB shows its own label, so it needs no tooltip.
    if (fab.isExtended) continue;
    expect(
      filled(fab.tooltip),
      isTrue,
      reason: 'FloatingActionButton has no tooltip',
    );
  }
  final menus = find.byWidgetPredicate((w) => w is PopupMenuButton);
  for (final menu in tester.widgetList<PopupMenuButton<dynamic>>(menus)) {
    expect(
      filled(menu.tooltip),
      isTrue,
      reason: 'PopupMenuButton has no tooltip',
    );
  }
}
