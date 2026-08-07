// lib/models/audit_entry.dart
import 'dart:convert';
import 'package:cryptography/cryptography.dart';

/// What happened to the contact.
enum AuditAction { create, update, delete }

/// Where the change came from. Stored as a string so an unknown value from a
/// newer build degrades to [AuditSource.unknown] instead of crashing the list.
enum AuditSource { manual, deviceSync, merge, restore, p2pSync, import, undo, unknown }

extension AuditActionCodec on AuditAction {
  String get dbValue => switch (this) {
    AuditAction.create => 'create',
    AuditAction.update => 'update',
    AuditAction.delete => 'delete',
  };

  /// Past-tense word shown in the list ("Added", "Edited", "Deleted").
  String get label => switch (this) {
    AuditAction.create => 'Added',
    AuditAction.update => 'Edited',
    AuditAction.delete => 'Deleted',
  };

  static AuditAction fromDb(String? value) => switch (value) {
    'create' => AuditAction.create,
    'delete' => AuditAction.delete,
    _ => AuditAction.update,
  };
}

extension AuditSourceCodec on AuditSource {
  String get dbValue => switch (this) {
    AuditSource.manual => 'manual',
    AuditSource.deviceSync => 'device_sync',
    AuditSource.merge => 'merge',
    AuditSource.restore => 'restore',
    AuditSource.p2pSync => 'p2p_sync',
    AuditSource.import => 'import',
    AuditSource.undo => 'undo',
    AuditSource.unknown => 'unknown',
  };

  /// Plain-English "who did it", shown under each entry.
  String get label => switch (this) {
    AuditSource.manual => 'In the app',
    AuditSource.deviceSync => 'Phone contacts sync',
    AuditSource.merge => 'Merged duplicates',
    AuditSource.restore => 'Backup restore',
    AuditSource.p2pSync => 'Sync from another device',
    AuditSource.import => 'File import',
    AuditSource.undo => 'Undo from the audit log',
    AuditSource.unknown => 'Unknown',
  };

  static AuditSource fromDb(String? value) => switch (value) {
    'manual' => AuditSource.manual,
    'device_sync' => AuditSource.deviceSync,
    'merge' => AuditSource.merge,
    'restore' => AuditSource.restore,
    'p2p_sync' => AuditSource.p2pSync,
    'import' => AuditSource.import,
    'undo' => AuditSource.undo,
    _ => AuditSource.unknown,
  };
}

/// A complete copy of one contact — its `contacts` row plus every child row —
/// taken at a point in time. This is what makes an audit entry reversible: an
/// undo writes the snapshot back verbatim.
///
/// Rows are stored exactly as SQLite returned them, minus ids (which are not
/// stable across a restore). Groups are kept as *names*, since group ids can
/// differ after a restore. Relationships are kept as contact-id pairs and are
/// re-created only where the other contact still exists.
class ContactSnapshot {
  /// The `contacts` row, without `id`.
  final Map<String, Object?> contact;

  /// Child rows by table name (`phone_numbers`, `emails`, `addresses`,
  /// `social_links`, `official_details`, `tags`), each without `id` /
  /// `contact_id`.
  final Map<String, List<Map<String, Object?>>> children;

  /// Group names this contact belonged to.
  final List<String> groups;

  /// `relationships` rows touching this contact, as
  /// `{contact_id, related_contact_id, relationship_type}`.
  final List<Map<String, Object?>> relationships;

  const ContactSnapshot({
    required this.contact,
    required this.children,
    required this.groups,
    required this.relationships,
  });

  /// Tables a snapshot carries, in the order they are written back.
  static const List<String> childTables = [
    'phone_numbers',
    'emails',
    'addresses',
    'social_links',
    'official_details',
    'tags',
  ];

  Map<String, Object?> toJson() => {
    'contact': contact,
    'children': children,
    'groups': groups,
    'relationships': relationships,
  };

  String encode() => jsonEncode(toJson());

  static ContactSnapshot fromJson(Map<String, Object?> json) {
    final rawChildren = (json['children'] as Map?) ?? const {};
    return ContactSnapshot(
      contact: Map<String, Object?>.from((json['contact'] as Map?) ?? const {}),
      children: {
        for (final entry in rawChildren.entries)
          entry.key as String: [
            for (final row in (entry.value as List? ?? const []))
              Map<String, Object?>.from(row as Map),
          ],
      },
      groups: [
        for (final g in (json['groups'] as List? ?? const [])) g as String,
      ],
      relationships: [
        for (final r in (json['relationships'] as List? ?? const []))
          Map<String, Object?>.from(r as Map),
      ],
    );
  }

  /// Decodes a stored JSON column; null/blank/corrupt text yields null rather
  /// than breaking the whole audit list.
  static ContactSnapshot? decode(String? text) {
    if (text == null || text.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(text);
      if (decoded is! Map) return null;
      return fromJson(Map<String, Object?>.from(decoded));
    } on FormatException {
      return null;
    }
  }

