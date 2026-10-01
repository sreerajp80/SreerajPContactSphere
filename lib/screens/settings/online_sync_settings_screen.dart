// lib/screens/settings/online_sync_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/models/online_sync_account.dart';
import 'package:smart_contacts_dialer/services/online_sync_service.dart';

class OnlineSyncSettingsScreen extends StatefulWidget {
  const OnlineSyncSettingsScreen({super.key});

  @override
  State<OnlineSyncSettingsScreen> createState() =>
      _OnlineSyncSettingsScreenState();
}

class _OnlineSyncSettingsScreenState extends State<OnlineSyncSettingsScreen> {
  final OnlineSyncService _syncService = OnlineSyncService();
  List<OnlineSyncAccount> _accounts = [];
  bool _isLoading = true;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() => _isLoading = true);
    final accounts = await _syncService.loadAccounts();
    setState(() {
      _accounts = accounts;
      _isLoading = false;
    });
  }

  Future<void> _triggerManualSync(OnlineSyncAccount account) async {
    setState(() => _isSyncing = true);
    final success = await _syncService.syncAccount(account);
    await _loadAccounts();
    setState(() => _isSyncing = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? AppLocalizations.of(
                    context,
                  ).msgSyncedWith(account.accountEmailOrName)
                : AppLocalizations.of(context).msgSyncCompleted,
          ),
        ),
      );
    }
  }

  void _showAddAccountDialog() {
    final emailController = TextEditingController();
    final serverController = TextEditingController();
    final usernameController = TextEditingController();
    OnlineProviderType selectedProvider = OnlineProviderType.google;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(AppLocalizations.of(context).titleAddOnlineAccount),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<OnlineProviderType>(
                  initialValue: selectedProvider,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).labelProvider,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: OnlineProviderType.google,
                      child: Text('Google Contacts'),
                    ),
                    DropdownMenuItem(
                      value: OnlineProviderType.microsoft,
                      child: Text('Microsoft Outlook'),
                    ),
                    DropdownMenuItem(
                      value: OnlineProviderType.carddav,
                      child: Text('CardDAV Server (Nextcloud/Fastmail)'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedProvider = val);
                    }
                  },
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    ).labelAccountEmailName,
                  ),
                ),
                if (selectedProvider == OnlineProviderType.carddav) ...[
                  TextField(
                    controller: serverController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).labelServerUrl,
                    ),
                  ),
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).labelUsername,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(context).actionCancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final account = OnlineSyncAccount(
                  id: 'account_${DateTime.now().millisecondsSinceEpoch}',
                  providerType: selectedProvider,
                  accountEmailOrName: emailController.text.trim().isEmpty
                      ? AppLocalizations.of(context).labelAccount
                      : emailController.text.trim(),
                  isContactSyncEnabled: true,
                  serverUrl: serverController.text.trim(),
                  username: usernameController.text.trim(),
                );
                await _syncService.saveAccount(account);
                if (ctx.mounted) Navigator.pop(ctx);
                _loadAccounts();
              },
              child: Text(AppLocalizations.of(context).actionAdd),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).titleOnlineProviderSync),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.shield_outlined, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context).descOnlineSyncIntro,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context).labelConfiguredProviders,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    ElevatedButton.icon(
                      onPressed: _showAddAccountDialog,
                      icon: const Icon(Icons.add),
                      label: Text(
                        AppLocalizations.of(context).actionAddAccount,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_accounts.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32.0),
                      child: Text(
                        AppLocalizations.of(context).emptyNoCloudAccounts,
                      ),
                    ),
                  )
                else
                  ..._accounts.map(
                    (acc) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Icon(
                          acc.providerType == OnlineProviderType.google
                              ? Icons.g_mobiledata
                              : acc.providerType == OnlineProviderType.microsoft
                              ? Icons.window
                              : Icons.cloud,
                          size: 32,
                        ),
                        title: Text(acc.accountEmailOrName),
                        subtitle: Text(
                          AppLocalizations.of(context).descProviderLastSynced(
                            acc.providerType.name.toUpperCase(),
                            acc.lastSyncedAt ??
                                AppLocalizations.of(context).labelNever,
                          ),
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: _isSyncing
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.sync),
                              onPressed: _isSyncing
                                  ? null
                                  : () => _triggerManualSync(acc),
                              tooltip: AppLocalizations.of(
                                context,
                              ).tooltipSyncNow,
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              tooltip: AppLocalizations.of(
                                context,
                              ).tooltipRemoveAccount,
                              onPressed: () async {
                                await _syncService.removeAccount(acc.id);
                                _loadAccounts();
                              },
                            ),
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
