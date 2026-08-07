// lib/models/group.dart
class Group {
  int? id;
  String name;
  String? ringtonePath;

  /// Display name of the group ringtone (e.g. the tone's title or the picked
  /// file's basename); null when no tone is set.
  String? ringtoneLabel;

  /// Number of contacts in this group. Populated by queries that join
  /// contact_groups; defaults to 0 otherwise.
  int contactCount;

  Group({
    this.id,
    required this.name,
    this.ringtonePath,
    this.ringtoneLabel,
    this.contactCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'ringtone_path': ringtonePath,
      'ringtone_label': ringtoneLabel,
    };
  }

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'] as int?,
      name: map['name'] as String,
      ringtonePath: map['ringtone_path'] as String?,
      ringtoneLabel: map['ringtone_label'] as String?,
      contactCount: (map['contact_count'] as int?) ?? 0,
    );
  }
}
