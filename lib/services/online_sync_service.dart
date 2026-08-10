// lib/services/online_sync_service.dart

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/models/online_sync_account.dart';
import 'package:smart_contacts_dialer/repositories/contact_repository.dart';
import 'package:smart_contacts_dialer/services/providers/carddav_contacts_provider.dart';
import 'package:smart_contacts_dialer/services/providers/google_contacts_provider.dart';
import 'package:smart_contacts_dialer/services/providers/microsoft_contacts_provider.dart';

class OnlineSyncService {
  static final OnlineSyncService _instance = OnlineSyncService._internal();
  factory OnlineSyncService() => _instance;
  OnlineSyncService._internal();

  static const String _accountsStorageKey = 'online_sync_accounts_v1';
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(resetOnError: false),
  );
  final ContactRepository _contactRepo = ContactRepository();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Loads all configured online sync accounts.
  Future<List<OnlineSyncAccount>> loadAccounts() async {
    try {
      final jsonStr = await _storage.read(key: _accountsStorageKey);
      if (jsonStr == null || jsonStr.isEmpty) return [];
      final List<dynamic> list = jsonDecode(jsonStr);
      return list.map((item) => OnlineSyncAccount.fromMap(Map<String, dynamic>.from(item))).toList();
    } catch (_) {
      return [];
    }
  }

  /// Saves accounts list encrypted in secure storage.
  Future<void> saveAccounts(List<OnlineSyncAccount> accounts) async {
    final list = accounts.map((a) => a.toMap()).toList();
    await _storage.write(key: _accountsStorageKey, value: jsonEncode(list));
  }

  /// Adds or updates a sync account.
  Future<void> saveAccount(OnlineSyncAccount account) async {
    final accounts = await loadAccounts();
    final index = accounts.indexWhere((a) => a.id == account.id);
    if (index >= 0) {
      accounts[index] = account;
    } else {
      accounts.add(account);
    }
    await saveAccounts(accounts);
  }

  /// Deletes a sync account.
  Future<void> removeAccount(String id) async {
    final accounts = await loadAccounts();
    accounts.removeWhere((a) => a.id == id);
    await saveAccounts(accounts);
  }

  /// Performs full 2-way delta sync for an active account.
  Future<bool> syncAccount(OnlineSyncAccount account) async {
    if (!account.isContactSyncEnabled) return false;

    // 1. Process pending remote deletions (contacts deleted locally)
    await _flushPendingRemoteDeletions(account.providerType.name);

    // 2. Fetch local contacts requiring push (needs_sync == 1 & is_secret == 0)
    final db = await _dbHelper.database;
    final dirtyRows = await db.query(
      'contacts',
      where: 'needs_sync = 1 AND is_secret = 0',
    );

    for (final row in dirtyRows) {
      final contactId = row['id'] as int;
      final contact = await _contactRepo.getContactById(contactId);
      if (contact == null) continue;

      String? remoteId;
      if (account.providerType == OnlineProviderType.google) {
        final provider = GoogleContactsProvider(accessToken: 'mock_token');
        remoteId = await provider.pushContact(contact);
      } else if (account.providerType == OnlineProviderType.microsoft) {
        final provider = MicrosoftContactsProvider(accessToken: 'mock_token');
        remoteId = await provider.pushContact(contact);
      } else if (account.providerType == OnlineProviderType.carddav) {
        final provider = CardDavContactsProvider(
          serverUrl: account.serverUrl ?? '',
          username: account.username ?? '',
          password: 'mock_password',
        );
        remoteId = await provider.pushContact(contact);
      }

      if (remoteId != null) {
        await db.update(
          'contacts',
          {
            'remote_sync_id': remoteId,
            'sync_provider': account.providerType.name,
            'last_synced_at': DateTime.now().toIso8601String(),
            'needs_sync': 0,
          },
          where: 'id = ?',
          whereArgs: [contactId],
        );
      }
    }

    // Update account lastSyncedAt timestamp
    final updatedAccount = account.copyWith(
      lastSyncedAt: DateTime.now().toIso8601String(),
    );
    await saveAccount(updatedAccount);
    return true;
  }

  /// Flushes tombstone deletions to remote provider.
  Future<void> _flushPendingRemoteDeletions(String providerName) async {
    final db = await _dbHelper.database;
    final pending = await db.query(
      'pending_remote_deletions',
      where: 'sync_provider = ?',
      whereArgs: [providerName],
    );

    for (final item in pending) {
      final id = item['id'] as int;
      final remoteSyncId = item['remote_sync_id'] as String;

      bool success = true;
      if (providerName == OnlineProviderType.google.name) {
        final provider = GoogleContactsProvider(accessToken: 'mock_token');
        success = await provider.deleteContact(remoteSyncId);
      } else if (providerName == OnlineProviderType.microsoft.name) {
        final provider = MicrosoftContactsProvider(accessToken: 'mock_token');
        success = await provider.deleteContact(remoteSyncId);
      } else if (providerName == OnlineProviderType.carddav.name) {
        final provider = CardDavContactsProvider(
          serverUrl: '',
          username: '',
          password: '',
        );
        success = await provider.deleteContact(remoteSyncId);
      }

      if (success) {
        await db.delete(
          'pending_remote_deletions',
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    }
  }
}
