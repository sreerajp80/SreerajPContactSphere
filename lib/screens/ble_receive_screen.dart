// lib/screens/ble_receive_screen.dart
//
// "Receive via Bluetooth": scans for a nearby phone that is sharing a contact
// (ContactSphere's "Share via Bluetooth" dialog), downloads the vCard over
// GATT (services/ble_receive_service.dart), and routes it through the same
// review/import flow as the QR scanner and the .vcf-intent path: a single
// contact opens the Add/Edit screen pre-filled, several get a confirm dialog
// and a bulk import through ContactSyncService. Pops with `true` when at
// least one contact was saved, so the caller can reload its list.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:smart_contacts_dialer/models/contact.dart';
import 'package:smart_contacts_dialer/services/ble_receive_service.dart';
import 'package:smart_contacts_dialer/services/ble_share_service.dart';
import 'package:smart_contacts_dialer/services/contact_sync_service.dart';
import 'package:smart_contacts_dialer/widgets/ble_receive_challenge_dialog.dart';
import 'package:smart_contacts_dialer/services/permission_service.dart';
import 'package:smart_contacts_dialer/services/vcard_service.dart';
import 'package:smart_contacts_dialer/screens/add_edit_contact_screen.dart';

/// What the screen is currently doing.
enum _Phase {
  starting,
  permissionDenied,
  bluetoothOff,
  scanning,
  authenticating,
  fetching,
}

class BleReceiveScreen extends StatefulWidget {
  const BleReceiveScreen({super.key});

  @override
  State<BleReceiveScreen> createState() => _BleReceiveScreenState();
}

class _BleReceiveScreenState extends State<BleReceiveScreen> {
  final BleReceiveService _ble = BleReceiveService();

  _Phase _phase = _Phase.starting;
  List<ScanResult> _results = const [];
  bool _scanning = false;

