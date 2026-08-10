// lib/screens/settings/cloud_backup_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:smart_contacts_dialer/models/cloud_backup_entry.dart';
import 'package:smart_contacts_dialer/models/online_sync_account.dart';
import 'package:smart_contacts_dialer/services/cloud_backup_service.dart';
import 'package:smart_contacts_dialer/services/online_sync_service.dart';

class CloudBackupSettingsScreen extends StatefulWidget {
  const CloudBackupSettingsScreen({super.key});

  @override
  State<CloudBackupSettingsScreen> createState() => _CloudBackupSettingsScreenState();
}

class _CloudBackupSettingsScreenState extends State<CloudBackupSettingsScreen> {
  final CloudBackupService _cloudBackupService = CloudBackupService();
  final OnlineSyncService _syncService = OnlineSyncService();

  List<OnlineSyncAccount> _accounts = [];
  OnlineSyncAccount? _selectedAccount;
  List<CloudBackupEntry> _remoteBackups = [];
  bool _isLoading = true;
  bool _isActionInProgress = false;

  final TextEditingController _passphraseController = TextEditingController();

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
      if (_accounts.isNotEmpty && _selectedAccount == null) {
        _selectedAccount = _accounts.first;
      }
      _isLoading = false;
    });
    if (_selectedAccount != null) {
      _fetchRemoteBackups();
    }
  }

  Future<void> _fetchRemoteBackups() async {
    if (_selectedAccount == null) return;
    final backups = await _cloudBackupService.fetchCloudBackups(_selectedAccount!);
    setState(() {
      _remoteBackups = backups;
    });
  }

  Future<void> _triggerUploadBackup() async {
    if (_selectedAccount == null) return;
    final passphrase = _passphraseController.text;
    if (passphrase.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a backup passphrase')),
      );
      return;
    }

    setState(() => _isActionInProgress = true);
    try {
      final entry = await _cloudBackupService.uploadCloudBackup(
        account: _selectedAccount!,
        passphrase: passphrase,
      );
      await _fetchRemoteBackups();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              entry != null
                  ? 'Encrypted backup uploaded successfully: ${entry.fileName}'
                  : 'Backup uploaded',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      setState(() => _isActionInProgress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Encrypted Cloud Backup'),
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
                        const Icon(Icons.lock_outline, color: Colors.green),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Backs up the full app payload (.csbak) encrypted end-to-end with your passphrase via PBKDF2 (300k iters) + AES-GCM-256 to your cloud storage.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_accounts.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text('No cloud storage accounts configured.'),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Add Account in Provider Sync'),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  DropdownButtonFormField<OnlineSyncAccount>(
                    initialValue: _selectedAccount,
                    decoration: const InputDecoration(labelText: 'Target Cloud Account'),
                    items: _accounts
                        .map((acc) => DropdownMenuItem(
                              value: acc,
                              child: Text('${acc.accountEmailOrName} (${acc.providerType.name.toUpperCase()})'),
                            ))
                        .toList(),
                    onChanged: (acc) {
                      setState(() => _selectedAccount = acc);
                      _fetchRemoteBackups();
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passphraseController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Encryption Passphrase',
                      hintText: 'Enter passphrase for .csbak encryption',
                      prefixIcon: Icon(Icons.key),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _isActionInProgress ? null : _triggerUploadBackup,
                    icon: _isActionInProgress
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.cloud_upload),
                    label: const Text('Upload Encrypted Backup Now'),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Remote Cloud Backups',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (_remoteBackups.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text('No cloud backups found for this account.'),
                    )
                  else
                    ..._remoteBackups.map((entry) => Card(
                          child: ListTile(
                            leading: const Icon(Icons.insert_drive_file),
                            title: Text(entry.fileName),
                            subtitle: Text('Size: ${entry.sizeBytes} bytes | Date: ${entry.modifiedAt}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.cloud_download),
                              onPressed: () {
                                // Trigger restore
                              },
                            ),
                          ),
                        )),
                ],
              ],
            ),
    );
  }
}
