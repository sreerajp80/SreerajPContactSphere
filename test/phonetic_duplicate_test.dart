// test/phonetic_duplicate_test.dart
//
// Unit tests for Soundex, Double Metaphone, phonetic name matching, E.164 phone
// normalization, and ContactRepository.findDuplicateGroups().

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' show join;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/models/contact.dart';
import 'package:smart_contacts_dialer/models/phone_number.dart';
import 'package:smart_contacts_dialer/repositories/contact_repository.dart';
import 'package:smart_contacts_dialer/utils/phone_normalizer.dart';
import 'package:smart_contacts_dialer/utils/phonetic_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const dbName = 'smart_contacts_test_phonetic_dup.db';

  group('Soundex & Double Metaphone Unit Tests', () {
    test('Soundex encodes Sreeraj and Sriraj consistently', () {
      final s1 = Soundex.encode('Sreeraj');
      final s2 = Soundex.encode('Sriraj');
      expect(s1, equals(s2));
      expect(s1.startsWith('S'), isTrue);
    });

    test('Soundex encodes Deepak and Dipak consistently', () {
      final s1 = Soundex.encode('Deepak');
      final s2 = Soundex.encode('Dipak');
      expect(s1, equals(s2));
    });

    test('Double Metaphone returns primary and secondary keys', () {
      final dm1 = DoubleMetaphone.encode('Sreeraj');
      final dm2 = DoubleMetaphone.encode('Sriraj');

      expect(dm1.primary.isNotEmpty, isTrue);
      expect(dm1.primary, equals(dm2.primary));
    });

    test('phoneticNameMatches matches transliterated Malayalam/Indian names', () {
      expect(phoneticNameMatches('Sreeraj', 'Sriraj'), isTrue);
      expect(phoneticNameMatches('Deepak', 'Dipak'), isTrue);
      expect(phoneticNameMatches('Kiran', 'Keeran'), isTrue);
      expect(phoneticNameMatches('Menon', 'Manon'), isTrue);
      expect(phoneticNameMatches('ശ്രീരാജ്', 'Sreeraj'), isTrue);
      expect(phoneticNameMatches('Sreeraj', 'John'), isFalse);
    });

    test('E.164 phone normalization matches national vs international numbers', () {
      const defaultIso = 'IN';
      final e1 = PhoneNormalizer.toE164('09447123456', defaultIso: defaultIso);
      final e2 = PhoneNormalizer.toE164('+919447123456', defaultIso: defaultIso);
      final e3 = PhoneNormalizer.toE164('9447123456', defaultIso: defaultIso);

      expect(e1, equals('+919447123456'));
      expect(e2, equals('+919447123456'));
      expect(e3, equals('+919447123456'));
      expect(PhoneNormalizer.sameNumber('09447123456', '+919447123456', defaultIso: defaultIso), isTrue);
    });
  });

  group('ContactRepository.findDuplicateGroups Database Tests', () {
    setUpAll(() {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      DatabaseHelper.setTestDatabaseName(dbName);
    });

    setUp(() async {
      await DatabaseHelper().close();
      await databaseFactory.deleteDatabase(join(await getDatabasesPath(), dbName));
    });

    tearDown(() async {
      await DatabaseHelper().close();
    });

    final repo = ContactRepository();

    test('finds phonetic name duplicates (Sreeraj vs Sriraj)', () async {
      final c1 = Contact(firstName: 'Sreeraj', lastName: 'P');
      c1.phoneNumbers = [PhoneNumber(number: '9847000001', type: 'personal', label: 'Mobile')];
      await repo.insertContact(c1);

      final c2 = Contact(firstName: 'Sriraj', lastName: 'P');
      c2.phoneNumbers = [PhoneNumber(number: '9847000002', type: 'personal', label: 'Mobile')];
      await repo.insertContact(c2);

      final groups = await repo.findDuplicateGroups();
      expect(groups.length, equals(1));
      expect(groups.first.contacts.length, equals(2));
      expect(groups.first.reason, contains('Similar name match'));
    });

    test('does not group unrelated names that collide on truncated Soundex/Metaphone codes', () async {
      // A long business name and an unrelated short personal name can share a
      // Soundex code by coincidence of the 4-character truncation, even though
      // the names are unrelated. Duplicate detection must not use Soundex/Metaphone.
      final c1 = Contact(firstName: 'Kings Multi Speciality Hospital');
      c1.phoneNumbers = [PhoneNumber(number: '9000000016', type: 'official', label: 'Work')];
      await repo.insertContact(c1);

      final c2 = Contact(firstName: 'Kamala');
      c2.phoneNumbers = [PhoneNumber(number: '9000000017', type: 'personal', label: 'Mobile')];
      await repo.insertContact(c2);

      final c3 = Contact(firstName: 'Krishnan', lastName: 'Uncle');
      c3.phoneNumbers = [PhoneNumber(number: '9000000019', type: 'personal', label: 'Mobile')];
      await repo.insertContact(c3);

      final groups = await repo.findDuplicateGroups();
      expect(groups, isEmpty);
    });

    test('finds E.164 phone normalized duplicates (national vs +91 format)', () async {
      final c1 = Contact(firstName: 'Anand');
      c1.phoneNumbers = [PhoneNumber(number: '09447123456', type: 'personal', label: 'Mobile')];
      await repo.insertContact(c1);

      final c2 = Contact(firstName: 'Anand Kumar');
      c2.phoneNumbers = [PhoneNumber(number: '+919447123456', type: 'personal', label: 'Work')];
      await repo.insertContact(c2);

      final groups = await repo.findDuplicateGroups();
      expect(groups.length, equals(1));
      expect(groups.first.contacts.length, equals(2));
      expect(groups.first.reason.toLowerCase(), contains('phone'));
    });
  });
}
