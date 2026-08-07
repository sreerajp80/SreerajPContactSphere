import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:smart_contacts_dialer/core/logging/app_logger.dart';
import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/models/audit_entry.dart';
import 'package:smart_contacts_dialer/repositories/audit_repository.dart';
import 'package:smart_contacts_dialer/repositories/contact_repository.dart';

/// Expiry duration options for ephemeral contacts.
enum EphemeralExpiryOption {
  twoHours('2 Hours', Duration(hours: 2)),
  twentyFourHours('24 Hours', Duration(hours: 24)),
  sevenDays('7 Days', Duration(days: 7)),
  autoDeleteCall('Auto-delete after 1 call', null);

  final String label;
  final Duration? duration;
  const EphemeralExpiryOption(this.label, this.duration);
}

/// Service that monitors and scrubs temporary, self-destructing ephemeral contacts.
class EphemeralContactService extends ChangeNotifier {
  static final EphemeralContactService _instance = EphemeralContactService._internal();
  factory EphemeralContactService() => _instance;
  EphemeralContactService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ContactRepository _contactRepo = ContactRepository();

  Timer? _cleanupTimer;
  final StreamController<int> _scrubbedController = StreamController<int>.broadcast();

  /// Emits contact IDs whenever an ephemeral contact is scrubbed.
  Stream<int> get onContactScrubbed => _scrubbedController.stream;

