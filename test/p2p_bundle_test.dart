// Round-trip test for the P2P sync bundle (the add-only MERGE payload).
//
// Seeds a "sender" database and exports a bundle, then wipes and reseeds a
// "receiver" database that already has some data, applies the bundle, and
// asserts the add-only merge: genuinely new contacts are added with NEW ids and
// their children/history remapped; a contact already present (name + shared
// phone) is skipped and its incoming children are NOT added; groups match by
// name; relationships remap both endpoints; flagged numbers dedupe; settings
// apply fill-only in incremental mode. The emergency info card is installed only
// onto a phone that has none, with its `contact_id` links remapped.
//
// SQLite-backed: run this file on its own (`flutter test test/p2p_bundle_test.dart`)
// — the shared sqlite3 native asset can double-copy-crash when several DB test
// files run in one invocation.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/services/p2p_sync_service.dart';
import 'package:smart_contacts_dialer/services/sync_bundle_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final bundleService = SyncBundleService();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.setTestDatabaseName('smart_contacts_test_p2p_bundle.db');
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      // "Sender" settings captured at export time.
      'theme_mode': 2,
      'default_country': 'IN',
      'spam_filter_enabled': true,
      // A SIM-account-keyed key that must NOT be synced.
      'default_sim_id': 'source-sim-account-xyz',
    });
    await DatabaseHelper().close();
    await databaseFactory.deleteDatabase(
      join(await getDatabasesPath(), 'smart_contacts_test_p2p_bundle.db'),
    );
  });

  tearDown(() async {
    await DatabaseHelper().close();
    await databaseFactory.deleteDatabase(
      join(await getDatabasesPath(), 'smart_contacts_test_p2p_bundle.db'),
    );
  });

  // --- Sender: two brand-new contacts + one that the receiver already has. ---
  Future<void> seedSender() async {
    final db = await DatabaseHelper().database;
    final alice = await db.insert('contacts', {
      'first_name': 'Alice',
      'is_favorite': 1,
      'relationship_score': 4.5,
    });
    final bob = await db.insert('contacts', {
      'first_name': 'Bob',
      'is_secret': 1,
    });
    // Carol matches a contact the receiver already has (name + shared phone).
    final carol = await db.insert('contacts', {'first_name': 'Carol'});
    // The sender's own owner ("Self") card — travels only on a Full Sync, and
    // lands on the receiver as a normal contact (is_self = 0).
    final me = await db.insert('contacts', {'first_name': 'Me', 'is_self': 1});

    await db.insert('phone_numbers', {
      'contact_id': alice,
      'number': '+911111111111',
      'type': 'personal',
    });
    await db.insert('phone_numbers', {
      'contact_id': bob,
      'number': '+912222222222',
      'type': 'personal',
    });
    await db.insert('phone_numbers', {
      'contact_id': carol,
      'number': '+913333333333',
      'type': 'personal',
    });
    await db.insert('phone_numbers', {
      'contact_id': me,
      'number': '+914444444444',
      'type': 'personal',
    });
    // An incoming child of the SKIPPED contact — must not be added.
    await db.insert('emails', {
      'contact_id': carol,
      'email': 'carol-incoming@x.com',
      'type': 'personal',
    });

    final family = await db.insert('groups', {'name': 'Family'});
    final work = await db.insert('groups', {'name': 'Work'});
    await db.insert('contact_groups', {
      'contact_id': alice,
      'group_id': family,
    });
    await db.insert('contact_groups', {'contact_id': bob, 'group_id': work});

    await db.insert('call_logs', {
      'contact_id': alice,
      'phone_number': '+911111111111',
      'call_type': 'outgoing',
      'duration': 42,
    });
    await db.insert('relationships', {
      'contact_id': alice,
      'related_contact_id': bob,
      'relationship_type': 'Friend',
    });
    await db.insert('flagged_numbers', {
      'number': '+919999999999',
      'number_e164': '919999999999',
      'kind': 'blocked',
      'created_at': '2026-01-01T00:00:00',
    });
    await db.insert('flagged_numbers', {
      'number': '+918888888888',
      'number_e164': '918888888888',
      'kind': 'spam',
      'created_at': '2026-01-01T00:00:00',
    });

    // The sender's emergency info card. Its entries cover every remapping case:
    // a contact that will be ADDED, one that will be MATCHED (skipped), one that
    // does not travel on a selective sync (the Self card), and a hand-typed one.
    await db.insert('emergency_info', {
      'id': 1,
      'enabled': 1,
      'owner_name': 'Sender Owner',
      'blood_group': 'B+',
    });
    await db.insert('emergency_contacts', {
      'contact_id': alice,
      'display_name': 'Alice',
      'number': '+911111111111',
      'relation_label': 'Wife',
      'sort_order': 0,
    });
    await db.insert('emergency_contacts', {
      'contact_id': carol,
      'display_name': 'Carol',
      'number': '+913333333333',
      'sort_order': 1,
    });
    await db.insert('emergency_contacts', {
      'contact_id': me,
      'display_name': 'Me',
      'number': '+914444444444',
      'sort_order': 2,
    });
    await db.insert('emergency_contacts', {
      'contact_id': null,
      'display_name': 'Dr Rao',
      'number': '+912222222299',
      'sort_order': 3,
    });
  }

  /// Wipe the DB and seed the RECEIVER's own data (a contact of its own, plus a
  /// Carol + Family + one flagged number that overlap the sender's).
  Future<void> reseedReceiver() async {
    final db = await DatabaseHelper().database;
    for (final t in [
      'phone_numbers',
      'emails',
      'call_logs',
      'relationships',
      'contact_groups',
      'emergency_contacts',
      'emergency_info',
      'contacts',
      'groups',
      'flagged_numbers',
    ]) {
      await db.delete(t);
    }
    await db.insert('contacts', {'first_name': 'Dave'});
    final carol = await db.insert('contacts', {'first_name': 'Carol'});
    await db.insert('phone_numbers', {
      'contact_id': carol,
      'number': '+913333333333',
      'type': 'personal',
    });
    await db.insert('groups', {'name': 'Family'});
    await db.insert('flagged_numbers', {
      'number': '+919999999999',
      'number_e164': '919999999999',
      'kind': 'blocked',
      'created_at': '2026-02-02T00:00:00',
    });

    // Receiver's own settings: theme already chosen (fill-only must keep it);
    // default_country not set (fill-only should fill it from the sender).
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', 0);
    await prefs.remove('default_country');
  }

  test(
    'add-only merge: new contacts added, matches skipped, ids remapped',
    () async {
      await seedSender();
      final bundle = await bundleService.exportBundle(
        mode: SyncMode.incremental,
        categories: SyncCategory.values.toSet(),
      );

      await reseedReceiver();
      final db = await DatabaseHelper().database;

      final summary = await bundleService.applyBundle(
        bundle.metaJson,
        const [],
      );

      // Two new contacts (Alice, Bob); Carol matched an existing one and skipped.
      expect(summary.contactsAdded, 2);
      expect(summary.contactsSkipped, 1);

      final contacts = await db.query('contacts');
      final names = contacts.map((c) => c['first_name']).toList();
      expect(names, containsAll(['Dave', 'Carol', 'Alice', 'Bob']));
      // Carol appears exactly once — the incoming Carol was NOT duplicated.
      expect(names.where((n) => n == 'Carol').length, 1);

      final alice = contacts.firstWhere((c) => c['first_name'] == 'Alice');
      final bob = contacts.firstWhere((c) => c['first_name'] == 'Bob');
      expect(alice['is_favorite'], 1);
      expect(bob['is_secret'], 1);

      // Alice's phone travelled and points at her NEW id.
      final alicePhones = await db.query(
        'phone_numbers',
        where: 'contact_id = ?',
        whereArgs: [alice['id']],
      );
      expect(alicePhones, hasLength(1));
      expect(alicePhones.first['number'], '+911111111111');

      // The SKIPPED Carol's incoming email must not have been added.
      final incomingCarolEmail = await db.query(
        'emails',
        where: 'email = ?',
        whereArgs: ['carol-incoming@x.com'],
      );
      expect(incomingCarolEmail, isEmpty);

      // History follows the new contact: Alice's call log is present.
      final aliceLogs = await db.query(
        'call_logs',
        where: 'contact_id = ?',
        whereArgs: [alice['id']],
      );
      expect(aliceLogs, hasLength(1));
      expect(aliceLogs.first['duration'], 42);

      // Relationship Alice→Bob remapped to both new ids.
      final rels = await db.query('relationships');
      expect(rels, hasLength(1));
      expect(rels.first['contact_id'], alice['id']);
      expect(rels.first['related_contact_id'], bob['id']);
      expect(rels.first['relationship_type'], 'Friend');
    },
  );

  test('Full Sync: the sender Self card is added as a normal contact', () async {
    await seedSender();
    final bundle = await bundleService.exportBundle(mode: SyncMode.full);

    await reseedReceiver();
    final db = await DatabaseHelper().database;
    // The receiver has its own owner card, which must stay the only Self.
    await db.insert('contacts', {'first_name': 'Owner', 'is_self': 1});

    final summary = await bundleService.applyBundle(bundle.metaJson, const []);

    // Alice, Bob, and the sender's "Me" are added; Carol matches and is skipped.
    expect(summary.contactsAdded, 3);
    expect(summary.contactsSkipped, 1);

    // "Me" arrived, but as a NORMAL contact (is_self cleared).
    final me = await db.query(
      'contacts',
      where: 'first_name = ?',
      whereArgs: ['Me'],
    );
    expect(me, hasLength(1));
    expect(me.first['is_self'], 0);

    // The receiver's own Self card is untouched — still the one and only.
    final selves = await db.query('contacts', where: 'is_self = 1');
    expect(selves, hasLength(1));
    expect(selves.first['first_name'], 'Owner');

    // The Self card's phone number travelled with it.
    final mePhones = await db.query(
      'phone_numbers',
      where: 'contact_id = ?',
      whereArgs: [me.first['id']],
    );
    expect(mePhones, hasLength(1));
    expect(mePhones.first['number'], '+914444444444');
  });

  test('selective sync: the sender Self card is NOT added', () async {
    await seedSender();
    final bundle = await bundleService.exportBundle(
      mode: SyncMode.incremental,
      categories: SyncCategory.values.toSet(),
    );

    await reseedReceiver();
    final db = await DatabaseHelper().database;

    await bundleService.applyBundle(bundle.metaJson, const []);

    // On a selective sync the owner card is skipped entirely.
    final me = await db.query(
      'contacts',
      where: 'first_name = ?',
      whereArgs: ['Me'],
    );
    expect(me, isEmpty);
    // And no Self card leaked onto the receiver.
    final selves = await db.query('contacts', where: 'is_self = 1');
    expect(selves, isEmpty);
  });

  test(
    'groups match by name; a new group is created; memberships remap',
    () async {
      await seedSender();
      final bundle = await bundleService.exportBundle(
        mode: SyncMode.incremental,
        categories: SyncCategory.values.toSet(),
      );
      await reseedReceiver();
      final db = await DatabaseHelper().database;

      final summary = await bundleService.applyBundle(
        bundle.metaJson,
        const [],
      );

      // 'Family' already existed (reused); 'Work' is new → one group added.
      expect(summary.groups, 1);
      final groups = await db.query('groups');
      final groupNames = groups.map((g) => g['name']).toList();
      expect(groupNames, containsAll(['Family', 'Work']));
      expect(groupNames.where((n) => n == 'Family').length, 1);

      final familyId = groups.firstWhere((g) => g['name'] == 'Family')['id'];
      final workId = groups.firstWhere((g) => g['name'] == 'Work')['id'];
      final alice = (await db.query(
        'contacts',
        where: 'first_name = ?',
        whereArgs: ['Alice'],
      )).first['id'];
      final bob = (await db.query(
        'contacts',
        where: 'first_name = ?',
        whereArgs: ['Bob'],
      )).first['id'];

      final memberships = await db.query('contact_groups');
      expect(
        memberships,
        containsAll([
          {'contact_id': alice, 'group_id': familyId},
          {'contact_id': bob, 'group_id': workId},
        ]),
      );
    },
  );

  test('flagged numbers dedupe on (number_e164, kind)', () async {
    await seedSender();
    final bundle = await bundleService.exportBundle(
      mode: SyncMode.incremental,
      categories: SyncCategory.values.toSet(),
    );
    await reseedReceiver();
    final db = await DatabaseHelper().database;

    await bundleService.applyBundle(bundle.metaJson, const []);

    final flagged = await db.query('flagged_numbers');
    // The blocked 919999999999 already existed (deduped); the spam
    // 918888888888 is new. So two rows total, no duplicate blocked.
    expect(flagged, hasLength(2));
    expect(
      flagged.where(
        (f) => f['number_e164'] == '919999999999' && f['kind'] == 'blocked',
      ),
      hasLength(1),
    );
    expect(
      flagged.where(
        (f) => f['number_e164'] == '918888888888' && f['kind'] == 'spam',
      ),
      hasLength(1),
    );
  });

  test(
    'emergency card installs on a phone with none; contact ids are remapped',
    () async {
      await seedSender();
      final bundle = await bundleService.exportBundle(
        mode: SyncMode.incremental,
        categories: SyncCategory.values.toSet(),
      );
      await reseedReceiver(); // receiver has NO card of its own
      final db = await DatabaseHelper().database;

      await bundleService.applyBundle(bundle.metaJson, const []);

      final info = await db.query('emergency_info');
      expect(info, hasLength(1));
      expect(info.first['id'], 1); // the table holds one row, under id 1
      expect(info.first['owner_name'], 'Sender Owner');
      expect(info.first['blood_group'], 'B+');

      final entries = await db.query(
        'emergency_contacts',
        orderBy: 'sort_order ASC',
      );
      expect(entries, hasLength(4));

      final aliceId = (await db.query(
        'contacts',
        where: 'first_name = ?',
        whereArgs: ['Alice'],
      )).first['id'];
      final carolId = (await db.query(
        'contacts',
        where: 'first_name = ?',
        whereArgs: ['Carol'],
      )).first['id'];

      // Added contact → the entry points at Alice's NEW id on this phone.
      expect(entries[0]['display_name'], 'Alice');
      expect(entries[0]['contact_id'], aliceId);
      // Matched (skipped) contact → the entry points at the receiver's Carol.
      expect(entries[1]['display_name'], 'Carol');
      expect(entries[1]['contact_id'], carolId);
      // The Self card never travels on a selective sync, so the link is dropped
      // — but the snapshotted name and number still work.
      expect(entries[2]['display_name'], 'Me');
      expect(entries[2]['contact_id'], isNull);
      expect(entries[2]['number'], '+914444444444');
      // Hand-typed entry: no link to begin with.
      expect(entries[3]['display_name'], 'Dr Rao');
      expect(entries[3]['contact_id'], isNull);
    },
  );

  test('a phone that already has an emergency card keeps its own', () async {
    await seedSender();
    final bundle = await bundleService.exportBundle(mode: SyncMode.full);
    await reseedReceiver();
    final db = await DatabaseHelper().database;

    // This phone's own card — medical data that must not be overwritten.
    await db.insert('emergency_info', {
      'id': 1,
      'enabled': 1,
      'owner_name': 'Receiver Owner',
      'blood_group': 'O-',
    });
    await db.insert('emergency_contacts', {
      'display_name': 'My brother',
      'number': '+915555555555',
    });

    await bundleService.applyBundle(bundle.metaJson, const []);

    final info = await db.query('emergency_info');
    expect(info, hasLength(1));
    expect(info.first['owner_name'], 'Receiver Owner');
    expect(info.first['blood_group'], 'O-');

    final entries = await db.query('emergency_contacts');
    expect(entries, hasLength(1));
    expect(entries.first['display_name'], 'My brother');
  });

  test(
    'incremental settings are fill-only; SIM-keyed ones never travel',
    () async {
      await seedSender();
      final bundle = await bundleService.exportBundle(
        mode: SyncMode.incremental,
        categories: SyncCategory.values.toSet(),
      );
      await reseedReceiver();

      await bundleService.applyBundle(bundle.metaJson, const []);

      final prefs = await SharedPreferences.getInstance();
      // theme_mode was already set on the receiver → kept (not overridden).
      expect(prefs.getInt('theme_mode'), 0);
      // default_country was unset on the receiver → filled from the sender.
      expect(prefs.getString('default_country'), 'IN');

      // default_sim_id must never be in the payload.
      final meta = jsonDecode(bundle.metaJson) as Map<String, dynamic>;
      final settingKeys = (meta['settings'] as List)
          .map((e) => (e as Map)['key'])
          .toList();
      expect(settingKeys, isNot(contains('default_sim_id')));
    },
  );

  test('a protocol mismatch is refused', () async {
    await seedSender();
    final bundle = await bundleService.exportBundle(mode: SyncMode.full);
    final meta = jsonDecode(bundle.metaJson) as Map<String, dynamic>;
    meta['protocol'] = 99; // pretend the sender speaks a different wire version
    await reseedReceiver();
    expect(
      () => bundleService.applyBundle(jsonEncode(meta), const []),
      throwsA(isA<P2PException>()),
    );
  });

  test('a schema-version mismatch is refused', () async {
    await seedSender();
    final bundle = await bundleService.exportBundle(mode: SyncMode.full);
    final meta = jsonDecode(bundle.metaJson) as Map<String, dynamic>;
    meta['dbVersion'] = 999999; // pretend the sender is a different app version
    await reseedReceiver();
    expect(
      () => bundleService.applyBundle(jsonEncode(meta), const []),
      throwsA(isA<P2PException>()),
    );
  });

  test('an over-long field is rejected before writing', () async {
    await seedSender();
    final bundle = await bundleService.exportBundle(mode: SyncMode.full);
    final meta = jsonDecode(bundle.metaJson) as Map<String, dynamic>;
    final contacts = (meta['tables'] as Map)['contacts'] as List;
    (contacts.first as Map)['first_name'] = 'x' * 200001; // over the field cap
    await reseedReceiver();
    expect(
      () => bundleService.applyBundle(jsonEncode(meta), const []),
      throwsA(isA<P2PException>()),
    );
  });
}
