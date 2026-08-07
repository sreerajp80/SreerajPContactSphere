// Unit tests for the per-group ringtone: the v13→v14 migration, the effective
// tone in ContactRepository.ringtoneMirrorEntries() (own tone, else the first
// toned group by name), and GroupRepository.groupRingtoneForContact() agreeing
// with that pick.
//
// Runs sqflite on the host VM via sqflite_common_ffi. The native ringtone
// mirror push is platform-channel bound and no-ops harmlessly under
// `flutter test`; actual ringing is verified on a device.

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/repositories/contact_repository.dart';
import 'package:smart_contacts_dialer/repositories/group_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.setTestDatabaseName('smart_contacts_test_group_ringtone.db');
  });

  setUp(() async {
    // Start each test from a clean schema.
    await DatabaseHelper().close();
    await databaseFactory.deleteDatabase(
      join(await getDatabasesPath(), 'smart_contacts_test_group_ringtone.db'),
    );
  });

  tearDown(() async {
    await DatabaseHelper().close();
  });

  /// Inserts a contact with one phone [number], returning the contact id.
  Future<int> addContact(
    DatabaseExecutor db,
    String name,
    String number, {
    String? tone,
  }) async {
    final id = await db.insert('contacts', {
      'first_name': name,
      'ringtone_path': tone,
    });
    await db.insert('phone_numbers', {'contact_id': id, 'number': number});
    return id;
  }

  Future<int> addGroup(DatabaseExecutor db, String name, {String? tone}) {
    return db.insert('groups', {'name': name, 'ringtone_path': tone});
  }

  Future<void> addMember(DatabaseExecutor db, int contactId, int groupId) {
    return db.insert('contact_groups', {
      'contact_id': contactId,
      'group_id': groupId,
    });
  }

  group('v13→v14 migration', () {
    test('keeps existing group rows and adds ringtone_label', () async {
      // Craft a minimal v13 database: a groups table without ringtone_label.
      final path = join(await getDatabasesPath(), 'smart_contacts_test_group_ringtone.db');
      final old = await databaseFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 13,
          onCreate: (db, version) async {
            await db.execute('''
              CREATE TABLE groups (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL UNIQUE,
                ringtone_path TEXT,
                created_at TEXT DEFAULT CURRENT_TIMESTAMP
              )
            ''');
          },
        ),
      );
      await old.insert('groups', {
        'name': 'Family',
        'ringtone_path': '/tones/family.mp3',
      });
      await old.close();

      // Opening through the helper runs _onUpgrade(13 → 14).
      final db = await DatabaseHelper().database;
      final rows = await db.query('groups');
      expect(rows, hasLength(1));
      expect(rows.single['name'], 'Family');
      expect(rows.single['ringtone_path'], '/tones/family.mp3');
      // The new column exists and defaults to null for migrated rows.
      expect(rows.single.containsKey('ringtone_label'), isTrue);
      expect(rows.single['ringtone_label'], isNull);
    });
  });

  group('ringtoneMirrorEntries with group fallback', () {
    test("a contact's own tone wins over their group's tone", () async {
      final db = await DatabaseHelper().database;
      final cid = await addContact(db, 'Anu', '9876543210', tone: '/t/own.mp3');
      final gid = await addGroup(db, 'Family', tone: '/t/family.mp3');
      await addMember(db, cid, gid);

      final map = await ContactRepository().ringtoneMirrorEntries();
      // Keyed by the number's trailing 10 digits (the whole number here).
      expect(map, {'9876543210': '/t/own.mp3'});
    });

    test('the group tone fills in when the contact has none', () async {
      final db = await DatabaseHelper().database;
      final cid = await addContact(db, 'Biju', '9995551234');
      final gid = await addGroup(db, 'Family', tone: '/t/family.mp3');
      await addMember(db, cid, gid);

      final map = await ContactRepository().ringtoneMirrorEntries();
      expect(map, {'9995551234': '/t/family.mp3'});
    });

    test('multi-group pick is deterministic: first by name, then id', () async {
      final db = await DatabaseHelper().database;
      final cid = await addContact(db, 'Devi', '9995550001');
      // Insert in reverse name order to prove ordering is by name, not id.
      final beta = await addGroup(db, 'Beta', tone: '/t/beta.mp3');
      final alpha = await addGroup(db, 'Alpha', tone: '/t/alpha.mp3');
      await addMember(db, cid, beta);
      await addMember(db, cid, alpha);

      final map = await ContactRepository().ringtoneMirrorEntries();
      expect(map, {'9995550001': '/t/alpha.mp3'});
    });

    test(
      'a toneless group is skipped in favour of a later toned one',
      () async {
        final db = await DatabaseHelper().database;
        final cid = await addContact(db, 'Eby', '9995550002');
        final alpha = await addGroup(db, 'Alpha'); // no tone
        final beta = await addGroup(db, 'Beta', tone: '/t/beta.mp3');
        await addMember(db, cid, alpha);
        await addMember(db, cid, beta);

        final map = await ContactRepository().ringtoneMirrorEntries();
        expect(map, {'9995550002': '/t/beta.mp3'});
      },
    );

    test('contacts with no tone anywhere are absent from the map', () async {
      final db = await DatabaseHelper().database;
      final cid = await addContact(db, 'Fahad', '9995550003');
      final gid = await addGroup(db, 'Alpha'); // group has no tone either
      await addMember(db, cid, gid);
      await addContact(db, 'Gopan', '9995550004'); // in no group at all

      final map = await ContactRepository().ringtoneMirrorEntries();
      expect(map, isEmpty);
    });
  });

  group('GroupRepository', () {
    test('groupRingtoneForContact matches the mirror pick', () async {
      final db = await DatabaseHelper().database;
      final cid = await addContact(db, 'Hari', '9995550005');
      final beta = await addGroup(db, 'Beta', tone: '/t/beta.mp3');
      final alpha = await addGroup(db, 'Alpha', tone: '/t/alpha.mp3');
      await addMember(db, cid, beta);
      await addMember(db, cid, alpha);

      final tone = await GroupRepository().groupRingtoneForContact(cid);
      expect(tone, '/t/alpha.mp3');
    });

    test('groupRingtoneForContact is null without a toned group', () async {
      final db = await DatabaseHelper().database;
      final cid = await addContact(db, 'Indu', '9995550006');
      final gid = await addGroup(db, 'Alpha'); // no tone
      await addMember(db, cid, gid);

      expect(await GroupRepository().groupRingtoneForContact(cid), isNull);
    });

    test('setGroupRingtone stores and clears path + label', () async {
      final repo = GroupRepository();
      final id = await repo.createGroup('Work');

      await repo.setGroupRingtone(id, path: '/t/work.mp3', label: 'Work tone');
      var groups = await repo.getAllGroups();
      expect(groups.single.ringtonePath, '/t/work.mp3');
      expect(groups.single.ringtoneLabel, 'Work tone');

      await repo.setGroupRingtone(id);
      groups = await repo.getAllGroups();
      expect(groups.single.ringtonePath, isNull);
      expect(groups.single.ringtoneLabel, isNull);
    });
  });
}
