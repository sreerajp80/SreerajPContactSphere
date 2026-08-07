// test/ephemeral_contact_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/models/contact.dart';
import 'package:smart_contacts_dialer/models/phone_number.dart';
import 'package:smart_contacts_dialer/repositories/contact_repository.dart';
import 'package:smart_contacts_dialer/repositories/interaction_repository.dart';
import 'package:smart_contacts_dialer/services/ephemeral_contact_service.dart';
import 'package:smart_contacts_dialer/services/contact_sync_service.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    DatabaseHelper.setTestDatabaseName(
      'ephemeral_test_${DateTime.now().microsecondsSinceEpoch}.db',
    );
    await DatabaseHelper().close();
  });

  tearDown(() async {
    await DatabaseHelper().close();
  });

  group('Contact Model Ephemeral Fields', () {
    test('toMap and fromMap serialize ephemeral attributes correctly', () {
      final now = DateTime.now();
      final contact = Contact(
        firstName: 'Cab',
        lastName: 'Driver',
        isEphemeral: true,
        ephemeralExpiresAt: now,
        ephemeralAutoDeleteCall: true,
        ephemeralCallCount: 1,
      );

      final map = contact.toMap();
      expect(map['is_ephemeral'], equals(1));
      expect(map['ephemeral_expires_at'], equals(now.toIso8601String()));
      expect(map['ephemeral_auto_delete_call'], equals(1));
      expect(map['ephemeral_call_count'], equals(1));

      final restored = Contact.fromMap(map);
      expect(restored.isEphemeral, isTrue);
      expect(restored.ephemeralAutoDeleteCall, isTrue);
      expect(restored.ephemeralCallCount, equals(1));
      expect(restored.ephemeralExpiresAt?.toIso8601String(), equals(now.toIso8601String()));
    });
  });

  group('EphemeralContactService Operations', () {
    test('checkAndScrubExpiredContacts scrubs contacts past expiry date', () async {
      final repo = ContactRepository();
      final service = EphemeralContactService();

      final expiredContact = Contact(
        firstName: 'Marketplace',
        lastName: 'Seller',
        isEphemeral: true,
        ephemeralExpiresAt: DateTime.now().subtract(const Duration(hours: 1)),
      )..phoneNumbers.add(PhoneNumber(number: '9876543210', type: 'personal'));

      final id = await repo.insertContact(expiredContact);
      expect(await repo.getContactById(id), isNotNull);

      final scrubbed = await service.checkAndScrubExpiredContacts();
      expect(scrubbed, equals(1));

      final fetched = await repo.getContactById(id);
      expect(fetched, isNull);
    });

    test('onCallCompleted scrubs contact when autoDeleteCall is active', () async {
      final repo = ContactRepository();
      final interactions = InteractionRepository();
      final service = EphemeralContactService();

      final tempContact = Contact(
        firstName: 'Delivery',
        lastName: 'Agent',
        isEphemeral: true,
        ephemeralAutoDeleteCall: true,
      )..phoneNumbers.add(PhoneNumber(number: '9988776655', type: 'personal'));

      final id = await repo.insertContact(tempContact);
      await interactions.logCall(
        contactId: id,
        phoneNumber: '9988776655',
      );

      await service.onCallCompleted(contactId: id, phoneNumber: '9988776655');

      final fetched = await repo.getContactById(id);
      expect(fetched, isNull);
    });

    test('extendExpiry updates expiry time and keeps contact ephemeral', () async {
      final repo = ContactRepository();
      final service = EphemeralContactService();

      final tempContact = Contact(
        firstName: 'Event',
        lastName: 'Lead',
        isEphemeral: true,
        ephemeralExpiresAt: DateTime.now().add(const Duration(hours: 2)),
      );

      final id = await repo.insertContact(tempContact);
      await service.extendExpiry(id, const Duration(hours: 24));

      final updated = await repo.getContactById(id);
      expect(updated, isNotNull);
      expect(updated!.isEphemeral, isTrue);
      expect(updated.ephemeralExpiresAt, isNotNull);
      expect(
        updated.ephemeralExpiresAt!.isAfter(DateTime.now().add(const Duration(hours: 23))),
        isTrue,
      );
    });

    test('makePermanent converts ephemeral contact to normal contact', () async {
      final repo = ContactRepository();
      final service = EphemeralContactService();

      final tempContact = Contact(
        firstName: 'Temp',
        lastName: 'Guy',
        isEphemeral: true,
        ephemeralAutoDeleteCall: true,
      );

      final id = await repo.insertContact(tempContact);
      await service.makePermanent(id);

      final updated = await repo.getContactById(id);
      expect(updated, isNotNull);
      expect(updated!.isEphemeral, isFalse);
      expect(updated.ephemeralAutoDeleteCall, isFalse);
      expect(updated.ephemeralExpiresAt, isNull);
    });

    test('ContactSyncService saveContact clears deviceId for ephemeral contacts', () async {
      final sync = ContactSyncService();
      final ephemeral = Contact(
        firstName: 'Cab',
        lastName: 'Driver',
        isEphemeral: true,
        deviceId: 'device_12345',
      );

      final id = await sync.saveContact(ephemeral);
      final repo = ContactRepository();
      final saved = await repo.getContactById(id);

      expect(saved, isNotNull);
      expect(saved!.isEphemeral, isTrue);
      expect(saved.deviceId, isNull);
    });
  });
}