  /// Received fraction of the current download, when known (whole-book
  /// transfers take long enough that a bare spinner reads as a hang).
  double? _fetchProgress;
  StreamSubscription<List<ScanResult>>? _resultsSub;
  StreamSubscription<bool>? _scanningSub;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _resultsSub?.cancel();
    _scanningSub?.cancel();
    _ble.stopScan();
    super.dispose();
  }

  Future<void> _init() async {
    setState(() => _phase = _Phase.starting);

    // Android 12+ split permissions; on Android 11 and below the split ones
    // resolve as granted but a BLE scan additionally needs location.
    final perms = PermissionService();
    var ok =
        await perms.ensure(Permission.bluetoothScan) &&
        await perms.ensure(Permission.bluetoothConnect);
    if (ok) {
      final sdk = await BleShareService().sdkInt();
      if (sdk > 0 && sdk < 31) {
        ok = await perms.ensureLocation();
      }
    }
    if (!mounted) return;
    if (!ok) {
      setState(() => _phase = _Phase.permissionDenied);
      return;
    }

    if (!await _ble.isBluetoothOn()) {
      if (mounted) setState(() => _phase = _Phase.bluetoothOff);
      return;
    }
    await _startScan();
  }

  Future<void> _turnOnAndScan() async {
    final on = await _ble.turnOn();
    if (!mounted) return;
    if (on) {
      await _startScan();
    } else {
      setState(() => _phase = _Phase.bluetoothOff);
    }
  }

  Future<void> _startScan() async {
    _resultsSub ??= _ble.scanResults.listen((results) {
      if (mounted && _phase != _Phase.fetching) {
        setState(() => _results = results);
      }
    });
    _scanningSub ??= _ble.isScanning.listen((scanning) {
      if (mounted) setState(() => _scanning = scanning);
    });
    setState(() {
      _phase = _Phase.scanning;
      _results = const [];
    });
    try {
      await _ble.startScan();
    } on BleReceiveException catch (e) {
      _showSnack(e.message);
    }
  }

  /// Connects to [result]'s phone, downloads the vCard, and runs the shared
  /// review/import flow. Returns to scanning on failure or a cancelled review.
  Future<void> _receiveFrom(ScanResult result) async {
    // --- Authentication gate: challenge the user before downloading ---
    final senderName = _ble.displayNameOf(result) ?? 'Unknown contact';
    final signal = _signalLabel(result.rssi);
    setState(() => _phase = _Phase.authenticating);
    await _ble.stopScan();

    if (!mounted) return;
    final allowed = await showBleReceiveChallenge(
      context,
      senderName: senderName,
      signalLabel: signal,
    );
    if (!mounted) return;
    if (!allowed) {
      await _startScan();
      return;
    }

    // --- Download the vCard payload ---
    setState(() {
      _phase = _Phase.fetching;
      _fetchProgress = null;
    });

    String vcardText;
    try {
      vcardText = await _ble.fetchVCard(
        result.device,
        onProgress: (received, total) {
          if (mounted && total > 0) {
            setState(() => _fetchProgress = (received / total).clamp(0.0, 1.0));
          }
        },
      );
    } on BleReceiveException catch (e) {
      _showSnack(e.message);
      await _startScan();
      return;
    }

    List<Contact> parsed;
    try {
      parsed = await VCardService().fromVCard(vcardText);
    } catch (_) {
      parsed = const <Contact>[];
    }
    if (parsed.isEmpty) {
      _showSnack('Could not read a contact from the transfer');
      await _startScan();
      return;
    }

    if (parsed.length == 1) {
      if (!mounted) return;
      // Review before saving; AddEditContactScreen's save runs the normal
      // two-way sync (app DB + device book), same as the QR/vCard flows.
      final saved = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => AddEditContactScreen(contact: parsed.first),
        ),
      );
      if (!mounted) return;
      if (saved == true) {
        Navigator.of(context).pop(true);
      } else {
        await _startScan();
      }
      return;
    }

    // One transfer rarely holds several contacts, but the vCard format allows
    // it — confirm and bulk-import, mirroring the multi-contact .vcf flow.
    if (!mounted) return;
    final approved = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Import contacts'),
        content: Text(
          'This transfer contains ${parsed.length} contacts. Import them '
          'into SreerajP Contacts Sphere and your phone contacts?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text('Import'),
          ),
        ],
      ),
    );
    if (approved != true) {
      await _startScan();
      return;
    }

    final sync = ContactSyncService();
    var imported = 0;
    for (final contact in parsed) {
      try {
        await sync.saveContact(contact);
        imported++;
      } catch (_) {
        // Keep going; report what actually made it.
      }
    }
    if (!mounted) return;
    if (imported > 0) {
      Navigator.of(context).pop(true);
    } else {
      _showSnack('Import failed');
      await _startScan();
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receive via Bluetooth'),
        actions: [
          if (_phase == _Phase.scanning && !_scanning)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Scan again',
              onPressed: _startScan,
            ),
        ],
      ),
      body: switch (_phase) {
        _Phase.starting => const Center(child: CircularProgressIndicator()),
        _Phase.permissionDenied => _CenteredNotice(
          icon: Icons.bluetooth_disabled,
          message:
              'Bluetooth permission is needed to receive a contact. Allow '
              'Nearby devices for SreerajP Contacts Sphere and try again.',
          actionLabel: 'Try again',
          onAction: _init,
        ),
        _Phase.bluetoothOff => _CenteredNotice(
          icon: Icons.bluetooth_disabled,
          message: 'Bluetooth is off.',
          actionLabel: 'Turn on Bluetooth',
          onAction: _turnOnAndScan,
        ),
        _Phase.authenticating => const _CenteredProgress(
          label: 'Verifying…',
        ),
        _Phase.fetching => _CenteredProgress(
          label: _fetchProgress == null
              ? 'Receiving…'
              : 'Receiving… ${(_fetchProgress! * 100).round()}%',
          value: _fetchProgress,
        ),
        _Phase.scanning => _buildScanBody(context),
      },
    );
  }

  Widget _buildScanBody(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        if (_scanning)
          const LinearProgressIndicator(minHeight: 2)
        else
          const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(
            'On the other phone, open the contact and choose '
            '"Share via Bluetooth". It will appear below.',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: _results.isEmpty
              ? Center(
                  child: Text(
                    _scanning
                        ? 'Looking for nearby phones…'
                        : 'No phones found.',
                    style: theme.textTheme.bodyMedium,
                  ),
                )
              : ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final result = _results[index];
                    final name =
                        _ble.displayNameOf(result) ?? 'Unknown contact';
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.bluetooth)),
                      title: Text(name),
                      subtitle: Text(_signalLabel(result.rssi)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _receiveFrom(result),
                    );
                  },
                ),
        ),
      ],
    );
  }

  /// Rough proximity from RSSI — exact dBm means nothing to most users.
  String _signalLabel(int rssi) {
    if (rssi >= -60) return 'Very close';
    if (rssi >= -75) return 'Nearby';
    return 'Weak signal — move the phones closer';
  }
}

/// Icon + message + one action, centered — the screen's blocking states.
class _CenteredNotice extends StatelessWidget {
  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _CenteredNotice({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}

class _CenteredProgress extends StatelessWidget {
  final String label;

  /// Progress in [0, 1] for a determinate indicator; null = indeterminate.
  final double? value;

  const _CenteredProgress({required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(value: value),
          const SizedBox(height: 16),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
