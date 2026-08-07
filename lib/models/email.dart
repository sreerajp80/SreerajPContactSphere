// lib/models/email.dart
class Email {
  int? id;
  int? contactId;
  String email;
  String? label;
  String type;
  bool isPrimary;

  Email({
    this.id,
    this.contactId,
    required this.email,
    this.label,
    required this.type,
    this.isPrimary = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contact_id': contactId,
      'email': email,
      'label': label,
      'type': type,
      'is_primary': isPrimary ? 1 : 0,
    };
  }

  factory Email.fromMap(Map<String, dynamic> map) {
    return Email(
      id: map['id'],
      contactId: map['contact_id'],
      email: map['email'],
      label: map['label'],
      type: map['type'],
      isPrimary: map['is_primary'] == 1,
    );
  }
}
