// lib/services/cloud_backup_service.dart

import 'dart:typed_data';
import 'package:smart_contacts_dialer/models/cloud_backup_entry.dart';
import 'package:smart_contacts_dialer/models/online_sync_account.dart';
import 'package:smart_contacts_dialer/services/backup_service.dart';
import 'package:smart_contacts_dialer/services/providers/carddav_contacts_provider.dart';
import 'package:smart_contacts_dialer/services/providers/google_contacts_provider.dart';
import 'package:smart_contacts_dialer/services/providers/microsoft_contacts_provider.dart';

class CloudBackupService {
  final BackupService _backupService = BackupService();

  /// Creates a password-encrypted .csbak payload and uploads it to the configured cloud target.
  Future<CloudBackupEntry?> uploadCloudBackup({
    required OnlineSyncAccount account,
    required String passphrase,
  }) async {
    // 1. Generate PBKDF2 + AES-GCM encrypted .csbak bytes
    final Uint8List backupBytes = await _backupService.encodeBackup(passphrase);
    final String fileName = _backupService.suggestedFileName();

    // 2. Direct upload to target provider
    if (account.providerType == OnlineProviderType.google) {
      final provider = GoogleContactsProvider(accessToken: 'mock_token');
      return await provider.uploadEncryptedBackup(bytes: backupBytes, fileName: fileName);
    } else if (account.providerType == OnlineProviderType.microsoft) {
      final provider = MicrosoftContactsProvider(accessToken: 'mock_token');
      return await provider.uploadEncryptedBackup(bytes: backupBytes, fileName: fileName);
    } else if (account.providerType == OnlineProviderType.carddav) {
      final provider = CardDavContactsProvider(
        serverUrl: account.serverUrl ?? '',
        username: account.username ?? '',
        password: 'mock_password',
      );
      return await provider.uploadEncryptedBackup(bytes: backupBytes, fileName: fileName);
    }
    return null;
  }

  /// Lists available encrypted .csbak backup files from the cloud provider.
  Future<List<CloudBackupEntry>> fetchCloudBackups(OnlineSyncAccount account) async {
    if (account.providerType == OnlineProviderType.google) {
      final provider = GoogleContactsProvider(accessToken: 'mock_token');
      return await provider.listBackups();
    } else if (account.providerType == OnlineProviderType.microsoft) {
      final provider = MicrosoftContactsProvider(accessToken: 'mock_token');
      return await provider.listBackups();
    } else if (account.providerType == OnlineProviderType.carddav) {
      final provider = CardDavContactsProvider(
        serverUrl: account.serverUrl ?? '',
        username: account.username ?? '',
        password: 'mock_password',
      );
      return await provider.listBackups();
    }
    return [];
  }

  /// Downloads an encrypted .csbak file from cloud storage and restores app data.
  Future<void> restoreCloudBackup({
    required OnlineSyncAccount account,
    required CloudBackupEntry entry,
    required String passphrase,
  }) async {
    Uint8List? bytes;

    if (account.providerType == OnlineProviderType.google) {
      final provider = GoogleContactsProvider(accessToken: 'mock_token');
      bytes = await provider.downloadBackup(entry.fileId);
    } else if (account.providerType == OnlineProviderType.microsoft) {
      final provider = MicrosoftContactsProvider(accessToken: 'mock_token');
      bytes = await provider.downloadBackup(entry.fileId);
    } else if (account.providerType == OnlineProviderType.carddav) {
      final provider = CardDavContactsProvider(
        serverUrl: account.serverUrl ?? '',
        username: account.username ?? '',
        password: 'mock_password',
      );
      bytes = await provider.downloadBackup(entry.fileId);
    }

    if (bytes == null || bytes.isEmpty) {
      throw const BackupException('Failed to download backup file from cloud.');
    }

    // Decrypt and replace app database via BackupService
    await _backupService.restoreBytes(bytes, passphrase);
  }
}
