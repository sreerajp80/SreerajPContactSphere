// lib/screens/permissions_screen.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:smart_contacts_dialer/core/constants/app_permissions.dart';
import 'package:smart_contacts_dialer/services/contact_sync_service.dart';
import 'package:smart_contacts_dialer/services/telecom_service.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

/// Lists every permission the app uses, grouped into Explicit (runtime-prompted)
/// and Implicit (declared, no separate prompt). Live grant status is shown for
/// permissions that expose one.
class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  final TelecomService _telecom = TelecomService();
  final Map<Permission, PermissionStatus> _statuses = {};

  /// Whether ContactSphere is the default phone app right now. Null while the
  /// first query is still in flight (the row shows a spinner until then).
  bool? _isDefaultDialer;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    final result = <Permission, PermissionStatus>{};
    for (final p in kAppPermissions) {
      final handle = p.handle;
      if (handle == null) continue;
      try {
        result[handle] = await handle.status;
      } catch (_) {
        // Some permissions aren't queryable on every OS version; skip silently.
      }
    }
    // The default-dialer role isn't a permission_handler permission; read it
    // from the native Telecom bridge (false off Android / on failure).
    bool isDefault = false;
    try {
      isDefault = await _telecom.isDefaultDialer();
    } catch (_) {
      // Best-effort; leave it false.
    }
    if (!mounted) return;
    setState(() {
      _statuses
        ..clear()
        ..addAll(result);
      _isDefaultDialer = isDefault;
      _loading = false;
    });

    // If contacts access is (now) granted, pull the device book into the app.
    // Best-effort and fire-and-forget so viewing this screen never blocks.
    final contacts = result[Permission.contacts];
    if (contacts != null && (contacts.isGranted || contacts.isLimited)) {
      unawaitedSyncFromDevice();
    }
  }

  @override
  Widget build(BuildContext context) {
    final explicit = kAppPermissions
        .where((p) => p.group == PermissionGroup.explicit)
        .toList();
    final implicit = kAppPermissions
        .where((p) => p.group == PermissionGroup.implicit)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Permissions'),
        actions: [
          const IconButton(
            tooltip: 'Open system settings',
            icon: Icon(Icons.settings_outlined),
            onPressed: openAppSettings,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            _sectionHeader(
              context,
              'Explicit',
              'Permissions and system roles requiring user interaction or runtime approval.',
            ),
            _group(context, explicit),
            const SizedBox(height: 24),
            _sectionHeader(
              context,
              'Implicit',
              'Declared in the manifest; granted automatically by system at install.',
            ),
            _group(context, implicit),
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title, String subtitle) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(color: colors.mutedText),
          ),
        ],
      ),
    );
  }

  Widget _group(BuildContext context, List<AppPermission> items) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Card(
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: colors.mutedText.withValues(alpha: 0.18),
              ),
            _row(context, items[i]),
          ],
        ],
      ),
    );
  }

  Widget _row(BuildContext context, AppPermission p) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final status = p.handle != null ? _statuses[p.handle] : null;
    return ListTile(
      leading: Icon(p.icon, color: theme.colorScheme.primary),
      title: Text(p.title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(p.reason, style: TextStyle(color: colors.mutedText)),
      trailing: p.isDefaultDialerRole
          ? _dialerChip(context)
          : _statusChip(context, status),
      isThreeLine: p.reason.length > 38,
      onTap: () => _onTap(p),
    );
  }

  /// Handles a row tap. Runtime permissions prompt when they can (undecided) or
  /// otherwise open the app's system settings page — Android has no per-
  /// permission deep link, so its settings page is the "corresponding page".
  /// The default-dialer row fires the system role prompt instead.
  Future<void> _onTap(AppPermission p) async {
    if (p.isDefaultDialerRole) {
      if (_isDefaultDialer == true) {
        await openAppSettings();
      } else {
        await _telecom.requestDefaultDialer();
      }
      await _refresh();
      return;
    }
    final handle = p.handle;
    if (handle == null) {
      // Implicit / system-managed: the app info page is the closest system page.
      await openAppSettings();
      return;
    }
    try {
      final status = await handle.status;
      // Undecided (plain denied, not permanently) → we can still show the OS
      // dialog; anything else (granted / limited / blocked) → open settings.
      if (status.isDenied && !status.isPermanentlyDenied) {
        await handle.request();
      } else {
        await openAppSettings();
      }
    } catch (_) {
      // Fall back to the settings page if the query/request isn't supported.
      await openAppSettings();
    }
    await _refresh();
  }

  Widget _statusChip(BuildContext context, PermissionStatus? status) {
    if (status == null) {
      // No runtime status to show (implicit / system-managed).
      return Text(
        'System',
        style: TextStyle(
          color: Theme.of(context).extension<AppColors>()!.mutedText,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      );
    }
    final granted = status.isGranted || status.isLimited;
    final color = granted ? const Color(0xFF10B981) : const Color(0xFFFB7185);
    final label = granted
        ? 'Granted'
        : status.isPermanentlyDenied
        ? 'Blocked'
        : 'Denied';
    return _chip(label, color);
  }

  /// Live chip for the default-dialer row: a spinner until the first query
  /// resolves, then "Default" (green) when set or "Not set" (rose) when not.
  Widget _dialerChip(BuildContext context) {
    final isDefault = _isDefaultDialer;
    if (isDefault == null) {
      return const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return isDefault
        ? _chip('Default', const Color(0xFF10B981))
        : _chip('Not set', const Color(0xFFFB7185));
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
