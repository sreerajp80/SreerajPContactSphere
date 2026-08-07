// lib/widgets/pin_keypad.dart
import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/theme/app_theme.dart';

/// A row of filled/empty dots showing how many digits of a PIN have been
/// entered. Used above [PinKeypad] on the setup and lock screens.
class PinDots extends StatelessWidget {
  final int length;
  final int filled;

  /// When true the dots flash in an error color (e.g. a wrong PIN).
  final bool error;

  const PinDots({
    super.key,
    required this.length,
    required this.filled,
    this.error = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final accent = theme.colorScheme.primary;
    final on = error ? theme.colorScheme.error : accent;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (i) {
        final active = i < filled;
        return Container(
          width: 16,
          height: 16,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? on : Colors.transparent,
            border: Border.all(color: active ? on : colors.mutedText, width: 2),
          ),
        );
      }),
    );
  }
}

/// An on-screen numeric keypad (0–9 plus a backspace) styled from [AppColors].
/// Purely presentational: it reports taps via [onDigit] / [onBackspace] and
/// keeps no state of its own.
class PinKeypad extends StatelessWidget {
  final ValueChanged<int> onDigit;
  final VoidCallback onBackspace;

  const PinKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in const [
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9],
        ])
          _row(context, row.map(_digitKey).toList()),
        _row(context, [
          const SizedBox(width: 76, height: 76),
          _digitKey(0),
          _backspaceKey(context),
        ]),
      ],
    );
  }

  Widget _row(BuildContext context, List<Widget> children) =>
      Row(mainAxisAlignment: MainAxisAlignment.center, children: children);

  Widget _digitKey(int digit) =>
      _KeyButton(label: '$digit', onTap: () => onDigit(digit));

  Widget _backspaceKey(BuildContext context) =>
      _KeyButton(icon: Icons.backspace_outlined, onTap: onBackspace);
}

class _KeyButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  const _KeyButton({this.label, this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: colors.searchFill,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 76,
            height: 76,
            child: Center(
              child: icon != null
                  ? Icon(icon, size: 24, color: colors.mutedText)
                  : Text(
                      label!,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
