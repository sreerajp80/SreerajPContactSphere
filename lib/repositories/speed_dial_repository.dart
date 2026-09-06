// lib/repositories/speed_dial_repository.dart
import 'package:sqflite/sqflite.dart';

import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/models/speed_dial_entry.dart';

/// Reads and writes the `speed_dial` table — the keypad keys 1–9 bound to a
/// saved number.
///
/// Two rules are enforced here rather than left to the UI:
///
/// * **Secret contacts can never hold a slot.** A slot shows a name on the
///   keypad and dials with one press, so binding a secret contact to a key
///   would expose it and call it with no unlock at all — which breaks the
///   project's secret-contacts rule.
/// * **One number per key.** `slot` is the table's primary key, so assigning a
///   key that is already taken replaces it in a single statement rather than
///   leaving two rows to disagree.
class SpeedDialRepository {
  final DatabaseHelper _dbHelper;

  SpeedDialRepository({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper();

  /// Joins the linked contact's name and avatar onto the stored row so the
  /// keypad and the settings list can label a key without a second query. A row
  /// whose contact is secret is filtered out by the callers below.
  static const String _projection = '''
      s.slot AS slot,
      s.contact_id AS contact_id,
      s.phone_number AS phone_number,
      c.photo_path AS photo_path,
      c.is_secret AS is_secret,
      TRIM(
        COALESCE(c.salutation || ' ', '') ||
        COALESCE(c.first_name, '') ||
        COALESCE(' ' || c.middle_name, '') ||
        COALESCE(' ' || c.last_name, '')
      ) AS display_name''';

  /// Every filled slot, keyed by slot number, lowest key first.
  ///
  /// A slot pointing at a secret contact is omitted — belt and braces next to
  /// the write-side check in [assign], so a row that somehow predates that check
  /// (an old backup, a contact made secret after it was assigned) still never
  /// surfaces on the keypad.
  Future<Map<int, SpeedDialEntry>> all() async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery('''
      SELECT $_projection
      FROM speed_dial s
      LEFT JOIN contacts c ON c.id = s.contact_id
      ORDER BY s.slot ASC
    ''');
    final result = <int, SpeedDialEntry>{};
    for (final row in rows) {
      if (row['is_secret'] == 1) continue;
      final entry = SpeedDialEntry.fromMap(row);
      if (!SpeedDialEntry.isValidSlot(entry.slot)) continue;
      result[entry.slot] = entry;
    }
    return result;
  }

  /// The entry bound to [slot], or null when the key is free (or holds a secret
  /// contact, which is treated as free — see [all]).
  Future<SpeedDialEntry?> forSlot(int slot) async {
    if (!SpeedDialEntry.isValidSlot(slot)) return null;
    final db = await _dbHelper.database;
    final rows = await db.rawQuery(
      '''
      SELECT $_projection
      FROM speed_dial s
      LEFT JOIN contacts c ON c.id = s.contact_id
      WHERE s.slot = ?
      LIMIT 1
      ''',
      [slot],
    );
    if (rows.isEmpty) return null;
    if (rows.first['is_secret'] == 1) return null;
    return SpeedDialEntry.fromMap(rows.first);
  }

  /// Binds [slot] to [phoneNumber], replacing whatever was there.
  ///
  /// Returns false and writes nothing when the slot is out of range, the number
  /// is blank, or [contactId] names a secret contact. Runs in a transaction so
  /// the secret check and the write cannot race a contact being made secret in
  /// between.
  Future<bool> assign({
    required int slot,
    required String phoneNumber,
    int? contactId,
  }) async {
    if (!SpeedDialEntry.isValidSlot(slot)) return false;
    final number = phoneNumber.trim();
    if (number.isEmpty) return false;

    final db = await _dbHelper.database;
    return db.transaction<bool>((txn) async {
      if (contactId != null && await _isSecret(txn, contactId)) return false;
      await txn.insert('speed_dial', {
        'slot': slot,
        'contact_id': contactId,
        'phone_number': number,
        'created_at': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      return true;
    });
  }

  /// Frees [slot]. Deleting the contact frees it too, through the foreign key's
  /// ON DELETE CASCADE.
  Future<void> clear(int slot) async {
    final db = await _dbHelper.database;
    await db.delete('speed_dial', where: 'slot = ?', whereArgs: [slot]);
  }

  /// Frees every slot bound to [contactId] — used when a contact is turned into
  /// a secret one, since a secret contact must not hold a key.
  Future<void> clearForContact(int contactId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'speed_dial',
      where: 'contact_id = ?',
      whereArgs: [contactId],
    );
  }

  Future<bool> _isSecret(DatabaseExecutor txn, int contactId) async {
    final rows = await txn.query(
      'contacts',
      columns: ['is_secret'],
      where: 'id = ?',
      whereArgs: [contactId],
      limit: 1,
    );
    if (rows.isEmpty) return false;
    return rows.first['is_secret'] == 1;
  }
}
