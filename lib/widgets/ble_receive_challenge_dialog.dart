// lib/widgets/ble_receive_challenge_dialog.dart
//
// Authentication gate shown before a BLE contact transfer is accepted on the
// receiving side. The challenge depends on the app's lock mode:
//  - LockMode.appPin:    in-dialog PIN keypad verified by AppPinService
//  - LockMode.deviceLock: biometric/credential prompt via AuthService
//  - LockMode.none:       consent dialog ("Allow transfer from <name>?")
//
// Returns true to proceed with the transfer, false/null to cancel.

import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/services/app_pin_service.dart';
import 'package:smart_contacts_dialer/services/auth_service.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/widgets/pin_keypad.dart';

/// Shows the appropriate challenge and returns `true` to allow the transfer.
/// [senderName] is the display name of the advertising device (from the scan
/// response), used in all three dialog variants so the user knows whom they
/// are accepting data from. [signalLabel] is a proximity hint ("Very close",
/// "Nearby", etc.).
Future<bool> showBleReceiveChallenge(
  BuildContext context, {
  required String senderName,
  required String signalLabel,
}) async {
  final lockMode = await AppSettings.readLockMode();

  if (!context.mounted) return false;

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _BleReceiveChallengeDialog(
      lockMode: lockMode,
      senderName: senderName,
      signalLabel: signalLabel,
    ),
  );
  return result == true;
}

class _BleReceiveChallengeDialog extends StatelessWidget {
  final LockMode lockMode;
  final String senderName;
  final String signalLabel;

  const _BleReceiveChallengeDialog({
    required this.lockMode,
    required this.senderName,
    required this.signalLabel,
  });

  @override
  Widget build(BuildContext context) {
    return switch (lockMode) {
      LockMode.appPin => _PinChallengeDialog(
          senderName: senderName,
          signalLabel: signalLabel,
        ),
      LockMode.deviceLock => _BiometricChallengeDialog(
          senderName: senderName,
          signalLabel: signalLabel,
        ),
      LockMode.none => _ConsentChallengeDialog(
          senderName: senderName,
          signalLabel: signalLabel,
        ),
    };
  }
}

// ---------------------------------------------------------------------------
// Consent dialog (LockMode.none) — "Allow transfer from <name>?"
// ---------------------------------------------------------------------------

class _ConsentChallengeDialog extends StatelessWidget {
  final String senderName;
  final String signalLabel;

  const _ConsentChallengeDialog({
    required this.senderName,
    required this.signalLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      icon: Icon(
        Icons.bluetooth_connected,
        size: 40,
        color: theme.colorScheme.primary,
      ),
      title: const Text('Incoming transfer'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'A nearby device wants to send you contacts.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _SenderInfoCard(
            senderName: senderName,
            signalLabel: signalLabel,
          ),
          const SizedBox(height: 12),
          Text(
            'Do you want to receive this transfer?',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Decline'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Accept'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Biometric / device-credential challenge (LockMode.deviceLock)
// ---------------------------------------------------------------------------

class _BiometricChallengeDialog extends StatefulWidget {
  final String senderName;
  final String signalLabel;

  const _BiometricChallengeDialog({
    required this.senderName,
    required this.signalLabel,
  });

  @override
  State<_BiometricChallengeDialog> createState() =>
      _BiometricChallengeDialogState();
}

class _BiometricChallengeDialogState extends State<_BiometricChallengeDialog> {
  final AuthService _auth = AuthService();
  bool _authenticating = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    // Prompt immediately so the user sees the fingerprint/face dialog.
    WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
  }

  Future<void> _authenticate() async {
    if (_authenticating) return;
    setState(() {
      _authenticating = true;
      _failed = false;
    });
    final ok = await _auth.authenticate(
      reason: 'Authenticate to receive a Bluetooth transfer',
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _authenticating = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      icon: Icon(
        Icons.fingerprint,
        size: 40,
        color: _failed ? theme.colorScheme.error : theme.colorScheme.primary,
      ),
      title: const Text('Authenticate to receive'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SenderInfoCard(
            senderName: widget.senderName,
            signalLabel: widget.signalLabel,
          ),
          const SizedBox(height: 16),
          Text(
            _failed
                ? 'Authentication failed. Try again or decline the transfer.'
                : 'Verify your identity to accept this Bluetooth transfer.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Decline'),
        ),
        FilledButton.icon(
          onPressed: _authenticating ? null : _authenticate,
          icon: _authenticating
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.lock_open_outlined, size: 18),
          label: Text(_authenticating ? 'Verifying…' : 'Try again'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// App-PIN challenge (LockMode.appPin)
// ---------------------------------------------------------------------------

class _PinChallengeDialog extends StatefulWidget {
  final String senderName;
  final String signalLabel;

  const _PinChallengeDialog({
    required this.senderName,
    required this.signalLabel,
  });

  @override
  State<_PinChallengeDialog> createState() => _PinChallengeDialogState();
}

class _PinChallengeDialogState extends State<_PinChallengeDialog> {
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
    // Auto-verify once the minimum PIN length (4) is reached — same pattern as
    // app_lock_screen.dart's _PinUnlock.
    if (_entry.length >= 4) _tryVerify();
  }

  void _onBackspace() {
    if (_entry.isEmpty) return;
    setState(() {
      _entry = _entry.substring(0, _entry.length - 1);
      _error = false;
    });
  }

  Future<void> _tryVerify() async {
    final attempt = _entry;
    setState(() => _checking = true);
    final ok = await _pins.verifyPin(attempt);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
      return;
    }
    // Wrong PIN: clear and shake (via the error state on PinDots).
    setState(() {
      _entry = '';
      _error = true;
      _checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      icon: Icon(
        Icons.pin_outlined,
        size: 40,
        color: _error ? theme.colorScheme.error : theme.colorScheme.primary,
      ),
      title: const Text('Enter PIN to receive'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SenderInfoCard(
            senderName: widget.senderName,
            signalLabel: widget.signalLabel,
          ),
          const SizedBox(height: 16),
          Text(
            _error
                ? 'Wrong PIN — try again'
                : 'Enter your app PIN to accept this Bluetooth transfer.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: _error ? theme.colorScheme.error : null,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          PinDots(length: _maxLen, filled: _entry.length, error: _error),
          const SizedBox(height: 12),
          PinKeypad(onDigit: _onDigit, onBackspace: _onBackspace),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Decline'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared: sender info card shown in all three challenge variants
// ---------------------------------------------------------------------------

class _SenderInfoCard extends StatelessWidget {
  final String senderName;
  final String signalLabel;

  const _SenderInfoCard({
    required this.senderName,
    required this.signalLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.bluetooth,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    senderName,
                    style: theme.textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    signalLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
