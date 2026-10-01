// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/l10n/settings_labels.dart';
import 'package:smart_contacts_dialer/services/auth_service.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/state/locale_controller.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';
import 'package:smart_contacts_dialer/utils/phone_normalizer.dart';
import 'package:smart_contacts_dialer/screens/about_screen.dart';
import 'package:smart_contacts_dialer/screens/appearance_screen.dart';
import 'package:smart_contacts_dialer/screens/backup/backup_restore_screen.dart';
import 'package:smart_contacts_dialer/screens/contacts_settings_screen.dart';
import 'package:smart_contacts_dialer/screens/default_country_screen.dart';
import 'package:smart_contacts_dialer/screens/emergency_info_screen.dart';
import 'package:smart_contacts_dialer/screens/features_screen.dart';
import 'package:smart_contacts_dialer/screens/help/help_home_screen.dart';
import 'package:smart_contacts_dialer/screens/language_settings_screen.dart';
import 'package:smart_contacts_dialer/screens/permissions_screen.dart';
import 'package:smart_contacts_dialer/screens/ringtone_settings_screen.dart';
import 'package:smart_contacts_dialer/screens/security_screen.dart';
import 'package:smart_contacts_dialer/screens/sim_settings_screen.dart';
import 'package:smart_contacts_dialer/screens/speed_dial_screen.dart';
import 'package:smart_contacts_dialer/screens/sync/sync_home_screen.dart';

import 'package:smart_contacts_dialer/screens/settings/online_sync_settings_screen.dart';
import 'package:smart_contacts_dialer/screens/settings/cloud_backup_settings_screen.dart';

/// Settings hub reached from the contacts ⋮ menu.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.titleSettings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _SettingsCard(
            icon: Icons.security_outlined,
            title: l10n.titleSecurity,
            subtitle: l10n.descSecurityCard,
            onTap: () => _push(context, const SecurityScreen()),
          ),
          const SizedBox(height: 12),
          const _DialerTopContactsCard(),
          const SizedBox(height: 12),
          const _DialpadScriptCard(),
          const SizedBox(height: 12),
          _SettingsCard(
            icon: Icons.touch_app_outlined,
            title: l10n.titleSpeedDial,
            subtitle: l10n.descSpeedDialCard,
            onTap: () => _push(context, const SpeedDialScreen()),
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            icon: Icons.contacts_outlined,
            title: l10n.navContacts,
            subtitle: l10n.descContactsCard,
            onTap: () => _push(context, const ContactsSettingsScreen()),
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            icon: Icons.sync_alt,
            title: l10n.titleSyncToAnotherDevice,
            subtitle: l10n.descSyncCard,
            onTap: () => _openSync(context),
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            icon: Icons.cloud_sync_outlined,
            title: l10n.titleOnlineProviderSync,
            subtitle: l10n.descOnlineSyncCard,
            onTap: () => _push(context, const OnlineSyncSettingsScreen()),
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            icon: Icons.backup_outlined,
            title: l10n.titleBackupRestore,
            subtitle: l10n.descBackupCard,
            onTap: () => _openBackup(context),
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            icon: Icons.cloud_upload_outlined,
            title: l10n.titleEncryptedCloudBackup,
            subtitle: l10n.descCloudBackupCard,
            onTap: () => _push(context, const CloudBackupSettingsScreen()),
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            icon: Icons.sim_card_outlined,
            title: l10n.titleSimCalling,
            subtitle: l10n.descSimCard,
            onTap: () => _push(context, const SimSettingsScreen()),
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            icon: Icons.notifications_active_outlined,
            title: l10n.labelRingtone,
            subtitle: l10n.descRingtoneCard,
            onTap: () => _push(context, const RingtoneSettingsScreen()),
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            icon: Icons.medical_information_outlined,
            title: l10n.titleEmergencyInfo,
            subtitle: l10n.descEmergencyCard,
            onTap: () => _push(context, const EmergencyInfoScreen()),
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            icon: Icons.public_outlined,
            title: l10n.titleDefaultCountry,
            subtitle: _countrySubtitle(context),
            onTap: () => _push(context, const DefaultCountryScreen()),
          ),
          const SizedBox(height: 12),
          _languageCard(context),
          const SizedBox(height: 12),
          _SettingsCard(
            icon: Icons.palette_outlined,
            title: l10n.titleAppearance,
            subtitle: l10n.descAppearanceCard,
            onTap: () => _push(context, const AppearanceScreen()),
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            icon: Icons.stars_outlined,
            title: l10n.titleFeatures,
            subtitle: l10n.descFeaturesCard,
            onTap: () => _push(context, const FeaturesScreen()),
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            icon: Icons.shield_outlined,
            title: l10n.titlePermissions,
            subtitle: l10n.descPermissionsCard,
            onTap: () => _push(context, const PermissionsScreen()),
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            icon: Icons.help_outline,
            title: l10n.titleHelp,
            subtitle: l10n.descHelpCard,
            onTap: () => _push(context, const HelpHomeScreen()),
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            icon: Icons.info_outline,
            title: l10n.titleAbout,
            subtitle: l10n.descAboutCard,
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
    final l10n = AppLocalizations.of(context);
    final auth = AuthService();

    if (await auth.isAvailable) {
      final ok = await auth.authenticate(reason: l10n.descAuthReasonSync);
      if (ok) {
        navigator.push(
          MaterialPageRoute(builder: (_) => const SyncHomeScreen()),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.errorAuthRequiredSync)),
        );
      }
      return;
    }

    // No device lock: authentication can't run. Warn and let the user decide.
    if (!context.mounted) return;
    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.titleNoScreenLock),
        content: Text(l10n.descNoLockSync),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.actionContinue),
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
    final l10n = AppLocalizations.of(context);
    final auth = AuthService();

    if (await auth.isAvailable) {
      final ok = await auth.authenticate(reason: l10n.descAuthReasonBackup);
      if (ok) {
        navigator.push(
          MaterialPageRoute(builder: (_) => const BackupRestoreScreen()),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.errorAuthRequiredBackup)),
        );
      }
      return;
    }

    // No device lock: authentication can't run. Warn and let the user decide.
    if (!context.mounted) return;
    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.titleNoScreenLock),
        content: Text(l10n.descNoLockBackup),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.actionContinue),
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
  /// Settings → Language (standard §8.4). The subtitle shows the current
  /// choice, and a screen reader hears "Language, currently …" as one label.
  Widget _languageCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final current = languageOptionLabel(
      l10n,
      context.watch<LocaleController>().value,
    );
    return _SettingsCard(
      icon: Icons.translate,
      title: l10n.titleLanguage,
      subtitle: current,
      semanticsLabel: l10n.semanticsLanguageSetting(current),
      onTap: () => _push(context, const LanguageSettingsScreen()),
    );
  }

  String _countrySubtitle(BuildContext context) {
    final iso = context.watch<AppSettings>().defaultCountryIso;
    final code = PhoneNormalizer.isoFromString(iso);
    final label = code == null
        ? iso
        : '${PhoneNormalizer.nameFor(code)} (+${PhoneNormalizer.dialCodeFor(code)})';
    return AppLocalizations.of(context).descCountrySubtitle(label);
  }
}

