// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_contacts_dialer/services/app_pin_service.dart';
import 'package:smart_contacts_dialer/services/auth_service.dart';
import 'package:smart_contacts_dialer/services/telecom_service.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';
import 'package:smart_contacts_dialer/utils/phone_normalizer.dart';
import 'package:smart_contacts_dialer/screens/about_screen.dart';
import 'package:smart_contacts_dialer/screens/app_pin_setup_screen.dart';
import 'package:smart_contacts_dialer/screens/appearance_screen.dart';
import 'package:smart_contacts_dialer/screens/audit_log_screen.dart';
import 'package:smart_contacts_dialer/screens/backup/backup_restore_screen.dart';
import 'package:smart_contacts_dialer/screens/contacts_settings_screen.dart';
import 'package:smart_contacts_dialer/screens/default_country_screen.dart';
import 'package:smart_contacts_dialer/screens/emergency_info_screen.dart';
import 'package:smart_contacts_dialer/screens/features_screen.dart';
import 'package:smart_contacts_dialer/screens/help/help_home_screen.dart';
import 'package:smart_contacts_dialer/screens/permissions_screen.dart';
import 'package:smart_contacts_dialer/screens/ringtone_settings_screen.dart';
import 'package:smart_contacts_dialer/screens/sim_settings_screen.dart';
import 'package:smart_contacts_dialer/screens/sync/sync_home_screen.dart';

/// Settings hub reached from the contacts ⋮ menu. Three cards route to the
/// Appearance, Permissions and About screens.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          const _DefaultDialerCard(),
          const SizedBox(height: 12),
          const _AppLockCard(),
          const SizedBox(height: 12),
          const _DialerTopContactsCard(),
          const SizedBox(height: 12),
          const _DialpadScriptCard(),
          const SizedBox(height: 12),
          const _ScreenshotGuardCard(),
          const SizedBox(height: 12),
          _SettingsCard(
            icon: Icons.history,
            title: 'Audit Log',
            subtitle: 'What changed on your contacts, and how to undo it',
            onTap: () => _push(context, const AuditLogScreen()),
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            icon: Icons.contacts_outlined,
            title: 'Contacts',
            subtitle: 'Your profile and contact options',
            onTap: () => _push(context, const ContactsSettingsScreen()),
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            icon: Icons.sync_alt,
            title: 'Sync to Another Device',
            subtitle: 'Send or receive contacts over Wi-Fi',
            onTap: () => _openSync(context),
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            icon: Icons.backup_outlined,
            title: 'Backup & Restore',
            subtitle: 'Save all your data to a file, or restore it',
            onTap: () => _openBackup(context),
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            icon: Icons.sim_card_outlined,
            title: 'SIM & calling',
            subtitle: 'Default SIM, caller identification and spam filtering',
            onTap: () => _push(context, const SimSettingsScreen()),
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            icon: Icons.notifications_active_outlined,
            title: 'Ringtone',
            subtitle: 'Volume, vibration and per-SIM ringtones',
            onTap: () => _push(context, const RingtoneSettingsScreen()),
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            icon: Icons.medical_information_outlined,
            title: 'Emergency info',
            subtitle: 'A card a helper can read on your lock screen',
            onTap: () => _push(context, const EmergencyInfoScreen()),
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            icon: Icons.public_outlined,
            title: 'Default country',
            subtitle: _countrySubtitle(context),
            onTap: () => _push(context, const DefaultCountryScreen()),
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            icon: Icons.palette_outlined,
            title: 'Appearance',
            subtitle: 'Theme mode and accent color',
            onTap: () => _push(context, const AppearanceScreen()),
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            icon: Icons.stars_outlined,
            title: 'Features',
            subtitle: 'Explore all features of ContactSphere',
            onTap: () => _push(context, const FeaturesScreen()),
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            icon: Icons.shield_outlined,
            title: 'Permissions',
            subtitle: 'What the app can access and why',
            onTap: () => _push(context, const PermissionsScreen()),
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            icon: Icons.help_outline,
            title: 'Help',
            subtitle: 'How features like sync work',
            onTap: () => _push(context, const HelpHomeScreen()),
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'Version, author and build details',
            onTap: () => _push(context, const AboutScreen()),
          ),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  /// Opens the Sync hub behind a biometric check — the payload can include
  /// secret contacts, so it is gated like secret-contact access.
  ///
  /// On a secured device (a lock is set up) we require a successful unlock. On a
  /// device with no lock at all authentication is impossible, so rather than
  /// trapping the user we warn them that synced data can't be protected and let
  /// them continue if they choose.
  Future<void> _openSync(BuildContext context) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final auth = AuthService();

    if (await auth.isAvailable) {
      final ok = await auth.authenticate(
        reason: 'Authenticate to sync your data',
      );
      if (ok) {
        navigator.push(
          MaterialPageRoute(builder: (_) => const SyncHomeScreen()),
        );
      } else {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Authentication required to sync your data'),
          ),
        );
      }
      return;
    }

    // No device lock: authentication can't run. Warn and let the user decide.
    if (!context.mounted) return;
    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('No screen lock'),
        content: const Text(
          'Your device has no screen lock, so synced data can\'t be protected '
          'by authentication. This may include secret contacts. Continue '
          'anyway?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (proceed == true) {
      navigator.push(MaterialPageRoute(builder: (_) => const SyncHomeScreen()));
    }
  }

  /// Opens Backup & Restore behind the same biometric check as Sync — a backup
  /// can include secret contacts, so it is gated like secret-contact access.
  /// Mirrors [_openSync]: require an unlock on a secured device; on a device
  /// with no lock, warn and let the user decide rather than trapping them.
  Future<void> _openBackup(BuildContext context) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final auth = AuthService();

    if (await auth.isAvailable) {
      final ok = await auth.authenticate(
        reason: 'Authenticate to back up or restore your data',
      );
      if (ok) {
        navigator.push(
          MaterialPageRoute(builder: (_) => const BackupRestoreScreen()),
        );
      } else {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Authentication required to back up or restore'),
          ),
        );
      }
      return;
    }

    // No device lock: authentication can't run. Warn and let the user decide.
    if (!context.mounted) return;
    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('No screen lock'),
        content: const Text(
          'Your device has no screen lock, so a backup can\'t be protected by '
          'authentication. A backup may include secret contacts. Continue '
          'anyway?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (proceed == true) {
      navigator.push(
        MaterialPageRoute(builder: (_) => const BackupRestoreScreen()),
      );
    }
  }

  /// The Default country card's subtitle, reflecting the current selection
  /// (e.g. "India (+91) · used to identify callers").
  String _countrySubtitle(BuildContext context) {
    final iso = context.watch<AppSettings>().defaultCountryIso;
    final code = PhoneNormalizer.isoFromString(iso);
    final label = code == null
        ? iso
        : '${PhoneNormalizer.nameFor(code)} (+${PhoneNormalizer.dialCodeFor(code)})';
    return '$label · used to identify callers';
  }
}

