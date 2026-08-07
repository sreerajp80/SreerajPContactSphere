// test/vcard_service_test.dart
//
// VCardService round-trips run entirely on the host: the flutter_contacts
// vCard writer/reader is pure Dart, and `persistPhotos: false` keeps the
// parser away from path_provider (no platform channels in `flutter test`).

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_contacts_dialer/models/address.dart';
import 'package:smart_contacts_dialer/models/contact.dart';
import 'package:smart_contacts_dialer/models/email.dart';
import 'package:smart_contacts_dialer/models/official_details.dart';
import 'package:smart_contacts_dialer/models/phone_number.dart';
import 'package:smart_contacts_dialer/models/social_link.dart';
import 'package:smart_contacts_dialer/services/vcard_service.dart';

Contact _sampleContact() {
  final c = Contact(
    salutation: 'Dr',
    firstName: 'Asha',
    middleName: 'K',
    lastName: 'Menon',
    dob: DateTime(1988, 4, 12),
  );
  c.phoneNumbers = [
    PhoneNumber(
      number: '+919876543210',
      label: 'Mobile',
      type: 'personal',
      isPrimary: true,
    ),
    PhoneNumber(number: '+914840000001', label: 'Work', type: 'personal'),
  ];
  c.emails = [
    Email(
      email: 'asha@example.com',
      label: 'Work',
      type: 'personal',
      isPrimary: true,
    ),
  ];
  c.addresses = [
    Address(
      type: 'official',
      companyName: 'Malabar Systems',
      street: '12 Marine Drive',
      cityTown: 'Kochi',
      state: 'Kerala',
      postalCode: '682001',
      country: 'India',
    ),
  ];
  c.officialDetails = OfficialDetails(
    designation: 'Chief Architect',
    department: 'Platform',
  );
  return c;
}

void main() {
  final service = VCardService();

  test('single contact round-trips through vCard text', () async {
    final vcf = service.toVCard(_sampleContact());
    expect(vcf, contains('BEGIN:VCARD'));
    expect(vcf, contains('END:VCARD'));
    expect(vcf, contains('Asha'));
    expect(vcf, contains('Menon'));

    final parsed = await service.fromVCard(vcf, persistPhotos: false);
    expect(parsed, hasLength(1));
    final back = parsed.first;
    expect(back.firstName, 'Asha');
    expect(back.lastName, 'Menon');
    expect(back.middleName, 'K');
    expect(back.deviceId, isNull, reason: 'parsed contacts must be unlinked');
    expect(
      back.phoneNumbers.map((p) => p.number.replaceAll(RegExp(r'[^\d+]'), '')),
      containsAll(['+919876543210', '+914840000001']),
    );
    expect(back.emails.map((e) => e.email), contains('asha@example.com'));
    expect(back.dob, DateTime(1988, 4, 12));
    expect(back.officialDetails?.designation, 'Chief Architect');
  });

  test(
    'external share exports standard vCard 3.0 for WhatsApp compatibility',
    () async {
      // परिवार ("family") — Devanagari.
      final c = Contact(firstName: 'परिवार')
        ..phoneNumbers = [
          PhoneNumber(
            number: '+919812345678',
            type: 'personal',
            isPrimary: true,
          ),
        ];

      final vcf = service.toVCard(c, externalShare: true);
      expect(vcf, contains('VERSION:3.0'));
      expect(vcf, contains('BEGIN:VCARD'));
      expect(vcf, contains('END:VCARD'));

      // Round-trips back to the original Unicode name.
      final parsed = await service.fromVCard(vcf, persistPhotos: false);
      expect(parsed, hasLength(1));
      expect(parsed.first.firstName, 'परिवार');
    },
  );

  test('default export uses vCard 3.0', () {
    final c = Contact(firstName: 'രമേഷ് ചേട്ടൻ')
      ..phoneNumbers = [
        PhoneNumber(number: '9000000015', label: 'Mobile', type: 'personal'),
      ];
    final vcf = service.toVCard(c, externalShare: true);
    expect(vcf, contains('VERSION:3.0'));
    expect(vcf, contains('TEL;TYPE=CELL:9000000015'));
  });

  test('whole-book export concatenates and re-imports every contact', () async {
    final other = Contact(firstName: 'Biju')
      ..phoneNumbers = [
        PhoneNumber(number: '+915551234567', type: 'personal', isPrimary: true),
      ];
    final vcf = service.toVCardAll([_sampleContact(), other]);
    expect('BEGIN:VCARD'.allMatches(vcf), hasLength(2));

    final parsed = await service.fromVCard(vcf, persistPhotos: false);
    expect(parsed.map((c) => c.firstName), containsAll(['Asha', 'Biju']));
  });

  test('QR payload never embeds the photo', () async {
    final photo = File(
      '${Directory.systemTemp.path}${Platform.pathSeparator}vcard_test_photo.jpg',
    );
    await photo.writeAsBytes(List<int>.filled(4096, 0x7A));
    addTearDown(() => photo.deleteSync());

    final c = _sampleContact()..photoPath = photo.path;
    expect(service.toVCard(c), contains('PHOTO'));
    final payload = service.qrPayload(c);
    expect(payload, isNot(contains('PHOTO')));
    expect(payload, contains('BEGIN:VCARD'));
    expect(payload, contains('TEL'));
  });

  test('QR payload trims socials and addresses when too dense to scan', () {
    final c = _sampleContact();
    c.socialLinks = [
      for (var i = 0; i < 40; i++)
        SocialLink(
          label: 'website',
          value: 'https://example.com/profile/$i/${'x' * 80}',
        ),
    ];
    final payload = service.qrPayload(c);
    expect(payload.length, lessThanOrEqualTo(VCardService.qrMaxChars));
    // The essentials survive the trim.
    expect(payload, contains('Asha'));
    expect(payload, contains('TEL'));
  });
}
