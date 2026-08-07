// lib/models/official_details.dart
class OfficialDetails {
  int? id;
  int? contactId;
  String? designation;
  String? department;

  OfficialDetails({this.id, this.contactId, this.designation, this.department});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contact_id': contactId,
      'designation': designation,
      'department': department,
    };
  }

  factory OfficialDetails.fromMap(Map<String, dynamic> map) {
    return OfficialDetails(
      id: map['id'] as int?,
      contactId: map['contact_id'] as int?,
      designation: map['designation'] as String?,
      department: map['department'] as String?,
    );
  }

  bool get isEmpty =>
      (designation == null || designation!.isEmpty) &&
      (department == null || department!.isEmpty);
}