  /// The contact's display name at the time of the snapshot.
  String get displayName {
    final name = [
      contact['salutation'],
      contact['first_name'],
      contact['middle_name'],
      contact['last_name'],
    ].whereType<String>().where((s) => s.trim().isNotEmpty).join(' ');
    return name.isEmpty ? 'Unnamed contact' : name;
  }

  bool get isSecret => contact['is_secret'] == 1;
}

/// One line of "before → after" shown on the entry detail screen.
class FieldChange {
  final String label;
  final String before;
  final String after;

  const FieldChange({
    required this.label,
    required this.before,
    required this.after,
  });
}

/// One recorded change to one contact.
class AuditEntry {
  static const String genesisHash =
      '0000000000000000000000000000000000000000000000000000000000000000';
  static final Sha256 _sha256 = Sha256();

  final int id;

  /// The contact the change was about. Still set for a delete, even though no
  /// such contact exists any more; null only for rows written without one.
  final int? contactId;

  /// Name at the time of the change, so a deleted contact still reads well.
  final String contactName;
  final AuditAction action;
  final AuditSource source;
  final DateTime changedAt;

  /// Short plain-English list of what changed ("Phone numbers, Last name").
  final String summary;
  final bool isSecret;
  final ContactSnapshot? before;
  final ContactSnapshot? after;

  /// SHA-256 hash of the preceding entry in the audit log chain.
  final String? prevHash;

  /// SHA-256 hash of (prevHash + current entry payload).
  final String? hash;

  const AuditEntry({
    required this.id,
    required this.contactId,
    required this.contactName,
    required this.action,
    required this.source,
    required this.changedAt,
    required this.summary,
    required this.isSecret,
    this.before,
    this.after,
    this.prevHash,
    this.hash,
  });

