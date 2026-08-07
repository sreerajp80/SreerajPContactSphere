// lib/screens/app_pin_setup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;

import 'package:smart_contacts_dialer/services/app_pin_service.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';
import 'package:smart_contacts_dialer/widgets/pin_keypad.dart';

/// Sets up the app-only unlock PIN. The user enters a 4–6 digit PIN, confirms
/// it, then is shown a one-time recovery code to write down. Pops `true` once a
/// PIN was saved (so the caller can switch to [LockMode.appPin]); pops `null`/
/// `false` if the user backs out before saving.
class AppPinSetupScreen extends StatefulWidget {
  const AppPinSetupScreen({super.key});

  @override
  State<AppPinSetupScreen> createState() => _AppPinSetupScreenState();
}

enum _Phase { enter, confirm, recovery }

class _AppPinSetupScreenState extends State<AppPinSetupScreen> {
  static const int _minLen = 4;
  static const int _maxLen = 6;

  final AppPinService _pins = AppPinService();

  _Phase _phase = _Phase.enter;
  String _first = '';
  String _entry = '';
  bool _error = false;
  bool _saving = false;
  String? _recoveryCode;

  String get _title => switch (_phase) {
    _Phase.enter => 'Set an app PIN',
    _Phase.confirm => 'Confirm your PIN',
    _Phase.recovery => 'Save your recovery code',
  };

  String get _subtitle => switch (_phase) {
    _Phase.enter => 'Choose a 4 to 6 digit PIN to unlock the app',
    _Phase.confirm => 'Enter the same PIN again',
    _Phase.recovery =>
      'If you forget your PIN, this code lets you back in. '
          'Write it down and keep it safe — it is shown only once.',
  };

  void _onDigit(int d) {
    if (_entry.length >= _maxLen) return;
    setState(() {
      _entry += '$d';
      _error = false;
    });
  }

  void _onBackspace() {
    if (_entry.isEmpty) return;
    setState(() => _entry = _entry.substring(0, _entry.length - 1));
  }

  Future<void> _onContinue() async {
    if (_entry.length < _minLen) return;
    if (_phase == _Phase.enter) {
      setState(() {
        _first = _entry;
        _entry = '';
        _phase = _Phase.confirm;
      });
      return;
    }
    // Confirm phase.
    if (_entry != _first) {
      setState(() {
        _error = true;
        _entry = '';
        _first = '';
        _phase = _Phase.enter;
      });
      return;
    }
    setState(() => _saving = true);
    try {
      final code = await _pins.setPin(_entry);
      if (!mounted) return;
      setState(() {
        _recoveryCode = code;
        _phase = _Phase.recovery;
        _saving = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = true;
        _entry = '';
        _first = '';
        _phase = _Phase.enter;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't save the PIN. Try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final accent = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _phase == _Phase.recovery
              ? _recoveryView(theme, colors, accent)
              : _entryView(theme, colors),
        ),
      ),
    );
  }

  Widget _entryView(ThemeData theme, AppColors colors) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Text(
          _subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.mutedText, fontSize: 14),
        ),
        if (_error) ...[
          const SizedBox(height: 12),
          Text(
            "PINs didn't match — start again",
            style: TextStyle(color: theme.colorScheme.error, fontSize: 13),
          ),
        ],
        const SizedBox(height: 32),
        PinDots(length: _maxLen, filled: _entry.length, error: _error),
        const Spacer(),
        PinKeypad(onDigit: _onDigit, onBackspace: _onBackspace),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: (_entry.length >= _minLen && !_saving)
                ? _onContinue
                : null,
            child: Text(_phase == _Phase.enter ? 'Continue' : 'Confirm'),
          ),
        ),
      ],
    );
  }

  Widget _recoveryView(ThemeData theme, AppColors colors, Color accent) {
    final code = _recoveryCode ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Text(
          _subtitle,
          style: TextStyle(color: colors.mutedText, fontSize: 14),
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              SelectableText(
                code,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: code));
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Recovery code copied')),
                  );
                },
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Copy'),
              ),
            ],
          ),
        ),
        const Spacer(),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text("I've saved it — turn on App lock"),
        ),
      ],
    );
  }
}
