// lib/repositories/group_repository.dart
import 'package:sqflite/sqflite.dart';

import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/models/group.dart';
import 'package:smart_contacts_dialer/repositories/contact_repository.dart';

class GroupRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// All groups with their contact counts, alphabetical.
  Future<List<Group>> getAllGroups() async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery('''
      SELECT g.*, COUNT(cg.contact_id) AS contact_count
      FROM groups g
      LEFT JOIN contact_groups cg ON cg.group_id = g.id
      GROUP BY g.id
      ORDER BY g.name ASC
    ''');
    return maps.map(Group.fromMap).toList();
  }

  /// Creates a group, returning its id. Throws if the name already exists
  /// (name is UNIQUE) — callers should validate/catch.
  Future<int> createGroup(String name, {String? ringtonePath}) async {
    final db = await _dbHelper.database;
    return db.insert('groups', {
      'name': name.trim(),
      'ringtone_path': ringtonePath,
    });
  }

  Future<int> renameGroup(int id, String name) async {
    final db = await _dbHelper.database;
    return db.update(
      'groups',
      {'name': name.trim()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Sets (or, with nulls, clears) the group's ringtone. Members without a
  /// tone of their own ring with this tone (see
  /// [ContactRepository.ringtoneMirrorEntries]).
  Future<void> setGroupRingtone(int id, {String? path, String? label}) async {
    final db = await _dbHelper.database;
    await db.update(
      'groups',
      {'ringtone_path': path, 'ringtone_label': label},
      where: 'id = ?',
      whereArgs: [id],
    );
    // Members' effective tones changed — refresh the native ringtone mirror.
    ContactRepository().pushRingtoneMirror();
  }

  Future<void> deleteGroup(int id) async {
    final db = await _dbHelper.database;
    // contact_groups rows cascade via the FK.
    await db.delete('groups', where: 'id = ?', whereArgs: [id]);
    // A deleted group takes its tone with it — members may fall back to
    // another tone tier.
    ContactRepository().pushRingtoneMirror();
  }

  /// The ids of contacts currently in [groupId]. Used to pre-check members in
  /// the "add contacts" picker on the Groups page.
  Future<Set<int>> contactIdsInGroup(int groupId) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'contact_groups',
      columns: ['contact_id'],
      where: 'group_id = ?',
      whereArgs: [groupId],
    );
    return {for (final r in rows) r['contact_id'] as int};
  }

  Future<void> addContactToGroup(int contactId, int groupId) async {
    final db = await _dbHelper.database;
    await db.insert('contact_groups', {
      'contact_id': contactId,
      'group_id': groupId,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
    // Joining a group with a tone can change the contact's effective tone.
    ContactRepository().pushRingtoneMirror();
  }

  Future<void> removeContactFromGroup(int contactId, int groupId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'contact_groups',
      where: 'contact_id = ? AND group_id = ?',
      whereArgs: [contactId, groupId],
    );
    ContactRepository().pushRingtoneMirror();
  }

  /// The group ringtone that applies to [contactId]: the tone of the contact's
  /// first toned group ordered by name (then id), or null when none of their
  /// groups has one. Must pick the same group as the mirror SQL in
  /// [ContactRepository.ringtoneMirrorEntries] so the late in-call push and the
  /// first-note mirror always agree.
  Future<String?> groupRingtoneForContact(int contactId) async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery(
      '''
      SELECT g.ringtone_path AS tone
      FROM contact_groups cg
      JOIN groups g ON g.id = cg.group_id
      WHERE cg.contact_id = ?
        AND g.ringtone_path IS NOT NULL AND TRIM(g.ringtone_path) != ''
      ORDER BY g.name ASC, g.id ASC
      LIMIT 1
      ''',
      [contactId],
    );
    if (rows.isEmpty) return null;
    return rows.first['tone'] as String?;
  }
}
