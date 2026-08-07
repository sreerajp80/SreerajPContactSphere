// lib/widgets/avatar_initial.dart
import 'package:flutter/material.dart';

/// The initial letter drawn inside an avatar circle or tile.
///
/// Always one line, and shrinks to fit rather than wrapping or spilling out of
/// the avatar. That matters for Malayalam: even after [initialFor] strips the
/// vowel signs, a wide base letter at a large font size can still be broader
/// than a small avatar, and a plain [Text] would wrap it onto a second line
/// half outside the circle.
class AvatarInitial extends StatelessWidget {
  const AvatarInitial(this.initial, {super.key, this.style});

  /// The letter to draw — normally the result of `initialFor(name)`.
  final String initial;

  /// Base text style. The font size in it is the *maximum*: the letter is
  /// scaled down from there when it would not fit.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Padding(
        // Breathing room so a scaled letter never touches the circle's edge.
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Text(
          initial,
          maxLines: 1,
          softWrap: false,
          textAlign: TextAlign.center,
          style: style,
        ),
      ),
    );
  }
}
