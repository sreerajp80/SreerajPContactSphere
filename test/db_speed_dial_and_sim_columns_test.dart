// Migration tests for the v29 -> v30 schema: the `speed_dial` table and the
// per-contact preferred-SIM columns.
//
// Both migrations are existence-checked helpers that also run on every open, so
// each is tested against a database that predates it AND re-run to prove the
// second call is a harmless no-op — which is exactly how they behave on a phone
// whose DB version ran ahead of the migration during development.

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:smart_contacts_dialer/database/database_helper.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  /// A pre-v30 contacts table: no preferred-SIM columns, no speed_dial table.
  Future<Database> openLegacy() async {
    final db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(version: 1),
    );
    await db.execute('PRAGMA foreign_keys = ON');
    await db.execute('''
      CREATE TABLE contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        first_name TEXT NOT NULL,
        last_name TEXT,
        is_secret INTEGER DEFAULT 0
      )
    ''');
    return db;
  }

  test('ensurePreferredSimColumns adds both columns and keeps data', () async {
    final db = await openLegacy();
    await db.insert('contacts', {'first_name': 'Anu'});

    await DatabaseHelper().ensurePreferredSimColumns(db);

    final info = await db.rawQuery('PRAGMA table_info(contacts)');
    final columns = info.map((c) => c['name'] as String).toSet();
    expect(columns.contains('preferred_sim_id'), isTrue);
    expect(columns.contains('preferred_sim_label'), isTrue);

    // An existing contact starts with no preference.
    final before = await db.query('contacts', where: 'id = 1');
    expect(before.first['preferred_sim_id'], isNull);

    // A value round-trips.
    await db.update(
      'contacts',
      {'preferred_sim_id': '2', 'preferred_sim_label': 'Work SIM'},
      where: 'id = ?',
      whereArgs: [1],
    );
    final after = await db.query('contacts', where: 'id = 1');
    expect(after.first['preferred_sim_id'], '2');
    expect(after.first['preferred_sim_label'], 'Work SIM');

    // Running it again must not throw or wipe the value.
    await DatabaseHelper().ensurePreferredSimColumns(db);
    final again = await db.query('contacts', where: 'id = 1');
    expect(again.first['preferred_sim_id'], '2');

    await db.close();
  });

  test('ensurePreferredSimColumns is a no-op with no contacts table', () async {
    final db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(version: 1),
    );
    // Must not throw when the table has not been created yet.
    await DatabaseHelper().ensurePreferredSimColumns(db);
    await db.close();
  });

  test('ensureSpeedDialTable creates the table and cascades', () async {
    final db = await openLegacy();
    final contactId = await db.insert('contacts', {'first_name': 'Anu'});

    await DatabaseHelper().ensureSpeedDialTable(db);

    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'speed_dial'",
    );
    expect(tables, isNotEmpty);

    await db.insert('speed_dial', {
      'slot': 3,
      'contact_id': contactId,
      'phone_number': '9876543210',
    });
    expect((await db.query('speed_dial')).length, 1);

    // Deleting the contact frees its key — no orphan row is left behind.
    await db.delete('contacts', where: 'id = ?', whereArgs: [contactId]);
    expect(await db.query('speed_dial'), isEmpty);

    // Running it again on a database that already has the table is safe.
    await DatabaseHelper().ensureSpeedDialTable(db);
    expect(
      await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'speed_dial'",
      ),
      isNotEmpty,
    );

    await db.close();
  });

  test('speed_dial slot is unique — a second assign replaces it', () async {
    final db = await openLegacy();
    await DatabaseHelper().ensureSpeedDialTable(db);

    await db.insert('speed_dial', {'slot': 1, 'phone_number': '111'});
    await db.insert('speed_dial', {
      'slot': 1,
      'phone_number': '222',
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    final rows = await db.query('speed_dial');
    expect(rows.length, 1);
    expect(rows.first['phone_number'], '222');

    await db.close();
  });
}
