// lib/screens/app_lock_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_contacts_dialer/services/app_pin_service.dart';
import 'package:smart_contacts_dialer/services/auth_service.dart';
import 'package:smart_contacts_dialer/services/screen_security_service.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';
import 'package:smart_contacts_dialer/widgets/pin_keypad.dart';

/// Full-screen lock shown over the app when App lock is enabled (Settings → App
/// lock). It cannot be dismissed by the back gesture/button while locked; it
/// pops (returning `true`) only on a successful unlock.
///
/// The unlock method depends on [mode]:
/// * [LockMode.deviceLock] prompts for the device credential (biometrics / PIN)
///   via [AuthService] on first show, with an Unlock button to retry.
/// * [LockMode.appPin] shows an in-app numeric keypad verified by
///   [AppPinService], plus a "Forgot PIN?" path that accepts the recovery code,
///   turns App lock off, and lets the user in.
class AppLockScreen extends StatefulWidget {
  final LockMode mode;

  const AppLockScreen({super.key, required this.mode});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  @override
  void initState() {
    super.initState();
    // Keep the lock screen out of screenshots and the Recents thumbnail.
    ScreenSecurity.acquire('app_lock');
  }

  @override
  void dispose() {
    ScreenSecurity.release('app_lock');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Block the back gesture/button: the app stays locked until authenticated.
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: widget.mode == LockMode.appPin
              ? const _PinUnlock()
              : const _DeviceUnlock(),
        ),
      ),
    );
  }
}

/// Device-credential unlock (the original behavior).
class _DeviceUnlock extends StatefulWidget {
  const _DeviceUnlock();

  @override
  State<_DeviceUnlock> createState() => _DeviceUnlockState();
}

class _DeviceUnlockState extends State<_DeviceUnlock> {
  final AuthService _auth = AuthService();
  bool _authenticating = false;

  @override
  void initState() {
    super.initState();
    // Prompt as soon as the lock appears, so the user usually never sees the
    // Unlock button — it is the fallback for a cancelled/failed prompt.
    WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
  }

  Future<void> _unlock() async {
    if (_authenticating) return;
    setState(() => _authenticating = true);
    final ok = await _auth.authenticate(reason: 'Unlock ContactSphere');
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _authenticating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final colors = theme.extension<AppColors>()!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LockBadge(accent: accent),
            const SizedBox(height: 24),
            const Text(
              'ContactSphere is locked',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Unlock with your fingerprint, face or device PIN to continue',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.mutedText, fontSize: 14),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: _authenticating ? null : _unlock,
              icon: _authenticating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.lock_open_outlined),
              label: Text(_authenticating ? 'Unlocking…' : 'Unlock'),
            ),
          ],
        ),
      ),
    );
  }
}

/// App-PIN unlock: numeric keypad + recovery-code fallback.
class _PinUnlock extends StatefulWidget {
  const _PinUnlock();

  @override
  State<_PinUnlock> createState() => _PinUnlockState();
}

class _PinUnlockState extends State<_PinUnlock> {
  static const int _maxLen = 6;

  final AppPinService _pins = AppPinService();
  String _entry = '';
  bool _error = false;
  bool _checking = false;

  void _onDigit(int d) {
    if (_checking || _entry.length >= _maxLen) return;
    setState(() {
      _entry += '$d';
      _error = false;
    });
    // A PIN can be 4–6 digits, so we can't auto-submit on a fixed length. Verify
    // on every keystroke once it's at least the minimum; a wrong full PIN just
    // clears. This keeps a correct PIN unlocking without a separate button.
    if (_entry.length >= 4) _tryUnlock();
  }

  void _onBackspace() {
    if (_entry.isEmpty) return;
    setState(() {
      _entry = _entry.substring(0, _entry.length - 1);
      _error = false;
    });
  }

  Future<void> _tryUnlock() async {
    final attempt = _entry;
    setState(() => _checking = true);
    final ok = await _pins.verifyPin(attempt);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
      return;
    }
    // Only flag an error once the user has reached the max length; shorter
    // entries might just be mid-typing a longer PIN.
    setState(() {
      _checking = false;
      if (attempt.length >= _maxLen) {
        _error = true;
        _entry = '';
      }
    });
  }

  Future<void> _forgotPin() async {
    final recovered = await showDialog<bool>(
      context: context,
      builder: (_) => const _RecoveryDialog(),
    );
    if (recovered == true && mounted) {
      // The recovery dialog already cleared the PIN and turned App lock off.
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final accent = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          _LockBadge(accent: accent),
          const SizedBox(height: 20),
          const Text(
            'ContactSphere is locked',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            _error ? 'Wrong PIN — try again' : 'Enter your app PIN to continue',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _error ? theme.colorScheme.error : colors.mutedText,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 28),
          PinDots(length: _maxLen, filled: _entry.length, error: _error),
          const Spacer(),
          PinKeypad(onDigit: _onDigit, onBackspace: _onBackspace),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _checking ? null : _forgotPin,
            child: const Text('Forgot PIN?'),
          ),
        ],
      ),
    );
  }
}

/// Prompts for the recovery code. On a correct code it clears the PIN and turns
/// App lock off (via [AppSettings]) and pops `true`.
class _RecoveryDialog extends StatefulWidget {
  const _RecoveryDialog();

  @override
  State<_RecoveryDialog> createState() => _RecoveryDialogState();
}

class _RecoveryDialogState extends State<_RecoveryDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _checking = false;
  bool _error = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _controller.text.trim();
    if (code.isEmpty) return;
    setState(() {
      _checking = true;
      _error = false;
    });
    final ok = await AppPinService().verifyRecoveryCode(code);
    if (!mounted) return;
    if (!ok) {
      setState(() {
        _checking = false;
        _error = true;
      });
      return;
    }
    // Correct code: drop the PIN and turn App lock off so the user gets in and
    // can set a new PIN from Settings.
    await AppPinService().clearPin();
    if (!mounted) return;
    await context.read<AppSettings>().setLockMode(LockMode.none);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter recovery code'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter the recovery code you saved when setting the PIN. This turns '
            'App lock off so you can set a new PIN.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: 'Recovery code',
              errorText: _error ? 'Incorrect code' : null,
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _checking ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _checking ? null : _submit,
          child: _checking
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Unlock'),
        ),
      ],
    );
  }
}

/// The rounded lock icon badge shared by both unlock views.
class _LockBadge extends StatelessWidget {
  final Color accent;

  const _LockBadge({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Icon(Icons.lock_outline, color: accent, size: 40),
    );
  }
}
