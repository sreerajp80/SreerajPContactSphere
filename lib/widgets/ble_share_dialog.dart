// lib/widgets/ble_share_dialog.dart
//
// "Share via Bluetooth" sender dialog: advertises a vCard payload (via the
// native peripheral behind BleShareService) while open, and shows the
// transfer's progress — waiting for a receiver, sending (with a percentage on
// long transfers), sent. Advertising stops when the dialog closes, so the
// phone is only discoverable while the user is looking at this dialog. Two
// front doors: showBleShareDialog (one contact) and showBleShareAllDialog
// (the whole book as one multi-contact vCard). The receiving side is
// screens/ble_receive_screen.dart.

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:smart_contacts_dialer/models/contact.dart';
import 'package:smart_contacts_dialer/services/ble_receive_service.dart';
import 'package:smart_contacts_dialer/services/ble_share_service.dart';
import 'package:smart_contacts_dialer/services/permission_service.dart';
import 'package:smart_contacts_dialer/services/vcard_service.dart';

/// Shows the Bluetooth share dialog for a single [contact].
/// Photos are included by default for single-contact shares.
Future<void> showBleShareDialog(BuildContext context, Contact contact) {
  return showDialog<void>(
    context: context,
    builder: (_) => BleShareDialog(
      title: contact.fullName,
      advertisedName: contact.fullName,
      contacts: [contact],
    ),
  );
}

/// Shows the Bluetooth share dialog for the whole book: [contacts] serialized
/// as one multi-contact vCard, advertised as "N contacts" (which is what the
/// receiver's scan list displays). Photos are off by default for batch shares
/// because they significantly increase transfer size and time.
Future<void> showBleShareAllDialog(
  BuildContext context,
  List<Contact> contacts,
) {
  return showDialog<void>(
    context: context,
    builder: (_) => BleShareDialog(
      title: 'Send ${contacts.length} contacts',
      advertisedName: '${contacts.length} contacts',
      contacts: contacts,
      defaultIncludePhoto: false,
    ),
  );
}

/// What the dialog is currently doing/showing.
enum _Phase {
  starting,
  permissionDenied,
  waiting,
  sending,
  sent,
  timedOut,
  error,
}

class BleShareDialog extends StatefulWidget {
  /// Dialog title (contact name, or "Send N contacts").
  final String title;

  /// Name broadcast in the advertisement's scan response (truncated to
  /// 13 UTF-8 bytes by the advertiser); what the receiver's list shows.
  final String advertisedName;

  /// The contacts to share. The vCard payload is built from these at start,
  /// using the current [includePhoto] setting.
  final List<Contact> contacts;

  /// Initial value of the "Include photos" toggle. Single-contact shares
  /// default to true; batch shares default to false.
  final bool defaultIncludePhoto;

  const BleShareDialog({
    super.key,
    required this.title,
    required this.advertisedName,
    required this.contacts,
    this.defaultIncludePhoto = true,
  });

  @override
  State<BleShareDialog> createState() => _BleShareDialogState();
}

class _BleShareDialogState extends State<BleShareDialog> {
  /// Sharing stops by itself after this long with **no transfer activity** —
  /// an idle timeout, reset by connect/read events, so a slow whole-book
  /// transfer is never cut off mid-flight; only "nobody came" ends early.
  static const Duration _idleTimeout = Duration(minutes: 2);

  final BleShareService _share = BleShareService();

  _Phase _phase = _Phase.starting;
  String? _errorMessage;

  /// Whether to include contact photos in the BLE payload.
  late bool _includePhoto = widget.defaultIncludePhoto;

  /// Served fraction of the payload, when known (drives the percentage).
  double? _progress;

  StreamSubscription<BleShareEvent>? _events;
  Timer? _idle;

  @override
  void initState() {
    super.initState();
    _events = _share.events.listen(_onEvent);
    _begin();
  }

  @override
  void dispose() {
    _idle?.cancel();
    _events?.cancel();
    // Fire-and-forget: the dialog is gone, advertising must not outlive it.
    _share.stop();
    super.dispose();
  }

  /// Builds the UTF-8 vCard payload from the contacts list, respecting the
  /// current [_includePhoto] toggle.
  Uint8List _buildPayload() {
    final vcard = VCardService();
    final text = widget.contacts.length == 1
        ? vcard.toVCard(widget.contacts.first, includePhoto: _includePhoto)
        : vcard.toVCardAll(widget.contacts, includePhoto: _includePhoto);
    return Uint8List.fromList(utf8.encode(text));
  }

