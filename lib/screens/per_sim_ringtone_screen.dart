// lib/screens/per_sim_ringtone_screen.dart
import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_contacts_dialer/models/sim_account.dart';
import 'package:smart_contacts_dialer/services/sim_service.dart';
import 'package:smart_contacts_dialer/services/telecom_service.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

/// Configuration screen for Per-SIM ringtone selection.
class PerSimRingtoneScreen extends StatefulWidget {
  const PerSimRingtoneScreen({super.key});

  @override
  State<PerSimRingtoneScreen> createState() => _PerSimRingtoneScreenState();
}

class _PerSimRingtoneScreenState extends State<PerSimRingtoneScreen> {
  final SimService _sims = SimService();
  final TelecomService _telecom = TelecomService();

  List<SimAccount> _accounts = const [];
  bool _loading = true;
  String? _defaultToneLabel;
  String? _previewingId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _telecom.stopRingtonePreview();
    super.dispose();
  }

  Future<void> _load({bool refresh = false}) async {
    if (mounted) setState(() => _loading = true);
    List<SimAccount> sims;
    try {
      sims = await _sims.list(refresh: refresh);
    } catch (_) {
      sims = const [];
    }
    final defaultTone = await _telecom.defaultRingtone();
    if (!mounted) return;
    setState(() {
      _accounts = sims;
      _defaultToneLabel = defaultTone?.label;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).titlePerSimRingtones),
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
                _perSimSection(colors),
                const SizedBox(height: 16),
                _perContactNote(colors),
              ],
            ),
    );
  }

  Widget _perSimSection(AppColors colors) {
    if (_accounts.isEmpty) {
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
                  AppLocalizations.of(context).emptyNoSimsRingtone,
                  style: TextStyle(color: colors.mutedText, fontSize: 13.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final settings = context.watch<AppSettings>();
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).labelPerSimRingtone,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              AppLocalizations.of(context).descPerSimRingtone,
              style: TextStyle(color: colors.mutedText, fontSize: 13),
            ),
            const SizedBox(height: 8),
            for (final sim in _accounts)
              _simRingtoneRow(
                colors,
                sim,
                settings.ringtoneForSim(sim.phoneAccountId),
              ),
          ],
        ),
      ),
    );
  }

  Widget _simRingtoneRow(AppColors colors, SimAccount sim, RingtoneRef? tone) {
    final accent = Theme.of(context).colorScheme.primary;
    final slot = sim.slotIndex != null ? 'SIM ${sim.slotIndex! + 1}' : 'SIM';
    final playing = _previewingId == sim.phoneAccountId;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sim.displayLabel,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 1),
                Row(
                  children: [
                    Icon(
                      tone != null
                          ? Icons.music_note
                          : Icons.notifications_none,
                      size: 15,
                      color: tone != null ? accent : colors.mutedText,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        tone != null ? tone.label : _defaultSubtitle(slot),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.mutedText,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (tone != null)
            IconButton(
              tooltip: playing
                  ? AppLocalizations.of(context).tooltipStop
                  : AppLocalizations.of(context).tooltipPreview,
              icon: Icon(playing ? Icons.stop : Icons.play_arrow),
              color: playing ? accent : colors.mutedText,
              onPressed: () => _togglePreview(sim.phoneAccountId, tone.path),
            ),
          IconButton(
            tooltip: tone != null
                ? AppLocalizations.of(context).tooltipChangeRingtone
                : AppLocalizations.of(context).tooltipPickRingtone,
            icon: const Icon(Icons.folder_open),
            color: colors.mutedText,
            onPressed: () => _pickForSim(sim.phoneAccountId, tone),
          ),
          if (tone != null)
            IconButton(
              tooltip: AppLocalizations.of(context).actionClear,
              icon: const Icon(Icons.close),
              color: colors.mutedText,
              onPressed: () => _clearForSim(sim.phoneAccountId),
            ),
        ],
      ),
    );
  }

  Widget _perContactNote(AppColors colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.person_outline, size: 16, color: colors.mutedText),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            AppLocalizations.of(context).descPerContactRingtoneNote,
            style: TextStyle(color: colors.mutedText, fontSize: 12.5),
          ),
        ),
      ],
    );
  }

  String _defaultSubtitle(String slot) => _defaultToneLabel == null
      ? AppLocalizations.of(context).descSlotDefaultRingtone(slot)
      : AppLocalizations.of(
          context,
        ).descSlotDefaultTone(slot, _defaultToneLabel!);

  Future<void> _pickForSim(String phoneAccountId, RingtoneRef? current) async {
    final source = await _chooseRingtoneSource();
    if (source == null || !mounted) return;

    RingtoneRef? picked;
    try {
      if (source == _RingtoneSource.phone) {
        final tone = await _telecom.pickRingtone(existingUri: current?.path);
        if (tone == null) return;
        picked = RingtoneRef(path: tone.path, label: tone.label);
      } else {
        final file = await _telecom.pickAudioDocument();
        if (file == null) return;
        picked = RingtoneRef(path: file.path, label: file.label);
      }
    } catch (e) {
      _say((l) => l.errorCouldNotPickRingtone('$e'));
      return;
    }

    if (!mounted) return;
    await _stopPreview();
    if (!mounted) return;
    await context.read<AppSettings>().setSimRingtone(phoneAccountId, picked);
  }

  Future<_RingtoneSource?> _chooseRingtoneSource() {
    final colors = Theme.of(context).extension<AppColors>()!;
    return showModalBottomSheet<_RingtoneSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.notifications_active_outlined,
                color: colors.mutedText,
              ),
              title: Text(AppLocalizations.of(context).titlePhoneRingtones),
              subtitle: Text(AppLocalizations.of(context).descPhoneRingtones),
              onTap: () => Navigator.pop(sheetContext, _RingtoneSource.phone),
            ),
            ListTile(
              leading: Icon(Icons.folder_open, color: colors.mutedText),
              title: Text(AppLocalizations.of(context).titleAudioFile),
              subtitle: Text(AppLocalizations.of(context).descAudioFile),
              onTap: () => Navigator.pop(sheetContext, _RingtoneSource.file),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _clearForSim(String phoneAccountId) async {
    if (_previewingId == phoneAccountId) await _stopPreview();
    if (!mounted) return;
    await context.read<AppSettings>().setSimRingtone(phoneAccountId, null);
  }

  Future<void> _togglePreview(String phoneAccountId, String path) async {
    if (_previewingId == phoneAccountId) {
      await _stopPreview();
      return;
    }
    await _stopPreview();
    switch (await _telecom.previewRingtone(path)) {
      case RingtonePreviewStatus.missing:
        await _revertMissingTone(phoneAccountId);
        return;
      case RingtonePreviewStatus.muted:
        _say((l) => l.errorRingVolumeMuted);
      case RingtonePreviewStatus.playing:
        break;
    }
    if (mounted) setState(() => _previewingId = phoneAccountId);
  }

  Future<void> _revertMissingTone(String phoneAccountId) async {
    if (mounted) setState(() => _previewingId = null);
    _say((l) => l.errorRingtoneRevert);
    if (!mounted) return;
    await context.read<AppSettings>().setSimRingtone(phoneAccountId, null);
  }

  Future<void> _stopPreview() async {
    if (_previewingId == null) return;
    await _telecom.stopRingtonePreview();
    if (mounted) setState(() => _previewingId = null);
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Shows a translated snackbar. The message is built only after the
  /// `mounted` check, so this is safe to call after an `await`.
  void _say(String Function(AppLocalizations l) message) {
    if (!mounted) return;
    _showMessage(message(AppLocalizations.of(context)));
  }
}

enum _RingtoneSource { phone, file }
