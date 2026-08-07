// lib/repositories/audit_repository.dart
import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';

import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/database/db_key.dart';
import 'package:smart_contacts_dialer/models/audit_entry.dart';

/// Result of verifying the audit log cryptographic SHA-256 hash chain.
class AuditChainVerificationResult {
  final bool isValid;
  final int totalEntries;
  final int verifiedEntries;
  final int? firstTamperedId;
  final String? errorMessage;

  const AuditChainVerificationResult({
    required this.isValid,
    required this.totalEntries,
    required this.verifiedEntries,
    this.firstTamperedId,
    this.errorMessage,
  });
}

/// Reads and writes the local audit log — one row per contact create / edit /
/// delete, with full before/after snapshots so a change can be undone.
///
/// Writing is done from inside [ContactRepository]'s existing transactions
/// (hence the `DatabaseExecutor txn` arguments), so a contact can never be
/// changed without the matching audit row landing atomically with it. The undo
/// itself lives in [ContactRepository.undoAudit], which owns the search-key and
/// mirror bookkeeping a write needs.
///
/// Each entry is cryptographically linked to the preceding entry via SHA-256 hash
/// chaining (`previousHash` + `currentPayload`), creating a tamper-proof audit log.
class AuditRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Entries older than this are dropped by [prune].
  static const Duration retention = Duration(days: 90);

  /// Hard cap on stored entries, so a big first sync can't grow the log without
  /// bound even inside the retention window.
  static const int maxEntries = 5000;

  // ===========================================================================
  // Writing (called from within a contact transaction)
  // ===========================================================================

  /// Full copy of [contactId] — its `contacts` row plus every child row — or
  /// null when no such contact exists. Ids are stripped: they are not stable
  /// across a restore, and the restore re-creates children from scratch.
  static Future<ContactSnapshot?> capture(
    DatabaseExecutor txn,
    int contactId,
  ) async {
    final rows = await txn.query(
      'contacts',
      where: 'id = ?',
      whereArgs: [contactId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final contact = Map<String, Object?>.from(rows.first)..remove('id');

    final children = <String, List<Map<String, Object?>>>{};
    for (final table in ContactSnapshot.childTables) {
      final childRows = await txn.query(
        table,
        where: 'contact_id = ?',
        whereArgs: [contactId],
      );
      if (childRows.isEmpty) continue;
      children[table] = [
        for (final r in childRows)
          Map<String, Object?>.from(r)
            ..remove('id')
            ..remove('contact_id'),
      ];
    }

    final groupRows = await txn.rawQuery(
      '''
      SELECT g.name AS name
      FROM contact_groups cg
      JOIN groups g ON g.id = cg.group_id
      WHERE cg.contact_id = ?
      ORDER BY g.name ASC
      ''',
      [contactId],
    );

    final relationshipRows = await txn.query(
      'relationships',
      columns: ['contact_id', 'related_contact_id', 'relationship_type'],
      where: 'contact_id = ? OR related_contact_id = ?',
      whereArgs: [contactId, contactId],
    );

    return ContactSnapshot(
      contact: contact,
      children: children,
      groups: [for (final r in groupRows) r['name'] as String],
      relationships: [
        for (final r in relationshipRows) Map<String, Object?>.from(r),
      ],
    );
  }

  /// Writes one audit row with SHA-256 cryptographic hash chaining to the previous entry.
  /// [before] is required for an edit or a delete (it is what an undo writes back);
  /// [after] for a create or an edit.
  static Future<void> record(
    DatabaseExecutor txn, {
    required int? contactId,
    required AuditAction action,
    required AuditSource source,
    ContactSnapshot? before,
    ContactSnapshot? after,
    String? summary,
    String? contactName,
  }) async {
    final snapshot = after ?? before;
    final changes = AuditEntry.diff(before, after);
    final name = contactName ?? snapshot?.displayName ?? 'Unnamed contact';
    final actionStr = action.dbValue;
    final sourceStr = source.dbValue;
    final timestamp = DateTime.now().toIso8601String();
    final sumStr = summary ?? AuditEntry.summaryOf(changes);
    final isSec = (snapshot?.isSecret ?? false);
    final beforeJson = before?.encode();
    final afterJson = after?.encode();

    final prevRows = await txn.rawQuery(
      'SELECT hash FROM audit_log ORDER BY id DESC LIMIT 1',
    );
    final prevHash =
        (prevRows.isNotEmpty ? prevRows.first['hash'] as String? : null) ??
        AuditEntry.genesisHash;

    final currentHash = await AuditEntry.calculateHash(
      prevHash: prevHash,
      contactId: contactId,
      contactName: name,
      actionDbValue: actionStr,
      sourceDbValue: sourceStr,
      changedAt: timestamp,
      summary: sumStr,
      isSecret: isSec,
      beforeJson: beforeJson,
      afterJson: afterJson,
    );

    await txn.insert('audit_log', {
      'contact_id': contactId,
      'contact_name': name,
      'action': actionStr,
      'source': sourceStr,
      'changed_at': timestamp,
      'summary': sumStr,
      'is_secret': isSec ? 1 : 0,
      'before_json': beforeJson,
      'after_json': afterJson,
      'prev_hash': prevHash,
      'hash': currentHash,
    });
  }

  // ===========================================================================
  // Reading & Verification
  // ===========================================================================

  /// Most recent entries first.
  ///
  /// [includeSecret] mirrors how the contact list treats secret contacts: their
  /// entries stay hidden until secret contacts are unlocked. [actions] filters
  /// by action when given; [contactId] narrows to a single contact.
  Future<List<AuditEntry>> entries({
    Set<AuditAction>? actions,
    bool includeSecret = false,
    int? contactId,
    int limit = 500,
  }) async {
    final db = await _dbHelper.database;
    final where = <String>[];
    final args = <Object?>[];
    if (!includeSecret) where.add('is_secret = 0');
    if (contactId != null) {
      where.add('contact_id = ?');
      args.add(contactId);
    }
    if (actions != null && actions.isNotEmpty) {
      final placeholders = List.filled(actions.length, '?').join(',');
      where.add('action IN ($placeholders)');
      args.addAll([for (final a in actions) a.dbValue]);
    }
    final rows = await db.query(
      'audit_log',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'changed_at DESC, id DESC',
      limit: limit,
    );
    return [for (final r in rows) AuditEntry.fromRow(r)];
  }

  /// A single entry by id, or null when it has since been pruned or cleared.
  Future<AuditEntry?> entryById(int id) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'audit_log',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return AuditEntry.fromRow(rows.first);
  }

  /// How many entries are stored (secret ones included).
  Future<int> count() async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery('SELECT COUNT(*) AS c FROM audit_log');
    return (rows.first['c'] as int?) ?? 0;
  }

  /// Ensures any legacy rows missing SHA-256 hashes are backfilled in sequential order.
  Future<void> ensureHashesBackfilled() async {
    final db = await _dbHelper.database;
    final rows = await db.query('audit_log', orderBy: 'id ASC');
    if (rows.isEmpty) return;

    var expectedPrevHash = AuditEntry.genesisHash;
    final batch = db.batch();
    var updated = 0;

    for (final row in rows) {
      final id = row['id'] as int;
      final storedPrev = row['prev_hash'] as String?;
      final storedHash = row['hash'] as String?;

      if (storedHash != null && storedHash.isNotEmpty && storedPrev != null) {
        expectedPrevHash = storedHash;
        continue;
      }

      final contactId = row['contact_id'] as int?;
      final name = (row['contact_name'] as String?) ?? 'Unnamed contact';
      final actionStr = (row['action'] as String?) ?? 'update';
      final sourceStr = (row['source'] as String?) ?? 'manual';
      final timestamp = (row['changed_at'] as String?) ?? '';
      final sumStr = (row['summary'] as String?) ?? '';
      final isSec = row['is_secret'] == 1;
      final beforeJson = row['before_json'] as String?;
      final afterJson = row['after_json'] as String?;

      final computedHash = await AuditEntry.calculateHash(
        prevHash: expectedPrevHash,
        contactId: contactId,
        contactName: name,
        actionDbValue: actionStr,
        sourceDbValue: sourceStr,
        changedAt: timestamp,
        summary: sumStr,
        isSecret: isSec,
        beforeJson: beforeJson,
        afterJson: afterJson,
      );

      batch.update(
        'audit_log',
        {'prev_hash': expectedPrevHash, 'hash': computedHash},
        where: 'id = ?',
        whereArgs: [id],
      );
      expectedPrevHash = computedHash;
      updated++;
    }

    if (updated > 0) {
      await batch.commit(noResult: true);
    }
  }

  /// Verifies the SHA-256 cryptographic hash chain across all audit entries.
  Future<AuditChainVerificationResult> verifyChain() async {
    await ensureHashesBackfilled();
    final db = await _dbHelper.database;
    final rows = await db.query('audit_log', orderBy: 'id ASC');
    if (rows.isEmpty) {
      return const AuditChainVerificationResult(
        isValid: true,
        totalEntries: 0,
        verifiedEntries: 0,
      );
    }

    var expectedPrevHash = AuditEntry.genesisHash;
    var verifiedCount = 0;

    for (final row in rows) {
      final entry = AuditEntry.fromRow(row);
      if (entry.prevHash != expectedPrevHash) {
        return AuditChainVerificationResult(
          isValid: false,
          totalEntries: rows.length,
          verifiedEntries: verifiedCount,
          firstTamperedId: entry.id,
          errorMessage:
              'Previous hash mismatch at entry #${entry.id} (${entry.contactName})',
        );
      }

      final validHash = await entry.verifyHash(expectedPrevHash);
      if (!validHash) {
        return AuditChainVerificationResult(
          isValid: false,
          totalEntries: rows.length,
          verifiedEntries: verifiedCount,
          firstTamperedId: entry.id,
          errorMessage:
              'Payload/Hash tamper detected at entry #${entry.id} (${entry.contactName})',
        );
      }

      verifiedCount++;
      expectedPrevHash = entry.hash!;
    }

    return AuditChainVerificationResult(
      isValid: true,
      totalEntries: rows.length,
      verifiedEntries: verifiedCount,
    );
  }

  /// Exports a sealed JSON file containing all audit log entries, verified chain
  /// status, and a cryptographic HMAC signature generated using the device key.
  /// Launches the system share sheet (`SharePlus`) and returns the written file.
  Future<File> exportSignedAuditLog({
    bool includeSecret = false,
    Directory? outputDir,
  }) async {
    final chainResult = await verifyChain();
    final dbEntries = await entries(
      includeSecret: includeSecret,
      limit: maxEntries,
    );
    final sortedEntries = dbEntries.reversed.toList(); // id ASC order for export

    final entriesJson = [
      for (final e in sortedEntries)
        {
          'id': e.id,
          'contactId': e.contactId,
          'contactName': e.contactName,
          'action': e.action.dbValue,
          'source': e.source.dbValue,
          'changedAt': e.changedAt.toIso8601String(),
          'summary': e.summary,
          'isSecret': e.isSecret,
          'before': e.before?.toJson(),
          'after': e.after?.toJson(),
          'prevHash': e.prevHash,
          'hash': e.hash,
        },
    ];

    final timestamp = DateTime.now().toIso8601String();
    final headHash = sortedEntries.isNotEmpty
        ? sortedEntries.last.hash ?? AuditEntry.genesisHash
        : AuditEntry.genesisHash;

    final documentContent = jsonEncode({
      'exportMetadata': {
        'version': 1,
        'exportedAt': timestamp,
        'totalEntries': sortedEntries.length,
        'chainHeadHash': headHash,
        'chainVerified': chainResult.isValid,
        'signatureAlgorithm': 'HMAC-SHA256',
      },
      'entries': entriesJson,
    });

    final signingKey = await DbKey.getOrCreate();
    final hmac = Hmac.sha256();
    final mac = await hmac.calculateMac(
      utf8.encode(documentContent),
      secretKey: SecretKey(utf8.encode(signingKey)),
    );
    final signatureHex =
        mac.bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

    final signedPayload = jsonEncode({
      'auditExport': jsonDecode(documentContent),
      'signature': signatureHex,
    });

    Directory dir;
    try {
      dir = outputDir ?? await getTemporaryDirectory();
    } catch (_) {
      dir = outputDir ?? Directory.systemTemp;
    }
    final fileName =
        'audit_log_signed_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File(p.join(dir.path, fileName));
    await file.writeAsString(signedPayload);

    try {
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], subject: fileName),
      );
    } catch (_) {
      // In host-side unit test environment, plugin channel is unattached
    }
    return file;
  }

  // ===========================================================================
  // Housekeeping
  // ===========================================================================

  /// Drops entries older than [retention], then trims the log to the newest
  /// [maxEntries] rows. Returns how many rows were removed. Called when the
  /// Audit Log screen opens — often enough to keep the log small, rarely enough
  /// to stay off the write path.
  Future<int> prune() async {
    final db = await _dbHelper.database;
    final cutoff = DateTime.now().subtract(retention).toIso8601String();
    var removed = await db.delete(
      'audit_log',
      where: 'changed_at < ?',
      whereArgs: [cutoff],
    );
    removed += await db.rawDelete(
      '''
      DELETE FROM audit_log
      WHERE id NOT IN (
        SELECT id FROM audit_log ORDER BY changed_at DESC, id DESC LIMIT ?
      )
      ''',
      [maxEntries],
    );
    return removed;
  }

  /// Empties the log. The contacts themselves are untouched — only the history
  /// of how they got that way is dropped, so pending undos go with it.
  Future<int> clear() async {
    final db = await _dbHelper.database;
    return db.delete('audit_log');
  }
}
