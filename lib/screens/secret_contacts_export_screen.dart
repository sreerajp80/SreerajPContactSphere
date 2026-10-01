// lib/screens/secret_contacts_export_screen.dart
import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_contacts_dialer/services/auth_service.dart';
import 'package:smart_contacts_dialer/services/export_import_service.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

/// Configuration screen for secret contacts export settings.
class SecretContactsExportScreen extends StatefulWidget {
  const SecretContactsExportScreen({super.key});

  @override
  State<SecretContactsExportScreen> createState() =>
      _SecretContactsExportScreenState();
}

class _SecretContactsExportScreenState
    extends State<SecretContactsExportScreen> {
  bool _exporting = false;

  Future<void> _exportSecrets(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final l = AppLocalizations.of(context);
    final auth = AuthService();

    if (await auth.isAvailable) {
      final ok = await auth.authenticate(reason: l.descAuthExportSecret);
      if (!ok) {
        messenger.showSnackBar(
          SnackBar(content: Text(l.errorAuthRequiredExportSecret)),
        );
        return;
      }
    }

    if (!context.mounted) return;
    setState(() => _exporting = true);
    try {
      final path = await ExportImportService().exportSecretContactsVcf();
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l.msgExportedSecretTo(path))),
      );
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l.errorExportSecretFailed('$e'))),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final accent = Theme.of(context).colorScheme.primary;
    final settings = context.watch<AppSettings>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).titleSecretContactsExport),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              value: settings.includeSecretInExport,
              activeThumbColor: accent,
              onChanged: (v) =>
                  context.read<AppSettings>().setIncludeSecretInExport(v),
              title: Text(
                AppLocalizations.of(context).labelIncludeSecretInExport,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(
                AppLocalizations.of(context).descIncludeSecretInExport,
                style: TextStyle(color: colors.mutedText, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            margin: EdgeInsets.zero,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: _exporting ? null : () => _exportSecrets(context),
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
                      child: Icon(Icons.download_outlined, color: accent),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(
                              context,
                            ).labelExportSecretContacts,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppLocalizations.of(
                              context,
                            ).descExportSecretContacts,
                            style: TextStyle(
                              color: colors.mutedText,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_exporting)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: accent,
                        ),
                      )
                    else
                      Icon(Icons.chevron_right, color: colors.mutedText),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