/// Chooses what the dialer's pre-dial "Top contacts" section shows: the
/// recency-based list (score, then most-recently contacted) or the contacts the
/// user has linked as family/friends. Opens a small chooser on tap.
class _DialerTopContactsCard extends StatelessWidget {
  const _DialerTopContactsCard();

  Future<void> _choose(BuildContext context, DialerTopSource current) async {
    final l10n = AppLocalizations.of(context);
    final chosen = await showDialog<DialerTopSource>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l10n.titleDialerTopContacts),
        children: [
          for (final source in DialerTopSource.values)
            _OptionTile(
              selected: source == current,
              title: dialerTopSourceLabel(l10n, source),
              subtitle: dialerTopSourceDescription(l10n, source),
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
    final l10n = AppLocalizations.of(context);

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
                    Text(
                      l10n.titleDialerTopContacts,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dialerTopSourceLabel(l10n, source),
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

  /// Replaces the title + subtitle a screen reader would otherwise read, when
  /// the row needs one clearer spoken label.
  final String? semanticsLabel;

  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.semanticsLabel,
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
                child: Semantics(
                  label: semanticsLabel,
                  excludeSemantics: semanticsLabel != null,
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
    final l10n = AppLocalizations.of(context);
    final chosen = await showDialog<DialpadScript>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l10n.titleDialpadScriptLayout),
        children: [
          for (final script in DialpadScript.values)
            _OptionTile(
              selected: script == current,
              title: dialpadScriptLabel(l10n, script),
              subtitle: dialpadScriptDescription(l10n, script),
              onTap: () => Navigator.of(ctx).pop(script),
            ),
        ],
      ),
    );
    if (chosen != null && context.mounted) {
      context.read<AppSettings>().setDialpadScript(chosen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final accent = theme.colorScheme.primary;
    final script = context.watch<AppSettings>().dialpadScript;
    final l10n = AppLocalizations.of(context);

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
                child: Icon(
                  Icons.keyboard_alt_outlined,
                  color: accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.titleDialpadScriptLayout,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${dialpadScriptLabel(l10n, script)} — '
                      '${dialpadScriptDescription(l10n, script)}',
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
