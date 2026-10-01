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

import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
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
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).titleSendToDevice),
      ),
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
        title: AppLocalizations.of(context).titleSent,
        message: AppLocalizations.of(
          context,
        ).descSentSummary(s.contactsAdded, s.groups, s.callLogs),
        onDone: () => _service.cancel(),
      );
    }
    if (state is SyncError) {
      return SyncResultView(
        success: false,
        title: AppLocalizations.of(context).titleCouldNotSend,
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
        SyncInfoCard(
          icon: Icons.info_outline,
          text: AppLocalizations.of(context).descSendIntro,
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onStart,
          icon: const Icon(Icons.wifi_tethering),
          label: Text(AppLocalizations.of(context).actionStart),
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context).descSameWifi,
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
              child: Text(AppLocalizations.of(context).actionCancel),
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
              AppLocalizations.of(context).descScanThisCode,
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
              AppLocalizations.of(context).descEnterTheseByHand,
              style: TextStyle(color: colors.mutedText, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            SyncLabeledValue(
              label: AppLocalizations.of(context).labelThisPhoneAddress,
              value: '${state.ipAddress}:${state.port}',
              onCopy: () => _copy(
                context,
                '${state.ipAddress}:${state.port}',
                AppLocalizations.of(context).msgAddressCopied,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context).labelPairingCode,
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
              onPressed: () => _copy(
                context,
                state.code,
                AppLocalizations.of(context).msgCodeCopied,
              ),
              icon: const Icon(Icons.copy, size: 18),
              label: Text(AppLocalizations.of(context).actionCopyCode),
            ),
          ],
        ),
      ),
    );
  }

  void _copy(BuildContext context, String value, String copiedMessage) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(copiedMessage),
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
            AppLocalizations.of(context).msgWaitingForOtherPhone,
            style: TextStyle(color: colors.mutedText),
          ),
        ],
      );
    }
    const green = Color(0xFF10B981);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle, color: green, size: 20),
        const SizedBox(width: 8),
        Text(
          AppLocalizations.of(context).labelOtherPhoneConnected,
          style: const TextStyle(color: green, fontWeight: FontWeight.w600),
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

  static Map<SyncCategory, String> _labelsFor(AppLocalizations l) => {
    SyncCategory.callHistory: l.labelCallHistory,
    SyncCategory.groups: l.tooltipGroups,
    SyncCategory.relationships: l.labelRelationships,
    SyncCategory.blockedNumbers: l.labelBlockedSpamNumbers,
    SyncCategory.emergencyCard: l.labelEmergencyInfoCard,
    SyncCategory.settings: l.labelAppSettings,
  };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppLocalizations.of(context).titleChooseWhatToShare,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SyncInfoCard(
          icon: Icons.shield_outlined,
          text: AppLocalizations.of(context).descNeverOverrides,
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => _confirmFullSync(context),
          icon: const Icon(Icons.copy_all),
          label: Text(AppLocalizations.of(context).actionFullSyncNewPhone),
        ),
        const SizedBox(height: 20),
        Text(
          AppLocalizations.of(context).labelOrSendOnly,
          style: TextStyle(color: colors.mutedText, fontSize: 13),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          leading: const Icon(Icons.person),
          title: Text(AppLocalizations.of(context).navContacts),
          subtitle: Text(AppLocalizations.of(context).labelAlwaysIncluded),
          trailing: const Icon(Icons.lock_outline, size: 18),
        ),
        for (final entry in _labelsFor(AppLocalizations.of(context)).entries)
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
          label: Text(AppLocalizations.of(context).actionSendSelected),
        ),
        const SizedBox(height: 8),
        Center(
          child: OutlinedButton(
            onPressed: () => widget.service.cancel(),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmFullSync(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context).titleFullSync),
        content: Text(AppLocalizations.of(context).descFullSync),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppLocalizations.of(context).actionSendEverything),
          ),
        ],
      ),
    );
    if (ok == true) widget.service.sendFullSync();
  }
}
