// lib/models/online_sync_account.dart

/// Represents a user-configured cloud contact sync or backup account.
enum OnlineProviderType {
  google,
  microsoft,
  carddav,
}

enum SyncConflictResolution {
  localWins,
  remoteWins,
  manual,
}

class OnlineSyncAccount {
  final String id;
  final OnlineProviderType providerType;
  final String accountEmailOrName;
  final bool isContactSyncEnabled;
  final bool isCloudBackupEnabled;
  final SyncConflictResolution conflictResolution;
  final String? lastSyncedAt;
  final String? lastBackupAt;
  final String? serverUrl; // For CardDAV / WebDAV
  final String? username; // For CardDAV / WebDAV

  const OnlineSyncAccount({
    required this.id,
    required this.providerType,
    required this.accountEmailOrName,
    this.isContactSyncEnabled = false,
    this.isCloudBackupEnabled = false,
    this.conflictResolution = SyncConflictResolution.localWins,
    this.lastSyncedAt,
    this.lastBackupAt,
    this.serverUrl,
    this.username,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'providerType': providerType.name,
      'accountEmailOrName': accountEmailOrName,
      'isContactSyncEnabled': isContactSyncEnabled ? 1 : 0,
      'isCloudBackupEnabled': isCloudBackupEnabled ? 1 : 0,
      'conflictResolution': conflictResolution.name,
      'lastSyncedAt': lastSyncedAt,
      'lastBackupAt': lastBackupAt,
      'serverUrl': serverUrl,
      'username': username,
    };
  }

  factory OnlineSyncAccount.fromMap(Map<String, dynamic> map) {
    return OnlineSyncAccount(
      id: map['id'] as String,
      providerType: OnlineProviderType.values.firstWhere(
        (e) => e.name == map['providerType'],
        orElse: () => OnlineProviderType.google,
      ),
      accountEmailOrName: map['accountEmailOrName'] as String? ?? '',
      isContactSyncEnabled: (map['isContactSyncEnabled'] as int? ?? 0) == 1,
      isCloudBackupEnabled: (map['isCloudBackupEnabled'] as int? ?? 0) == 1,
      conflictResolution: SyncConflictResolution.values.firstWhere(
        (e) => e.name == map['conflictResolution'],
        orElse: () => SyncConflictResolution.localWins,
      ),
      lastSyncedAt: map['lastSyncedAt'] as String?,
      lastBackupAt: map['lastBackupAt'] as String?,
      serverUrl: map['serverUrl'] as String?,
      username: map['username'] as String?,
    );
  }

  OnlineSyncAccount copyWith({
    String? id,
    OnlineProviderType? providerType,
    String? accountEmailOrName,
    bool? isContactSyncEnabled,
    bool? isCloudBackupEnabled,
    SyncConflictResolution? conflictResolution,
    String? lastSyncedAt,
    String? lastBackupAt,
    String? serverUrl,
    String? username,
  }) {
    return OnlineSyncAccount(
      id: id ?? this.id,
      providerType: providerType ?? this.providerType,
      accountEmailOrName: accountEmailOrName ?? this.accountEmailOrName,
      isContactSyncEnabled: isContactSyncEnabled ?? this.isContactSyncEnabled,
      isCloudBackupEnabled: isCloudBackupEnabled ?? this.isCloudBackupEnabled,
      conflictResolution: conflictResolution ?? this.conflictResolution,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      lastBackupAt: lastBackupAt ?? this.lastBackupAt,
      serverUrl: serverUrl ?? this.serverUrl,
      username: username ?? this.username,
    );
  }
}
