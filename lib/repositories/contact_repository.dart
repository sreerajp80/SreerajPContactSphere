// lib/repositories/contact_repository.dart
import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/services/telecom_service.dart';
import 'package:smart_contacts_dialer/utils/malayalam_transliterator.dart';
import 'package:smart_contacts_dialer/utils/affiliation_key.dart';
import 'package:smart_contacts_dialer/utils/phone_normalizer.dart';
import 'package:smart_contacts_dialer/models/audit_entry.dart';
import 'package:smart_contacts_dialer/models/contact.dart';
import 'package:smart_contacts_dialer/models/phone_number.dart';
import 'package:smart_contacts_dialer/models/email.dart';
import 'package:smart_contacts_dialer/models/address.dart';
import 'package:smart_contacts_dialer/models/official_details.dart';
import 'package:smart_contacts_dialer/models/social_link.dart';
import 'package:smart_contacts_dialer/repositories/audit_repository.dart';
import 'package:smart_contacts_dialer/repositories/relationship_repository.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/utils/t9_utils.dart';

/// A single phone-number hit for the dialer's match-as-you-type suggestions:
/// the owning contact's id/name and the matched number.
class PhoneMatch {
  final int contactId;
  final String contactName;

  /// Given name only (no salutation) — the source for avatar initials.
  final String firstName;
  final String number;

  /// The matched phone's label (e.g. "Mobile", "Work"), or null when unlabeled.
  /// Rendered as the "Label · number" line in the dialer's suggestion rows.
  final String? label;

  /// Filesystem path to the contact's profile photo, or null when none. The
  /// dialer paints this as the avatar and falls back to the initial when the
  /// path is null or the file is missing.
  final String? photoPath;

  const PhoneMatch({
    required this.contactId,
    required this.contactName,
    this.firstName = '',
    required this.number,
    this.label,
    this.photoPath,
  });
}

/// One duplicate set for the Find-duplicates screen: the member contacts
/// (keep-candidate first), a short human reason they were grouped, and a
/// per-contact detail line (primary phone + label / email fallback / field
/// count), keyed by contact id.
class DuplicateSet {
  final List<Contact> contacts;
  final String reason;
  final Map<int, String> details;

  /// Whether two members share a phone number (digit-normalized). A set linked
  /// only by name (`false`) is far more likely to be different people who happen
  /// to share a name, so the duplicates screen defaults such sets to nothing
  /// ticked for merge; phone-linked sets stay ticked.
  final bool linkedByPhone;

  const DuplicateSet({
    required this.contacts,
    required this.reason,
    required this.details,
    required this.linkedByPhone,
  });
}

/// One tag with the number of contacts that carry it — a row for the Tag
/// Cloud screen, which sizes each tag chip by [count].
class TagCount {
  final String name;
  final int count;

  const TagCount({required this.name, required this.count});
}

/// A contact who shares a house or an employer with one of the contacts already
/// picked — a suggested member for the group/tag being built.
///
/// [label] is the shared value as the *peer* has it stored (e.g. "Infosys Ltd"),
/// shown to explain the suggestion; [kind] says which field matched.
class AffiliationPeer {
  final int contactId;
  final AffiliationKind kind;
  final String label;

  const AffiliationPeer({
    required this.contactId,
    required this.kind,
    required this.label,
  });

  /// Reason line for the suggestion row, e.g. "Same house: Sreelakshmi".
  String get reason => switch (kind) {
    AffiliationKind.house => 'Same house: $label',
    AffiliationKind.company => 'Same company: $label',
  };
}

enum AffiliationKind { house, company }

class ContactRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final RelationshipRepository _relationships = RelationshipRepository();

  /// Strips everything but digits — used to compare typed dialpad input against
  /// stored numbers that may carry +country codes, spaces, dashes or parens.
  static String normalizeDigits(String s) => s.replaceAll(RegExp(r'\D'), '');

  /// Phone numbers or T9 name matches whose digits/letters match [fragment]'s digits,
  /// for the dialer's live suggestions. Matching supports both phone digit fragments
  /// and T9 Smart Dialing (letter-to-digit name matching). Returns at most
  /// [limit] hits; an empty/whitespace fragment yields nothing.
  Future<List<PhoneMatch>> findByPhoneFragment(
    String fragment, {
    int limit = 8,
  }) async {
    final digits = normalizeDigits(fragment);
    if (digits.isEmpty) return const <PhoneMatch>[];

    final db = await _dbHelper.database;
    final rows = await db.rawQuery(
      '''
      SELECT p.number AS number,
             p.label AS label,
             c.id AS contact_id,
             c.first_name AS first_name,
             c.photo_path AS photo_path,
             TRIM(
               COALESCE(c.salutation || ' ', '') ||
               COALESCE(c.first_name, '') ||
               COALESCE(' ' || c.middle_name, '') ||
               COALESCE(' ' || c.last_name, '')
             ) AS contact_name
      FROM phone_numbers p
      JOIN contacts c ON c.id = p.contact_id
      ''',
    );

    final scoredMatches = <_ScoredMatch>[];

    for (final r in rows) {
      final name = (r['contact_name'] as String?)?.trim() ?? '';
      final number = r['number'] as String;
      final score = T9Utils.scoreMatch(name, number, digits);

      if (score > 0) {
        final label = (r['label'] as String?)?.trim();
        scoredMatches.add(
          _ScoredMatch(
            match: PhoneMatch(
              contactId: r['contact_id'] as int,
              contactName: name,
              firstName: ((r['first_name'] as String?) ?? '').trim(),
              number: number,
              label: (label == null || label.isEmpty) ? null : label,
              photoPath: r['photo_path'] as String?,
            ),
            score: score,
          ),
        );
      }
    }

    scoredMatches.sort((a, b) {
      final scoreCompare = b.score.compareTo(a.score);
      if (scoreCompare != 0) return scoreCompare;
      return a.match.contactName.compareTo(b.match.contactName);
    });

    final uniqueMatches = <PhoneMatch>[];
    final seen = <String>{};

    for (final sm in scoredMatches) {
      final key = '${sm.match.contactId}_${sm.match.number}';
      if (seen.add(key)) {
        uniqueMatches.add(sm.match);
        if (uniqueMatches.length >= limit) break;
      }
    }

    return uniqueMatches;
  }

  /// Resolves a full phone number (an incoming caller ID or a dialed number) to
  /// matching contacts by normalizing both sides to canonical E.164 under
  /// [defaultIso] (see [PhoneNormalizer]). Unlike [findByPhoneFragment] — which
  /// finds stored numbers that *contain* a typed fragment for dialer
  /// suggestions — this matches a stored national number (9876543210) to an
  /// incoming number carrying a country code (+919876543210) and vice versa.
  /// Returns at most [limit] hits; an empty number yields nothing.
  Future<List<PhoneMatch>> findByFullNumber(
    String number, {
    required String defaultIso,
    int limit = 1,
  }) async {
    final digits = normalizeDigits(number);
    if (digits.isEmpty) return const <PhoneMatch>[];

    // A trailing slice is a cheap SQL prefilter; the exact E.164 relationship is
    // confirmed in Dart below. Uses the same [_mirrorMatchDigits] slice as the
    // native mirror so all three key numbers the same way.
    final tail = digits.length > _mirrorMatchDigits
        ? digits.substring(digits.length - _mirrorMatchDigits)
        : digits;

    final db = await _dbHelper.database;
    final rows = await db.rawQuery(
      '''
      SELECT p.number AS number,
             p.label AS label,
             c.id AS contact_id,
             c.first_name AS first_name,
             c.photo_path AS photo_path,
             TRIM(
               COALESCE(c.salutation || ' ', '') ||
               COALESCE(c.first_name, '') ||
               COALESCE(' ' || c.middle_name, '') ||
               COALESCE(' ' || c.last_name, '')
             ) AS contact_name
      FROM phone_numbers p
      JOIN contacts c ON c.id = p.contact_id
      WHERE REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
              p.number, ' ', ''), '-', ''), '(', ''), ')', ''), '+', ''), '.', '')
            LIKE ?
      ORDER BY c.first_name ASC
      ''',
      ['%$tail%'],
    );

    final out = <PhoneMatch>[];
    for (final r in rows) {
      final stored = r['number'] as String;
      if (!PhoneNormalizer.sameNumber(stored, number, defaultIso: defaultIso)) {
        continue;
      }
      final name = (r['contact_name'] as String?)?.trim();
      final label = (r['label'] as String?)?.trim();
      out.add(
        PhoneMatch(
          contactId: r['contact_id'] as int,
          contactName: (name == null || name.isEmpty) ? '' : name,
          firstName: ((r['first_name'] as String?) ?? '').trim(),
          number: stored,
          label: (label == null || label.isEmpty) ? null : label,
          photoPath: (r['photo_path'] as String?),
        ),
      );
      if (out.length >= limit) break;
    }
    return out;
  }

  /// Shared column list for the dialer's pre-dial lists (Favorites / Top
  /// contacts): contact id, assembled display name, and the primary phone + its
  /// label. Selected from `contacts c`; map rows with [_preDialMatch].
  static const String _preDialProjection = '''
      c.id AS contact_id,
      c.first_name AS first_name,
      c.photo_path AS photo_path,
      TRIM(
        COALESCE(c.salutation || ' ', '') ||
        COALESCE(c.first_name, '') ||
        COALESCE(' ' || c.middle_name, '') ||
        COALESCE(' ' || c.last_name, '')
      ) AS contact_name,
      (SELECT p.number FROM phone_numbers p
         WHERE p.contact_id = c.id
         ORDER BY p.is_primary DESC, p.id ASC LIMIT 1) AS number,
      (SELECT p.label FROM phone_numbers p
         WHERE p.contact_id = c.id
         ORDER BY p.is_primary DESC, p.id ASC LIMIT 1) AS label''';

  /// Maps a [_preDialProjection] row into a [PhoneMatch]. A contact with no
  /// phone yields an empty number so the caller can disable its call action.
  PhoneMatch _preDialMatch(Map<String, Object?> r) {
    final name = (r['contact_name'] as String?)?.trim();
    final label = (r['label'] as String?)?.trim();
    return PhoneMatch(
      contactId: r['contact_id'] as int,
      contactName: (name == null || name.isEmpty) ? '' : name,
      firstName: ((r['first_name'] as String?) ?? '').trim(),
      number: (r['number'] as String?) ?? '',
      label: (label == null || label.isEmpty) ? null : label,
      photoPath: (r['photo_path'] as String?),
    );
  }

  /// Starred contacts (non-secret) with their primary phone + label, for the
  /// dialer's Favorites list shown before any digits are typed. Ordered by name.
  /// A favorite with no phone is still returned (empty number) so the caller can
  /// show it with its call action disabled. Toggle a favorite via [setFavorite].
  Future<List<PhoneMatch>> getFavoriteMatches({int limit = 20}) async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery(
      '''
      SELECT $_preDialProjection
      FROM contacts c
      WHERE c.is_favorite = 1 AND c.is_secret = 0
      ORDER BY c.first_name ASC
      LIMIT ?
      ''',
      [limit],
    );
    return rows.map(_preDialMatch).toList();
  }

  /// The given contacts as pre-dial rows, **in the order [ids] were given** —
  /// the caller has already decided the ranking (see `ReachWindowService`).
  /// Secret and favorite contacts are skipped, matching the other pre-dial
  /// lists; ids with no surviving row are simply dropped.
  Future<List<PhoneMatch>> getMatchesForIds(List<int> ids) async {
    if (ids.isEmpty) return const <PhoneMatch>[];
    final db = await _dbHelper.database;
    final rows = await db.rawQuery(
      '''
      SELECT $_preDialProjection
      FROM contacts c
      WHERE c.id IN (${List.filled(ids.length, '?').join(',')})
        AND c.is_secret = 0 AND c.is_favorite = 0
      ''',
      ids,
    );
    final byId = {
      for (final r in rows) r['contact_id'] as int: _preDialMatch(r),
    };
    return [for (final id in ids) ?byId[id]];
  }

  /// The dialer's "Top contacts" list in **recency** mode: the highest
  /// `relationship_score` contacts first, then — if there aren't [limit] of
  /// those — filled with the most-recently contacted people (by latest
  /// `call_logs` timestamp), so the section isn't empty once any call has been
  /// made. Non-secret, non-favorite only (Favorites has its own section);
  /// de-duplicated across the two passes. A contact with no phone is still
  /// returned (empty number), matching [getFavoriteMatches].
  Future<List<PhoneMatch>> getTopRecentMatches({int limit = 5}) async {
    final db = await _dbHelper.database;

    // Pass 1: contacts with an actual relationship score, best first.
    final scoredRows = await db.rawQuery(
      '''
      SELECT $_preDialProjection
      FROM contacts c
      WHERE c.is_secret = 0 AND c.is_favorite = 0 AND c.relationship_score > 0
      ORDER BY c.relationship_score DESC, c.first_name ASC
      LIMIT ?
      ''',
      [limit],
    );

    final matches = <PhoneMatch>[];
    final seen = <int>{};
    for (final r in scoredRows) {
      final m = _preDialMatch(r);
      matches.add(m);
      seen.add(m.contactId);
    }
    if (matches.length >= limit) return matches;

    // Pass 2: fill the rest with the most-recently contacted, skipping any
    // already picked in pass 1.
    final remaining = limit - matches.length;
    final notIn = seen.isEmpty
        ? ''
        : 'AND c.id NOT IN (${List.filled(seen.length, '?').join(',')})';
    final recentRows = await db.rawQuery(
      '''
      SELECT $_preDialProjection, MAX(cl.timestamp) AS last_contacted
      FROM contacts c
      JOIN call_logs cl ON cl.contact_id = c.id
      WHERE c.is_secret = 0 AND c.is_favorite = 0 $notIn
      GROUP BY c.id
      ORDER BY last_contacted DESC
      LIMIT ?
      ''',
      [...seen, remaining],
    );
    for (final r in recentRows) {
      matches.add(_preDialMatch(r));
    }
    return matches;
  }

  /// The dialer's "Top contacts" list in **relations** mode: contacts the user
  /// has explicitly linked as relations (family, friends, …) — anyone with a row
  /// in `relationships` — highest `relationship_score` first, then by name.
  /// Non-secret, non-favorite only.
  Future<List<PhoneMatch>> getFamilyFriendsMatches({int limit = 5}) async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery(
      '''
      SELECT $_preDialProjection
      FROM contacts c
      WHERE c.is_secret = 0 AND c.is_favorite = 0
        AND EXISTS (SELECT 1 FROM relationships r WHERE r.contact_id = c.id)
      ORDER BY c.relationship_score DESC, c.first_name ASC
      LIMIT ?
      ''',
      [limit],
    );
    return rows.map(_preDialMatch).toList();
  }

  /// Stars or unstars a contact (drives the dialer's Favorites list).
  Future<void> setFavorite(int contactId, bool value) async {
    final db = await _dbHelper.database;
    await db.update(
      'contacts',
      {'is_favorite': value ? 1 : 0},
      where: 'id = ?',
      whereArgs: [contactId],
    );
  }

  /// The Telecom `phoneAccountId` of the SIM this contact prefers, or null when
  /// it has no preference (or the contact no longer exists).
  ///
  /// A single-column read rather than a full hydrate, because it runs on the
  /// call path every time a call is placed from a screen that knows the contact.
  Future<String?> preferredSimId(int contactId) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'contacts',
      columns: ['preferred_sim_id'],
      where: 'id = ?',
      whereArgs: [contactId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final id = rows.first['preferred_sim_id'] as String?;
    return (id == null || id.isEmpty) ? null : id;
  }

  /// Sets (or clears, with a null [phoneAccountId]) this contact's preferred
  /// SIM without touching the rest of the record — used by the contact editor's
  /// SIM section.
  Future<void> setPreferredSim(
    int contactId,
    String? phoneAccountId,
    String? label,
  ) async {
    final db = await _dbHelper.database;
    await db.update(
      'contacts',
      {'preferred_sim_id': phoneAccountId, 'preferred_sim_label': label},
      where: 'id = ?',
      whereArgs: [contactId],
    );
  }

  /// Romanized search key of the contact's full name (see [searchKey]) —
  /// stored in `contacts.name_translit` so an English-script query can match
  /// a Malayalam-script name. Kept current on every insert/update.
  String _nameSearchKey(Contact contact) {
    return searchKey(_fullNameOf(contact));
  }

  /// The contact's name parts as one string, in the same order
  /// [DatabaseHelper.contactSearchName] uses — both keys below must be built
  /// from identical text or the staleness check flags every row forever.
  String _fullNameOf(Contact contact) => [
    contact.salutation,
    contact.firstName,
    contact.middleName,
    contact.lastName,
    contact.formalName,
  ].whereType<String>().where((s) => s.isNotEmpty).join(' ');

  /// Sound-only search key of the contact's full name (see [phoneticCode]) —
  /// stored in `contacts.name_phonetic` so a query typed in English matches a
  /// Malayalam-spelled name even when the two disagree about vowels
  /// (`Michael` / മൈക്കിൾ). Kept current on every insert/update.
  String _namePhonetic(Contact contact) => phoneticCode(_fullNameOf(contact));

  /// Inserts a contact and its children. [source] says who is doing it — it is
  /// recorded in the audit log so the history distinguishes a hand edit from a
  /// device sync or a restore.
  Future<int> insertContact(
    Contact contact, {
    AuditSource source = AuditSource.manual,
  }) async {
    final db = await _dbHelper.database;

    final contactId = await db.transaction((txn) async {
      // Insert contact
      contact.createdAt = DateTime.now();
      contact.updatedAt = DateTime.now();
      final contactMap = contact.toMap()..remove('id');
      contactMap['name_translit'] = _nameSearchKey(contact);
      contactMap['name_phonetic'] = _namePhonetic(contact);
      contactMap['sort_first'] = sortRoman(contact.firstName);
      contactMap['sort_last'] = sortRoman(contact.lastName ?? '');
      contactMap['needs_sync'] = contact.isSecret ? 0 : 1;
      final int contactId = await txn.insert('contacts', contactMap);

      // "Self" is a singleton — clear the flag on any previous Self record.
      if (contact.isSelf) await _clearOtherSelf(txn, contactId);

      await _insertChildren(txn, contactId, contact);
      await AuditRepository.record(
        txn,
        contactId: contactId,
        action: AuditAction.create,
        source: source,
        after: await AuditRepository.capture(txn, contactId),
        summary: 'Contact added',
      );
      return contactId;
    });
    await relinkCallLogs(contactId, contact.phoneNumbers);
    pushRingtoneMirror();
    return contactId;
  }

  /// Back-fills `call_logs.contact_id` for unlinked rows whose number matches
  /// one of [phoneNumbers]. `call_logs.contact_id` is normally set once, at the
  /// moment a call is logged, by matching against contacts that exist *then*
  /// ([CallEventLogger._resolveContactId]). Without this, a call from a number
  /// that had no contact yet stays showing the raw number in Recents forever,
  /// even after a matching contact is added later. Uses the same trailing-digit
  /// prefilter + [PhoneNormalizer.sameNumber] confirmation as [findByFullNumber]
  /// so the match logic stays consistent across the app.
  Future<void> relinkCallLogs(
    int contactId,
    List<PhoneNumber> phoneNumbers, {
    String? defaultIso,
  }) async {
    if (phoneNumbers.isEmpty) return;
    final iso = defaultIso ?? await AppSettings.readDefaultCountryIso();
    final db = await _dbHelper.database;

    final idsToLink = <int>{};
    for (final p in phoneNumbers) {
      final digits = normalizeDigits(p.number);
      if (digits.isEmpty) continue;
      final tail = digits.length > _mirrorMatchDigits
          ? digits.substring(digits.length - _mirrorMatchDigits)
          : digits;

      final rows = await db.rawQuery(
        '''
        SELECT id, phone_number FROM call_logs
        WHERE contact_id IS NULL
          AND REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                phone_number, ' ', ''), '-', ''), '(', ''), ')', ''), '+', ''), '.', '')
              LIKE ?
        ''',
        ['%$tail%'],
      );
      for (final r in rows) {
        final stored = r['phone_number'] as String?;
        if (stored == null) continue;
        if (PhoneNormalizer.sameNumber(stored, p.number, defaultIso: iso)) {
          idsToLink.add(r['id'] as int);
        }
      }
    }
    if (idsToLink.isEmpty) return;

    final placeholders = List.filled(idsToLink.length, '?').join(',');
    await db.rawUpdate(
      'UPDATE call_logs SET contact_id = ? WHERE id IN ($placeholders)',
      [contactId, ...idsToLink],
    );
  }

  /// Updates an existing contact and replaces its child rows. Requires
  /// [contact.id] to be set. Returns the number of contact rows updated (0/1).
  /// [source] is recorded in the audit log (see [insertContact]).
  Future<int> updateContact(
    Contact contact, {
    AuditSource source = AuditSource.manual,
  }) async {
    final id = contact.id;
    if (id == null) {
      throw ArgumentError('updateContact requires contact.id to be set');
    }
    final db = await _dbHelper.database;

    final updated = await db.transaction((txn) async {
      // Snapshot BEFORE anything is touched — this is what an undo writes back.
      final before = await AuditRepository.capture(txn, id);
      contact.updatedAt = DateTime.now();
      final map = contact.toMap()
        ..remove('id')
        ..remove('created_at'); // preserve original creation time
      map['name_translit'] = _nameSearchKey(contact);
      map['name_phonetic'] = _namePhonetic(contact);
      map['sort_first'] = sortRoman(contact.firstName);
      map['sort_last'] = sortRoman(contact.lastName ?? '');
      map['needs_sync'] = contact.isSecret ? 0 : 1;
      final count = await txn.update(
        'contacts',
        map,
        where: 'id = ?',
        whereArgs: [id],
      );

      // "Self" is a singleton — clear the flag on any previous Self record.
      if (contact.isSelf) await _clearOtherSelf(txn, id);

      // A secret contact must not hold a speed-dial key: the key would show its
      // name on the keypad and dial it with no unlock. Freeing the slot here
      // covers a contact that was assigned first and made secret afterwards.
      if (contact.isSecret) {
        await txn.delete('speed_dial', where: 'contact_id = ?', whereArgs: [id]);
      }

      // Replace children wholesale (simpler and correct for an edit form).
      for (final table in const [
        'phone_numbers',
        'emails',
        'addresses',
        'official_details',
        'social_links',
        'tags',
        'contact_groups',
      ]) {
        await txn.delete(table, where: 'contact_id = ?', whereArgs: [id]);
      }
      await _insertChildren(txn, id, contact);
      if (count > 0) {
        await AuditRepository.record(
          txn,
          contactId: id,
          action: AuditAction.update,
          source: source,
          before: before,
          after: await AuditRepository.capture(txn, id),
        );
      }
      return count;
    });
    await relinkCallLogs(id, contact.phoneNumbers);
    pushRingtoneMirror();
    return updated;
  }

  /// Deletes a contact (children cascade). [source] is recorded in the audit
  /// log, together with a full snapshot so the delete can be undone.
  Future<void> deleteContact(
    int id, {
    AuditSource source = AuditSource.manual,
  }) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      final before = await AuditRepository.capture(txn, id);
      if (before == null) return; // nothing there; nothing to log

      // Record tombstone deletion if sync metadata exists
      final rows = await txn.query(
        'contacts',
        columns: ['remote_sync_id', 'sync_provider'],
        where: 'id = ?',
        whereArgs: [id],
      );
      if (rows.isNotEmpty) {
        final remoteId = rows.first['remote_sync_id'] as String?;
        final provider = rows.first['sync_provider'] as String?;
        if (remoteId != null && remoteId.isNotEmpty && provider != null && provider.isNotEmpty) {
          await txn.insert('pending_remote_deletions', {
            'remote_sync_id': remoteId,
            'sync_provider': provider,
            'deleted_at': DateTime.now().toIso8601String(),
          });
        }
      }

      // With foreign_keys ON, child rows cascade automatically.
      await txn.delete('contacts', where: 'id = ?', whereArgs: [id]);
      await AuditRepository.record(
        txn,
        contactId: id,
        action: AuditAction.delete,
        source: source,
        before: before,
        summary: 'Contact deleted',
      );
    });
    pushRingtoneMirror();
  }

  /// Reverses one audit entry and records the reversal as its own entry (source
  /// [AuditSource.undo]), so the log never hides how the data got back.
  ///
  /// * a **create** is undone by deleting the contact again;
  /// * an **edit** by writing the "before" snapshot back over the same contact;
  /// * a **delete** by re-creating the contact from the snapshot. That contact
  ///   gets a **new id**: old call-log rows stay unlinked (the delete cleared
  ///   their link), and only relationships whose other person still exists are
  ///   restored.
  ///
  /// Returns the id of the contact the data now lives on, or null when the undo
  /// removed the contact. Throws [StateError] when the entry cannot be undone
  /// (no snapshot, or the contact it targets is already gone).
  Future<int?> undoAudit(AuditEntry entry) async {
    final db = await _dbHelper.database;

    switch (entry.action) {
      case AuditAction.create:
        final id = entry.contactId;
        if (id == null) throw StateError('This entry has no contact to remove.');
        final existing = await db.query(
          'contacts',
          columns: ['id'],
          where: 'id = ?',
          whereArgs: [id],
          limit: 1,
        );
        if (existing.isEmpty) {
          throw StateError('That contact has already been deleted.');
        }
        await deleteContact(id, source: AuditSource.undo);
        return null;

      case AuditAction.update:
        final snapshot = entry.before;
        final id = entry.contactId;
        if (snapshot == null || id == null) {
          throw StateError('This entry has no earlier version to restore.');
        }
        final restored = await db.transaction((txn) async {
          final existing = await txn.query(
            'contacts',
            columns: ['id'],
            where: 'id = ?',
            whereArgs: [id],
            limit: 1,
          );
          if (existing.isEmpty) {
            throw StateError(
              'That contact no longer exists. Undo the delete first.',
            );
          }
          final before = await AuditRepository.capture(txn, id);
          await txn.update(
            'contacts',
            snapshot.contact,
            where: 'id = ?',
            whereArgs: [id],
          );
          if (snapshot.contact['is_self'] == 1) {
            await _clearOtherSelf(txn, id);
          }
          for (final table in ContactSnapshot.childTables) {
            await txn.delete(table, where: 'contact_id = ?', whereArgs: [id]);
          }
          await txn.delete(
            'contact_groups',
            where: 'contact_id = ?',
            whereArgs: [id],
          );
          await _writeSnapshot(txn, id, snapshot);
          await AuditRepository.record(
            txn,
            contactId: id,
            action: AuditAction.update,
            source: AuditSource.undo,
            before: before,
            after: await AuditRepository.capture(txn, id),
          );
          return id;
        });
        pushRingtoneMirror();
        return restored;

      case AuditAction.delete:
        final snapshot = entry.before;
        if (snapshot == null) {
          throw StateError('This entry has no saved copy to restore.');
        }
        final newId = await db.transaction((txn) async {
          final row = Map<String, Object?>.from(snapshot.contact)
            ..remove('id')
            ..['updated_at'] = DateTime.now().toIso8601String();
          final id = await txn.insert('contacts', row);
          if (row['is_self'] == 1) await _clearOtherSelf(txn, id);
          await _writeSnapshot(txn, id, snapshot, previousId: entry.contactId);
          await AuditRepository.record(
            txn,
            contactId: id,
            action: AuditAction.create,
            source: AuditSource.undo,
            after: await AuditRepository.capture(txn, id),
            summary: 'Deleted contact restored',
          );
          return id;
        });
        pushRingtoneMirror();
        return newId;
    }
  }

  /// Writes a snapshot's child rows, group memberships and (when [previousId]
  /// is given) relationships onto [contactId]. The caller has already cleared
  /// whatever was there.
  ///
  /// [previousId] is the id the snapshotted contact had when it was captured;
  /// it identifies which side of each stored relationship row was "this"
  /// contact, so the row can be re-pointed at the new id. Relationships are
  /// restored only where the other person still exists — a link to someone who
  /// has since been deleted cannot be rebuilt.
  Future<void> _writeSnapshot(
    DatabaseExecutor txn,
    int contactId,
    ContactSnapshot snapshot, {
    int? previousId,
  }) async {
    for (final table in ContactSnapshot.childTables) {
      for (final row in snapshot.children[table] ?? const []) {
        await txn.insert(table, {
          ...row,
          'contact_id': contactId,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    }
    await _insertGroupMemberships(txn, contactId, snapshot.groups);

    final oldId = previousId;
    if (oldId == null) return;
    for (final row in snapshot.relationships) {
      final from = row['contact_id'] as int?;
      final to = row['related_contact_id'] as int?;
      if (from == null || to == null) continue;
      final otherId = from == oldId ? to : from;
      if (otherId == oldId) continue; // self-referential; nothing to rebuild
      final other = await txn.query(
        'contacts',
        columns: ['id'],
        where: 'id = ?',
        whereArgs: [otherId],
        limit: 1,
      );
      if (other.isEmpty) continue; // the other person is gone
      await txn.insert('relationships', {
        'contact_id': from == oldId ? contactId : otherId,
        'related_contact_id': from == oldId ? otherId : contactId,
        'relationship_type': row['relationship_type'],
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  /// Trailing digits used to key the native mirrors (contact tones + names). Must
  /// stay in step with the native lookup (IncomingCallRinger.MATCH_DIGITS) and the
  /// [findByFullNumber] SQL prefilter slice so all three match the same way. Set to
  /// 10 — India's fixed 10-digit mobile plan — so distinct numbers that share a
  /// shorter suffix (e.g. 9000123456 and 9111123456 both end 0123456) don't
  /// collide, while a leading +91 / 0 is still absorbed.
  static const int _mirrorMatchDigits = 10;

  /// The contact side of the native ringtone mirror: one entry per phone number
  /// of every contact with an *effective* ringtone — their own tone, else the
  /// tone of their first toned group (name ASC, then id ASC; the same pick as
  /// [GroupRepository.groupRingtoneForContact]). Keyed by the number's trailing
  /// [_mirrorMatchDigits] digits (whole digit string when shorter), mapping to
  /// the tone path/URI. On a (rare) trailing-digit collision the later row wins;
  /// the in-call flow's exact lookup still corrects the tone late if needed.
  Future<Map<String, String>> ringtoneMirrorEntries() async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery('''
      SELECT number, tone FROM (
        SELECT p.number AS number, c.id AS cid,
               CASE WHEN c.ringtone_path IS NOT NULL AND TRIM(c.ringtone_path) != ''
                    THEN c.ringtone_path
                    ELSE (SELECT g.ringtone_path
                          FROM contact_groups cg
                          JOIN groups g ON g.id = cg.group_id
                          WHERE cg.contact_id = c.id
                            AND g.ringtone_path IS NOT NULL
                            AND TRIM(g.ringtone_path) != ''
                          ORDER BY g.name ASC, g.id ASC
                          LIMIT 1)
               END AS tone
        FROM phone_numbers p
        JOIN contacts c ON c.id = p.contact_id
        WHERE c.is_secret = 0
      )
      WHERE tone IS NOT NULL AND TRIM(tone) != ''
      ORDER BY cid ASC
      ''');
    final out = <String, String>{};
    for (final r in rows) {
      final digits = normalizeDigits((r['number'] as String?) ?? '');
      if (digits.isEmpty) continue;
      final key = digits.length > _mirrorMatchDigits
          ? digits.substring(digits.length - _mirrorMatchDigits)
          : digits;
      out[key] = r['tone'] as String;
    }
    return out;
  }

  /// Builds the digit→name map the native side reads to title a missed-call
  /// notification when the app (and its DB) isn't running. Covers **every**
  /// contact with a number (unlike [ringtoneMirrorEntries], which is sparse), so a
  /// missed call from any saved contact shows a name. The name is composed like
  /// [Contact.fullName] (salutation + first + middle + last). Keyed by the number's
  /// trailing [_mirrorMatchDigits] digits (whole digit string when shorter). On a
  /// (rare, with a 10-digit key) trailing-digit collision the later row wins.
  Future<Map<String, String>> contactNameMirrorEntries() async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery('''
      SELECT p.number AS number, c.id AS cid,
             c.salutation AS salutation, c.first_name AS first_name,
             c.middle_name AS middle_name, c.last_name AS last_name
      FROM phone_numbers p
      JOIN contacts c ON c.id = p.contact_id
      WHERE c.is_secret = 0
      ORDER BY c.id ASC
      ''');
    final out = <String, String>{};
    for (final r in rows) {
      final digits = normalizeDigits((r['number'] as String?) ?? '');
      if (digits.isEmpty) continue;
      final name =
          [
                r['salutation'] as String?,
                r['first_name'] as String?,
                r['middle_name'] as String?,
                r['last_name'] as String?,
              ]
              .where((e) => e != null && e.trim().isNotEmpty)
              .map((e) => e!.trim())
              .join(' ');
      if (name.isEmpty) continue;
      final key = digits.length > _mirrorMatchDigits
          ? digits.substring(digits.length - _mirrorMatchDigits)
          : digits;
      out[key] = name;
    }
    return out;
  }

  /// Debounce for [pushRingtoneMirror], static so writes from any repository
  /// instance coalesce (screens construct their own `ContactRepository()`).
  /// A device-contacts sync updates hundreds of contacts in a loop; without
  /// this each write would rebuild and re-push the whole map.
  static Timer? _mirrorPushTimer;

  /// Schedules a rebuild + push of the contact-tone map to the native ringtone
  /// mirror so an incoming call rings the caller's own tone from the first note
  /// (see [TelecomService.setRingtoneMirror]). Called after every contact write;
  /// debounced so a burst of writes (device sync) pushes once, shortly after the
  /// last write. Best-effort: on failure the ringer falls back to the default
  /// tone and the in-call flow's late push still corrects it.
  void pushRingtoneMirror() {
    _mirrorPushTimer?.cancel();
    _mirrorPushTimer = Timer(const Duration(seconds: 1), () {
      _mirrorPushTimer = null;
      unawaited(_pushRingtoneMirrorNow());
    });
  }

  Future<void> _pushRingtoneMirrorNow() async {
    try {
      // Push tones and names together — same debounce, same triggers, same native
      // prefs file — so native can ring the right tone and title a missed-call
      // notification with the contact's name, both before the Flutter engine is up.
      final tones = await ringtoneMirrorEntries();
      final names = await contactNameMirrorEntries();
      await TelecomService().setRingtoneMirror(
        contactTones: tones,
        contactNames: names,
      );
    } catch (_) {
      // Best-effort; see pushRingtoneMirror.
    }
  }

  /// Clears `is_self` on every contact except [exceptId] — the singleton
  /// invariant for the "Self" record. Runs inside the caller's transaction.
  Future<void> _clearOtherSelf(DatabaseExecutor txn, int exceptId) async {
    await txn.update(
      'contacts',
      {'is_self': 0},
      where: 'is_self = 1 AND id != ?',
      whereArgs: [exceptId],
    );
  }

  /// The "Self" contact (the phone owner) as a slim summary for the list, or
  /// null when none has been set. Mirrors [getContactSummaries]' projection.
  Future<Contact?> getSelfSummary() async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery(
      '$_summarySelect WHERE c.is_self = 1 LIMIT 1',
    );
    if (rows.isEmpty) return null;
    return _summaryFromRow(rows.first);
  }

  /// The fully hydrated "Self" contact, or null when none has been set.
  Future<Contact?> getSelfContact() async {
    final db = await _dbHelper.database;
    final maps = await db.query('contacts', where: 'is_self = 1', limit: 1);
    if (maps.isEmpty) return null;
    return _hydrate(Contact.fromMap(maps.first));
  }

  Future<void> _insertChildren(
    DatabaseExecutor txn,
    int contactId,
    Contact contact,
  ) async {
    for (var phone in contact.phoneNumbers) {
      phone.contactId = contactId;
      await txn.insert('phone_numbers', phone.toMap()..remove('id'));
    }
    for (var email in contact.emails) {
      email.contactId = contactId;
      await txn.insert('emails', email.toMap()..remove('id'));
    }
    for (var address in contact.addresses) {
      address.contactId = contactId;
      await txn.insert('addresses', address.toMap()..remove('id'));
    }
    for (var social in contact.socialLinks) {
      social.contactId = contactId;
      await txn.insert('social_links', social.toMap()..remove('id'));
    }
    if (contact.officialDetails != null && !contact.officialDetails!.isEmpty) {
      contact.officialDetails!.contactId = contactId;
      await txn.insert(
        'official_details',
        contact.officialDetails!.toMap()..remove('id'),
      );
    }
    await _insertTags(txn, contactId, contact.tags);
    await _insertGroupMemberships(txn, contactId, contact.groups);
  }

  /// Inserts free-text tags for a contact, de-duplicated and trimmed.
  Future<void> _insertTags(
    DatabaseExecutor txn,
    int contactId,
    List<String> tags,
  ) async {
    final seen = <String>{};
    for (final raw in tags) {
      final name = raw.trim();
      if (name.isEmpty || !seen.add(name)) continue;
      await txn.insert('tags', {'contact_id': contactId, 'name': name});
    }
  }

  /// Links a contact to the named groups, creating any group that doesn't yet
  /// exist (group names are UNIQUE).
  Future<void> _insertGroupMemberships(
    DatabaseExecutor txn,
    int contactId,
    List<String> groupNames,
  ) async {
    final seen = <String>{};
    for (final raw in groupNames) {
      final name = raw.trim();
      if (name.isEmpty || !seen.add(name)) continue;

      final existing = await txn.query(
        'groups',
        columns: ['id'],
        where: 'name = ?',
        whereArgs: [name],
        limit: 1,
      );
      final int groupId = existing.isNotEmpty
          ? existing.first['id'] as int
          : await txn.insert('groups', {'name': name});

      await txn.insert('contact_groups', {
        'contact_id': contactId,
        'group_id': groupId,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  Future<Contact?> getContactById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return _hydrate(Contact.fromMap(maps.first));
  }

  /// Looks up the app contact linked to a device address-book entry, or null if
  /// none is linked. Used by the device→app sync to upsert (update vs insert)
  /// and by the merged read to de-duplicate a contact that exists in both
  /// sources. Returns the fully hydrated aggregate.
  Future<Contact?> getContactByDeviceId(String deviceId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'contacts',
      where: 'device_id = ?',
      whereArgs: [deviceId],
      limit: 1,
    );
    if (maps.isNotEmpty) return _hydrate(Contact.fromMap(maps.first));

    // Not a primary link — it may be a device contact previously absorbed into
    // another contact by the auto-merge dedup. Resolve via merged_device_ids so
    // such entries are recognised and updated in place, never re-imported.
    final merged = await db.rawQuery(
      '''
      SELECT c.* FROM contacts c
      JOIN merged_device_ids m ON m.contact_id = c.id
      WHERE m.device_id = ?
      LIMIT 1
      ''',
      [deviceId],
    );
    if (merged.isEmpty) return null;
    return _hydrate(Contact.fromMap(merged.first));
  }

  /// The id of an existing contact that owns a phone number whose digits match
  /// [number]'s digits, or null if none — the signal the auto-merge-on-import
  /// dedup uses to fold a duplicate device contact into an existing row instead
  /// of inserting a new one. [excludeId] skips a contact (e.g. the row just
  /// inserted). An empty/blank number never matches.
  Future<int?> findContactIdByNormalizedPhone(
    String number, {
    int? excludeId,
  }) async {
    final digits = normalizeDigits(number);
    if (digits.isEmpty) return null;

    final db = await _dbHelper.database;
    final rows = await db.rawQuery('''
      SELECT p.contact_id AS contact_id
      FROM phone_numbers p
      WHERE REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
              p.number, ' ', ''), '-', ''), '(', ''), ')', ''), '+', ''), '.', '')
            = ?
        ${excludeId != null ? 'AND p.contact_id != ?' : ''}
      ORDER BY p.contact_id ASC
      LIMIT 1
      ''', excludeId != null ? [digits, excludeId] : [digits]);
    if (rows.isEmpty) return null;
    return rows.first['contact_id'] as int?;
  }

  /// Records that [deviceId] now resolves to [contactId] (an absorbed duplicate),
  /// so future syncs update that contact instead of re-importing the duplicate.
  /// [confirmed] marks a link recognised via a user-confirmed merge (matched by
  /// phone number, see [confirmedMergePhones]) rather than the automatic
  /// name+phone import-time dedup — the sync's name-based healing must never
  /// re-split a confirmed link.
  Future<void> recordMergedDeviceId(
    int contactId,
    String deviceId, {
    bool confirmed = false,
  }) async {
    final db = await _dbHelper.database;
    await db.insert('merged_device_ids', {
      'device_id': deviceId,
      'contact_id': contactId,
      // Automatic import-time absorption: name-based healing still applies, so a
      // wrongly merged different-person self-corrects on a later sync.
      'user_confirmed': confirmed ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Total number of contacts (respecting the secret filter), for paging.
  Future<int> countContacts({
    bool includeSecret = false,
    bool requirePhone = false,
  }) async {
    final db = await _dbHelper.database;
    // Self is excluded to stay consistent with [getContactSummaries] (which
    // pins it separately), keeping offset paging correct. When [requirePhone]
    // is set the count must match the same filter the list applies, so paging
    // (offset/total) stays in step with the hidden-numberless rows.
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS n FROM contacts'
      ' WHERE is_self = 0${includeSecret ? '' : ' AND is_secret = 0'}'
      '${requirePhone ? ' AND EXISTS (SELECT 1 FROM phone_numbers p'
                ' WHERE p.contact_id = contacts.id)' : ''}',
    );
    return Sqflite.firstIntValue(rows) ?? 0;
  }

  /// Mean relationship score across all contacts (respecting the secret filter),
  /// for the list's health hero — exact even when the list is paged. Returns 0
  /// when there are no contacts.
  Future<double> averageRelationshipScore({bool includeSecret = false}) async {
    final db = await _dbHelper.database;
    // Self's score is meaningless as your own record — exclude it.
    final rows = await db.rawQuery(
      'SELECT AVG(relationship_score) AS avg FROM contacts'
      ' WHERE is_self = 0${includeSecret ? '' : ' AND is_secret = 0'}',
    );
    final v = rows.first['avg'];
    return v is num ? v.toDouble() : 0.0;
  }

  /// Slim projection for the contact list: only what a card renders — name
  /// parts, photo path, score, device link, the primary phone, and the first
  /// group — via correlated subqueries, skipping the full child-table hydration
  /// [getAllContacts] does. `WHERE`/`LIMIT` are appended by callers.
  static const String _summarySelect = '''
    SELECT c.id, c.salutation, c.first_name, c.middle_name, c.last_name,
           c.photo_path, c.relationship_score, c.device_id, c.is_self,
           c.is_favorite,
           (SELECT p.number FROM phone_numbers p
              WHERE p.contact_id = c.id
              ORDER BY p.is_primary DESC, p.id ASC LIMIT 1) AS primary_number,
           (SELECT e.email FROM emails e
              WHERE e.contact_id = c.id
              ORDER BY e.is_primary DESC, e.id ASC LIMIT 1) AS primary_email,
           (SELECT g.name FROM contact_groups cg
              JOIN groups g ON g.id = cg.group_id
              WHERE cg.contact_id = c.id
              ORDER BY g.name ASC LIMIT 1) AS first_group
    FROM contacts c
  ''';

  Contact _summaryFromRow(Map<String, dynamic> r) {
    final contact = Contact.fromMap(r);
    final number = r['primary_number'] as String?;
    if (number != null && number.isNotEmpty) {
      contact.phoneNumbers = [PhoneNumber(number: number, type: 'personal')];
    }
    final email = r['primary_email'] as String?;
    if (email != null && email.isNotEmpty) {
      contact.emails = [Email(email: email, type: 'personal', isPrimary: true)];
    }
    final group = r['first_group'] as String?;
    if (group != null && group.isNotEmpty) {
      contact.groups = [group];
    }
    return contact;
  }

  /// A lightweight, paged read for the contact list. Detail views still load the
  /// complete aggregate with [getContactById].
  Future<List<Contact>> getContactSummaries({
    bool includeSecret = false,
    bool favoritesOnly = false,
    bool sortByLastName = false,
    bool requirePhone = false,
    int? limit,
    int offset = 0,
  }) async {
    final db = await _dbHelper.database;
    // Order by the romanized sort keys (sort_first/sort_last) so Malayalam and
    // English names interleave in one A–Z order — SQLite NOCASE only folds
    // ASCII, so raw Malayalam names would clump after 'z' by code point. NOCASE
    // still normalizes case within the ASCII keys, and the id tiebreaker keeps
    // LIMIT/OFFSET paging stable when the leading key repeats. When sorting by
    // last name we fall back to first name for contacts that share (or lack) one.
    final orderBy = sortByLastName
        ? 'c.sort_last COLLATE NOCASE ASC, c.sort_first COLLATE NOCASE ASC,'
              ' c.id ASC'
        : 'c.sort_first COLLATE NOCASE ASC, c.id ASC';
    // Self is excluded here — it's fetched via [getSelfSummary] and pinned to
    // the top of the list separately, so it never counts against paging.
    final rows = await db.rawQuery(
      '$_summarySelect'
      ' WHERE c.is_self = 0${includeSecret ? '' : ' AND c.is_secret = 0'}'
      '${favoritesOnly ? ' AND c.is_favorite = 1' : ''}'
      '${requirePhone ? ' AND EXISTS (SELECT 1 FROM phone_numbers p'
                ' WHERE p.contact_id = c.id)' : ''}'
      ' ORDER BY $orderBy'
      '${limit != null ? ' LIMIT ? OFFSET ?' : ''}',
      limit != null ? [limit, offset] : const [],
    );
    return rows.map(_summaryFromRow).toList();
  }

  /// Per-section contact counts for the list's letter headers, e.g.
  /// `{'A': 12, 'B': 5, '#': 3}`. Uses the same filters as [getContactSummaries]
  /// so the totals match the list, and keys off the same romanized sort key, so
  /// the buckets line up with [sectionLetterFor]. Cheap (one grouped COUNT), so
  /// it stays accurate even though the list itself loads page by page. Names
  /// whose romanized initial is not `A`–`Z` (digits, symbols, empty) fold into
  /// the `#` bucket.
  Future<Map<String, int>> getSectionCounts({
    bool includeSecret = false,
    bool favoritesOnly = false,
    bool sortByLastName = false,
    bool requirePhone = false,
  }) async {
    final db = await _dbHelper.database;
    final key = sortByLastName ? 'c.sort_last' : 'c.sort_first';
    final rows = await db.rawQuery(
      'SELECT UPPER(SUBSTR($key, 1, 1)) AS letter, COUNT(*) AS n'
      ' FROM contacts c'
      ' WHERE c.is_self = 0${includeSecret ? '' : ' AND c.is_secret = 0'}'
      '${favoritesOnly ? ' AND c.is_favorite = 1' : ''}'
      '${requirePhone ? ' AND EXISTS (SELECT 1 FROM phone_numbers p'
                ' WHERE p.contact_id = c.id)' : ''}'
      ' GROUP BY letter',
    );
    final counts = <String, int>{};
    for (final r in rows) {
      final raw = (r['letter'] as String?) ?? '';
      final n = (r['n'] as int?) ?? 0;
      final bucket = _isAsciiLetter(raw) ? raw : '#';
      counts[bucket] = (counts[bucket] ?? 0) + n;
    }
    return counts;
  }

  static bool _isAsciiLetter(String s) {
    if (s.length != 1) return false;
    final c = s.codeUnitAt(0);
    return c >= 0x41 && c <= 0x5A; // 'A'..'Z'
  }

  /// Slim search across name, any phone, and any email — DB-backed so it matches
  /// the whole address book (not just the pages currently loaded into the list).
  /// A blank query returns nothing (the caller shows the paged list instead).
  Future<List<Contact>> searchContactSummaries(
    String query, {
    bool includeSecret = false,
    bool favoritesOnly = false,
  }) async {
    final q = query.trim();
    if (q.isEmpty) return const <Contact>[];

    final db = await _dbHelper.database;
    final like = '%${q.toLowerCase()}%';
    final digits = normalizeDigits(q);
    final key = searchKey(q);
    final useTranslit = key.isNotEmpty;
    final code = phoneticCode(q);
    final usePhonetic = code.length >= phoneticCodeMinLen;
    final rows = await db.rawQuery(
      '''
      $_summarySelect
      WHERE ${includeSecret ? '' : 'c.is_secret = 0 AND'}
            ${favoritesOnly ? 'c.is_favorite = 1 AND' : ''} (
        LOWER(TRIM(
          COALESCE(c.salutation || ' ', '') || COALESCE(c.first_name, '') ||
          COALESCE(' ' || c.middle_name, '') || COALESCE(' ' || c.last_name, '')
        )) LIKE ?
        OR EXISTS (
          SELECT 1 FROM phone_numbers p WHERE p.contact_id = c.id AND
            REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
              p.number, ' ', ''), '-', ''), '(', ''), ')', ''), '+', ''), '.', '')
            LIKE ?
        )
        OR EXISTS (
          SELECT 1 FROM emails e
          WHERE e.contact_id = c.id AND LOWER(e.email) LIKE ?
        )
        OR EXISTS (
          SELECT 1 FROM tags t
          WHERE t.contact_id = c.id AND LOWER(t.name) LIKE ?
        )
        OR LOWER(COALESCE(c.formal_name, '')) LIKE ?
        ${useTranslit ? "OR c.name_translit LIKE ? OR c.name_translit LIKE ?" : ''}
        ${usePhonetic ? "OR c.name_phonetic LIKE ? OR c.name_phonetic LIKE ?" : ''}
      )
      ORDER BY c.is_self DESC, c.sort_first COLLATE NOCASE ASC, c.id ASC
      ''',
      [
        like,
        digits.isEmpty ? ' ' : '%$digits%',
        like,
        like,
        like,
        if (useTranslit) ...['$key%', '% $key%'],
        if (usePhonetic) ...['$code%', '% $code%'],
      ],
    );
    return rows.map(_summaryFromRow).toList();
  }

  /// Every distinct tag with the number of contacts using it, for the Tag Cloud
  /// screen. Respects the secret filter — a tag used only by secret contacts is
  /// hidden unless [includeSecret] is set (and its count excludes secret owners
  /// otherwise). Ordered by count desc, then name, so the busiest tags lead.
  Future<List<TagCount>> getTagCounts({bool includeSecret = false}) async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery('''
      SELECT t.name AS name, COUNT(DISTINCT t.contact_id) AS n
      FROM tags t
      JOIN contacts c ON c.id = t.contact_id
      WHERE TRIM(t.name) != ''${includeSecret ? '' : ' AND c.is_secret = 0'}
      GROUP BY t.name
      ORDER BY n DESC, t.name COLLATE NOCASE ASC
      ''');
    return rows
        .map(
          (r) =>
              TagCount(name: r['name'] as String, count: (r['n'] as int?) ?? 0),
        )
        .toList();
  }

  /// Every distinct, non-blank tag name across all contacts, ordered
  /// case-insensitively. Not secret-filtered: tag names are free-form and used
  /// only as autocomplete suggestions when editing a contact.
  Future<List<String>> getDistinctTagNames() async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery('''
      SELECT DISTINCT name
      FROM tags
      WHERE TRIM(name) != ''
      ORDER BY name COLLATE NOCASE ASC
      ''');
    return rows.map((r) => r['name'] as String).toList();
  }

  /// Slim summaries of the contacts carrying an exact [tag] (case-insensitive),
  /// for the per-tag list opened from the Tag Cloud. Ordered like the main list.
  /// Respects the secret filter. A blank tag returns nothing.
  Future<List<Contact>> getContactSummariesByTag(
    String tag, {
    bool includeSecret = false,
  }) async {
    final name = tag.trim();
    if (name.isEmpty) return const <Contact>[];

    final db = await _dbHelper.database;
    final rows = await db.rawQuery(
      '$_summarySelect'
      ' WHERE c.is_self = 0${includeSecret ? '' : ' AND c.is_secret = 0'}'
      ' AND EXISTS (SELECT 1 FROM tags t WHERE t.contact_id = c.id'
      ' AND LOWER(t.name) = LOWER(?))'
      ' ORDER BY c.sort_first COLLATE NOCASE ASC, c.id ASC',
      [name],
    );
    return rows.map(_summaryFromRow).toList();
  }

  /// Cap on returned suggestions, so a 200-person employer cannot bury the
  /// picker's own contact list under suggestion rows.
  static const int _maxAffiliationPeers = 50;

  /// Contacts who share a house or an employer with any of [seedContactIds] —
  /// the suggestion source for "add members to this group/tag".
  ///
  /// Matching happens in Dart, not SQL: folding "Infosys Ltd" and "INFOSYS" onto
  /// one key (see [companyAffiliationKey]) is past what SQLite can express, so
  /// the address rows are read and keyed here. Fine at this app's scale; if it
  /// ever isn't, the fix is a stored key column, which needs no API change.
  ///
  /// Seeds are excluded from the result. Peers are ordered house-matches first
  /// (a household is a stronger signal than a shared employer), then by name,
  /// and capped at [_maxAffiliationPeers].
  Future<List<AffiliationPeer>> getAffiliationPeers(
    Set<int> seedContactIds, {
    bool includeSecret = false,
  }) async {
    if (seedContactIds.isEmpty) return const <AffiliationPeer>[];

    final db = await _dbHelper.database;
    // Every address that could take part, with its owner's name for ordering.
    // Secret contacts stay out unless asked for, as everywhere else.
    final rows = await db.rawQuery('''
      SELECT a.contact_id AS contact_id, a.house_name AS house_name,
             a.company_name AS company_name, a.post_office AS post_office,
             a.city_town AS city_town, c.sort_first AS sort_first
      FROM addresses a
      JOIN contacts c ON c.id = a.contact_id
      WHERE c.is_self = 0${includeSecret ? '' : ' AND c.is_secret = 0'}
        AND (TRIM(COALESCE(a.house_name, '')) != ''
             OR TRIM(COALESCE(a.company_name, '')) != '')
      ''');

    // Keys the seeds carry, and the label to show for each.
    final seedKeys = <String, String>{};
    for (final r in rows) {
      final owner = r['contact_id'] as int?;
      if (owner == null || !seedContactIds.contains(owner)) continue;
      for (final entry in _keysForAddressRow(r).entries) {
        seedKeys.putIfAbsent(entry.key, () => entry.value);
      }
    }
    if (seedKeys.isEmpty) return const <AffiliationPeer>[];

    // Best match per candidate: a house match wins over a company one.
    final best = <int, AffiliationPeer>{};
    final sortNames = <int, String>{};
    for (final r in rows) {
      final owner = r['contact_id'] as int?;
      if (owner == null || seedContactIds.contains(owner)) continue;
      sortNames[owner] = (r['sort_first'] as String?) ?? '';
      for (final key in _keysForAddressRow(r).keys) {
        if (!seedKeys.containsKey(key)) continue;
        final kind = key.startsWith('house:')
            ? AffiliationKind.house
            : AffiliationKind.company;
        final existing = best[owner];
        if (existing != null && existing.kind == AffiliationKind.house) continue;
        best[owner] = AffiliationPeer(
          contactId: owner,
          kind: kind,
          // Label the value as the *seed* has it spelled, so every suggestion
          // in one session reads consistently.
          label: seedKeys[key]!,
        );
      }
    }

    final peers = best.values.toList()
      ..sort((a, b) {
        if (a.kind != b.kind) {
          return a.kind == AffiliationKind.house ? -1 : 1;
        }
        return (sortNames[a.contactId] ?? '').toLowerCase().compareTo(
          (sortNames[b.contactId] ?? '').toLowerCase(),
        );
      });
    return peers.length > _maxAffiliationPeers
        ? peers.sublist(0, _maxAffiliationPeers)
        : peers;
  }

  /// The affiliation keys one address row contributes, mapped to the raw text to
  /// display for each.
  Map<String, String> _keysForAddressRow(Map<String, dynamic> r) {
    final result = <String, String>{};
    final house = (r['house_name'] as String?)?.trim();
    final company = (r['company_name'] as String?)?.trim();
    final locality =
        (r['post_office'] as String?)?.trim().isNotEmpty == true
        ? r['post_office'] as String?
        : r['city_town'] as String?;

    final houseKey = houseAffiliationKey(house, locality: locality);
    if (houseKey != null && house != null) result[houseKey] = house;
    final companyKey = companyAffiliationKey(company);
    if (companyKey != null && company != null) result[companyKey] = company;
    return result;
  }

  /// Moves every contact carrying [from] onto the tag [to], matching [from]
  /// case-insensitively. Returns how many contacts were changed.
  ///
  /// This is both "rename" and "merge": if nothing else uses [to] the user sees
  /// a rename, and if something does they see a merge. One code path, so the two
  /// cannot drift apart. Because `tags` has no unique constraint, a contact that
  /// carried *both* names would end up with two identical rows — so duplicates
  /// are collapsed here rather than left for the reader to de-dup.
  Future<int> retagAll(String from, String to) async {
    final oldName = from.trim();
    final newName = to.trim();
    if (oldName.isEmpty || newName.isEmpty) return 0;
    if (oldName.toLowerCase() == newName.toLowerCase()) {
      // Pure case change ("family" → "Family"): rewrite in place, nothing to
      // merge, and skip the duplicate cleanup which would be a no-op.
      final db = await _dbHelper.database;
      return db.rawUpdate(
        'UPDATE tags SET name = ? WHERE LOWER(TRIM(name)) = LOWER(?)',
        [newName, oldName],
      );
    }

    final db = await _dbHelper.database;
    return db.transaction<int>((txn) async {
      // Contacts that already hold the target: for them the old row is dropped
      // instead of renamed, which is what keeps duplicates from appearing.
      final holders = await txn.rawQuery(
        'SELECT DISTINCT contact_id FROM tags'
        ' WHERE LOWER(TRIM(name)) = LOWER(?)',
        [newName],
      );
      final holderIds = holders
          .map((r) => r['contact_id'] as int?)
          .whereType<int>()
          .toSet();

      final moved = await txn.rawUpdate(
        'UPDATE tags SET name = ? WHERE LOWER(TRIM(name)) = LOWER(?)'
        '${holderIds.isEmpty ? '' : ' AND contact_id NOT IN (${holderIds.join(',')})'}',
        [newName, oldName],
      );
      final dropped = holderIds.isEmpty
          ? 0
          : await txn.rawDelete(
              'DELETE FROM tags WHERE LOWER(TRIM(name)) = LOWER(?)'
              ' AND contact_id IN (${holderIds.join(',')})',
              [oldName],
            );
      // Normalise the surviving rows' spelling too, so a pre-existing
      // "Family"/"family" split collapses to the one name just chosen.
      await txn.rawUpdate(
        'UPDATE tags SET name = ? WHERE LOWER(TRIM(name)) = LOWER(?)'
        ' AND name != ?',
        [newName, newName, newName],
      );
      return moved + dropped;
    });
  }

  /// Adds [tag] to each of [contactIds], skipping any contact that already
  /// carries it (case-insensitively). Returns how many rows were inserted.
  Future<int> addTagToContacts(String tag, Set<int> contactIds) async {
    final name = tag.trim();
    if (name.isEmpty || contactIds.isEmpty) return 0;

    final db = await _dbHelper.database;
    return db.transaction<int>((txn) async {
      final existing = await txn.rawQuery(
        'SELECT DISTINCT contact_id FROM tags'
        ' WHERE LOWER(TRIM(name)) = LOWER(?)'
        ' AND contact_id IN (${List.filled(contactIds.length, '?').join(',')})',
        [name, ...contactIds],
      );
      final already = existing
          .map((r) => r['contact_id'] as int?)
          .whereType<int>()
          .toSet();

      var inserted = 0;
      for (final id in contactIds) {
        if (already.contains(id)) continue;
        await txn.insert('tags', {'contact_id': id, 'name': name});
        inserted++;
      }
      return inserted;
    });
  }

  /// Removes [tag] from each of [contactIds]. Returns how many rows were
  /// deleted. Leaves the tag on every other contact.
  Future<int> removeTagFromContacts(String tag, Set<int> contactIds) async {
    final name = tag.trim();
    if (name.isEmpty || contactIds.isEmpty) return 0;

    final db = await _dbHelper.database;
    return db.rawDelete(
      'DELETE FROM tags WHERE LOWER(TRIM(name)) = LOWER(?)'
      ' AND contact_id IN (${List.filled(contactIds.length, '?').join(',')})',
      [name, ...contactIds],
    );
  }

  /// Deletes [tag] only when no contact carries it, returning whether it went.
  ///
  /// A tag is not a row of its own — it exists only as the tag rows on contacts
  /// — so "delete an unused tag" is really "clean up leftovers (blank-named or
  /// orphaned rows) for a name nobody uses". The count is re-checked inside the
  /// transaction so a contact tagged from another screen a moment ago cannot be
  /// silently stripped by a stale count in the UI.
  Future<bool> deleteEmptyTag(String tag) async {
    final name = tag.trim();
    if (name.isEmpty) return false;

    final db = await _dbHelper.database;
    return db.transaction<bool>((txn) async {
      final rows = await txn.rawQuery(
        'SELECT COUNT(DISTINCT t.contact_id) AS n FROM tags t'
        ' JOIN contacts c ON c.id = t.contact_id'
        ' WHERE LOWER(TRIM(t.name)) = LOWER(?)',
        [name],
      );
      final inUse = (rows.first['n'] as int?) ?? 0;
      if (inUse > 0) return false;
      await txn.rawDelete('DELETE FROM tags WHERE LOWER(TRIM(name)) = LOWER(?)', [
        name,
      ]);
      return true;
    });
  }

  /// Minimum romanized-key length for a stem token to count as a match, so a
  /// short stem does not match half the address book.
  static const int _stemMinLen = 3;

  /// Voice-dial name resolver: finds contacts by **stem**, so an inflected
  /// Malayalam name still matches its base form. Malayalam case endings only
  /// *append* to the name (`സീത` → `സീതയെ`/`സീതയോട്`), and that survives the
  /// romanized [searchKey] (`vava` is a prefix of `vavaie`), so a query name
  /// token matches a stored name token when one key is a prefix of the other
  /// (sharing at least [_stemMinLen] characters). Used only as the dialer's
  /// voice fallback, when the exact/substring [searchContactSummaries] found
  /// nothing. Results are ranked best-match first.
  Future<List<Contact>> searchContactsByNameStem(
    String query, {
    bool includeSecret = false,
  }) async {
    // Spoken name as romanized key tokens; ignore tokens below the guard length.
    final queryTokens = searchKey(
      query,
    ).split(' ').where((t) => t.length >= _stemMinLen).toList();
    if (queryTokens.isEmpty) return const <Contact>[];

    final db = await _dbHelper.database;
    // Prefilter in SQL: keep contacts whose name_translit has a token starting
    // with some query token's first [_stemMinLen] chars (both match directions
    // share that prefix). The precise all-tokens rule is applied in Dart below.
    final likeArgs = <String>[];
    final likeClauses = <String>[];
    for (final t in queryTokens) {
      final pre = t.substring(0, _stemMinLen);
      likeClauses.add('c.name_translit LIKE ? OR c.name_translit LIKE ?');
      likeArgs
        ..add('$pre%') // stem at the start of the name
        ..add('% $pre%'); // stem at a later word
    }
    final rows = await db.rawQuery('''
      SELECT c.id AS id, c.name_translit AS name_translit
      FROM contacts c
      WHERE ${includeSecret ? '' : 'c.is_secret = 0 AND'}
            (${likeClauses.join(' OR ')})
      ''', likeArgs);

    // Score: every query token must prefix-match some stored token. Exact token
    // hits outweigh prefix hits, so a fuller name ranks above a bare stem.
    final scored = <MapEntry<int, int>>[];
    for (final r in rows) {
      final id = r['id'] as int?;
      if (id == null) continue;
      final storedTokens = ((r['name_translit'] as String?) ?? '')
          .split(' ')
          .where((t) => t.isNotEmpty)
          .toList();
      var score = 0;
      var allMatched = true;
      for (final qt in queryTokens) {
        var best = 0;
        for (final st in storedTokens) {
          final overlap = qt.length < st.length ? qt.length : st.length;
          if (overlap < _stemMinLen) continue;
          if (qt == st) {
            best = 3; // exact
            break;
          }
          if ((st.startsWith(qt) || qt.startsWith(st)) && best < 1) {
            best = 1; // prefix
          }
        }
        if (best == 0) {
          allMatched = false;
          break;
        }
        score += best;
      }
      if (allMatched) scored.add(MapEntry(id, score));
    }
    if (scored.isEmpty) return const <Contact>[];
    scored.sort((a, b) => b.value.compareTo(a.value)); // best score first

    final ids = scored.map((e) => e.key).toList();
    final placeholders = List.filled(ids.length, '?').join(',');
    final hydrated = await db.rawQuery(
      '$_summarySelect WHERE c.id IN ($placeholders)',
      ids,
    );
    final byId = {
      for (final row in hydrated) row['id'] as int: _summaryFromRow(row),
    };
    // Restore the ranked order (the IN query returns rows in table order).
    return [
      for (final id in ids)
        if (byId[id] != null) byId[id]!,
    ];
  }

  /// Every device `device_id` currently linked to a contact — both the primary
  /// `contacts.device_id` links and the auto-merge `merged_device_ids` records —
  /// as `device_id -> contact_id`, in one query for the batched device sync.
  Future<Map<String, int>> deviceIdLinks() async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery('''
      SELECT device_id, id AS contact_id FROM contacts WHERE device_id IS NOT NULL
      UNION ALL
      SELECT device_id, contact_id FROM merged_device_ids
    ''');
    final map = <String, int>{};
    for (final r in rows) {
      final d = r['device_id'] as String?;
      if (d != null) map[d] = r['contact_id'] as int;
    }
    return map;
  }

  /// The device ids recorded in `merged_device_ids` — absorbed-duplicate links,
  /// as opposed to a row's own primary `contacts.device_id`. Lets the sync
  /// re-verify absorptions and heal ones that were recorded wrongly.
  Future<Set<String>> mergedDeviceIds() async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery('SELECT device_id FROM merged_device_ids');
    return rows.map((r) => r['device_id'] as String).toSet();
  }

  /// The device ids recorded in `merged_device_ids` by a **user-confirmed**
  /// merge (from the Find-duplicates screen), as opposed to an automatic
  /// import-time absorption. The sync must never re-split these on a name
  /// mismatch — the user has explicitly declared them the same person.
  Future<Set<String>> confirmedMergedDeviceIds() async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery(
      'SELECT device_id FROM merged_device_ids WHERE user_confirmed = 1',
    );
    return rows.map((r) => r['device_id'] as String).toSet();
  }

  /// The non-null `device_id`s of the given contacts — the phone-book links to
  /// remove when a merge deletes these contacts (captured before the app-side
  /// merge deletes their rows). Includes both each contact's own primary link
  /// and any device ids it had already absorbed via `merged_device_ids`
  /// (e.g. from an earlier auto-merge), so a repeat merge of the same person
  /// cleans up every native copy instead of leaving older absorbed ones behind
  /// on the phone.
  Future<List<String>> deviceIdsForContacts(List<int> ids) async {
    if (ids.isEmpty) return const <String>[];
    final db = await _dbHelper.database;
    final placeholders = List.filled(ids.length, '?').join(',');
    final rows = await db.rawQuery(
      'SELECT device_id FROM contacts '
      'WHERE id IN ($placeholders) AND device_id IS NOT NULL '
      'UNION '
      'SELECT device_id FROM merged_device_ids WHERE contact_id IN ($placeholders)',
      [...ids, ...ids],
    );
    return rows.map((r) => r['device_id'] as String).toList();
  }

  /// Removes an absorbed-duplicate link, so the device contact can be imported
  /// as its own row again (the auto-merge heal path).
  Future<void> removeMergedDeviceId(String deviceId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'merged_device_ids',
      where: 'device_id = ?',
      whereArgs: [deviceId],
    );
  }

  /// `normalizedDigits -> contact_id` for every phone of a **non-secret**
  /// contact (first owner wins), the in-memory index the auto-merge dedup tests
  /// each incoming device contact against. Secret contacts are excluded so a
  /// device contact is never folded into (or linked to) an app-only secret row.
  Future<Map<String, int>> phoneIndexNonSecret() async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery('''
      SELECT p.number AS number, p.contact_id AS contact_id
      FROM phone_numbers p
      JOIN contacts c ON c.id = p.contact_id
      WHERE c.is_secret = 0
    ''');
    final map = <String, int>{};
    for (final r in rows) {
      final digits = normalizeDigits(r['number'] as String);
      if (digits.isEmpty) continue;
      map.putIfAbsent(digits, () => r['contact_id'] as int);
    }
    return map;
  }

  /// `normalizedDigits -> contact_id` for every phone number that was part of
  /// a user-confirmed merge (see `mergeContacts`), the signal the device sync
  /// uses to recognise a re-synced duplicate by phone number even when
  /// Android has reassigned its device-contact id (see
  /// `ContactSyncService._mergeDeviceContacts`).
  Future<Map<String, int>> confirmedMergePhones() async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery(
      'SELECT digits, contact_id FROM confirmed_merge_phones',
    );
    return {
      for (final r in rows) r['digits'] as String: r['contact_id'] as int,
    };
  }

  /// [secretOnly] restricts the result to secret contacts (it overrides
  /// [includeSecret]); used by the secret-only export.
  Future<List<Contact>> getAllContacts({
    bool includeSecret = false,
    bool secretOnly = false,
  }) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> contactMaps = await db.query(
      'contacts',
      where: secretOnly
          ? 'is_secret = 1'
          : (includeSecret ? null : 'is_secret = 0'),
      orderBy: 'is_self DESC, sort_first COLLATE NOCASE ASC, id ASC',
    );

    final List<Contact> contacts = [];
    for (var map in contactMaps) {
      contacts.add(await _hydrate(Contact.fromMap(map)));
    }
    return contacts;
  }

  /// Loads a contact's child collections.
  Future<Contact> _hydrate(Contact contact) async {
    final id = contact.id!;
    contact.phoneNumbers = await _getPhoneNumbers(id);
    contact.emails = await _getEmails(id);
    contact.addresses = await _getAddresses(id);
    contact.socialLinks = await _getSocialLinks(id);
    contact.groups = await _getContactGroups(id);
    contact.tags = await _getTags(id);
    contact.officialDetails = await _getOfficialDetails(id);
    contact.relationships = await _relationships.getRelationsOf(id);
    return contact;
  }

  /// Contacts that share a name or a phone number with another contact.
  ///
  /// Returns slim summaries (name parts + primary phone) via [_summarySelect] —
  /// exactly what the duplicates screen renders — in a single query. The full
  /// per-contact child hydration is intentionally skipped: the screen never
  /// reads those children, and hydrating them would cost one query per contact.
  Future<List<Contact>> findDuplicates({String defaultIso = 'IN'}) async {
    final groups = await findDuplicateGroups(defaultIso: defaultIso);
    final result = <Contact>[];
    for (final g in groups) {
      result.addAll(g.contacts);
    }
    return result;
  }

  /// Duplicate candidates grouped into **connected sets** — what the Find-duplicates
  /// screen renders one card per.
  ///
  /// Two contacts land in the same set when they share an exact name key, a
  /// transliterated `searchKey`, exact phone digits, or a canonical E.164 phone
  /// number (`phone_numbers_parser`). Membership is transitive (union-find). Only
  /// sets of two or more are returned.
  ///
  /// Phonetic-code matching (Soundex / Double Metaphone) was deliberately removed:
  /// both compress a name into 4 characters, so short and multi-word names collided
  /// on unrelated contacts and produced false-positive merges. `phonetic_utils.dart`
  /// still exists for contact search, but must not be put back on this path without
  /// a much stricter scoring model.
  Future<List<DuplicateSet>> findDuplicateGroups({String defaultIso = 'IN'}) async {
    final db = await _dbHelper.database;

    final rows = await db.rawQuery('''
      $_summarySelect
      WHERE c.is_self = 0
      ORDER BY c.first_name ASC
    ''');

    if (rows.isEmpty) return const <DuplicateSet>[];

    final order = <int>[];
    final byId = <int, Contact>{};
    final scoreById = <int, double>{};
    for (final r in rows) {
      final contact = _summaryFromRow(r);
      final id = contact.id;
      if (id == null) continue;
      order.add(id);
      byId[id] = contact;
      final s = r['relationship_score'];
      scoreById[id] = s is num ? s.toDouble() : 0.0;
    }

    final parent = <int, int>{for (final id in order) id: id};
    int find(int x) {
      var root = x;
      while (parent[root] != root) {
        root = parent[root]!;
      }
      var cur = x;
      while (parent[cur] != root) {
        final next = parent[cur]!;
        parent[cur] = root;
        cur = next;
      }
      return root;
    }

    void union(int a, int b) {
      final ra = find(a);
      final rb = find(b);
      if (ra != rb) parent[ra] = rb;
    }

    final exactNameById = <int, String>{};
    final searchKeyById = <int, String>{};

    final byExactName = <String, int>{};
    final bySearchKey = <String, int>{};

    for (final id in order) {
      final c = byId[id]!;
      final fullName = '${c.firstName} ${c.lastName ?? ''}'.trim();
      final exactKey = fullName.toLowerCase();
      final sKey = searchKey(fullName);

      exactNameById[id] = exactKey;
      searchKeyById[id] = sKey;

      if (exactKey.isNotEmpty) {
        final prev = byExactName[exactKey];
        if (prev != null) {
          union(prev, id);
        } else {
          byExactName[exactKey] = id;
        }
      }

      if (sKey.isNotEmpty) {
        final prev = bySearchKey[sKey];
        if (prev != null) {
          union(prev, id);
        } else {
          bySearchKey[sKey] = id;
        }
      }
    }

    final ids = order.toList();
    if (ids.isEmpty) return const <DuplicateSet>[];
    final placeholders = List.filled(ids.length, '?').join(',');

    final phoneRows = await db.rawQuery(
      'SELECT contact_id, number, label FROM phone_numbers '
      'WHERE contact_id IN ($placeholders) '
      'ORDER BY contact_id, is_primary DESC, id ASC',
      ids,
    );

    final phonesById = <int, Set<String>>{};
    final e164PhonesById = <int, Set<String>>{};
    final byDigits = <String, int>{};
    final byE164 = <String, int>{};
    final primaryPhone = <int, ({String number, String? label})>{};

    for (final r in phoneRows) {
      final cid = r['contact_id'] as int?;
      if (cid == null || !parent.containsKey(cid)) continue;
      final number = r['number'] as String? ?? '';
      if (number.trim().isNotEmpty) {
        primaryPhone.putIfAbsent(
          cid,
          () => (number: number, label: r['label'] as String?),
        );
      }
      final digits = normalizeDigits(number);
      final e164 = PhoneNormalizer.toE164(number, defaultIso: defaultIso);

      if (digits.isNotEmpty) {
        phonesById.putIfAbsent(cid, () => <String>{}).add(digits);
        final prev = byDigits[digits];
        if (prev != null) {
          union(prev, cid);
        } else {
          byDigits[digits] = cid;
        }
      }

      if (e164 != null && e164.isNotEmpty) {
        e164PhonesById.putIfAbsent(cid, () => <String>{}).add(e164);
        final prev = byE164[e164];
        if (prev != null) {
          union(prev, cid);
        } else {
          byE164[e164] = cid;
        }
      }
    }

    final emailRows = await db.rawQuery(
      'SELECT contact_id, email FROM emails '
      'WHERE contact_id IN ($placeholders) '
      'ORDER BY contact_id, is_primary DESC, id ASC',
      ids,
    );
    final primaryEmail = <int, String>{};
    for (final r in emailRows) {
      final cid = r['contact_id'] as int?;
      if (cid == null) continue;
      final e = r['email'] as String? ?? '';
      if (e.trim().isEmpty) continue;
      primaryEmail.putIfAbsent(cid, () => e);
    }

    final fieldRows = await db.rawQuery(
      'SELECT contact_id, COUNT(*) AS n FROM ('
      'SELECT contact_id FROM phone_numbers WHERE contact_id IN ($placeholders) '
      'UNION ALL SELECT contact_id FROM emails WHERE contact_id IN ($placeholders) '
      'UNION ALL SELECT contact_id FROM addresses WHERE contact_id IN ($placeholders) '
      'UNION ALL SELECT contact_id FROM social_links WHERE contact_id IN ($placeholders)'
      ') GROUP BY contact_id',
      [...ids, ...ids, ...ids, ...ids],
    );
    final fieldsById = <int, int>{};
    for (final r in fieldRows) {
      final cid = r['contact_id'] as int?;
      if (cid == null) continue;
      fieldsById[cid] = (r['n'] as int?) ?? 0;
    }

    final groups = <int, List<int>>{};
    for (final id in order) {
      groups.putIfAbsent(find(id), () => <int>[]).add(id);
    }

    final result = <DuplicateSet>[];
    for (final members in groups.values) {
      if (members.length < 2) continue;
      members.sort((a, b) {
        final cmp = scoreById[b]!.compareTo(scoreById[a]!);
        return cmp != 0 ? cmp : a.compareTo(b);
      });
      final details = <int, String>{
        for (final id in members)
          id: _detailFor(
            primaryPhone[id]?.number,
            primaryPhone[id]?.label,
            primaryEmail[id],
            fieldsById[id] ?? 0,
          ),
      };
      result.add(
        DuplicateSet(
          contacts: [for (final id in members) byId[id]!],
          reason: _reasonFor(
            members,
            exactNameById,
            searchKeyById,
            phonesById,
            e164PhonesById,
          ),
          details: details,
          linkedByPhone: _sharedPhone(members, phonesById, e164PhonesById),
        ),
      );
    }
    return result;
  }

  static String _detailFor(
    String? number,
    String? label,
    String? email,
    int fields,
  ) {
    final parts = <String>[];
    if (number != null && number.trim().isNotEmpty) {
      parts.add(number.trim());
      final l = label?.trim() ?? '';
      parts.add(l.isEmpty ? 'no label' : l);
    } else if (email != null && email.trim().isNotEmpty) {
      parts.add(email.trim());
      parts.add('no phone');
    } else {
      parts.add('No phone');
    }
    if (fields > 0) parts.add('$fields field${fields == 1 ? '' : 's'}');
    return parts.join(' · ');
  }

  static bool _sharedPhone(
    List<int> members,
    Map<int, Set<String>> phonesById,
    Map<int, Set<String>> e164PhonesById,
  ) {
    for (int i = 0; i < members.length; i++) {
      for (int j = i + 1; j < members.length; j++) {
        final m1 = members[i];
        final m2 = members[j];
        final p1 = phonesById[m1] ?? const <String>{};
        final p2 = phonesById[m2] ?? const <String>{};
        if (p1.intersection(p2).isNotEmpty) return true;
        final e1 = e164PhonesById[m1] ?? const <String>{};
        final e2 = e164PhonesById[m2] ?? const <String>{};
        if (e1.intersection(e2).isNotEmpty) return true;
      }
    }
    return false;
  }

  static String _reasonFor(
    List<int> members,
    Map<int, String> exactNameById,
    Map<int, String> searchKeyById,
    Map<int, Set<String>> phonesById,
    Map<int, Set<String>> e164PhonesById,
  ) {
    var sharedPhone = false;
    var sharedExactName = false;
    var sharedSimilarName = false;

    for (int i = 0; i < members.length; i++) {
      for (int j = i + 1; j < members.length; j++) {
        final m1 = members[i];
        final m2 = members[j];

        final p1 = phonesById[m1] ?? const <String>{};
        final p2 = phonesById[m2] ?? const <String>{};
        final e1 = e164PhonesById[m1] ?? const <String>{};
        final e2 = e164PhonesById[m2] ?? const <String>{};

        if (p1.intersection(p2).isNotEmpty || e1.intersection(e2).isNotEmpty) {
          sharedPhone = true;
        }

        final ex1 = exactNameById[m1];
        final ex2 = exactNameById[m2];
        if (ex1 != null && ex1.isNotEmpty && ex1 == ex2) {
          sharedExactName = true;
        } else {
          final sk1 = searchKeyById[m1];
          final sk2 = searchKeyById[m2];

          if (sk1 != null && sk1.isNotEmpty && sk1 == sk2) {
            sharedSimilarName = true;
          }
        }
      }
    }

    if ((sharedExactName || sharedSimilarName) && sharedPhone) {
      return sharedExactName
          ? 'Same name & number'
          : 'Similar name & phone match';
    }
    if (sharedPhone) return 'Same phone number';
    if (sharedExactName) return 'Same name';
    return 'Similar name match';
  }

  /// Re-points every child row from [duplicateIds] onto [primaryId], then
  /// deletes the duplicate contact rows. Runs in a single transaction.
  Future<void> mergeContacts(int primaryId, List<int> duplicateIds) async {
    final ids = duplicateIds.where((id) => id != primaryId).toList();
    if (ids.isEmpty) return;

    final db = await _dbHelper.database;
    final placeholders = List.filled(ids.length, '?').join(',');

    await db.transaction((txn) async {
      // Snapshots taken before the re-pointing starts: the primary's, so the
      // "grew by a merge" edit can be undone, and each duplicate's, so an
      // absorbed contact can be brought back as a separate contact.
      final primaryBefore = await AuditRepository.capture(txn, primaryId);
      final duplicatesBefore = <int, ContactSnapshot?>{
        for (final id in ids) id: await AuditRepository.capture(txn, id),
      };

      // Tables with a plain contact_id we can re-point directly.
      for (final table in const [
        'phone_numbers',
        'emails',
        'addresses',
        'call_logs',
        'interactions',
        'reminders',
      ]) {
        await txn.rawUpdate(
          'UPDATE $table SET contact_id = ? WHERE contact_id IN ($placeholders)',
          [primaryId, ...ids],
        );
      }

      // contact_groups: PK is (contact_id, group_id); OR IGNORE drops rows that
      // would collide with a membership the primary already has.
      await txn.rawUpdate(
        'UPDATE OR IGNORE contact_groups SET contact_id = ? WHERE contact_id IN ($placeholders)',
        [primaryId, ...ids],
      );

      // relationships reference contacts from both sides.
      await txn.rawUpdate(
        'UPDATE relationships SET contact_id = ? WHERE contact_id IN ($placeholders)',
        [primaryId, ...ids],
      );
      await txn.rawUpdate(
        'UPDATE relationships SET related_contact_id = ? WHERE related_contact_id IN ($placeholders)',
        [primaryId, ...ids],
      );

      // official_details has UNIQUE(contact_id); OR IGNORE keeps the primary's
      // existing row and skips duplicates' rows (left behind, removed by cascade).
      await txn.rawUpdate(
        'UPDATE OR IGNORE official_details SET contact_id = ? WHERE contact_id IN ($placeholders)',
        [primaryId, ...ids],
      );

      // Re-pointing both sides of a relationship onto the primary can create a
      // self-referential row (primary related to itself); drop those.
      await txn.delete(
        'relationships',
        where: 'contact_id = related_contact_id',
      );

      // Re-pointing can also collapse two links onto the same pair, leaving
      // duplicate directed rows (the primary related to the same contact twice).
      // Keep one row per (contact_id, related_contact_id) pair.
      await txn.rawDelete('''
        DELETE FROM relationships
        WHERE id NOT IN (
          SELECT MIN(id) FROM relationships
          GROUP BY contact_id, related_contact_id
        )
        ''');

      // Preserve the duplicates' device links before their rows (and the
      // cascade-deleted merged_device_ids rows) disappear, so the absorbed
      // device contacts are recognised — not re-imported — on the next sync.
      // First re-point any merge rows already owned by the duplicates onto the
      // primary, promoting them to user_confirmed as part of this deliberate
      // merge so a later sync never re-splits them on a name mismatch.
      await txn.rawUpdate(
        'UPDATE merged_device_ids SET contact_id = ?, user_confirmed = 1 WHERE contact_id IN ($placeholders)',
        [primaryId, ...ids],
      );
      // ...then capture each duplicate's own primary device link, marked
      // user_confirmed = 1: this is a deliberate merge, so the sync's name-based
      // "heal wrong absorption" rule must never re-split it (see
      // ContactSyncService._mergeDeviceContacts).
      await txn.rawInsert(
        '''
        INSERT OR REPLACE INTO merged_device_ids (device_id, contact_id, user_confirmed)
        SELECT device_id, ?, 1 FROM contacts
        WHERE id IN ($placeholders) AND device_id IS NOT NULL
        ''',
        [primaryId, ...ids],
      );

      // Record every phone number now on the merged group against the primary,
      // keyed by number rather than by device id: Android can reassign a
      // device contact's internal id when it re-links/re-splits raw contacts
      // (e.g. a WhatsApp resync), which otherwise makes this exact duplicate
      // look brand-new on the next sync and reintroduces it. phone_numbers was
      // already re-pointed onto primaryId above, so this covers both the
      // primary's original numbers and the absorbed duplicates'.
      final mergedPhoneRows = await txn.rawQuery(
        'SELECT DISTINCT number FROM phone_numbers WHERE contact_id = ?',
        [primaryId],
      );
      for (final row in mergedPhoneRows) {
        final digits = normalizeDigits(row['number'] as String);
        if (digits.isEmpty) continue;
        await txn.insert(
          'confirmed_merge_phones',
          {'digits': digits, 'contact_id': primaryId},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      // Delete the duplicate contacts; cascade cleans up any remaining children.
      await txn.delete(
        'contacts',
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );

      // A merge is logged as what it actually is: the kept contact was edited,
      // and each absorbed contact was deleted. Undoing an absorbed contact
      // brings it back as its own contact; it does not strip the copied rows
      // back out of the kept one.
      await AuditRepository.record(
        txn,
        contactId: primaryId,
        action: AuditAction.update,
        source: AuditSource.merge,
        before: primaryBefore,
        after: await AuditRepository.capture(txn, primaryId),
        summary: 'Absorbed ${ids.length} duplicate'
            '${ids.length == 1 ? '' : 's'}',
      );
      for (final entry in duplicatesBefore.entries) {
        if (entry.value == null) continue;
        await AuditRepository.record(
          txn,
          contactId: entry.key,
          action: AuditAction.delete,
          source: AuditSource.merge,
          before: entry.value,
          summary: 'Merged into another contact',
        );
      }
    });
  }

  /// A contact's full phone numbers (with labels and `is_primary`), loaded on
  /// demand — e.g. when Call is tapped on the list, whose slim summaries carry
  /// only the primary number. Public wrapper over [_getPhoneNumbers].
  Future<List<PhoneNumber>> getPhoneNumbers(int contactId) =>
      _getPhoneNumbers(contactId);

  Future<List<PhoneNumber>> _getPhoneNumbers(int contactId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'phone_numbers',
      where: 'contact_id = ?',
      whereArgs: [contactId],
    );
    return maps.map((map) => PhoneNumber.fromMap(map)).toList();
  }

  /// A contact's emails, loaded on demand (the list carries only the primary
  /// email in its slim summaries). Public wrapper over [_getEmails].
  Future<List<Email>> getEmails(int contactId) => _getEmails(contactId);

  Future<List<Email>> _getEmails(int contactId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'emails',
      where: 'contact_id = ?',
      whereArgs: [contactId],
    );
    return maps.map((map) => Email.fromMap(map)).toList();
  }

  Future<List<Address>> _getAddresses(int contactId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'addresses',
      where: 'contact_id = ?',
      whereArgs: [contactId],
    );
    return maps.map((map) => Address.fromMap(map)).toList();
  }

  Future<List<SocialLink>> _getSocialLinks(int contactId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'social_links',
      where: 'contact_id = ?',
      whereArgs: [contactId],
    );
    return maps.map((map) => SocialLink.fromMap(map)).toList();
  }

  Future<List<String>> _getTags(int contactId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'tags',
      columns: ['name'],
      where: 'contact_id = ?',
      whereArgs: [contactId],
    );
    return maps.map((map) => map['name'] as String).toList();
  }

  Future<List<String>> _getContactGroups(int contactId) async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery(
      '''
      SELECT g.name
      FROM groups g
      JOIN contact_groups cg ON g.id = cg.group_id
      WHERE cg.contact_id = ?
    ''',
      [contactId],
    );
    return maps.map((map) => map['name'] as String).toList();
  }

  Future<OfficialDetails?> _getOfficialDetails(int contactId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'official_details',
      where: 'contact_id = ?',
      whereArgs: [contactId],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return OfficialDetails.fromMap(maps.first);
    }
    return null;
  }
}

class _ScoredMatch {
  final PhoneMatch match;
  final int score;
  const _ScoredMatch({required this.match, required this.score});
}

