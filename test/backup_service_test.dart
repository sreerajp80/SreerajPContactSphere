// Round-trip test for the password-protected Backup / Restore.
//
// Backup takes the WHOLE database (via SyncBundleService.exportBundle full),
// encrypts it with a password, and can restore it as a FULL REPLACE (via
// SyncBundleService.replaceAllFromBundle). This verifies:
//   • a good password round-trips and the restore is an EXACT copy (original
//     ids, is_self, and name_translit preserved; pre-existing rows gone);
//   • the backup settings overwrite the current ones;
//   • the emergency info card travels and is restored verbatim, while a payload
//     written before the card joined the bundle leaves the phone's card alone;
//   • a wrong password is rejected and nothing is changed;
//   • a foreign / truncated file is rejected;
//   • a schema-version mismatch is refused.
//
// No photos are seeded, so the run needs no path_provider plugin. SQLite-backed:
// run this file on its own (`flutter test test/backup_service_test.dart`).

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/services/backup_service.dart';
import 'package:smart_contacts_dialer/services/sync_bundle_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final backup = BackupService();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.setTestDatabaseName('smart_contacts_test_backup.db');
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'theme_mode': 2, // captured in the backup
      'default_country': 'IN',
    });
    await DatabaseHelper().close();
    await databaseFactory.deleteDatabase(
      join(await getDatabasesPath(), 'smart_contacts_test_backup.db'),
    );
  });

  tearDown(() async {
    await DatabaseHelper().close();
    await databaseFactory.deleteDatabase(
      join(await getDatabasesPath(), 'smart_contacts_test_backup.db'),
    );
  });

  /// Seeds the "original" data that a backup captures.
  Future<int> seedOriginal() async {
    final db = await DatabaseHelper().database;
    final alice = await db.insert('contacts', {
      'first_name': 'Alice',
      'is_favorite': 1,
      'is_self': 1, // must survive a restore verbatim (unlike a sync merge)
      'name_translit': 'alice', // must survive verbatim
    });
    await db.insert('contacts', {'first_name': 'Bob'});
    await db.insert('phone_numbers', {
      'contact_id': alice,
      'number': '+911111111111',
      'type': 'personal',
    });
    final family = await db.insert('groups', {'name': 'Family'});
    await db.insert('contact_groups', {
      'contact_id': alice,
      'group_id': family,
    });
    await db.insert('call_logs', {
      'contact_id': alice,
      'phone_number': '+911111111111',
      'call_type': 'outgoing',
      'duration': 42,
    });
    await db.insert('flagged_numbers', {
      'number': '+919999999999',
      'number_e164': '919999999999',
      'kind': 'blocked',
      'created_at': '2026-01-01T00:00:00',
    });
    // The emergency info card: one row plus its people-to-call entries.
    await db.insert('emergency_info', {
      'id': 1,
      'enabled': 1,
      'owner_name': 'Alice A',
      'blood_group': 'B+',
      'allergies': 'Penicillin',
      'show_allergies': 0, // a per-field switch that must survive verbatim
    });
    await db.insert('emergency_contacts', {
      'contact_id': alice, // FK to contacts; a full replace keeps the id
      'display_name': 'Alice',
      'number': '+911111111111',
      'relation_label': 'Wife',
      'sort_order': 0,
    });
    await db.insert('emergency_contacts', {
      'contact_id': null, // typed in by hand, not linked to a contact
      'display_name': 'Dr Rao',
      'number': '+912222222222',
      'sort_order': 1,
    });
    return alice;
  }

  /// Wipes and puts DIFFERENT data in place (so a restore must remove it).
  Future<void> reseedDifferent() async {
    final db = await DatabaseHelper().database;
    for (final t in [
      'phone_numbers',
      'contact_groups',
      'call_logs',
      'flagged_numbers',
      'emergency_contacts',
      'emergency_info',
      'contacts',
      'groups',
    ]) {
      await db.delete(t);
    }
    await db.insert('contacts', {'first_name': 'Zoe', 'is_self': 1});
    await db.insert('emergency_info', {
      'id': 1,
      'enabled': 1,
      'owner_name': 'Zoe Z',
      'blood_group': 'O-',
    });
    await db.insert('emergency_contacts', {
      'display_name': 'Zoe\'s brother',
      'number': '+913333333333',
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', 0); // will be overwritten by restore
  }

  test(
    'full round-trip: restore is an exact copy and replaces everything',
    () async {
      final aliceId = await seedOriginal();
      final bytes = await backup.encodeBackup('correct horse');

      await reseedDifferent();
      final db = await DatabaseHelper().database;

      await backup.restoreBytes(bytes, 'correct horse');

      // The "different" data is gone; the original is back verbatim.
      final contacts = await db.query('contacts');
      final names = contacts.map((c) => c['first_name']).toList();
      expect(names, containsAll(['Alice', 'Bob']));
      expect(names, isNot(contains('Zoe')));

      final alice = contacts.firstWhere((c) => c['first_name'] == 'Alice');
      expect(alice['id'], aliceId); // original id preserved
      expect(alice['is_self'], 1); // preserved (a sync merge would zero this)
      expect(alice['is_favorite'], 1);
      expect(alice['name_translit'], 'alice'); // search key preserved

      // Children came back attached to the original id.
      final phones = await db.query(
        'phone_numbers',
        where: 'contact_id = ?',
        whereArgs: [aliceId],
      );
      expect(phones, hasLength(1));
      expect(phones.first['number'], '+911111111111');

      final logs = await db.query(
        'call_logs',
        where: 'contact_id = ?',
        whereArgs: [aliceId],
      );
      expect(logs, hasLength(1));
      expect(logs.first['duration'], 42);

      final groups = await db.query('groups');
      expect(groups.map((g) => g['name']), contains('Family'));
      final flagged = await db.query('flagged_numbers');
      expect(flagged, hasLength(1));

      // The emergency card came back, replacing the "different" one.
      final info = await db.query('emergency_info');
      expect(info, hasLength(1));
      expect(info.first['owner_name'], 'Alice A');
      expect(info.first['blood_group'], 'B+');
      expect(info.first['allergies'], 'Penicillin');
      expect(info.first['show_allergies'], 0); // per-field switch preserved

      final emergencyContacts = await db.query(
        'emergency_contacts',
        orderBy: 'sort_order ASC',
      );
      expect(emergencyContacts, hasLength(2));
      expect(emergencyContacts.first['display_name'], 'Alice');
      expect(emergencyContacts.first['relation_label'], 'Wife');
      // Contact ids are preserved by a full replace, so the link still resolves.
      expect(emergencyContacts.first['contact_id'], aliceId);
      expect(emergencyContacts.last['display_name'], 'Dr Rao');
      expect(emergencyContacts.last['contact_id'], isNull);

      // Settings were overwritten by the backup's values.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('theme_mode'), 2);
    },
  );

  test('a backup made before the card was included leaves the card alone', () async {
    await seedOriginal();
    final bundle = await SyncBundleService().exportBundle(mode: SyncMode.full);

    // Rebuild the payload without the emergency tables — exactly what a backup
    // file written before the card joined the bundle contains.
    final meta = jsonDecode(bundle.metaJson) as Map<String, dynamic>;
    (meta['tables'] as Map)
      ..remove('emergency_info')
      ..remove('emergency_contacts');

    await reseedDifferent(); // current card = Zoe's
    final db = await DatabaseHelper().database;

    await SyncBundleService().replaceAllFromBundle(jsonEncode(meta), []);

    // Contacts were replaced as usual...
    final names = (await db.query(
      'contacts',
    )).map((c) => c['first_name']).toList();
    expect(names, containsAll(['Alice', 'Bob']));
    expect(names, isNot(contains('Zoe')));

    // ...but the card on the phone was neither wiped nor overwritten.
    final info = await db.query('emergency_info');
    expect(info, hasLength(1));
    expect(info.first['owner_name'], 'Zoe Z');
    final emergencyContacts = await db.query('emergency_contacts');
    expect(emergencyContacts, hasLength(1));
    expect(emergencyContacts.first['display_name'], 'Zoe\'s brother');
  });

  test('speed-dial keys travel in a backup and come back', () async {
    final aliceId = await seedOriginal();
    final db = await DatabaseHelper().database;
    await db.insert('speed_dial', {
      'slot': 2,
      'contact_id': aliceId,
      'phone_number': '9876543210',
    });

    final bundle = await SyncBundleService().exportBundle(mode: SyncMode.full);

    await reseedDifferent();
    // Whatever the phone has now must be replaced by the backup's keys.
    await DatabaseHelper().database.then(
      (d) => d.insert('speed_dial', {'slot': 7, 'phone_number': '111'}),
    );

    await SyncBundleService().replaceAllFromBundle(bundle.metaJson, []);

    final restored = await (await DatabaseHelper().database).query('speed_dial');
    expect(restored, hasLength(1));
    expect(restored.first['slot'], 2);
    expect(restored.first['phone_number'], '9876543210');
    // Contact ids are preserved by a full replace, so the link still resolves.
    expect(restored.first['contact_id'], aliceId);
  });

  test('a backup made before speed dial existed leaves the keys alone', () async {
    await seedOriginal();
    final bundle = await SyncBundleService().exportBundle(mode: SyncMode.full);

    // Rebuild the payload without the speed-dial table — exactly what a backup
    // file written before the feature existed contains.
    final meta = jsonDecode(bundle.metaJson) as Map<String, dynamic>;
    (meta['tables'] as Map).remove('speed_dial');

    await reseedDifferent();
    final db = await DatabaseHelper().database;
    await db.insert('speed_dial', {'slot': 4, 'phone_number': '555000'});

    await SyncBundleService().replaceAllFromBundle(jsonEncode(meta), []);

    // Contacts were replaced as usual...
    final names = (await db.query(
      'contacts',
    )).map((c) => c['first_name']).toList();
    expect(names, containsAll(['Alice', 'Bob']));

    // ...but the key set on this phone survived untouched.
    final keys = await db.query('speed_dial');
    expect(keys, hasLength(1));
    expect(keys.first['slot'], 4);
    expect(keys.first['phone_number'], '555000');
  });

  test('wrong password is rejected and nothing is changed', () async {
    await seedOriginal();
    final bytes = await backup.encodeBackup('right-one');

    await reseedDifferent(); // current data = just "Zoe"
    final db = await DatabaseHelper().database;

    await expectLater(
      () => backup.restoreBytes(bytes, 'WRONG'),
      throwsA(isA<BackupException>()),
    );

    // The restore never ran, so the current data is untouched.
    final names = (await db.query(
      'contacts',
    )).map((c) => c['first_name']).toList();
    expect(names, ['Zoe']);
  });

  test('a foreign / truncated file is rejected', () async {
    await seedOriginal();
    await expectLater(
      () => backup.restoreBytes(Uint8List.fromList([1, 2, 3, 4, 5]), 'x'),
      throwsA(isA<BackupException>()),
    );
  });

  test('a schema-version mismatch is refused', () async {
    await seedOriginal();
    final bytes = await backup.encodeBackup('pw');

    // Pretend the app's DB is now a different schema version than the backup.
    final db = await DatabaseHelper().database;
    await db.execute('PRAGMA user_version = 999999');

    await expectLater(
      () => backup.restoreBytes(bytes, 'pw'),
      throwsA(isA<BackupException>()),
    );
  });
}
