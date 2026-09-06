// test/in_call_route_recovery_test.dart
//
// Pins the stop rule used when the app clears whatever is stacked over the
// calling screen — the call-ended clean-up and the notification-tap recovery.
//
// The security case matters most: `popUntil` pops with `Navigator.pop`, which
// ignores `PopScope`, so a rule that walked past the app-lock route would
// dismiss the lock with no PIN or biometric check.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_contacts_dialer/main.dart';

/// A plain page used as a stand-in for one of the real screens.
MaterialPageRoute<void> _page(String label) => MaterialPageRoute<void>(
  builder: (_) => Scaffold(body: Center(child: Text(label))),
);

void main() {
  /// Builds a navigator holding a home route and returns its state.
  Future<NavigatorState> pumpNavigator(WidgetTester tester) async {
    final key = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: key,
        home: const Scaffold(body: Center(child: Text('home'))),
      ),
    );
    return key.currentState!;
  }

  testWidgets('the pop stops at the app lock, leaving it on screen', (
    tester,
  ) async {
    final nav = await pumpNavigator(tester);

    // The calling screen, then Add call over it (which buries the calling
    // screen), then the app lock on top after a background/resume.
    final inCall = _page('in call');
    final addCall = _page('add call');
    final lock = _page('app lock');
    nav.push(inCall);
    nav.push(addCall);
    nav.push(lock);
    await tester.pumpAndSettle();

    nav.popUntil(inCallPopStop(inCall, lock));
    await tester.pumpAndSettle();

    // The lock survives and is still the visible route: the user must still
    // authenticate. Nothing below it was reached.
    expect(lock.isActive, isTrue);
    expect(lock.isCurrent, isTrue);
    expect(find.text('app lock'), findsOneWidget);
    expect(addCall.isActive, isTrue);
  });

  testWidgets('with no lock up, the pop still unburies the calling screen', (
    tester,
  ) async {
    final nav = await pumpNavigator(tester);

    final inCall = _page('in call');
    final addCall = _page('add call');
    nav.push(inCall);
    nav.push(addCall);
    await tester.pumpAndSettle();

    nav.popUntil(inCallPopStop(inCall, null));
    await tester.pumpAndSettle();

    expect(inCall.isCurrent, isTrue);
    expect(addCall.isActive, isFalse);
    expect(find.text('in call'), findsOneWidget);
  });

  testWidgets('a stale lock route that is gone does not block the pop', (
    tester,
  ) async {
    final nav = await pumpNavigator(tester);

    final inCall = _page('in call');
    final addCall = _page('add call');
    final goneLock = _page('old lock');
    nav.push(inCall);
    nav.push(addCall);
    await tester.pumpAndSettle();

    // [goneLock] was never pushed, so it can never match: the rule falls back to
    // the calling route, which is the behaviour we want.
    nav.popUntil(inCallPopStop(inCall, goneLock));
    await tester.pumpAndSettle();

    expect(inCall.isCurrent, isTrue);
  });

  testWidgets('the first route is the backstop when the target is not there', (
    tester,
  ) async {
    final nav = await pumpNavigator(tester);

    final orphan = _page('orphan');
    final other = _page('other');
    nav.push(other);
    await tester.pumpAndSettle();

    // [orphan] is not on the stack, so only `isFirst` can stop the walk.
    nav.popUntil(inCallPopStop(orphan, null));
    await tester.pumpAndSettle();

    expect(find.text('home'), findsOneWidget);
    expect(other.isActive, isFalse);
  });
}
