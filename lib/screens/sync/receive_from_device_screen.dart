// lib/screens/sync/receive_from_device_screen.dart
//
// Client side of P2P sync. Scan the sender's QR (or type its address + pairing
// code), connect, wait for the sender to choose what to share, then MERGE it
// into this phone add-only — the receiver keeps its own data; nothing is
// overwritten or removed. Secret contacts can be part of the payload, so the
// whole sync area is entered behind a biometric check at the Settings level.

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import 'package:smart_contacts_dialer/services/p2p_sync_service.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';
import 'package:smart_contacts_dialer/screens/sync/sync_views.dart';

class ReceiveFromDeviceScreen extends StatefulWidget {
  const ReceiveFromDeviceScreen({super.key});

  @override
  State<ReceiveFromDeviceScreen> createState() =>
      _ReceiveFromDeviceScreenState();
}

class _ReceiveFromDeviceScreenState extends State<ReceiveFromDeviceScreen> {
  final P2PSyncService _service = P2PSyncService();
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  bool _settingsReloaded = false;

  @override
  void dispose() {
    _service.cancel();
    _ipController.dispose();
    _portController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receive from Another Device')),
      body: ListenableBuilder(
        listenable: _service,
        builder: (context, _) {
          final state = _service.state;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _body(context, state),
              if (state is SyncCompleted && !state.sent)
                _reloadSettings(context),
            ],
          );
        },
      ),
    );
  }

  Widget _body(BuildContext context, SyncState state) {
    if (state is SyncConnecting) {
      return const SyncProgressView(message: 'Connecting…');
    }
    if (state is SyncWaitingForSender) {
      return const SyncProgressView(
        message: 'Connected — waiting for the sender to choose…',
      );
    }
    if (state is SyncInProgress) {
      return SyncProgressView(message: state.message, fraction: state.fraction);
    }
    if (state is SyncCompleted && !state.sent) {
      final s = state.summary;
      return SyncResultView(
        success: true,
        title: 'Received',
        message:
            'Added ${s.contactsAdded} new contacts '
            '(${s.contactsSkipped} already on this phone were kept). '
            'Nothing was removed.',
        onDone: () {
          _settingsReloaded = false;
          _service.cancel();
        },
      );
    }
    if (state is SyncError) {
      return SyncResultView(
        success: false,
        title: 'Could not receive',
        message: state.message,
        onDone: () => _service.cancel(),
      );
    }
    return _ReceiveForm(
      ipController: _ipController,
      portController: _portController,
      codeController: _codeController,
      onScan: _scan,
      onConnect: _connect,
    );
  }

  Future<void> _scan() async {
    final result = await Navigator.of(context)
        .push<({String ip, int port, String code})>(
          MaterialPageRoute(builder: (_) => const _SyncQrScanScreen()),
        );
    if (result == null || !mounted) return;
    _ipController.text = result.ip;
    _portController.text = result.port.toString();
    _codeController.text = result.code;
    _service.connectAndReceive(result.ip, result.port, result.code);
  }

  void _connect() {
    final ip = _ipController.text.trim();
    final port = int.tryParse(_portController.text.trim());
    final code = _codeController.text.trim();
    if (ip.isEmpty || port == null || code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter the address, port and pairing code'),
        ),
      );
      return;
    }
    _service.connectAndReceive(ip, port, code);
  }

  /// After a successful receive the settings on disk may have changed, so
  /// refresh the in-memory [AppSettings] once (theme/accent/toggles/mirrors).
  Widget _reloadSettings(BuildContext context) {
    if (!_settingsReloaded) {
      _settingsReloaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<AppSettings>().load();
      });
    }
    return const SizedBox.shrink();
  }
}

class _ReceiveForm extends StatelessWidget {
  final TextEditingController ipController;
  final TextEditingController portController;
  final TextEditingController codeController;
  final VoidCallback onScan;
  final VoidCallback onConnect;

  const _ReceiveForm({
    required this.ipController,
    required this.portController,
    required this.codeController,
    required this.onScan,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SyncInfoCard(
          icon: Icons.download_outlined,
          text:
              'This ADDS the other phone\'s contacts to this phone. Contacts '
              'you already have are kept as they are — nothing here is changed '
              'or removed.',
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onScan,
          icon: const Icon(Icons.qr_code_scanner),
          label: const Text('Scan the other phone\'s QR'),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Divider(color: colors.mutedText.withValues(alpha: 0.4)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'or enter by hand',
                style: TextStyle(color: colors.mutedText, fontSize: 12.5),
              ),
            ),
            Expanded(
              child: Divider(color: colors.mutedText.withValues(alpha: 0.4)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: ipController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Other phone\'s address',
                  hintText: 'e.g. 192.168.1.42',
                  prefixIcon: Icon(Icons.wifi),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: portController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Port',
                  hintText: 'e.g. 51234',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: codeController,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: 'Pairing code',
            hintText: 'shown on the other phone',
            prefixIcon: Icon(Icons.password),
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: onConnect,
          icon: const Icon(Icons.link),
          label: const Text('Connect'),
        ),
        const SizedBox(height: 8),
        Text(
          'Both phones must be on the same Wi-Fi network.',
          style: TextStyle(color: colors.mutedText, fontSize: 12.5),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Camera scanner for a ContactSphere pairing QR. Pops with the parsed
/// (ip, port, code) on the first valid code, or nothing if the user backs out.
class _SyncQrScanScreen extends StatefulWidget {
  const _SyncQrScanScreen();

  @override
  State<_SyncQrScanScreen> createState() => _SyncQrScanScreenState();
}

class _SyncQrScanScreenState extends State<_SyncQrScanScreen> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );
  bool _handling = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handling) return;
    String? raw;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue?.trim();
      if (value != null && value.isNotEmpty) {
        raw = value;
        break;
      }
    }
    if (raw == null) return;

    _handling = true;
    await _controller.stop();

    final parsed = P2PSyncService.parseSyncUri(raw);
    if (parsed == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Not a ContactSphere pairing code')),
        );
      }
      try {
        await _controller.start();
      } catch (_) {}
      _handling = false;
      return;
    }
    if (mounted) Navigator.of(context).pop(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan pairing code'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          IgnorePointer(
            child: Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: accent, width: 3),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
