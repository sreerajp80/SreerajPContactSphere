// lib/widgets/voice_input_button.dart
import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/services/speech_service.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

/// The app's mic button: idle it sits muted like the other inline icons;
/// while listening it fills with the accent color and pulses gently. Used by
/// the contacts search bar and the dialer so voice input looks the same
/// everywhere.
///
/// Tap to listen, tap again (or just stop talking) to finish. The recognized
/// words stream out through [onWords]; availability problems (mic denied, no
/// recognizer on the device) surface as a snackbar, never an error.
class VoiceInputButton extends StatefulWidget {
  /// Words heard so far; called repeatedly while the user speaks and once
  /// more with `isFinal: true` when the session ends with a result.
  final void Function(String words, bool isFinal) onWords;
  final String tooltip;

  const VoiceInputButton({
    super.key,
    required this.onWords,
    this.tooltip = 'Voice search',
  });

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with SingleTickerProviderStateMixin {
  final SpeechService _speech = SpeechService();

  // Created in initState (not a lazy `late final`): a lazy field first touched
  // in dispose() would create the controller during teardown, where the
  // ticker's ancestor lookup is illegal.
  late final AnimationController _pulse;
  bool _listening = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
      lowerBound: 0.8,
    )..value = 1.0;
  }

  @override
  void dispose() {
    // A still-running session dies on its own (the service is a singleton);
    // its done-callback is guarded by `mounted`, so it can't reach this state.
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_listening) {
      await _speech.stop(); // _onSessionDone resets the UI
      return;
    }
    final started = await _speech.listen(
      onWords: (words, isFinal) {
        if (mounted) widget.onWords(words, isFinal);
      },
      onDone: _onSessionDone,
    );
    if (!mounted) return;
    if (!started) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Voice input is not available — check the microphone permission.',
            ),
          ),
        );
      return;
    }
    setState(() => _listening = true);
    _pulse.repeat(reverse: true);
  }

  void _onSessionDone() {
    if (!mounted) return;
    _pulse
      ..stop()
      ..value = 1.0;
    setState(() => _listening = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final accent = theme.colorScheme.primary;

    return IconButton(
      tooltip: _listening ? 'Stop listening' : widget.tooltip,
      onPressed: _toggle,
      icon: _listening
          ? ScaleTransition(
              scale: _pulse,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.mic, size: 20, color: accent),
              ),
            )
          : Icon(Icons.mic_none, size: 22, color: colors.mutedText),
    );
  }
}
