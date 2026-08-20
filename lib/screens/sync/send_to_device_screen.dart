// lib/screens/sync/send_to_device_screen.dart
//
// Host side of P2P sync (connect-then-choose). This phone starts hosting and
// shows a QR + IP/port/pairing code. Once the other phone connects, the sender
// chooses what to share — a Full Sync (for a brand-new phone) or specific
// categories — and the payload is pushed. The receiver MERGES it add-only, so
// nothing on the other phone is overwritten.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:smart_contacts_dialer/services/p2p_sync_service.dart';
import 'package:smart_contacts_dialer/services/sync_bundle_service.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';
import 'package:smart_contacts_dialer/screens/sync/sync_views.dart';

class SendToDeviceScreen extends StatefulWidget {
  const SendToDeviceScreen({super.key});

  @override
  State<SendToDeviceScreen> createState() => _SendToDeviceScreenState();
}

class _SendToDeviceScreenState extends State<SendToDeviceScreen> {
  final P2PSyncService _service = P2PSyncService();

  @override
  void dispose() {
    _service.cancel(); // tear down the host server / socket on leaving
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send to Another Device')),
      body: ListenableBuilder(
        listenable: _service,
        builder: (context, _) {
          final state = _service.state;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [_body(context, state)],
          );
        },
      ),
    );
  }

  Widget _body(BuildContext context, SyncState state) {
    if (state is SyncHosting) {
      return _HostingView(state: state, service: _service);
    }
    if (state is SyncInProgress) {
      return SyncProgressView(message: state.message, fraction: state.fraction);
    }
    if (state is SyncCompleted && state.sent) {
      final s = state.summary;
      return SyncResultView(
        success: true,
        title: 'Sent',
        message:
            'Sent ${s.contactsAdded} contacts, ${s.groups} groups and '
            '${s.callLogs} call-log entries to the other phone.',
        onDone: () => _service.cancel(),
      );
    }
    if (state is SyncError) {
      return SyncResultView(
        success: false,
        title: 'Could not send',
        message: state.message,
        onDone: () => _service.cancel(),
      );
    }
    // Idle
    return _StartView(onStart: () => _service.startHost());
  }
}

class _StartView extends StatelessWidget {
  final VoidCallback onStart;
  const _StartView({required this.onStart});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SyncInfoCard(
          icon: Icons.info_outline,
          text:
              'Share this phone\'s SreerajP Contacts Sphere data with another phone on '
              'the same Wi-Fi. Start below, then scan the QR (or type the code) '
              'on the other phone. After it connects, pick what to send.',
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onStart,
          icon: const Icon(Icons.wifi_tethering),
          label: const Text('Start'),
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

class _HostingView extends StatelessWidget {
  final SyncHosting state;
  final P2PSyncService service;

  const _HostingView({required this.state, required this.service});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ConnectionCard(state: state),
        const SizedBox(height: 16),
        _StatusChip(connected: state.clientConnected),
        const SizedBox(height: 16),
        if (state.clientConnected)
          _ChooseWhatToShare(service: service)
        else
          Center(
            child: OutlinedButton(
              onPressed: () => service.cancel(),
              child: const Text('Cancel'),
            ),
          ),
      ],
    );
  }
}

