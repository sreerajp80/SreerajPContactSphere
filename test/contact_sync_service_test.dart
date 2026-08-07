// Unit tests for ContactSyncService's source-orchestration logic. The device
// side (DeviceContactService -> flutter_contacts) is platform-channel bound and
// is inert on the host VM: every call is caught and degrades to a safe default
// (permission "not granted", no device contacts). These tests therefore verify
// the SQLite-facing behaviour and the secret-unlink rule, which run host-side
// via sqflite_common_ffi. Full device sync is verified manually on a device.

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/models/contact.dart';
import 'package:smart_contacts_dialer/models/email.dart';
import 'package:smart_contacts_dialer/models/phone_number.dart';
import 'package:smart_contacts_dialer/repositories/contact_repository.dart';
import 'package:smart_contacts_dialer/services/contact_sync_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final sync = ContactSyncService();
  final repo = ContactRepository();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.setTestDatabaseName('smart_contacts_test_contact_sync.db');
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await DatabaseHelper().close();
    await databaseFactory.deleteDatabase(
      join(await getDatabasesPath(), 'smart_contacts_test_contact_sync.db'),
    );
  });

  tearDown(() async {
    await DatabaseHelper().close();
  });

  test('saveContact inserts a new contact and returns its id', () async {
    final id = await sync.saveContact(Contact(firstName: 'Ada'));
    expect(id, greaterThan(0));

    final stored = await repo.getContactById(id);
    expect(stored, isNotNull);
    expect(stored!.firstName, 'Ada');
    // No device permission on the host VM, so it stays app-only (unlinked).
    expect(stored.deviceId, isNull);
  });

  test('making a contact secret unlinks it from the device', () async {
    // A contact that was previously linked to a device entry.
    final id = await repo.insertContact(
      Contact(firstName: 'Grace', deviceId: 'dev-123'),
    );

    // Re-save as secret: secret contacts are app-only, so the link is dropped.
    final saved = await sync.saveContact(
      Contact(id: id, firstName: 'Grace', deviceId: 'dev-123', isSecret: true),
    );
    expect(saved, id);

    final stored = await repo.getContactById(id);
    expect(stored!.isSecret, isTrue);
    expect(stored.deviceId, isNull);
    // The link is gone, so a device-id lookup no longer finds it.
    expect(await repo.getContactByDeviceId('dev-123'), isNull);
  });

  test(
    'mergedContacts returns app contacts (no device access on host)',
    () async {
      await repo.insertContact(Contact(firstName: 'Linus'));
      await repo.insertContact(Contact(firstName: 'Margaret'));

      final merged = await sync.mergedContacts();
      expect(
        merged.map((c) => c.firstName),
        containsAll(['Linus', 'Margaret']),
      );
    },
  );

  test('deleteContact removes the app row', () async {
    final id = await repo.insertContact(Contact(firstName: 'Dennis'));
    expect(await repo.getContactById(id), isNotNull);

    await sync.deleteContact(Contact(id: id, firstName: 'Dennis'));
    expect(await repo.getContactById(id), isNull);
  });

  test('syncFromDevice is a no-op without device permission', () async {
    await repo.insertContact(Contact(firstName: 'Edsger'));
    // Host VM has no contacts permission -> returns 0, changes nothing.
    expect(await sync.syncFromDevice(), 0);
    expect((await repo.getAllContacts()).length, 1);
  });

  test('syncToDevice is a no-op without device permission', () async {
    await repo.insertContact(Contact(firstName: 'Ada'));
    // Host VM has no contacts permission -> returns zero counts, changes nothing.
    final result = await sync.syncToDevice();
    expect(result.total, 0);
    expect(result.created, 0);
    expect(result.updated, 0);
    final stored = await repo.getAllContacts();
    expect(stored.length, 1);
    // Nothing was written, so the app row stays unlinked.
    expect(stored.single.deviceId, isNull);
  });

  test('getContactSummaries is paged and carries the primary phone', () async {
    await repo.insertContact(
      Contact(firstName: 'Ada')
        ..phoneNumbers = [
          PhoneNumber(number: '111', type: 'personal'),
          PhoneNumber(number: '222', type: 'personal', isPrimary: true),
        ],
    );
    await repo.insertContact(Contact(firstName: 'Bjarne'));
    await repo.insertContact(Contact(firstName: 'Carmack'));

    final page = await sync.localSummaries(limit: 2);
    expect(page.map((c) => c.firstName), ['Ada', 'Bjarne']);
    // The primary number wins over insertion order.
    expect(page.first.phoneNumbers.single.number, '222');

    final next = await sync.localSummaries(limit: 2, offset: 2);
    expect(next.map((c) => c.firstName), ['Carmack']);
    expect(await sync.contactCount(), 3);
  });

  test(
    'searchSummaries matches name, phone and email across the book',
    () async {
      await repo.insertContact(
        Contact(firstName: 'Grace', lastName: 'Hopper')
          ..phoneNumbers = [
            PhoneNumber(number: '+1 (555) 010-2030', type: 'personal'),
          ]
          ..emails = [Email(email: 'grace@navy.mil', type: 'personal')],
      );
      await repo.insertContact(Contact(firstName: 'Alan', lastName: 'Turing'));

      expect((await sync.searchSummaries('hopper')).single.firstName, 'Grace');
      // Phone search ignores formatting (digits only).
      expect(
        (await sync.searchSummaries('5550102030')).single.firstName,
        'Grace',
      );
      expect(
        (await sync.searchSummaries('navy.mil')).single.firstName,
        'Grace',
      );
      expect(await sync.searchSummaries('zzz'), isEmpty);
    },
  );

  test(
    'merging duplicates preserves device links so they are not re-imported',
    () async {
      // Two app rows that came from two device entries of the same person.
      final primary = await repo.insertContact(
        Contact(firstName: 'Margaret', deviceId: 'dev-A')
          ..phoneNumbers = [PhoneNumber(number: '900', type: 'personal')],
      );
      final dup = await repo.insertContact(
        Contact(firstName: 'Margaret', deviceId: 'dev-B')
          ..phoneNumbers = [PhoneNumber(number: '900', type: 'personal')],
      );

      await repo.mergeContacts(primary, [dup]);

      // The duplicate row is gone...
      expect(await repo.getContactById(dup), isNull);
      // ...but its device link now resolves to the surviving primary, so a future
      // sync recognises 'dev-B' instead of re-creating a duplicate.
      final resolved = await repo.getContactByDeviceId('dev-B');
      expect(resolved, isNotNull);
      expect(resolved!.id, primary);
    },
  );

  test(
    'findDuplicates groups by shared name/phone and returns primary phone',
    () async {
      // Same name, different number -> both are duplicates by name.
      await repo.insertContact(
        Contact(firstName: 'Sam', lastName: 'Lee')
          ..phoneNumbers = [PhoneNumber(number: '111', type: 'personal')],
      );
      await repo.insertContact(
        Contact(firstName: 'Sam', lastName: 'Lee')
          ..phoneNumbers = [PhoneNumber(number: '222', type: 'personal')],
      );
      // Different name, shared number -> both are duplicates by phone.
      await repo.insertContact(
        Contact(firstName: 'Bob')
          ..phoneNumbers = [PhoneNumber(number: '333', type: 'personal')],
      );
      await repo.insertContact(
        Contact(firstName: 'Rob')
          ..phoneNumbers = [PhoneNumber(number: '333', type: 'personal')],
      );
      // A loner: no shared name or number.
      await repo.insertContact(
        Contact(firstName: 'Zoe')
          ..phoneNumbers = [PhoneNumber(number: '999', type: 'personal')],
      );

      final dups = await repo.findDuplicates();
      expect(dups.map((c) => c.firstName).toSet(), {'Sam', 'Bob', 'Rob'});
      expect(dups.where((c) => c.firstName == 'Zoe'), isEmpty);
      // The slim summary still carries the primary phone the screen renders.
      final bob = dups.firstWhere((c) => c.firstName == 'Bob');
      expect(bob.phoneNumbers.single.number, '333');
    },
  );

  test('merging carries over child rows the primary lacks', () async {
    // Primary has only a phone; the duplicate has the email + address.
    final primary = await repo.insertContact(
      Contact(firstName: 'Nina')
        ..phoneNumbers = [PhoneNumber(number: '500', type: 'personal')],
    );
    final dup = await repo.insertContact(
      Contact(firstName: 'Nina')
        ..phoneNumbers = [PhoneNumber(number: '500', type: 'personal')]
        ..emails = [Email(email: 'nina@x.io', type: 'personal')],
    );

    await repo.mergeContacts(primary, [dup]);

    final merged = await repo.getContactById(primary);
    expect(merged, isNotNull);
    // The absorbed duplicate's email is re-pointed onto the primary.
    expect(merged!.emails.map((e) => e.email), contains('nina@x.io'));
  });

  test('syncDeviceContacts keeps a contact that shares a number with a '
      'different person', () async {
    // Two different people sharing one number (e.g. a family landline) must
    // both exist — a number match alone is not identity.
    await repo.insertContact(
      Contact(
        firstName: 'Dad',
      )..phoneNumbers = [PhoneNumber(number: '0484 100 200', type: 'personal')],
    );

    final changed = await sync.syncDeviceContacts([
      Contact(firstName: 'Mom', deviceId: 'dev-mom')
        ..phoneNumbers = [PhoneNumber(number: '0484100200', type: 'personal')],
    ]);

    expect(changed, 1);
    final all = await repo.getAllContacts();
    expect(all.map((c) => c.firstName).toSet(), {'Dad', 'Mom'});
    expect((await repo.getContactByDeviceId('dev-mom'))!.firstName, 'Mom');
  });

  test(
    'syncDeviceContacts absorbs a genuine duplicate (same name and number)',
    () async {
      final adaId = await repo.insertContact(
        Contact(firstName: 'Ada', lastName: 'Lovelace')
          ..phoneNumbers = [PhoneNumber(number: '111 222', type: 'personal')],
      );

      final changed = await sync.syncDeviceContacts([
        Contact(firstName: 'Ada', lastName: 'Lovelace', deviceId: 'dev-ada')
          ..phoneNumbers = [PhoneNumber(number: '111222', type: 'personal')],
      ]);

      expect(changed, 1);
      // Absorbed, not inserted: still one row, and the device id resolves to it.
      expect((await repo.getAllContacts()).length, 1);
      expect((await repo.getContactByDeviceId('dev-ada'))!.id, adaId);
    },
  );

  test('syncDeviceContacts heals a wrongly absorbed device contact', () async {
    // An earlier (buggy) sync folded Mom into Dad because they share a number.
    final dadId = await repo.insertContact(
      Contact(firstName: 'Dad')
        ..phoneNumbers = [PhoneNumber(number: '100200', type: 'personal')],
    );
    await repo.recordMergedDeviceId(dadId, 'dev-mom');

    final changed = await sync.syncDeviceContacts([
      Contact(firstName: 'Mom', deviceId: 'dev-mom')
        ..phoneNumbers = [PhoneNumber(number: '100200', type: 'personal')],
    ]);

    expect(changed, 1);
    // Mom got her own row back; Dad is untouched.
    final mom = await repo.getContactByDeviceId('dev-mom');
    expect(mom!.firstName, 'Mom');
    expect(mom.id, isNot(dadId));
    expect((await repo.getContactById(dadId))!.firstName, 'Dad');
  });

  test('syncDeviceContacts does not re-split a user-confirmed merge with a '
      'different name', () async {
    // The user deliberately merged two device contacts that share a number but
    // have slightly different names ("Dr. X" vs "Dr X"). repo.mergeContacts
    // records the absorbed device id as user_confirmed = 1.
    final keepId = await repo.insertContact(
      Contact(firstName: 'Dr. X', deviceId: 'dev-keep')
        ..phoneNumbers = [PhoneNumber(number: '100200', type: 'personal')],
    );
    final dupId = await repo.insertContact(
      Contact(firstName: 'Dr X', deviceId: 'dev-dup')
        ..phoneNumbers = [PhoneNumber(number: '100200', type: 'personal')],
    );
    await repo.mergeContacts(keepId, [dupId]);
    expect((await repo.getAllContacts()).length, 1);

    // The phone still has both device contacts (a delete may not have reached
    // the account). Syncing them must NOT undo the merge, despite the name
    // mismatch — the confirmed absorption is honoured.
    final changed = await sync.syncDeviceContacts([
      Contact(firstName: 'Dr. X', deviceId: 'dev-keep')
        ..phoneNumbers = [PhoneNumber(number: '100200', type: 'personal')],
      Contact(firstName: 'Dr X', deviceId: 'dev-dup')
        ..phoneNumbers = [PhoneNumber(number: '100200', type: 'personal')],
    ]);

    // Still one row: the confirmed duplicate was refreshed in place, not split.
    expect((await repo.getAllContacts()).length, 1);
    expect((await repo.getContactByDeviceId('dev-dup'))!.id, keepId);
    // The kept name is preserved (a differently-named copy did not overwrite it).
    expect((await repo.getContactById(keepId))!.firstName, 'Dr. X');
    // 'changed' counts the refreshed own-link contact only (the confirmed
    // duplicate is skipped without a write).
    expect(changed, 1);
  });

  test(
    'syncDeviceContacts does not resurrect a confirmed merge after Android '
    'reassigns the absorbed device id',
    () async {
      // Reproduces the real-world bug: Android's contact-aggregation engine
      // can reassign a device contact's internal id when it re-links/splits
      // raw contacts (e.g. after a WhatsApp resync). A user-confirmed merge
      // keyed only on the old device id would then miss on the next sync and
      // silently recreate the duplicate. The confirmed-merge phone-number
      // record (confirmed_merge_phones) must catch it instead.
      final keepId = await repo.insertContact(
        Contact(firstName: 'Dr. Ramakrishnan', lastName: 'D', deviceId: 'dev-keep')
          ..phoneNumbers = [PhoneNumber(number: '9000000013', type: 'personal')],
      );
      final dupId = await repo.insertContact(
        Contact(firstName: 'Dr Ramakhrishnan', lastName: 'D', deviceId: 'dev-dup-old')
          ..phoneNumbers = [PhoneNumber(number: '9000000013', type: 'personal')],
      );
      await repo.mergeContacts(keepId, [dupId]);
      expect((await repo.getAllContacts()).length, 1);

      // The next sync sees the same phone contact under a brand-new device id
      // (as if Android re-aggregated it) and a name that neither matches the
      // survivor exactly nor only differs by punctuation.
      final changed = await sync.syncDeviceContacts([
        Contact(firstName: 'Dr. Ramakrishnan', lastName: 'D', deviceId: 'dev-keep')
          ..phoneNumbers = [PhoneNumber(number: '9000000013', type: 'personal')],
        Contact(
            firstName: 'Dr Ramakhrishnan',
            lastName: 'D',
            deviceId: 'dev-dup-new')
          ..phoneNumbers = [PhoneNumber(number: '9000000013', type: 'personal')],
      ]);

      // Still one row: the reassigned id was recognised by phone number, not
      // re-imported as a fresh duplicate. 'changed' counts both the refreshed
      // own-link contact (dev-keep) and the newly-recorded confirmed link
      // (dev-dup-new).
      expect((await repo.getAllContacts()).length, 1);
      expect(changed, 2);
      expect((await repo.getContactByDeviceId('dev-dup-new'))!.id, keepId);
    },
  );

  test('syncDeviceContacts reports merging progress, then clears it', () async {
    final events = <SyncProgress?>[];
    final sub = sync.onSyncProgress.listen(events.add);

    // 25 contacts -> updates at 0, 10, 20, a final 25/25, then the terminal
    // null that tells listeners the sync is over.
    final devices = List.generate(
      25,
      (i) => Contact(firstName: 'C$i', deviceId: 'dev-$i'),
    );
    await sync.syncDeviceContacts(devices);
    // Broadcast stream events are delivered asynchronously — let them land.
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(events, isNotEmpty);
    expect(events.first!.phase, SyncPhase.merging);
    expect(events.first!.processed, 0);
    expect(events.first!.total, 25);
    // Second-to-last event is the completed count; the last is the null reset.
    final last = events[events.length - 2]!;
    expect(last.processed, 25);
    expect(last.total, 25);
    expect(events.last, isNull);
    expect(sync.currentProgress, isNull);
  });

  test('initial-sync flag: set by a completed sync, not by a no-op', () async {
    expect(await sync.hasCompletedInitialSync(), isFalse);
    // Host VM has no contacts permission -> no-op, flag stays unset.
    await sync.syncFromDevice();
    expect(await sync.hasCompletedInitialSync(), isFalse);
    // A sync that actually ran (even over an empty book) sets it.
    await sync.syncDeviceContacts(const []);
    expect(await sync.hasCompletedInitialSync(), isTrue);
  });

  test(
    'summaries sort case-insensitively (lowercase names not pushed last)',
    () async {
      await repo.insertContact(Contact(firstName: 'beta'));
      await repo.insertContact(Contact(firstName: 'Arun'));
      await repo.insertContact(Contact(firstName: 'Carl'));

      final page = await sync.localSummaries();
      expect(page.map((c) => c.firstName), ['Arun', 'beta', 'Carl']);
    },
  );

  test('findContactIdByNormalizedPhone matches ignoring formatting', () async {
    final id = await repo.insertContact(
      Contact(firstName: 'Linus')
        ..phoneNumbers = [
          PhoneNumber(number: '+91 90000 00012', type: 'personal'),
        ],
    );
    expect(await repo.findContactIdByNormalizedPhone('919000000012'), id);
    expect(
      await repo.findContactIdByNormalizedPhone('919000000012', excludeId: id),
      isNull,
    );
    expect(await repo.findContactIdByNormalizedPhone('000'), isNull);
  });
}
