// lib/widgets/number_picker_sheet.dart
import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/models/phone_number.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

/// Compact bottom sheet asking which of a contact's numbers to dial. Returns the
/// chosen [PhoneNumber], or null if the sheet was dismissed (call aborted).
///
/// Shown on a long-press of the list's Call button; the normal SIM chooser then
/// runs afterwards via [CallLifecycleMixin.startCall].
Future<PhoneNumber?> showNumberPickerSheet(
  BuildContext context, {
  required String displayName,
  required List<PhoneNumber> numbers,
}) {
  return showModalBottomSheet<PhoneNumber>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) =>
        _NumberPickerSheet(displayName: displayName, numbers: numbers),
  );
}

class _NumberPickerSheet extends StatelessWidget {
  const _NumberPickerSheet({required this.displayName, required this.numbers});

  final String displayName;
  final List<PhoneNumber> numbers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final accent = theme.colorScheme.primary;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Call $displayName',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              'Choose a number',
              style: TextStyle(color: colors.mutedText, fontSize: 13),
            ),
            const SizedBox(height: 12),
            for (final ph in numbers) _numberTile(context, ph, accent, colors),
          ],
        ),
      ),
    );
  }

  Widget _numberTile(
    BuildContext context,
    PhoneNumber ph,
    Color accent,
    AppColors colors,
  ) {
    final label = ph.label?.trim();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: colors.isDark
            ? Border.all(color: Colors.white.withValues(alpha: 0.06))
            : null,
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onTap: () => Navigator.pop(context, ph),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.phone, color: accent),
        ),
        title: Text(
          ph.number,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: (label != null && label.isNotEmpty)
            ? Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: colors.mutedText, fontSize: 12.5),
              )
            : null,
        trailing: Icon(Icons.chevron_right, color: colors.mutedText),
      ),
    );
  }
}
