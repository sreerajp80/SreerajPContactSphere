// lib/screens/ringtone_volume_vibration_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

/// Configuration screen for Ringtone volume and vibration settings.
class RingtoneVolumeVibrationScreen extends StatefulWidget {
  const RingtoneVolumeVibrationScreen({super.key});

  @override
  State<RingtoneVolumeVibrationScreen> createState() =>
      _RingtoneVolumeVibrationScreenState();
}

class _RingtoneVolumeVibrationScreenState
    extends State<RingtoneVolumeVibrationScreen> {
  int? _volumeDrag;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final accent = Theme.of(context).colorScheme.primary;
    final settings = context.watch<AppSettings>();
    final value = _volumeDrag ?? settings.ringtoneVolumePercent;

    return Scaffold(
      appBar: AppBar(title: const Text('Volume & Vibration')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Card(
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
                        ? 'Muted — the ringtone won’t sound, but the phone still '
                              'vibrates if vibration is on below'
                        : 'Plays incoming-call ringtones at $value% of your '
                              'phone’s ring volume',
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
                          onChanged: (v) =>
                              setState(() => _volumeDrag = v.round()),
                          onChangeEnd: (v) {
                            setState(() => _volumeDrag = null);
                            context
                                .read<AppSettings>()
                                .setRingtoneVolumePercent(v.round());
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
          ),
          const SizedBox(height: 12),
          Card(
            margin: EdgeInsets.zero,
            child: SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              value: settings.vibrateOnIncomingCall,
              activeThumbColor: accent,
              onChanged: (v) =>
                  context.read<AppSettings>().setVibrateOnIncomingCall(v),
              title: const Text(
                'Vibrate on incoming calls',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                'Your phone comes first: silent mode, Do Not Disturb and the '
                'phone’s own “Vibrate for calls” setting all override this',
                style: TextStyle(color: colors.mutedText, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
