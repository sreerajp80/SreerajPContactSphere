// lib/models/phone_number.dart
class PhoneNumber {
  int? id;
  int? contactId;
  String number;
  String? label;
  String type;
  bool isPrimary;

  PhoneNumber({
    this.id,
    this.contactId,
    required this.number,
    this.label,
    required this.type,
    this.isPrimary = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contact_id': contactId,
      'number': number,
      'label': label,
      'type': type,
      'is_primary': isPrimary ? 1 : 0,
    };
  }

  factory PhoneNumber.fromMap(Map<String, dynamic> map) {
    return PhoneNumber(
      id: map['id'],
      contactId: map['contact_id'],
      number: map['number'],
      label: map['label'],
      type: map['type'],
      isPrimary: map['is_primary'] == 1,
    );
  }
}
