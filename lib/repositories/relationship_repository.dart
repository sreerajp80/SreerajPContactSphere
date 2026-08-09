// lib/repositories/relationship_repository.dart
import 'dart:async' show unawaited;
import 'package:sqflite/sqflite.dart';

import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/models/relationship.dart';
import 'package:smart_contacts_dialer/services/quiet_hours_service.dart';

/// Read/write access to the `relationships` table.
///
/// A link between two contacts is stored as **two directed rows** (A→B and
/// B→A). The reverse row's type comes from [RelationshipTypes.reciprocalOf], so
/// recording "A is B's Father" also records "B is A's Child". This keeps each
/// contact's relationships a trivial `WHERE contact_id = ?` query and makes the
/// ego-sphere view symmetric. There is no UNIQUE constraint on the table, so
/// de-duplication is enforced here (any existing pair is removed before insert).
class RelationshipRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Creates or updates the link between [contactId] and [relatedContactId],
  /// storing both directions. [type] is from [contactId]'s perspective. A link
  /// to oneself is ignored. Replaces any existing link between the pair.
  Future<void> setRelationship({
    required int contactId,
    required int relatedContactId,
    required String type,
  }) async {
    if (contactId == relatedContactId) return;
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      // The reverse row describes [contactId] (the owner), so its label is
      // gendered by the owner's gender (e.g. reverse of "Cousin Brother" is
      // "Cousin Sister" when the owner is female).
      final ownerGender = await _genderOf(txn, contactId);
      final reverse = RelationshipTypes.reciprocalOf(
        type,
        subjectGender: ownerGender,
      );
      await _deletePair(txn, contactId, relatedContactId);
      await txn.insert('relationships', {
        'contact_id': contactId,
        'related_contact_id': relatedContactId,
        'relationship_type': type.trim(),
      });
      await txn.insert('relationships', {
        'contact_id': relatedContactId,
        'related_contact_id': contactId,
        'relationship_type': reverse,
      });
    });
    unawaited(QuietHoursService().syncQuietHoursMirror());
  }

  /// Removes the link between the two contacts (both directed rows).
  Future<void> removeRelationship({
    required int contactId,
    required int relatedContactId,
  }) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await _deletePair(txn, contactId, relatedContactId);
    });
    unawaited(QuietHoursService().syncQuietHoursMirror());
  }

  /// The `gender` value of the contact with [id], or null if unset/missing.
  /// Used to gender the auto-computed reverse relationship label.
  Future<String?> _genderOf(DatabaseExecutor txn, int id) async {
    final rows = await txn.query(
      'contacts',
      columns: ['gender'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['gender'] as String?;
  }

  Future<void> _deletePair(DatabaseExecutor txn, int a, int b) async {
    await txn.delete(
      'relationships',
      where:
          '(contact_id = ? AND related_contact_id = ?) '
          'OR (contact_id = ? AND related_contact_id = ?)',
      whereArgs: [a, b, b, a],
    );
  }

  /// The contacts related to [contactId], resolved for display (joined to
  /// `contacts`), ordered by name. Skips rows whose related contact no longer
  /// exists (shouldn't happen with FK cascade, but defensive).
  ///
  /// De-duplicates by related contact (`GROUP BY r.related_contact_id`) so a
  /// contact is listed once even if the table holds more than one directed row
  /// for the pair — which the contact-merge path can leave behind. Writes go
  /// through [setRelationship], which already de-dupes the pair on insert.
  Future<List<RelatedContact>> getRelationsOf(int contactId) async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery(
      '''
      SELECT MIN(r.relationship_type) AS relationship_type,
             c.id AS id,
             c.first_name AS first_name,
             c.middle_name AS middle_name,
             c.last_name AS last_name,
             c.salutation AS salutation,
             c.photo_path AS photo_path,
             c.relationship_score AS relationship_score
      FROM relationships r
      JOIN contacts c ON c.id = r.related_contact_id
      WHERE r.contact_id = ?
      GROUP BY r.related_contact_id
      ORDER BY c.first_name ASC, c.last_name ASC
      ''',
      [contactId],
    );

    return rows.map((row) {
      final name = [
        row['salutation'],
        row['first_name'],
        row['middle_name'],
        row['last_name'],
      ].where((e) => e != null && (e as String).isNotEmpty).join(' ');
      return RelatedContact(
        contactId: row['id'] as int,
        fullName: name,
        firstName: (row['first_name'] as String?) ?? '',
        photoPath: row['photo_path'] as String?,
        relationshipScore: (row['relationship_score'] as num?)?.toDouble() ?? 0,
        relationshipType: (row['relationship_type'] as String?) ?? 'Relative',
      );
    }).toList();
  }

  /// The relationship type the phone owner (the `is_self` contact) has recorded
  /// for [contactId], described from the owner's side — so "Father" means this
  /// contact *is* the owner's father. Null when there is no self contact, no
  /// link between the two, or the link has no type.
  ///
  /// A narrow single-query alternative to `getRelationsOf(selfId)` for the
  /// in-call path, which needs one label and must not pull the owner's whole
  /// relation list. `MIN(...)` picks one deterministically if the merge path has
  /// left duplicate rows for the pair, mirroring [getRelationsOf].
  Future<String?> relationshipToSelf(int contactId) async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery(
      '''
      SELECT MIN(r.relationship_type) AS relationship_type
      FROM relationships r
      JOIN contacts s ON s.id = r.contact_id
      WHERE s.is_self = 1 AND r.related_contact_id = ?
      ''',
      [contactId],
    );
    if (rows.isEmpty) return null;
    return rows.first['relationship_type'] as String?;
  }

  /// Every contact that has at least one relationship defined, with how many
  /// distinct contacts it links to — the Relation Status list. Because links
  /// are stored as two reciprocal rows, matching on `contact_id` alone covers
  /// both directions. Secret contacts are excluded, consistent with the other
  /// cross-contact views. The self contact is excluded too, since it can never
  /// accrue a real score (no one calls themselves).
  Future<List<RelationOverview>> getContactsWithRelations() async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery('''
      SELECT c.id AS id,
             c.first_name AS first_name,
             c.middle_name AS middle_name,
             c.last_name AS last_name,
             c.salutation AS salutation,
             c.photo_path AS photo_path,
             c.relationship_score AS relationship_score,
             COUNT(DISTINCT r.related_contact_id) AS relation_count
      FROM contacts c
      JOIN relationships r ON r.contact_id = c.id
      WHERE c.is_secret = 0 AND c.is_self = 0
      GROUP BY c.id
      ORDER BY c.first_name ASC, c.last_name ASC
      ''');

    return rows.map((row) {
      final name = [
        row['salutation'],
        row['first_name'],
        row['middle_name'],
        row['last_name'],
      ].where((e) => e != null && (e as String).isNotEmpty).join(' ');
      return RelationOverview(
        contactId: row['id'] as int,
        fullName: name,
        firstName: (row['first_name'] as String?) ?? '',
        photoPath: row['photo_path'] as String?,
        relationshipScore: (row['relationship_score'] as num?)?.toDouble() ?? 0,
        relationCount: (row['relation_count'] as num?)?.toInt() ?? 0,
      );
    }).toList();
  }
}