  Future<void> _begin() async {
    setState(() {
      _phase = _Phase.starting;
      _errorMessage = null;
      _progress = null;
    });

    // Android 12+ runtime permissions for advertising + hosting the GATT
    // server. On Android 11 and below these resolve as granted (the legacy
    // BLUETOOTH/BLUETOOTH_ADMIN entries are install-time).
    final perms = PermissionService();
    final ok =
        await perms.ensure(Permission.bluetoothAdvertise) &&
        await perms.ensure(Permission.bluetoothConnect);
    if (!mounted) return;
    if (!ok) {
      setState(() => _phase = _Phase.permissionDenied);
      return;
    }

    var error = await _share.start(
      payload: _buildPayload(),
      name: widget.advertisedName,
    );
    if (error == 'bluetooth_off') {
      // One shot at the system "turn on Bluetooth?" consent dialog.
      if (await BleReceiveService().turnOn()) {
        error = await _share.start(
          payload: _buildPayload(),
          name: widget.advertisedName,
        );
      }
    }
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _phase = _Phase.error;
        _errorMessage = switch (error) {
          'bluetooth_off' => 'Bluetooth is off. Turn it on and try again.',
          'unsupported' => 'This phone can\'t share over Bluetooth LE.',
          'no_permission' => 'Bluetooth permission was denied.',
          _ => 'Could not start Bluetooth sharing.',
        };
      });
      return;
    }

    // The native advertiser reports "advertising" via the event stream; until
    // then keep the spinner.
    _restartIdleTimer();
  }

  /// (Re)arms the idle timeout. Called on start and on every sign of life
  /// from a receiver, so only genuine inactivity ends the session.
  void _restartIdleTimer() {
    _idle?.cancel();
    _idle = Timer(_idleTimeout, () {
      if (!mounted || _phase == _Phase.sent) return;
      _share.stop();
      setState(() => _phase = _Phase.timedOut);
    });
  }

  void _onEvent(BleShareEvent event) {
    if (!mounted) return;
    switch (event.state) {
      case BleShareState.advertising:
        if (_phase == _Phase.starting) setState(() => _phase = _Phase.waiting);
      case BleShareState.connected:
      case BleShareState.sending:
        _restartIdleTimer();
        if (_phase != _Phase.sent) {
          setState(() {
            _phase = _Phase.sending;
            _progress = event.progress ?? _progress;
          });
        }
      case BleShareState.complete:
        _idle?.cancel();
        // The receiver has every byte; stop advertising and show success.
        _share.stop();
        setState(() => _phase = _Phase.sent);
      case BleShareState.disconnected:
        // A receiver that bailed mid-read; we're still advertising for the
        // next attempt (unless the transfer had already finished).
        if (_phase == _Phase.sending) {
          setState(() {
            _phase = _Phase.waiting;
            _progress = null;
          });
        }
      case BleShareState.error:
        _idle?.cancel();
        _share.stop();
        setState(() {
          _phase = _Phase.error;
          _errorMessage = event.message ?? 'Bluetooth sharing failed.';
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canRetry =
        _phase == _Phase.timedOut ||
        _phase == _Phase.error ||
        _phase == _Phase.permissionDenied;

    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _statusVisual(theme),
          const SizedBox(height: 16),
          Text(
            _statusText(),
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          if (_phase == _Phase.waiting) ...[
            const SizedBox(height: 8),
            Text(
              'On the other phone, open SreerajP Contacts Sphere and choose '
              '"Receive via Bluetooth" from the contacts menu.',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
          // Only show the photo toggle before a transfer has started
          // (waiting phase) so the user can decide before data flows.
          if (_phase == _Phase.starting || _phase == _Phase.waiting)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: _includePhoto,
                    onChanged: _phase == _Phase.starting
                        ? null
                        : (v) {
                            if (v == null) return;
                            setState(() => _includePhoto = v);
                            // Restart advertising with the new payload.
                            _share.stop();
                            _begin();
                          },
                  ),
                  Text(
                    'Include photos',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
        ],
      ),
      actions: [
        if (canRetry)
          FilledButton.icon(
            onPressed: _begin,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Try again'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(_phase == _Phase.sent ? 'Done' : 'Close'),
        ),
      ],
    );
  }

  Widget _statusVisual(ThemeData theme) {
    final accent = theme.colorScheme.primary;
    switch (_phase) {
      case _Phase.starting:
      case _Phase.waiting:
      case _Phase.sending:
        return SizedBox.square(
          dimension: 56,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.square(
                dimension: 56,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: accent.withValues(alpha: 0.7),
                  // Determinate ring once the transfer reports progress.
                  value: _phase == _Phase.sending ? _progress : null,
                ),
              ),
              Icon(
                _phase == _Phase.sending
                    ? Icons.bluetooth_connected
                    : Icons.bluetooth_searching,
                color: accent,
                size: 28,
              ),
            ],
          ),
        );
      case _Phase.sent:
        return Icon(
          Icons.check_circle_outline,
          color: theme.colorScheme.primary,
          size: 56,
        );
      case _Phase.permissionDenied:
      case _Phase.timedOut:
      case _Phase.error:
        return Icon(
          Icons.bluetooth_disabled,
          color: theme.colorScheme.error,
          size: 56,
        );
    }
  }

  String _statusText() {
    return switch (_phase) {
      _Phase.starting => 'Starting Bluetooth sharing…',
      _Phase.waiting => 'Waiting for a nearby phone…',
      _Phase.sending =>
        _progress == null
            ? 'Sending…'
            : 'Sending… ${(_progress! * 100).round()}%',
      _Phase.sent => 'Sent.',
      _Phase.permissionDenied =>
        'Bluetooth permission is needed to share. Allow Nearby devices for '
            'SreerajP Contacts Sphere and try again.',
      _Phase.timedOut =>
        'No phone connected. Try again when the receiver is ready.',
      _Phase.error => _errorMessage ?? 'Bluetooth sharing failed.',
    };
  }
}
