// test/business_card_parser_test.dart
//
// Unit tests for BusinessCardParser — the mapping from card text lines to a
// draft contact. Pure Dart: no plugin and no database, so this file runs on the
// host with plain `flutter test`.

import 'package:flutter_test/flutter_test.dart';

import 'package:smart_contacts_dialer/utils/business_card_parser.dart';

void main() {
  group('BusinessCardParser', () {
    test('reads a full corporate card', () {
      // The SoftwareOne card, in the order ML Kit reads it (name block first,
      // logo word to the right, company block at the bottom).
      final draft = BusinessCardParser.parse(
        const [
          'Ajay Shankar K',
          'Business Development Manager',
          'ajay.shankar@softwareone.com',
          '+ 91 9497369134',
          'software',
          'one',
          'SoftwareOne India Private Ltd.',
          'Tower B, 3rd Floor, Global Technology Park,',
          'Bellandur, Bangalore, Karnataka 560103',
          'www.softwareone.com',
        ],
        defaultIso: 'IN',
      );

      final c = draft.contact;
      expect(c.firstName, 'Ajay');
      expect(c.middleName, 'Shankar');
      expect(c.lastName, 'K');

      expect(c.phoneNumbers, hasLength(1));
      expect(c.phoneNumbers.single.number.replaceAll(' ', ''), '+919497369134');
      expect(c.phoneNumbers.single.type, 'official');
      expect(c.phoneNumbers.single.isPrimary, isTrue);

      expect(c.emails.single.email, 'ajay.shankar@softwareone.com');
      expect(c.officialDetails?.designation, 'Business Development Manager');

      final address = c.addresses.single;
      expect(address.type, 'official');
      expect(address.companyName, 'SoftwareOne India Private Ltd.');
      expect(address.street, contains('Tower B'));
      expect(address.street, contains('Global Technology Park'));
      expect(address.cityTown, 'Bangalore');
      expect(address.state, 'Karnataka');
      expect(address.postalCode, '560103');

      expect(c.socialLinks.single.label, 'Website');
      expect(c.socialLinks.single.value, 'www.softwareone.com');
    });

    test('gives a bare national number its country code', () {
      final draft = BusinessCardParser.parse(
        const ['Rahul Menon', 'Mob: 9847012345'],
        defaultIso: 'IN',
      );

      expect(draft.contact.firstName, 'Rahul');
      expect(draft.contact.lastName, 'Menon');
      expect(
        draft.contact.phoneNumbers.single.number.replaceAll(' ', ''),
        '+919847012345',
      );
    });

    test('keeps both numbers on a two-number card, first is primary', () {
      final draft = BusinessCardParser.parse(
        const [
          'Priya Nair',
          'Tel: +91 484 2345678',
          'Mobile: +91 9847012345',
        ],
        defaultIso: 'IN',
      );

      final phones = draft.contact.phoneNumbers;
      expect(phones, hasLength(2));
      expect(phones.first.isPrimary, isTrue);
      expect(phones.last.isPrimary, isFalse);
      expect(phones.map((p) => p.number.replaceAll(' ', '')), [
        '+914842345678',
        '+919847012345',
      ]);
    });

    test('the same number printed twice is stored once', () {
      final draft = BusinessCardParser.parse(
        const ['Priya Nair', 'Mob: 9847012345', 'Tel: +91 98470 12345'],
        defaultIso: 'IN',
      );

      expect(draft.contact.phoneNumbers, hasLength(1));
    });

    test('a name-only card yields just the name', () {
      final draft = BusinessCardParser.parse(
        const ['Dr. Anita Joseph'],
        defaultIso: 'IN',
      );

      final c = draft.contact;
      expect(c.salutation, 'Dr');
      expect(c.firstName, 'Anita');
      expect(c.lastName, 'Joseph');
      expect(c.phoneNumbers, isEmpty);
      expect(c.emails, isEmpty);
      expect(c.addresses, isEmpty);
      expect(draft.isEmpty, isFalse);
    });

    test('falls back to the email local part when no name line is present', () {
      final draft = BusinessCardParser.parse(
        const ['ajay.shankar@softwareone.com', '+91 9497369134'],
        defaultIso: 'IN',
      );

      expect(draft.contact.firstName, 'Ajay');
      expect(draft.contact.lastName, 'Shankar');
    });

    test('junk input gives an empty draft, not an exception', () {
      final draft = BusinessCardParser.parse(
        const ['###', '|', '   '],
        defaultIso: 'IN',
      );

      expect(draft.isEmpty, isTrue);
      expect(draft.contact.firstName, isEmpty);
    });

    test('no lines at all gives an empty draft', () {
      final draft = BusinessCardParser.parse(const [], defaultIso: 'IN');

      expect(draft.isEmpty, isTrue);
      expect(draft.unmatchedLines, isEmpty);
    });

    test('lines it cannot place are handed back, not dropped', () {
      final draft = BusinessCardParser.parse(
        const ['Ajay Shankar K', 'Scan me for offers', 'ajay@example.com'],
        defaultIso: 'IN',
      );

      expect(draft.unmatchedLines, contains('Scan me for offers'));
      expect(draft.rawText, contains('Scan me for offers'));
    });
  });
}
