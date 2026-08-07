// lib/models/social_link.dart
class SocialLink {
  int? id;
  int? contactId;

  /// Platform name — a preset (e.g. "LinkedIn") or a user-entered custom label.
  String? label;

  /// The profile URL or handle.
  String value;
  bool isPrimary;

  SocialLink({
    this.id,
    this.contactId,
    this.label,
    required this.value,
    this.isPrimary = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contact_id': contactId,
      'label': label,
      'value': value,
      'is_primary': isPrimary ? 1 : 0,
    };
  }

  factory SocialLink.fromMap(Map<String, dynamic> map) {
    return SocialLink(
      id: map['id'] as int?,
      contactId: map['contact_id'] as int?,
      label: map['label'] as String?,
      value: map['value'] as String,
      isPrimary: map['is_primary'] == 1,
    );
  }
}