  /// Starts the periodic timer (runs every 60 seconds) to check for expired contacts.
  void startMonitoring() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      checkAndScrubExpiredContacts();
    });
    // Also run an immediate check on startup/monitoring start.
    checkAndScrubExpiredContacts();
  }

  /// Stops periodic monitoring.
  void stopMonitoring() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
  }

  /// Queries all ephemeral contacts and scrubs any that have reached their expiry time
  /// or exceeded call thresholds. Returns the total count of scrubbed contacts.
  Future<int> checkAndScrubExpiredContacts() async {
    try {
      final db = await _dbHelper.database;
      final rows = await db.query(
        'contacts',
        columns: [
          'id',
          'ephemeral_expires_at',
          'ephemeral_auto_delete_call',
          'ephemeral_call_count',
        ],
        where: 'is_ephemeral = 1',
      );

      final now = DateTime.now();
      var scrubbedCount = 0;

      for (final r in rows) {
        final id = r['id'] as int;
        final expiresAtStr = r['ephemeral_expires_at'] as String?;
        final autoDeleteCall = (r['ephemeral_auto_delete_call'] as int?) == 1;
        final callCount = (r['ephemeral_call_count'] as int?) ?? 0;

        bool shouldScrub = false;

        if (expiresAtStr != null) {
          final expiresAt = DateTime.tryParse(expiresAtStr);
          if (expiresAt != null && now.isAfter(expiresAt)) {
            shouldScrub = true;
          }
        }

        if (autoDeleteCall && callCount >= 1) {
          shouldScrub = true;
        }

        if (shouldScrub) {
          await scrubEphemeralContact(id);
          scrubbedCount++;
        }
      }

      if (scrubbedCount > 0) {
        notifyListeners();
      }
      return scrubbedCount;
    } catch (e, stack) {
      AppLogger.error(
        'Error checking/scrubbing expired ephemeral contacts',
        error: e,
        stackTrace: stack,
      );
      return 0;
    }
  }

  /// Permanently scrubs an ephemeral contact, including its record, child entries,
  /// notes, and associated call logs.
  Future<void> scrubEphemeralContact(int contactId) async {
    try {
      final db = await _dbHelper.database;
      final contact = await _contactRepo.getContactById(contactId);
      if (contact == null) return;

      // Extract raw numbers to cleanse associated unlinked call logs as well
      final phoneNumbers = contact.phoneNumbers.map((p) => p.number).toList();

      await db.transaction((txn) async {
        final before = await AuditRepository.capture(txn, contactId);

        // Delete from contacts table; ON DELETE CASCADE handles phone_numbers, emails, etc.
        await txn.delete('contacts', where: 'id = ?', whereArgs: [contactId]);

        // Permanently scrub associated call logs for this ephemeral contact ID & numbers
        await txn.delete(
          'call_logs',
          where: 'contact_id = ?',
          whereArgs: [contactId],
        );

        for (final numStr in phoneNumbers) {
          await txn.delete(
            'call_logs',
            where: 'phone_number = ?',
            whereArgs: [numStr],
          );
        }

        // Record audit entry
        if (before != null) {
          await AuditRepository.record(
            txn,
            contactId: contactId,
            action: AuditAction.delete,
            source: AuditSource.manual,
            before: before,
            summary: 'Ephemeral contact permanently scrubbed',
          );
        }
      });

      _contactRepo.pushRingtoneMirror();
      _scrubbedController.add(contactId);
      notifyListeners();
    } catch (e, stack) {
      AppLogger.error(
        'Error scrubbing ephemeral contact $contactId',
        error: e,
        stackTrace: stack,
      );
    }
  }

  /// Called when a call finishes for a given [contactId] or [phoneNumber].
  /// Increments call count and scrubs immediately if `ephemeral_auto_delete_call` is enabled.
  Future<void> onCallCompleted({int? contactId, String? phoneNumber}) async {
    try {
      final db = await _dbHelper.database;
      int? targetId = contactId;

      if (targetId == null && phoneNumber != null && phoneNumber.isNotEmpty) {
        final numRows = await db.query(
          'phone_numbers',
          columns: ['contact_id'],
          where: 'number = ?',
          whereArgs: [phoneNumber],
          limit: 1,
        );
        if (numRows.isNotEmpty) {
          targetId = numRows.first['contact_id'] as int?;
        }
      }

      if (targetId == null) return;

      final rows = await db.query(
        'contacts',
        columns: [
          'id',
          'is_ephemeral',
          'ephemeral_auto_delete_call',
          'ephemeral_call_count',
          'ephemeral_expires_at',
        ],
        where: 'id = ?',
        whereArgs: [targetId],
        limit: 1,
      );

      if (rows.isEmpty) return;
      final row = rows.first;
      final isEphemeral = (row['is_ephemeral'] as int?) == 1;

      if (!isEphemeral) return;

      final autoDeleteCall = (row['ephemeral_auto_delete_call'] as int?) == 1;
      final currentCalls = ((row['ephemeral_call_count'] as int?) ?? 0) + 1;

      await db.update(
        'contacts',
        {'ephemeral_call_count': currentCalls},
        where: 'id = ?',
        whereArgs: [targetId],
      );

      if (autoDeleteCall || currentCalls >= 1) {
        await scrubEphemeralContact(targetId);
      }
    } catch (e, stack) {
      AppLogger.error(
        'Error handling post-call ephemeral check',
        error: e,
        stackTrace: stack,
      );
    }
  }

  /// Extends the expiry of an existing ephemeral contact by [duration].
  Future<void> extendExpiry(int contactId, Duration duration) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'contacts',
      columns: ['ephemeral_expires_at'],
      where: 'id = ?',
      whereArgs: [contactId],
    );

    DateTime baseTime = DateTime.now();
    if (rows.isNotEmpty && rows.first['ephemeral_expires_at'] != null) {
      final currentExpires = DateTime.tryParse(rows.first['ephemeral_expires_at'] as String);
      if (currentExpires != null && currentExpires.isAfter(baseTime)) {
        baseTime = currentExpires;
      }
    }

    final newExpires = baseTime.add(duration);
    await db.update(
      'contacts',
      {
        'is_ephemeral': 1,
        'ephemeral_expires_at': newExpires.toIso8601String(),
        'ephemeral_auto_delete_call': 0,
      },
      where: 'id = ?',
      whereArgs: [contactId],
    );
    notifyListeners();
  }

  /// Converts an ephemeral contact into a permanent contact.
  Future<void> makePermanent(int contactId) async {
    final db = await _dbHelper.database;
    await db.update(
      'contacts',
      {
        'is_ephemeral': 0,
        'ephemeral_expires_at': null,
        'ephemeral_auto_delete_call': 0,
        'ephemeral_call_count': 0,
      },
      where: 'id = ?',
      whereArgs: [contactId],
    );
    notifyListeners();
  }
}
