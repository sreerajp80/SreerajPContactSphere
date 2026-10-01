// lib/screens/sim_preferences_screen.dart
import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_contacts_dialer/models/sim_account.dart';
import 'package:smart_contacts_dialer/services/sim_service.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

/// Manage SIM options: Default SIM for outgoing calls, Ask before each call toggle,
/// and display colours for SIM cards on the calling screen.
class SimPreferencesScreen extends StatefulWidget {
  const SimPreferencesScreen({super.key});

  @override
  State<SimPreferencesScreen> createState() => _SimPreferencesScreenState();
}

class _SimPreferencesScreenState extends State<SimPreferencesScreen> {
  final SimService _sims = SimService();
  List<SimAccount> _accounts = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool refresh = false}) async {
    if (mounted) setState(() => _loading = true);
    List<SimAccount> sims;
    try {
      sims = await _sims.list(refresh: refresh);
    } catch (_) {
      sims = const [];
    }
    if (!mounted) return;
    setState(() {
      _accounts = sims;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).labelSimCardsAccounts),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: AppLocalizations.of(context).tooltipRefreshSims,
            onPressed: _loading ? null : () => _load(refresh: true),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                if (_accounts.isEmpty)
                  _noSimsNote(colors)
                else ...[
                  _defaultSimCard(colors),
                  const SizedBox(height: 12),
                  _askSimCard(colors),
                  const SizedBox(height: 12),
                  _simColorsCard(colors),
                ],
              ],
            ),
    );
  }

  Widget _noSimsNote(AppColors colors) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.sim_card_alert_outlined, color: colors.mutedText),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                AppLocalizations.of(context).emptyNoSims,
                style: TextStyle(color: colors.mutedText, fontSize: 13.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultSimCard(AppColors colors) {
    final accent = Theme.of(context).colorScheme.primary;
    final settings = context.watch<AppSettings>();
    final selected = settings.defaultSimId;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).labelDefaultSim,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppLocalizations.of(context).descDefaultSimInfo,
                    style: TextStyle(color: colors.mutedText, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            _optionTile(
              colors: colors,
              accent: accent,
              selected: selected == null,
              title: AppLocalizations.of(context).labelSystemDefault,
              subtitle: AppLocalizations.of(context).descLetAndroidChoose,
              onTap: () => context.read<AppSettings>().setDefaultSimId(null),
            ),
            for (final sim in _accounts)
              _optionTile(
                colors: colors,
                accent: accent,
                selected: selected == sim.phoneAccountId,
                title: sim.displayLabel,
                subtitle: _simSubtitle(sim),
                onTap: () => context.read<AppSettings>().setDefaultSimId(
                  sim.phoneAccountId,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _askSimCard(AppColors colors) {
    final accent = Theme.of(context).colorScheme.primary;
    final settings = context.watch<AppSettings>();
    final ask = settings.askSimBeforeCall;
    final canAsk = _accounts.length > 1;

    return Card(
      margin: EdgeInsets.zero,
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        value: ask && canAsk,
        activeThumbColor: accent,
        onChanged: canAsk
            ? (v) => context.read<AppSettings>().setAskSimBeforeCall(v)
            : null,
        title: Text(
          AppLocalizations.of(context).labelAskSimEachCall,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          canAsk
              ? AppLocalizations.of(context).descAskSimEachCall
              : AppLocalizations.of(context).descNeedsMoreThanOneSim,
          style: TextStyle(color: colors.mutedText, fontSize: 13),
        ),
      ),
    );
  }

  Widget _simColorsCard(AppColors colors) {
    final settings = context.watch<AppSettings>();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).labelSimColours,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppLocalizations.of(context).descSimColoursInfo,
                    style: TextStyle(color: colors.mutedText, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            for (final sim in _accounts) _simColorTile(colors, settings, sim),
          ],
        ),
      ),
    );
  }

  Widget _simColorTile(AppColors colors, AppSettings settings, SimAccount sim) {
    final picked = settings.colorForSim(sim.phoneAccountId);
    final color = picked ?? AppTheme.defaultSimColor(sim.slotIndex);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _pickSimColor(sim, picked),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.mutedText.withValues(alpha: 0.4),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sim.displayLabel,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    picked == null
                        ? '${_simSubtitle(sim)} · ${AppLocalizations.of(context).labelDefaultColour}'
                        : _simSubtitle(sim),
                    style: TextStyle(color: colors.mutedText, fontSize: 12.5),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colors.mutedText, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _pickSimColor(SimAccount sim, Color? picked) async {
    final colors = Theme.of(context).extension<AppColors>()!;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).titleColourFor(sim.displayLabel),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    for (final choice in AppTheme.simColorChoices)
                      _colorSwatch(
                        sheetContext,
                        sim,
                        choice,
                        selected:
                            picked != null &&
                            picked.toARGB32() == choice.toARGB32(),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () {
                    context.read<AppSettings>().setSimColor(
                      sim.phoneAccountId,
                      null,
                    );
                    Navigator.of(sheetContext).pop();
                  },
                  icon: Icon(Icons.restart_alt, color: colors.mutedText),
                  label: Text(
                    AppLocalizations.of(context).actionUseDefault,
                    style: TextStyle(color: colors.mutedText),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _colorSwatch(
    BuildContext sheetContext,
    SimAccount sim,
    Color choice, {
    required bool selected,
  }) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: () {
        context.read<AppSettings>().setSimColor(sim.phoneAccountId, choice);
        Navigator.of(sheetContext).pop();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: choice, shape: BoxShape.circle),
        child: selected
            ? Icon(Icons.check, color: AppTheme.contrastOn(choice))
            : null,
      ),
    );
  }

  Widget _optionTile({
    required AppColors colors,
    required Color accent,
    required bool selected,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? accent : colors.mutedText,
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: TextStyle(color: colors.mutedText, fontSize: 12.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _simSubtitle(SimAccount sim) {
    final slot = sim.slotIndex != null ? 'SIM ${sim.slotIndex! + 1}' : 'SIM';
    final carrier = sim.carrierName?.trim();
    if (carrier != null && carrier.isNotEmpty && carrier != sim.displayLabel) {
      return '$slot · $carrier';
    }
    return slot;
  }
}
