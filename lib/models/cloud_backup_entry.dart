// lib/models/cloud_backup_entry.dart

/// Represents a remote encrypted backup (.csbak) file stored in cloud storage.
class CloudBackupEntry {
  final String fileId;
  final String fileName;
  final String providerName; // 'google_drive', 'onedrive', 'carddav_webdav'
  final int sizeBytes;
  final String modifiedAt;
  final String? downloadUrl;

  const CloudBackupEntry({
    required this.fileId,
    required this.fileName,
    required this.providerName,
    required this.sizeBytes,
    required this.modifiedAt,
    this.downloadUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'fileId': fileId,
      'fileName': fileName,
      'providerName': providerName,
      'sizeBytes': sizeBytes,
      'modifiedAt': modifiedAt,
      'downloadUrl': downloadUrl,
    };
  }

  factory CloudBackupEntry.fromMap(Map<String, dynamic> map) {
    return CloudBackupEntry(
      fileId: map['fileId'] as String? ?? '',
      fileName: map['fileName'] as String? ?? '',
      providerName: map['providerName'] as String? ?? '',
      sizeBytes: map['sizeBytes'] as int? ?? 0,
      modifiedAt: map['modifiedAt'] as String? ?? '',
      downloadUrl: map['downloadUrl'] as String?,
    );
  }
}
