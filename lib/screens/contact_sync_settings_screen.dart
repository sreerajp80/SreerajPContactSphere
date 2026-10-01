// lib/screens/contact_sync_settings_screen.dart
//
// The "Sync" screen reached from Settings → Contacts → Sync. Groups every
// device-sync action in one place:
//
//   Contacts
//     • Add device contacts to app            (merge; syncFromDevice)
//     • Add app contacts to device            (merge; syncToDevice)
//     • Add device contacts to app (destructive)   (mirrorFromDevice)
//     • Add app contacts to device (destructive)   (mirrorToDevice)
//   Call log
//     • Add device call log to app            (import, merge)
//     • Add device call log to app (destructive)   (import, replace)
//
// The destructive actions delete "extras" in the target so it mirrors the
// source, and always ask for confirmation first. Self and secret contacts are
// never deleted by either destructive contact action (enforced in
// ContactSyncService.mirrorFromDevice / mirrorToDevice). There is no
// app→device call-log direction: Android owns the system call log.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/services/call_log_import_service.dart';
import 'package:smart_contacts_dialer/services/contact_sync_service.dart';
import 'package:smart_contacts_dialer/services/device_account.dart';
import 'package:smart_contacts_dialer/services/device_contact_service.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

/// Preference key remembering the last destination account chosen for the
/// app→device push, so the picker preselects it next time.
const String _kLastToDeviceAccountId = 'sync_to_device_account_id';

/// Shows an app-styled sheet to choose where app contacts are written on the
/// device (the local "Device" storage or a real account), remembering the
/// choice. Returns the chosen destination, or null if the user dismissed it.
Future<WritableAccount?> _pickToDeviceAccount(BuildContext context) async {
  final accounts = await DeviceContactService().writableAccounts();
  if (!context.mounted) return null;

  String? savedId;
  try {
    savedId = (await SharedPreferences.getInstance()).getString(
      _kLastToDeviceAccountId,
    );
  } catch (_) {
    savedId = null;
  }
  if (!context.mounted) return null;

  final theme = Theme.of(context);
  final l10n = AppLocalizations.of(context);

  final chosen = await showModalBottomSheet<WritableAccount>(
    context: context,
    backgroundColor: theme.colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              l10n.labelSaveContactsTo,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          for (final a in accounts)
            ListTile(
              leading: Icon(
                a.isLocal ? Icons.smartphone_outlined : Icons.cloud_outlined,
                color: theme.colorScheme.primary,
              ),
              title: Text(a.label),
              trailing: a.id == savedId
                  ? Icon(Icons.check, color: theme.colorScheme.primary)
                  : null,
              onTap: () => Navigator.of(ctx).pop(a),
            ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );

  if (chosen != null) {
    try {
      await (await SharedPreferences.getInstance()).setString(
        _kLastToDeviceAccountId,
        chosen.id,
      );
    } catch (_) {
      // Non-fatal: the sync still runs to the chosen account this time.
    }
  }
  return chosen;
}

class ContactSyncSettingsScreen extends StatelessWidget {
  const ContactSyncSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.titleSync)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _SectionHeader(l10n.navContacts),
          const _AddDeviceContactsToAppCard(),
          const SizedBox(height: 12),
          const _AddAppContactsToDeviceCard(),
          const SizedBox(height: 12),
          const _MirrorFromDeviceCard(),
          const SizedBox(height: 12),
          const _MirrorToDeviceCard(),
          const SizedBox(height: 24),
          _SectionHeader(l10n.labelCallLog),
          const _ImportCallLogCard(),
          const SizedBox(height: 12),
          const _ReplaceCallLogCard(),
        ],
      ),
    );
  }
}

/// A small heading above a group of cards.
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: colors.mutedText,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

/// Confirmation prompt shown before a destructive action runs. Returns true
/// only when the user taps the (danger-styled) confirm button.
Future<bool> _confirm(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
}) async {
  final theme = Theme.of(context);
  final l10n = AppLocalizations.of(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(l10n.actionCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// A generic sync-action card: an accent (or danger) icon, title and subtitle,
/// a spinner while its action runs (taps ignored meanwhile), and a snackbar
/// showing the result. [action] returns the message to display, or throws to
/// report a failure. [confirm] (when set) runs first; a cancel aborts silently.
class _SyncActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool destructive;

  /// Runs the operation and returns the snackbar message. Throwing shows a
  /// generic failure message.
  final Future<String> Function() action;

  /// Optional confirmation gate; return false to abort.
  final Future<bool> Function(BuildContext context)? confirm;

  const _SyncActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.action,
    this.destructive = false,
    this.confirm,
  });

  @override
  State<_SyncActionCard> createState() => _SyncActionCardState();
}

class _SyncActionCardState extends State<_SyncActionCard> {
  bool _busy = false;

  Future<void> _run() async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context);
    if (widget.confirm != null) {
      final ok = await widget.confirm!(context);
      if (!ok) return;
    }
    if (!mounted) return;
    setState(() => _busy = true);
    String message;
    try {
      message = await widget.action();
    } catch (_) {
      message = l10n.errorSyncFailed;
    }
    if (!mounted) return;
    setState(() => _busy = false);
    // An empty message means "nothing to report" (e.g. the user cancelled a
    // picker) — stay silent instead of flashing a blank snackbar.
    if (message.isEmpty) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final tint = widget.destructive
        ? theme.colorScheme.error
        : theme.colorScheme.primary;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: _busy ? null : _run,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: _busy
                    ? Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: tint,
                          ),
                        ),
                      )
                    : Icon(widget.icon, color: tint),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _busy
                          ? AppLocalizations.of(context).labelWorking
                          : widget.subtitle,
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