/// Shows whether ContactSphere is Android's default phone app and lets the user
/// request the role. On non-Android hosts the status query resolves false and
/// tapping is a no-op, so the card simply prompts (harmlessly) to set default.
class _DefaultDialerCard extends StatefulWidget {
  const _DefaultDialerCard();

  @override
  State<_DefaultDialerCard> createState() => _DefaultDialerCardState();
}

class _DefaultDialerCardState extends State<_DefaultDialerCard> {
  final TelecomService _telecom = TelecomService();
  bool _isDefault = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final value = await _telecom.isDefaultDialer();
    if (mounted) setState(() => _isDefault = value);
  }

  Future<void> _request() async {
    if (_isDefault || _busy) return;
    setState(() => _busy = true);
    await _telecom.requestDefaultDialer();
    if (!mounted) return;
    setState(() => _busy = false);
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final accent = theme.colorScheme.primary;
    const green = Color(0xFF10B981);

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: _isDefault ? null : _request,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (_isDefault ? green : accent).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  _isDefault ? Icons.verified_outlined : Icons.dialpad,
                  color: _isDefault ? green : accent,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Default phone app',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isDefault
                          ? 'ContactSphere handles your calls'
                          : 'Set ContactSphere as your default dialer',
                      style: TextStyle(color: colors.mutedText, fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (_busy)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (_isDefault)
                const Icon(Icons.check_circle, color: green)
              else
                Icon(Icons.chevron_right, color: colors.mutedText),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card that picks how the app is locked: Off, Device lock, or an app PIN.
/// Tapping opens a chooser. "Device lock" is disabled when the device has no
/// screen lock (authentication can't run); "App PIN" is always available and
/// launches PIN setup the first time it's chosen.
class _AppLockCard extends StatefulWidget {
  const _AppLockCard();

  @override
  State<_AppLockCard> createState() => _AppLockCardState();
}

class _AppLockCardState extends State<_AppLockCard> {
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
        // Reuse an existing PIN if one is already set; otherwise run setup and
        // only switch to PIN mode once a PIN was actually saved.
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

/// Bottom-sheet chooser for the [LockMode]. Returns the picked mode (or null if
/// dismissed). Device lock is shown disabled when no device screen lock exists.
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

/// Blocks screenshots, screen recording and the Recents thumbnail on the
/// contact detail and in-call screens. On by default. The app-lock screen and
/// the secret-contacts list block them regardless of this switch — the user has
/// already said that data is to stay hidden.
class _ScreenshotGuardCard extends StatelessWidget {
  const _ScreenshotGuardCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final enabled = context.watch<AppSettings>().screenshotGuardEnabled;

    return Card(
      margin: EdgeInsets.zero,
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        value: enabled,
        activeThumbColor: theme.colorScheme.primary,
        onChanged: (v) =>
            context.read<AppSettings>().setScreenshotGuardEnabled(v),
        secondary: const Icon(Icons.screenshot_monitor_outlined),
        title: const Text(
          'Block screenshots',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          'Keeps contact details and calls out of screenshots, screen '
          'recordings and the Recents preview',
          style: TextStyle(color: colors.mutedText, fontSize: 13),
        ),
      ),
    );
  }
}

/// Chooses what the dialer's pre-dial "Top contacts" section shows: the
/// recency-based list (score, then most-recently contacted) or the contacts the
/// user has linked as family/friends. Opens a small chooser on tap.
class _DialerTopContactsCard extends StatelessWidget {
  const _DialerTopContactsCard();

  static String _labelFor(DialerTopSource source) => switch (source) {
    DialerTopSource.relations => 'Family & friends',
    DialerTopSource.likelyToAnswer => 'Likely to answer now',
    DialerTopSource.recent => 'Most recent',
  };

  static String _descFor(DialerTopSource source) => switch (source) {
    DialerTopSource.relations => 'Contacts you’ve linked as relations',
    DialerTopSource.likelyToAnswer =>
      'Ordered by who usually answers at this time of day',
    DialerTopSource.recent => 'Most contacted, then most recent calls',
  };

  Future<void> _choose(BuildContext context, DialerTopSource current) async {
    final chosen = await showDialog<DialerTopSource>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Dialer top contacts'),
        children: [
          for (final source in DialerTopSource.values)
            _OptionTile(
              selected: source == current,
              title: _labelFor(source),
              subtitle: _descFor(source),
              onTap: () => Navigator.of(ctx).pop(source),
            ),
        ],
      ),
    );
    if (chosen != null && context.mounted) {
      context.read<AppSettings>().setDialerTopSource(chosen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final accent = theme.colorScheme.primary;
    final source = context.watch<AppSettings>().dialerTopSource;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _choose(context, source),
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
                child: Icon(Icons.star_outline, color: accent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dialer top contacts',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _labelFor(source),
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

/// A single selectable row in the [_DialerTopContactsCard] chooser dialog, with
/// a leading check on the current selection.
class _OptionTile extends StatelessWidget {
  final bool selected;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionTile({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final accent = theme.colorScheme.primary;

    return ListTile(
      onTap: onTap,
      leading: Icon(
        selected ? Icons.check_circle : Icons.circle_outlined,
        color: selected ? accent : colors.mutedText,
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: colors.mutedText, fontSize: 12.5),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsCard({
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

/// Chooses the secondary script layout on dialpad keys 2–9.
class _DialpadScriptCard extends StatelessWidget {
  const _DialpadScriptCard();

  Future<void> _choose(BuildContext context, DialpadScript current) async {
    final chosen = await showDialog<DialpadScript>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Dialpad script layout'),
        children: [
          for (final script in DialpadScript.values)
            _OptionTile(
              selected: script == current,
              title: script.label,
              subtitle: _descFor(script),
              onTap: () => Navigator.of(ctx).pop(script),
            ),
        ],
      ),
    );
    if (chosen != null && context.mounted) {
      context.read<AppSettings>().setDialpadScript(chosen);
    }
  }

  static String _descFor(DialpadScript script) {
    switch (script) {
      case DialpadScript.auto:
        return 'Follows your device language / locale';
      case DialpadScript.malayalam:
        return 'Dual English + Malayalam script layout (ക-ങ)';
      case DialpadScript.devanagari:
        return 'Dual English + Devanagari script layout (क-ङ)';
      case DialpadScript.cyrillic:
        return 'Dual English + Cyrillic script layout (АБВГ)';
      case DialpadScript.arabic:
        return 'Dual English + Arabic script layout (ا ب ت ث)';
      case DialpadScript.greek:
        return 'Dual English + Greek script layout (ΑΒΓ)';
      case DialpadScript.none:
        return 'Standard English letters only (A-Z)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final accent = theme.colorScheme.primary;
    final script = context.watch<AppSettings>().dialpadScript;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _choose(context, script),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.keyboard_alt_outlined, color: accent, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dialpad script layout',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${script.label} — ${_descFor(script)}',
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
