// lib/widgets/sim_picker_sheet.dart
import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/models/sim_account.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

/// Bottom sheet asking which SIM to place a call on. Returns the chosen
/// [SimAccount], or null if the user dismissed it (call should be aborted).
///
/// Shown by [CallLifecycleMixin] when "ask which SIM before each call" is on and
/// the device has more than one SIM.
Future<SimAccount?> showSimPickerSheet(
  BuildContext context, {
  required List<SimAccount> sims,
}) {
  return showModalBottomSheet<SimAccount>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) => _SimPickerSheet(sims: sims),
  );
}

class _SimPickerSheet extends StatelessWidget {
  const _SimPickerSheet({required this.sims});

  final List<SimAccount> sims;

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
            const Text(
              'Call with',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              'Choose the SIM for this call',
              style: TextStyle(color: colors.mutedText, fontSize: 13),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < sims.length; i++)
              _simTile(context, sims[i], accent, colors),
          ],
        ),
      ),
    );
  }

  Widget _simTile(
    BuildContext context,
    SimAccount sim,
    Color accent,
    AppColors colors,
  ) {
    final slot = sim.slotIndex != null ? 'SIM ${sim.slotIndex! + 1}' : 'SIM';
    final subtitle = <String>[
      slot,
      if (sim.carrierName != null && sim.carrierName!.trim().isNotEmpty)
        sim.carrierName!.trim(),
    ].where((s) => s != sim.displayLabel).join(' · ');

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
        onTap: () => Navigator.pop(context, sim),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.sim_card_outlined, color: accent),
        ),
        title: Text(
          sim.displayLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: subtitle.isEmpty
            ? null
            : Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: colors.mutedText, fontSize: 12.5),
              ),
        trailing: Icon(Icons.chevron_right, color: colors.mutedText),
      ),
    );
  }
}
