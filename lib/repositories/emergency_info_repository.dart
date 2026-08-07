// lib/repositories/emergency_info_repository.dart
import 'package:sqflite/sqflite.dart';

import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/models/emergency_info.dart';
import 'package:smart_contacts_dialer/services/emergency_card_service.dart';

/// Reads and writes the emergency info card (`emergency_info` — a single row —
/// plus its `emergency_contacts` rows), and pushes the published subset to the
/// native lock-screen mirror.
///
/// The record itself always stays in the encrypted DB. Only [pushMirror]
/// publishes anything, and only the fields the user switched on (see
/// `EmergencyInfo.toMirrorJson`).
class EmergencyInfoRepository {
  /// The `emergency_info` table holds at most one row, under this id.
  static const int rowId = 1;

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final EmergencyCardService _card = EmergencyCardService();

  /// The saved card, or an empty (disabled) one on a fresh install.
  Future<EmergencyInfo> load() async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'emergency_info',
      where: 'id = ?',
      whereArgs: [rowId],
      limit: 1,
    );
    final contacts = await _loadContacts(db);
    if (rows.isEmpty) return EmergencyInfo(contacts: contacts);
    return EmergencyInfo.fromMap(rows.first, contacts: contacts);
  }

  Future<List<EmergencyContactEntry>> _loadContacts(DatabaseExecutor db) async {
    final rows = await db.query(
      'emergency_contacts',
      orderBy: 'sort_order ASC, id ASC',
    );
    return rows.map(EmergencyContactEntry.fromMap).toList();
  }

  /// Saves the whole card in one transaction (the single info row, then the
  /// contact list replaced wholesale — the list is short and always edited as a
  /// unit), then refreshes the lock-screen mirror.
  Future<void> save(EmergencyInfo info) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.insert(
        'emergency_info',
        info.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.delete('emergency_contacts');
      for (var i = 0; i < info.contacts.length; i++) {
        final entry = info.contacts[i];
        entry.sortOrder = i;
        final map = entry.toMap()..remove('id');
        await txn.insert('emergency_contacts', map);
      }
    });
    await pushMirror(info);
  }

  /// Publishes (or clears) the native lock-screen card for [info], loading the
  /// saved record first when none is passed.
  ///
  /// Called after every save and once on app load (see `AppSettings.load`), so
  /// an existing install and a reinstalled/restored one both end up with a
  /// mirror that matches the DB without waiting for the next edit.
  Future<void> pushMirror([EmergencyInfo? info]) async {
    try {
      final card = info ?? await load();
      final payload = card.toMirrorJson();
      if (payload == null) {
        await _card.clear();
      } else {
        await _card.publish(payload);
      }
    } catch (_) {
      // Best-effort: the mirror refreshes on the next save / app load.
    }
  }

  /// Turns the whole feature off: clears the master switch and wipes the
  /// published card immediately. The record stays in the encrypted DB so the
  /// user can switch it back on without retyping.
  Future<void> disable() async {
    final info = await load();
    info.enabled = false;
    await save(info);
  }
}
