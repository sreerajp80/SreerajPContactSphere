// lib/screens/settings/online_sync_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:smart_contacts_dialer/models/online_sync_account.dart';
import 'package:smart_contacts_dialer/services/online_sync_service.dart';

class OnlineSyncSettingsScreen extends StatefulWidget {
  const OnlineSyncSettingsScreen({super.key});

  @override
  State<OnlineSyncSettingsScreen> createState() => _OnlineSyncSettingsScreenState();
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
                ? 'Synced successfully with ${account.accountEmailOrName}'
                : 'Sync completed',
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
          title: const Text('Add Online Account'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<OnlineProviderType>(
                  initialValue: selectedProvider,
                  decoration: const InputDecoration(labelText: 'Provider'),
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
                    if (val != null) setDialogState(() => selectedProvider = val);
                  },
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Account Email / Name'),
                ),
                if (selectedProvider == OnlineProviderType.carddav) ...[
                  TextField(
                    controller: serverController,
                    decoration: const InputDecoration(labelText: 'Server URL'),
                  ),
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(labelText: 'Username'),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final account = OnlineSyncAccount(
                  id: 'account_${DateTime.now().millisecondsSinceEpoch}',
                  providerType: selectedProvider,
                  accountEmailOrName: emailController.text.trim().isEmpty
                      ? 'Account'
                      : emailController.text.trim(),
                  isContactSyncEnabled: true,
                  serverUrl: serverController.text.trim(),
                  username: usernameController.text.trim(),
                );
                await _syncService.saveAccount(account);
                if (ctx.mounted) Navigator.pop(ctx);
                _loadAccounts();
              },
              child: const Text('Add'),
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
        title: const Text('Online Provider Sync'),
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
                            'Opt-in 2-way contact sync with Google, Microsoft & CardDAV. Zero telemetry, direct API requests only.',
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
                      'Configured Providers',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    ElevatedButton.icon(
                      onPressed: _showAddAccountDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Account'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_accounts.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: Text('No cloud sync accounts configured.'),
                    ),
                  )
                else
                  ..._accounts.map((acc) => Card(
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
                            'Provider: ${acc.providerType.name.toUpperCase()}\n'
                            'Last Synced: ${acc.lastSyncedAt ?? "Never"}',
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
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.sync),
                                onPressed: _isSyncing ? null : () => _triggerManualSync(acc),
                                tooltip: 'Sync Now',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () async {
                                  await _syncService.removeAccount(acc.id);
                                  _loadAccounts();
                                },
                              ),
                            ],
                          ),
                        ),
                      )),
              ],
            ),
    );
  }
}