class _ConnectionCard extends StatelessWidget {
  final SyncHosting state;
  const _ConnectionCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final accent = theme.colorScheme.primary;
    final grouped = P2PSyncService.groupCode(state.code);
    final uri = P2PSyncService.buildSyncUri(
      ip: state.ipAddress,
      port: state.port,
      code: state.code,
    );

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'On the other phone, choose Receive, then scan this code:',
              style: TextStyle(color: colors.mutedText, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Tight box: QrImageView is built around a LayoutBuilder that throws
            // on intrinsic-size queries; a fixed square answers it directly.
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SizedBox.square(
                dimension: 220,
                child: QrImageView(data: uri),
              ),
            ),
            const Divider(height: 32),
            Text(
              '…or enter these by hand:',
              style: TextStyle(color: colors.mutedText, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            SyncLabeledValue(
              label: 'This phone\'s address',
              value: '${state.ipAddress}:${state.port}',
              onCopy: () =>
                  _copy(context, '${state.ipAddress}:${state.port}', 'Address'),
            ),
            const SizedBox(height: 12),
            Text(
              'Pairing code',
              style: TextStyle(color: colors.mutedText, fontSize: 13),
            ),
            const SizedBox(height: 8),
            SelectableText(
              grouped,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                fontFeatures: const [FontFeature.tabularFigures()],
                color: accent,
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => _copy(context, state.code, 'Code'),
              icon: const Icon(Icons.copy, size: 18),
              label: const Text('Copy code'),
            ),
          ],
        ),
      ),
    );
  }

  void _copy(BuildContext context, String value, String what) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$what copied'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool connected;
  const _StatusChip({required this.connected});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    if (!connected) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(
            'Waiting for the other phone…',
            style: TextStyle(color: colors.mutedText),
          ),
        ],
      );
    }
    const green = Color(0xFF10B981);
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.check_circle, color: green, size: 20),
        SizedBox(width: 8),
        Text(
          'Other phone connected',
          style: TextStyle(color: green, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// Full Sync + per-category checkboxes, enabled only once a peer is connected.
class _ChooseWhatToShare extends StatefulWidget {
  final P2PSyncService service;
  const _ChooseWhatToShare({required this.service});

  @override
  State<_ChooseWhatToShare> createState() => _ChooseWhatToShareState();
}

class _ChooseWhatToShareState extends State<_ChooseWhatToShare> {
  // Contacts are the spine and always travel; these are the optional extras.
  // The emergency card is left OFF by default: it is personal medical data, so
  // sharing it is always a deliberate tick.
  final Set<SyncCategory> _selected = {
    SyncCategory.callHistory,
    SyncCategory.groups,
    SyncCategory.relationships,
    SyncCategory.blockedNumbers,
    SyncCategory.settings,
  };

  static const _labels = <SyncCategory, String>{
    SyncCategory.callHistory: 'Call history',
    SyncCategory.groups: 'Groups',
    SyncCategory.relationships: 'Relationships',
    SyncCategory.blockedNumbers: 'Blocked & spam numbers',
    SyncCategory.emergencyCard: 'Emergency info card',
    SyncCategory.settings: 'App settings',
  };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Choose what to share',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        const SyncInfoCard(
          icon: Icons.shield_outlined,
          text:
              'This never overrides anything already on the other phone. On '
              'a conflict, the other phone keeps its own data.',
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => _confirmFullSync(context),
          icon: const Icon(Icons.copy_all),
          label: const Text('Full Sync (for a brand-new phone)'),
        ),
        const SizedBox(height: 20),
        Text(
          'Or send only:',
          style: TextStyle(color: colors.mutedText, fontSize: 13),
        ),
        const ListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          leading: Icon(Icons.person),
          title: Text('Contacts'),
          subtitle: Text('Always included'),
          trailing: Icon(Icons.lock_outline, size: 18),
        ),
        for (final entry in _labels.entries)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            value: _selected.contains(entry.key),
            title: Text(entry.value),
            onChanged: (v) => setState(() {
              if (v == true) {
                _selected.add(entry.key);
              } else {
                _selected.remove(entry.key);
              }
            }),
          ),
        const SizedBox(height: 12),
        FilledButton.tonalIcon(
          onPressed: () => widget.service.sendSelectiveSync(_selected),
          icon: const Icon(Icons.send),
          label: const Text('Send selected'),
        ),
        const SizedBox(height: 8),
        Center(
          child: OutlinedButton(
            onPressed: () => widget.service.cancel(),
            child: const Text('Cancel'),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmFullSync(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Full Sync?'),
        content: const Text(
          'Send everything (contacts, groups, call history, relationships, '
          'blocked numbers and settings). Best for a brand-new phone. The other '
          'phone still keeps any data it already has.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Send everything'),
          ),
        ],
      ),
    );
    if (ok == true) widget.service.sendFullSync();
  }
}
