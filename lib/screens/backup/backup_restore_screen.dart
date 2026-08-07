// lib/screens/backup/backup_restore_screen.dart
//
// "Backup & Restore" hub, reached from Settings behind a biometric check (a
// backup can include secret contacts). Two actions:
//   • Back up now   — asks for a password, writes an encrypted backup file, then
//                     opens the share sheet so the user picks where to save it.
//   • Restore       — picks a backup file, asks for its password, confirms the
//                     wipe, then REPLACES all current data with the backup.
//
// The password matters: the backup is encrypted with it and is useless without
// it. There is no recovery — that is the point (see backup_service.dart).

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:smart_contacts_dialer/services/backup_service.dart';
import 'package:smart_contacts_dialer/services/contact_sync_service.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  final BackupService _service = BackupService();
  bool _busy = false;
  String _busyLabel = '';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _ActionCard(
                icon: Icons.backup_outlined,
                title: 'Back up now',
                subtitle:
                    'Save all your contacts, photos and settings to one '
                    'password-protected file.',
                onTap: _busy ? null : _startBackup,
              ),
              const SizedBox(height: 12),
              _ActionCard(
                icon: Icons.restore_outlined,
                title: 'Restore from a file',
                subtitle:
                    'Load a backup file. This replaces everything currently in '
                    'the app.',
                onTap: _busy ? null : _startRestore,
              ),
              const SizedBox(height: 20),
              Text(
                'The backup is locked with your password. Keep it safe — without '
                'it the file cannot be opened, on this or any other phone. That '
                'same password is what lets you restore on a new phone.',
                style: TextStyle(color: colors.mutedText, fontSize: 12.5),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          if (_busy) _busyOverlay(),
        ],
      ),
    );
  }

  Widget _busyOverlay() {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.45),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                _busyLabel,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Backup
  // ===========================================================================

  Future<void> _startBackup() async {
    final password = await _askPassword(confirm: true);
    if (password == null || !mounted) return;

    setState(() {
      _busy = true;
      _busyLabel = 'Creating backup…';
    });
    final messenger = ScaffoldMessenger.of(context);
    try {
      final file = await _service.createBackup(password);
      if (!mounted) return;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: _service.suggestedFileName(),
        ),
      );
      messenger.showSnackBar(
        const SnackBar(content: Text('Backup ready. Choose where to save it.')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Backup failed: ${_message(e)}')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ===========================================================================
  // Restore
  // ===========================================================================

  Future<void> _startRestore() async {
    // A permissive type group: some Android file providers do not filter by our
    // custom .csbak extension, so we accept any file and validate the bytes.
    const typeGroup = XTypeGroup(
      label: 'ContactSphere backup',
      extensions: ['csbak'],
    );
    final XFile? picked = await openFile(acceptedTypeGroups: [typeGroup]);
    if (picked == null || !mounted) return;

    final password = await _askPassword(confirm: false);
    if (password == null || !mounted) return;

    final proceed = await _confirmReplace();
    if (proceed != true || !mounted) return;

    setState(() {
      _busy = true;
      _busyLabel = 'Restoring…';
    });
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final settings = context.read<AppSettings>();
    try {
      await _service.restoreBackup(picked, password);
      // Pull the restored settings (theme, accent, …) back into the live UI.
      await settings.load();
      // Announce the wholesale data change so the already-mounted Contacts tab
      // re-reads the DB (Dialer/Recents reload themselves on tab selection).
      ContactSyncService().notifyLocalDataChanged();
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Restore complete.')),
      );
      // Back out to the main screen so its lists reload from the new data.
      navigator.popUntil((route) => route.isFirst);
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
      }
      messenger.showSnackBar(
        SnackBar(content: Text('Restore failed: ${_message(e)}')),
      );
    }
  }

  Future<bool?> _confirmReplace() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Replace all data?'),
        content: const Text(
          'Restoring will DELETE everything currently in the app — all '
          'contacts, call history, groups and settings — and replace it with '
          'the backup. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Replace'),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Password dialog
  // ===========================================================================

  /// Prompts for a password. With [confirm] (backup) a second field must match
  /// and a minimum length is enforced; without it (restore) a single field is
  /// shown. Returns the password, or null if cancelled.
  Future<String?> _askPassword({required bool confirm}) {
    return showDialog<String>(
      context: context,
      builder: (ctx) => _PasswordDialog(confirm: confirm),
    );
  }

  String _message(Object e) => e is BackupException ? e.message : e.toString();
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.primary.withValues(
                  alpha: 0.12,
                ),
                foregroundColor: theme.colorScheme.primary,
                child: Icon(icon),
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
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(color: colors.mutedText, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

/// Password entry. For a backup ([confirm] true) it shows a confirm field and
/// enforces a minimum length; for a restore it shows a single field.
class _PasswordDialog extends StatefulWidget {
  final bool confirm;
  const _PasswordDialog({required this.confirm});

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  static const int _minLen = 6;

  final TextEditingController _pass = TextEditingController();
  final TextEditingController _confirm = TextEditingController();
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    final pass = _pass.text;
    if (widget.confirm) {
      if (pass.length < _minLen) {
        setState(() => _error = 'Use at least $_minLen characters.');
        return;
      }
      if (pass != _confirm.text) {
        setState(() => _error = 'The passwords do not match.');
        return;
      }
    } else if (pass.isEmpty) {
      setState(() => _error = 'Enter the backup password.');
      return;
    }
    Navigator.of(context).pop(pass);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.confirm ? 'Set a backup password' : 'Backup password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _pass,
            obscureText: _obscure,
            autofocus: true,
            decoration: InputDecoration(
              labelText: widget.confirm ? 'Password' : 'Enter password',
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            onSubmitted: (_) => widget.confirm ? null : _submit(),
          ),
          if (widget.confirm) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _confirm,
              obscureText: _obscure,
              decoration: const InputDecoration(labelText: 'Confirm password'),
              onSubmitted: (_) => _submit(),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12.5,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.confirm ? 'Back up' : 'Restore'),
        ),
      ],
    );
  }
}
