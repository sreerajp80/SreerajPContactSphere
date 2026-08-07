// lib/screens/ringtone_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_contacts_dialer/models/sim_account.dart';
import 'package:smart_contacts_dialer/services/sim_service.dart';
import 'package:smart_contacts_dialer/services/telecom_service.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

/// Incoming-call ringer preferences: ringtone volume, vibration, and a ringtone
/// per SIM. Reached from the Settings hub.
///
/// Volume and vibration are mirrored to the native ringer by [AppSettings] so
/// they apply even on a cold-start incoming call. Per-SIM ringtones are applied
/// from the Flutter side when a call comes in (see `in_call_screen.dart`), with
/// a contact's own ringtone taking precedence over the SIM's.
class RingtoneSettingsScreen extends StatefulWidget {
  const RingtoneSettingsScreen({super.key});

  @override
  State<RingtoneSettingsScreen> createState() => _RingtoneSettingsScreenState();
}

class _RingtoneSettingsScreenState extends State<RingtoneSettingsScreen> {
  final SimService _sims = SimService();
  final TelecomService _telecom = TelecomService();

  List<SimAccount> _accounts = const [];
  bool _loading = true;

  /// Display name of the device's default ringtone, shown for SIMs with no
  /// override. Null until resolved (or if it can't be read).
  String? _defaultToneLabel;

  /// Live slider position while dragging; committed to [AppSettings] on release.
  int? _volumeDrag;

  /// phone-account id of the SIM whose ringtone is currently previewing, if any.
  String? _previewingId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    // Stop any native preview still looping.
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
        title: const Text('Ringtone'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh SIMs',
            onPressed: _loading ? null : () => _load(refresh: true),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _volumeCard(colors),
                const SizedBox(height: 12),
                _vibrationCard(colors),
                const SizedBox(height: 12),
                _perSimSection(colors),
                const SizedBox(height: 16),
                _perContactNote(colors),
              ],
            ),
    );
  }

  Widget _volumeCard(AppColors colors) {
    final accent = Theme.of(context).colorScheme.primary;
    final settings = context.watch<AppSettings>();
    final value = _volumeDrag ?? settings.ringtoneVolumePercent;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ringtone volume',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              value == 0
                  ? 'Muted — the ringtone won’t sound'
                  : 'Plays incoming-call ringtones at $value%',
              style: TextStyle(color: colors.mutedText, fontSize: 13),
            ),
            Row(
              children: [
                Icon(
                  value == 0 ? Icons.volume_off : Icons.volume_up,
                  color: value == 0 ? colors.mutedText : accent,
                ),
                Expanded(
                  child: Slider(
                    value: value.toDouble(),
                    max: 100,
                    divisions: 20,
                    label: '$value%',
                    activeColor: accent,
                    onChanged: (v) => setState(() => _volumeDrag = v.round()),
                    onChangeEnd: (v) {
                      setState(() => _volumeDrag = null);
                      context.read<AppSettings>().setRingtoneVolumePercent(
                        v.round(),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    '$value%',
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _vibrationCard(AppColors colors) {
    final accent = Theme.of(context).colorScheme.primary;
    final settings = context.watch<AppSettings>();

    return Card(
      margin: EdgeInsets.zero,
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        value: settings.vibrateOnIncomingCall,
        activeThumbColor: accent,
        onChanged: (v) =>
            context.read<AppSettings>().setVibrateOnIncomingCall(v),
        title: const Text(
          'Vibrate on incoming calls',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          'Silent mode still overrides this and suppresses vibration',
          style: TextStyle(color: colors.mutedText, fontSize: 13),
        ),
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
                  'No SIMs detected. Per-SIM ringtones need phone permission and '
                  'a device with at least one SIM. Grant the phone permission and '
                  'tap refresh.',
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
            const Text(
              'Per-SIM ringtone',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              'A ringtone for calls received on each SIM',
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
              tooltip: playing ? 'Stop' : 'Preview',
              icon: Icon(playing ? Icons.stop : Icons.play_arrow),
              color: playing ? accent : colors.mutedText,
              onPressed: () => _togglePreview(sim.phoneAccountId, tone.path),
            ),
          IconButton(
            tooltip: tone != null ? 'Change ringtone' : 'Pick ringtone',
            icon: const Icon(Icons.folder_open),
            color: colors.mutedText,
            onPressed: () => _pickForSim(sim.phoneAccountId, tone),
          ),
          if (tone != null)
            IconButton(
              tooltip: 'Clear',
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
            'A ringtone set on an individual contact takes precedence over the '
            'per-SIM ringtone. Set one from a contact’s edit screen.',
            style: TextStyle(color: colors.mutedText, fontSize: 12.5),
          ),
        ),
      ],
    );
  }

  /// Subtitle for a SIM with no override: the real default tone name when we
  /// could read it, else a plain fallback.
  String _defaultSubtitle(String slot) => _defaultToneLabel == null
      ? '$slot · default ringtone'
      : '$slot · Default · $_defaultToneLabel';

  /// Lets the user pick a tone for [phoneAccountId] from the phone's built-in
  /// ringtones or from an audio file, then stores it.
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
      _showMessage('Could not pick ringtone: $e');
      return;
    }

    if (!mounted) return;
    await _stopPreview();
    if (!mounted) return;
    await context.read<AppSettings>().setSimRingtone(phoneAccountId, picked);
  }

  /// Bottom-sheet chooser: pick from the phone's ringtones or an audio file.
  /// Returns null if dismissed.
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
              title: const Text('Phone ringtones'),
              subtitle: const Text('Choose from the ringtones on this device'),
              onTap: () => Navigator.pop(sheetContext, _RingtoneSource.phone),
            ),
            ListTile(
              leading: Icon(Icons.folder_open, color: colors.mutedText),
              title: const Text('Audio file'),
              subtitle: const Text('Pick an audio file from your folders'),
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

  /// Plays/stops an in-app preview of a SIM's ringtone through the native
  /// player, on the ring stream at ring volume — exactly like an actual call.
  /// Preview only — it does not set the OS incoming-call ringer.
  Future<void> _togglePreview(String phoneAccountId, String path) async {
    if (_previewingId == phoneAccountId) {
      await _stopPreview();
      return;
    }
    await _stopPreview();
    switch (await _telecom.previewRingtone(path)) {
      case RingtonePreviewStatus.missing:
        // The tone's backing file is gone — revert to default.
        await _revertMissingTone(phoneAccountId);
        return;
      case RingtonePreviewStatus.muted:
        _showMessage('Ring volume is muted — turn it up to hear the preview.');
      case RingtonePreviewStatus.playing:
        break;
    }
    if (mounted) setState(() => _previewingId = phoneAccountId);
  }

  /// A stored tone whose backing file is gone (deleted/moved, or a lost grant):
  /// tell the user and clear that SIM's override so it falls back to the default.
  Future<void> _revertMissingTone(String phoneAccountId) async {
    if (mounted) setState(() => _previewingId = null);
    _showMessage(
      'This ringtone is no longer available — reverting to default.',
    );
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
}

/// Where a picked ringtone comes from: the phone's built-in ringtones or a file.
enum _RingtoneSource { phone, file }
