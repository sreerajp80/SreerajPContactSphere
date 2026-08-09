// test/quiet_hours_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/repositories/relationship_repository.dart';
import 'package:smart_contacts_dialer/services/quiet_hours_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.setTestDatabaseName('smart_contacts_test_quiet_hours.db');
  });

  setUp(() async {
    await DatabaseHelper().close();
    await databaseFactory.deleteDatabase(
      path.join(await getDatabasesPath(), 'smart_contacts_test_quiet_hours.db'),
    );
  });

  tearDown(() async {
    await DatabaseHelper().close();
  });

  group('QuietHoursTiers mapping', () {
    test('correctly maps relationship types to tier categories', () {
      expect(QuietHoursTiers.tierForRelationship('Father'), QuietHoursTiers.immediateFamily);
      expect(QuietHoursTiers.tierForRelationship('Mother'), QuietHoursTiers.immediateFamily);
      expect(QuietHoursTiers.tierForRelationship('Spouse'), QuietHoursTiers.immediateFamily);
      expect(QuietHoursTiers.tierForRelationship('Brother'), QuietHoursTiers.immediateFamily);

      expect(QuietHoursTiers.tierForRelationship('Grandfather'), QuietHoursTiers.extendedFamily);
      expect(QuietHoursTiers.tierForRelationship('Uncle'), QuietHoursTiers.extendedFamily);
      expect(QuietHoursTiers.tierForRelationship('Cousin'), QuietHoursTiers.extendedFamily);

      expect(QuietHoursTiers.tierForRelationship('Friend'), QuietHoursTiers.friends);
      expect(QuietHoursTiers.tierForRelationship('Neighbour'), QuietHoursTiers.friends);

      expect(QuietHoursTiers.tierForRelationship('Colleague'), QuietHoursTiers.work);
      expect(QuietHoursTiers.tierForRelationship('UnknownLabel'), null);
    });
  });

  group('QuietHoursService.resolveAllowedNumbers', () {
    test('resolves emergency, relationship-linked, and starred contact numbers', () async {
      final db = await DatabaseHelper().database;

      // Create self contact
      final selfId = await db.insert('contacts', {
        'first_name': 'Owner',
        'is_self': 1,
      });

      // Create contact 1: Dad (Immediate family)
      final dadId = await db.insert('contacts', {
        'first_name': 'Dad',
        'is_favorite': 0,
      });
      await db.insert('phone_numbers', {
        'contact_id': dadId,
        'number': '+91 98765 43210',
      });

      // Create contact 2: Boss (Work)
      final bossId = await db.insert('contacts', {
        'first_name': 'Boss',
        'is_favorite': 0,
      });
      await db.insert('phone_numbers', {
        'contact_id': bossId,
        'number': '+91 91234 56789',
      });

      // Create contact 3: Starred Friend
      final friendId = await db.insert('contacts', {
        'first_name': 'BestFriend',
        'is_favorite': 1,
      });
      await db.insert('phone_numbers', {
        'contact_id': friendId,
        'number': '+91 99999 88888',
      });

      // Insert relationships from self
      final relRepo = RelationshipRepository();
      await relRepo.setRelationship(
        contactId: selfId,
        relatedContactId: dadId,
        type: 'Father',
      );
      await relRepo.setRelationship(
        contactId: selfId,
        relatedContactId: bossId,
        type: 'Colleague',
      );

      // Insert ICE contact
      await db.insert('emergency_contacts', {
        'display_name': 'Doctor',
        'number': '+91 90000 11111',
      });

      final service = QuietHoursService();

      // Test 1: Only Emergency & Immediate Family (default)
      final defaultAllowed = await service.resolveAllowedNumbers({
        QuietHoursTiers.emergency,
        QuietHoursTiers.immediateFamily,
      });
      expect(defaultAllowed, contains('919876543210')); // Dad
      expect(defaultAllowed, contains('919000011111')); // Doctor (ICE)
      expect(defaultAllowed, isNot(contains('919123456789'))); // Boss (Work)
      expect(defaultAllowed, isNot(contains('919999988888'))); // Friend (Starred)

      // Test 2: Immediate Family + Starred
      final familyAndStarred = await service.resolveAllowedNumbers({
        QuietHoursTiers.immediateFamily,
        QuietHoursTiers.starred,
      });
      expect(familyAndStarred, contains('919876543210')); // Dad
      expect(familyAndStarred, contains('919999988888')); // Friend (Starred)
      expect(familyAndStarred, isNot(contains('919123456789'))); // Boss (Work)

      // Test 3: Work only
      final workOnly = await service.resolveAllowedNumbers({
        QuietHoursTiers.work,
      });
      expect(workOnly, contains('919123456789')); // Boss
      expect(workOnly.length, equals(1));

      // Create contact 4: Tagged Contact
      final vipId = await db.insert('contacts', {
        'first_name': 'VIP Person',
        'is_favorite': 0,
      });
      await db.insert('phone_numbers', {
        'contact_id': vipId,
        'number': '+91 97777 66666',
      });
      await db.insert('tags', {
        'contact_id': vipId,
        'name': 'VIP',
      });

      // Test 4: Allowed Tags
      final tagAllowed = await service.resolveAllowedNumbers({}, {'VIP'}, {});
      expect(tagAllowed, contains('919777766666'));

      // Test 5: Allowed Contact ID
      final idAllowed = await service.resolveAllowedNumbers({}, {}, {bossId});
      expect(idAllowed, contains('919123456789'));

      // Test 6: Specific Relationship Label
      final fatherOnly = await service.resolveAllowedNumbers({'Father'});
      expect(fatherOnly, contains('919876543210'));
      expect(fatherOnly.length, equals(1));
    });
  });
}


