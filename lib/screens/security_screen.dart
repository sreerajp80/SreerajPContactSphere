// lib/screens/security_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_contacts_dialer/screens/app_pin_setup_screen.dart';
import 'package:smart_contacts_dialer/screens/audit_log_screen.dart';
import 'package:smart_contacts_dialer/screens/screenshot_guard_settings_screen.dart';
import 'package:smart_contacts_dialer/services/app_pin_service.dart';
import 'package:smart_contacts_dialer/services/auth_service.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

/// Security preferences screen reached from Settings -> Security.
/// Houses App Lock, Block Screenshots, and Audit Log settings.
class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          const AppLockCard(),
          const SizedBox(height: 12),
          _SettingsTileCard(
            icon: Icons.screenshot_monitor_outlined,
            title: 'Screenshot guard',
            subtitle: 'Block screenshots, recordings, and Recents preview',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ScreenshotGuardSettingsScreen(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _SettingsTileCard(
            icon: Icons.history,
            title: 'Audit log',
            subtitle: 'What changed on your contacts, and how to undo it',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AuditLogScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTileCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTileCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final accent = theme.colorScheme.primary;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(color: colors.mutedText, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colors.mutedText),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card that picks how the app is locked: Off, Device lock, or an app PIN.
class AppLockCard extends StatefulWidget {
  const AppLockCard({super.key});

  @override
  State<AppLockCard> createState() => _AppLockCardState();
}

class _AppLockCardState extends State<AppLockCard> {
  bool _deviceLockAvailable = true;

  @override
  void initState() {
    super.initState();
    _checkAvailable();
  }

  Future<void> _checkAvailable() async {
    final available = await AuthService().isAvailable;
    if (mounted) setState(() => _deviceLockAvailable = available);
  }

  String _subtitleFor(LockMode mode) => switch (mode) {
        LockMode.none => 'Off — the app opens without a lock',
        LockMode.deviceLock => 'On — unlock with your device lock',
        LockMode.appPin => 'On — unlock with your app PIN',
      };

  Future<void> _openChooser(AppSettings settings) async {
    final chosen = await showModalBottomSheet<LockMode>(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) => _LockModeSheet(
        current: settings.lockMode,
        deviceLockAvailable: _deviceLockAvailable,
      ),
    );
    if (chosen == null || chosen == settings.lockMode) return;
    if (!mounted) return;

    switch (chosen) {
      case LockMode.none:
        await settings.setLockMode(LockMode.none);
      case LockMode.deviceLock:
        await settings.setLockMode(LockMode.deviceLock);
      case LockMode.appPin:
        final hasPin = await AppPinService().hasPin();
        if (!mounted) return;
        if (hasPin) {
          await settings.setLockMode(LockMode.appPin);
          return;
        }
        final saved = await Navigator.of(context).push<bool>(
          MaterialPageRoute(builder: (_) => const AppPinSetupScreen()),
        );
        if (saved == true && mounted) {
          await settings.setLockMode(LockMode.appPin);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final accent = theme.colorScheme.primary;
    final settings = context.watch<AppSettings>();
    final on = settings.appLockEnabled;
    final iconColor = on ? accent : colors.mutedText;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _openChooser(settings),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(Icons.lock_outline, color: iconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'App lock',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _subtitleFor(settings.lockMode),
                      style: TextStyle(color: colors.mutedText, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colors.mutedText),
            ],
          ),
        ),
      ),
    );
  }
}

class _LockModeSheet extends StatelessWidget {
  final LockMode current;
  final bool deviceLockAvailable;

  const _LockModeSheet({
    required this.current,
    required this.deviceLockAvailable,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'App lock',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          _option(
            context,
            mode: LockMode.none,
            icon: Icons.lock_open_outlined,
            title: 'Off',
            subtitle: 'No lock when opening the app',
          ),
          _option(
            context,
            mode: LockMode.deviceLock,
            icon: Icons.fingerprint,
            title: 'Device lock',
            subtitle: deviceLockAvailable
                ? 'Fingerprint, face or device PIN'
                : 'Set a screen lock on your device to use this',
            enabled: deviceLockAvailable,
            colors: colors,
          ),
          _option(
            context,
            mode: LockMode.appPin,
            icon: Icons.pin_outlined,
            title: 'App PIN',
            subtitle: 'A separate PIN just for this app',
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _option(
    BuildContext context, {
    required LockMode mode,
    required IconData icon,
    required String title,
    required String subtitle,
    bool enabled = true,
    AppColors? colors,
  }) {
    final muted = colors?.mutedText;
    return ListTile(
      enabled: enabled,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: (!enabled && muted != null) ? TextStyle(color: muted) : null,
      ),
      trailing: current == mode ? const Icon(Icons.check) : null,
      onTap: enabled ? () => Navigator.of(context).pop(mode) : null,
    );
  }
}