// ---------------------------------------------------------------------------
// Contacts
// ---------------------------------------------------------------------------

class _AddDeviceContactsToAppCard extends StatelessWidget {
  const _AddDeviceContactsToAppCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _SyncActionCard(
      icon: Icons.sync_outlined,
      title: l10n.actionAddDeviceToApp,
      subtitle: l10n.descAddDeviceToApp,
      action: () async {
        if (!await DeviceContactService().ensurePermission()) {
          return l10n.errorContactsPermissionSync;
        }
        final changed = await ContactSyncService().syncFromDevice();
        return changed > 0
            ? l10n.msgContactsSynced(changed)
            : l10n.msgContactsUpToDate;
      },
    );
  }
}

class _AddAppContactsToDeviceCard extends StatelessWidget {
  const _AddAppContactsToDeviceCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _SyncActionCard(
      icon: Icons.upload_outlined,
      title: l10n.actionAddAppToDevice,
      subtitle: l10n.descAddAppToDevice,
      action: () async {
        if (!await DeviceContactService().ensurePermission()) {
          return l10n.errorContactsPermissionSync;
        }
        if (!context.mounted) return '';
        final target = await _pickToDeviceAccount(context);
        if (target == null) return ''; // cancelled — stay silent
        final result = await ContactSyncService().syncToDevice(target: target);
        if (result.total == 0) {
          return result.failed > 0
              ? l10n.errorCouldNotSaveTo(target.label, result.failed)
              : l10n.msgNoContactsToSyncToDevice;
        }
        return result.failed > 0
            ? l10n.msgSavedToWithFailed(
                target.label,
                result.total,
                result.failed,
              )
            : l10n.msgSavedTo(target.label, result.total);
      },
    );
  }
}

class _MirrorFromDeviceCard extends StatelessWidget {
  const _MirrorFromDeviceCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _SyncActionCard(
      icon: Icons.sync_problem_outlined,
      title: l10n.actionMirrorDeviceToApp,
      subtitle: l10n.descMirrorDeviceToApp,
      destructive: true,
      confirm: (ctx) => _confirm(
        ctx,
        title: l10n.titleMirrorDeviceToApp,
        body: l10n.descMirrorDeviceToAppConfirm,
        confirmLabel: l10n.actionMirror,
      ),
      action: () async {
        if (!await DeviceContactService().ensurePermission()) {
          return l10n.errorContactsPermissionSync;
        }
        final removed = await ContactSyncService().mirrorFromDevice();
        return removed > 0
            ? l10n.msgMirroredFromDevice(removed)
            : l10n.msgMirroredFromDeviceNone;
      },
    );
  }
}

class _MirrorToDeviceCard extends StatelessWidget {
  const _MirrorToDeviceCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _SyncActionCard(
      icon: Icons.sync_problem_outlined,
      title: l10n.actionMirrorAppToDevice,
      subtitle: l10n.descMirrorAppToDevice,
      destructive: true,
      confirm: (ctx) => _confirm(
        ctx,
        title: l10n.titleMirrorAppToDevice,
        body: l10n.descMirrorAppToDeviceConfirm,
        confirmLabel: l10n.actionMirror,
      ),
      action: () async {
        if (!await DeviceContactService().ensurePermission()) {
          return l10n.errorContactsPermissionSync;
        }
        if (!context.mounted) return '';
        final target = await _pickToDeviceAccount(context);
        if (target == null) return ''; // cancelled — stay silent
        final removed = await ContactSyncService().mirrorToDevice(
          target: target,
        );
        return removed > 0
            ? l10n.msgMirroredTo(target.label, removed)
            : l10n.msgMirroredToNone(target.label);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Call log
// ---------------------------------------------------------------------------

class _ImportCallLogCard extends StatelessWidget {
  const _ImportCallLogCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _SyncActionCard(
      icon: Icons.call_outlined,
      title: l10n.actionImportCallLog,
      subtitle: l10n.descImportCallLog,
      action: () async {
        final result = await CallLogImportService().importFromDevice();
        if (result.failed) {
          return l10n.errorCouldNotReadCallLog;
        }
        if (!result.changedAnything) return l10n.msgCallLogUpToDate;
        final parts = <String>[
          if (result.inserted > 0) l10n.labelCountAdded(result.inserted),
          if (result.updated > 0) l10n.labelCountUpdated(result.updated),
        ];
        return l10n.msgCallLogImported(parts.join(', '));
      },
    );
  }
}

class _ReplaceCallLogCard extends StatelessWidget {
  const _ReplaceCallLogCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _SyncActionCard(
      icon: Icons.restore_page_outlined,
      title: l10n.actionReplaceCallLog,
      subtitle: l10n.descReplaceCallLog,
      destructive: true,
      confirm: (ctx) => _confirm(
        ctx,
        title: l10n.titleReplaceCallHistory,
        body: l10n.descReplaceCallHistoryConfirm,
        confirmLabel: l10n.actionReplace,
      ),
      action: () async {
        final result = await CallLogImportService().importFromDevice(
          replace: true,
        );
        if (result.failed) {
          return l10n.errorCouldNotReadCallLog;
        }
        return l10n.msgCallLogReplaced(result.inserted);
      },
    );
  }
}
