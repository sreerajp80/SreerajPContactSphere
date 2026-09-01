// lib/widgets/keyboard_inset_guard.dart
import 'package:flutter/material.dart';

/// Drops a bottom view-inset that no text field asked for.
///
/// A call arriving while the keyboard is open changes the activity's window
/// underneath the IME (show-when-locked flags flip, the call may come up over
/// the keyguard, the task is moved to the back when it ends). The IME is
/// dismissed during that transition while the activity is paused, and the
/// resulting inset update can fail to reach the engine — Flutter then keeps the
/// stale keyboard height in `MediaQuery.viewInsets`.
///
/// The damage is easy to see: every [Scaffold] shrinks its **body** by that
/// phantom inset while leaving the bottom bar pinned to the true bottom, so the
/// whole app looks cropped — a short list, a blank band, and a FAB or a keypad
/// overlapping the content above it — until the app is restarted.
///
/// `MainActivity` asks Android to re-send the insets at the two moments the
/// window is known to change; this widget is the safety net for whatever that
/// misses. Placed above the [Navigator] (see `MaterialApp.builder`) so every
/// route is covered.
///
/// It only ever *removes* an inset that nothing is using, and it is deliberately
/// conservative: while a text field holds focus — or while the focus can't be
/// inspected — the inset is passed through untouched, so a real keyboard still
/// resizes the body exactly as before.
class KeyboardInsetGuard extends StatefulWidget {
  final Widget child;

  const KeyboardInsetGuard({super.key, required this.child});

  @override
  State<KeyboardInsetGuard> createState() => _KeyboardInsetGuardState();
}

class _KeyboardInsetGuardState extends State<KeyboardInsetGuard> {
  bool _textFocused = false;

  @override
  void initState() {
    super.initState();
    _textFocused = _hasTextFocus();
    FocusManager.instance.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_onFocusChanged);
    super.dispose();
  }

  void _onFocusChanged() {
    final focused = _hasTextFocus();
    if (focused == _textFocused || !mounted) return;
    setState(() => _textFocused = focused);
  }

  /// True when the focused node belongs to a text field (so a keyboard is
  /// legitimately expected). Returns true when the focus can't be inspected —
  /// passing a real inset through is always safer than dropping one.
  ///
  /// The search goes *up* from the focused node: a text field's focus node
  /// lives inside its [EditableText], so an ancestor walk finds it. Searching
  /// downwards would not work — with nothing focused the primary focus is the
  /// root scope, whose subtree contains every field on screen.
  bool _hasTextFocus() {
    final focus = FocusManager.instance.primaryFocus;
    if (focus == null || !focus.hasFocus) return false;
    // Nothing has taken focus: the manager parks it on a scope, not on a field.
    if (focus is FocusScopeNode) return false;
    final context = focus.context;
    if (context is! Element) return true;
    if (context.widget is EditableText) return true;
    var found = false;
    context.visitAncestorElements((element) {
      if (element.widget is EditableText) {
        found = true;
        return false;
      }
      return true;
    });
    return found;
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    if (_textFocused || media.viewInsets.bottom <= 0) return widget.child;
    return MediaQuery(
      data: media.copyWith(
        viewInsets: media.viewInsets.copyWith(bottom: 0),
        // With the phantom keyboard gone, the system bar inset it had swallowed
        // is real padding again (this is what SafeArea reads).
        padding: media.padding.copyWith(bottom: media.viewPadding.bottom),
      ),
      child: widget.child,
    );
  }
}
