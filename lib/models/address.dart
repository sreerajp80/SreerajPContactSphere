// lib/models/address.dart
class Address {
  int? id;
  int? contactId;
  String type; // 'personal' | 'official'
  String? houseName;
  String? companyName;
  String? street;
  String? postOffice;
  String? cityTown;
  String? villageMunicipality;
  String? postalCode;
  String? state;
  String? country;

  Address({
    this.id,
    this.contactId,
    required this.type,
    this.houseName,
    this.companyName,
    this.street,
    this.postOffice,
    this.cityTown,
    this.villageMunicipality,
    this.postalCode,
    this.state,
    this.country,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contact_id': contactId,
      'type': type,
      'house_name': houseName,
      'company_name': companyName,
      'street': street,
      'post_office': postOffice,
      'city_town': cityTown,
      'village_municipality': villageMunicipality,
      'postal_code': postalCode,
      'state': state,
      'country': country,
    };
  }

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      id: map['id'] as int?,
      contactId: map['contact_id'] as int?,
      type: (map['type'] as String?) ?? 'personal',
      houseName: map['house_name'] as String?,
      companyName: map['company_name'] as String?,
      street: map['street'] as String?,
      postOffice: map['post_office'] as String?,
      cityTown: map['city_town'] as String?,
      villageMunicipality: map['village_municipality'] as String?,
      postalCode: map['postal_code'] as String?,
      state: map['state'] as String?,
      country: map['country'] as String?,
    );
  }

  /// A human-readable single-line rendering, skipping empty parts.
  String get formatted {
    return [
      houseName,
      companyName,
      street,
      postOffice,
      cityTown,
      villageMunicipality,
      postalCode,
      state,
      country,
    ].where((e) => e != null && e.isNotEmpty).join(', ');
  }
}