  factory AuditEntry.fromRow(Map<String, Object?> row) => AuditEntry(
    id: row['id'] as int,
    contactId: row['contact_id'] as int?,
    contactName: (row['contact_name'] as String?) ?? 'Unnamed contact',
    action: AuditActionCodec.fromDb(row['action'] as String?),
    source: AuditSourceCodec.fromDb(row['source'] as String?),
    changedAt:
        DateTime.tryParse((row['changed_at'] as String?) ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
    summary: (row['summary'] as String?) ?? '',
    isSecret: row['is_secret'] == 1,
    before: ContactSnapshot.decode(row['before_json'] as String?),
    after: ContactSnapshot.decode(row['after_json'] as String?),
    prevHash: row['prev_hash'] as String?,
    hash: row['hash'] as String?,
  );

  /// Computes SHA-256 hash over [prevHash] and entry fields payload.
  static Future<String> calculateHash({
    required String prevHash,
    required int? contactId,
    required String contactName,
    required String actionDbValue,
    required String sourceDbValue,
    required String changedAt,
    required String summary,
    required bool isSecret,
    required String? beforeJson,
    required String? afterJson,
  }) async {
    final payload = [
      contactId?.toString() ?? '',
      contactName,
      actionDbValue,
      sourceDbValue,
      changedAt,
      summary,
      isSecret ? '1' : '0',
      beforeJson ?? '',
      afterJson ?? '',
    ].join('|');
    final input = '$prevHash|$payload';
    final digest = await _sha256.hash(utf8.encode(input));
    return digest.bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Computes expected SHA-256 hash for this entry given [effectivePrevHash].
  Future<String> computeExpectedHash(String effectivePrevHash) {
    return calculateHash(
      prevHash: effectivePrevHash,
      contactId: contactId,
      contactName: contactName,
      actionDbValue: action.dbValue,
      sourceDbValue: source.dbValue,
      changedAt: changedAt.toIso8601String(),
      summary: summary,
      isSecret: isSecret,
      beforeJson: before?.encode(),
      afterJson: after?.encode(),
    );
  }

  /// Verifies if stored [hash] matches SHA-256(effectivePrevHash + payload).
  Future<bool> verifyHash(String effectivePrevHash) async {
    if (hash == null || hash!.isEmpty) return false;
    final expected = await computeExpectedHash(effectivePrevHash);
    return hash == expected;
  }


  /// Whether this entry can be reversed. An edit or a delete needs the "before"
  /// snapshot to write back; a create just needs the contact to still be there.
  bool get canUndo => switch (action) {
    AuditAction.create => contactId != null,
    AuditAction.update => before != null && contactId != null,
    AuditAction.delete => before != null,
  };

  /// What the Undo button will do, in plain English.
  String get undoDescription => switch (action) {
    AuditAction.create => 'Undo will delete this contact again.',
    AuditAction.update => 'Undo will put the old details back.',
    AuditAction.delete =>
      'Undo will create this contact again. It gets a new id, so old call '
          'history stays unlinked and only relationships whose other person '
          'still exists come back.',
  };

  /// Field-by-field difference between [before] and [after]. Used by the detail
  /// screen and, at write time, to build [summary].
  List<FieldChange> get changes => diff(before, after);

  /// Human labels for the `contacts` columns worth showing. Columns not listed
  /// here are derived or bookkeeping (search keys, sort keys, timestamps, the
  /// computed relationship score) and would only add noise.
  static const Map<String, String> contactFieldLabels = {
    'salutation': 'Salutation',
    'first_name': 'First name',
    'middle_name': 'Middle name',
    'last_name': 'Last name',
    'formal_name': 'Formal name',
    'gender': 'Gender',
    'dob': 'Date of birth',
    'photo_path': 'Photo',
    'card_photo_path': 'Calling card',
    'ringtone_label': 'Ringtone',
    'blood_group': 'Blood group',
    'anniversary': 'Anniversary',
    'meetiversary': 'Meetiversary',
    'is_secret': 'Secret',
    'is_favorite': 'Favourite',
    'is_self': 'Self',
    'device_id': 'Phone contacts link',
  };

  /// Labels for the child collections, in display order.
  static const Map<String, String> childLabels = {
    'phone_numbers': 'Phone numbers',
    'emails': 'Emails',
    'addresses': 'Addresses',
    'social_links': 'Social links',
    'official_details': 'Work details',
    'tags': 'Tags',
  };

  /// Compares two snapshots (either may be null, for a create or a delete).
  static List<FieldChange> diff(ContactSnapshot? before, ContactSnapshot? after) {
    final out = <FieldChange>[];
    for (final entry in contactFieldLabels.entries) {
      final b = _formatField(entry.key, before?.contact[entry.key]);
      final a = _formatField(entry.key, after?.contact[entry.key]);
      if (b == a) continue;
      out.add(FieldChange(label: entry.value, before: b, after: a));
    }
    for (final entry in childLabels.entries) {
      final b = _formatRows(entry.key, before);
      final a = _formatRows(entry.key, after);
      if (b == a) continue;
      out.add(FieldChange(label: entry.value, before: b, after: a));
    }
    final bGroups = (before?.groups ?? const <String>[]).join(', ');
    final aGroups = (after?.groups ?? const <String>[]).join(', ');
    if (bGroups != aGroups) {
      out.add(FieldChange(label: 'Groups', before: bGroups, after: aGroups));
    }
    return out;
  }

  /// Short summary line built from [diff]; at most three field names, then a
  /// count of the rest.
  static String summaryOf(List<FieldChange> changes) {
    if (changes.isEmpty) return 'No visible field changed';
    final names = [for (final c in changes) c.label];
    if (names.length <= 3) return names.join(', ');
    return '${names.take(3).join(', ')} and ${names.length - 3} more';
  }

  static String _formatField(String column, Object? value) {
    if (value == null) return '';
    switch (column) {
      case 'is_secret':
      case 'is_favorite':
      case 'is_self':
        return value == 1 ? 'Yes' : 'No';
      case 'dob':
      case 'anniversary':
      case 'meetiversary':
        final text = value.toString();
        return text.length >= 10 ? text.substring(0, 10) : text;
      default:
        return value.toString();
    }
  }

  /// One-line rendering of a child table's rows, used both for comparison and
  /// for display, so what the screen shows is exactly what was compared.
  static String _formatRows(String table, ContactSnapshot? snapshot) {
    final rows = snapshot?.children[table] ?? const <Map<String, Object?>>[];
    final parts = <String>[];
    for (final row in rows) {
      switch (table) {
        case 'phone_numbers':
          parts.add(_withLabel(row['number'], row['label']));
        case 'emails':
          parts.add(_withLabel(row['email'], row['label']));
        case 'addresses':
          parts.add(
            [
              row['house_name'],
              row['company_name'],
              row['street'],
              row['post_office'],
              row['city_town'],
              row['village_municipality'],
              row['postal_code'],
              row['state'],
              row['country'],
            ].whereType<String>().where((s) => s.trim().isNotEmpty).join(', '),
          );
        case 'social_links':
          parts.add(_withLabel(row['value'], row['label']));
        case 'official_details':
          parts.add(
            [
              row['designation'],
              row['department'],
            ].whereType<String>().where((s) => s.trim().isNotEmpty).join(' · '),
          );
        case 'tags':
          parts.add((row['name'] as String?) ?? '');
      }
    }
    return parts.where((p) => p.trim().isNotEmpty).join(', ');
  }

  static String _withLabel(Object? value, Object? label) {
    final v = (value as String?)?.trim() ?? '';
    final l = (label as String?)?.trim() ?? '';
    if (v.isEmpty) return '';
    return l.isEmpty ? v : '$v ($l)';
  }
}
