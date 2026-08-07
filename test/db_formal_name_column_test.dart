import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:smart_contacts_dialer/database/database_helper.dart';

/// Migration test for the v19 -> v20 "formal name" column: a contacts table
/// that predates the column (an existing device on v19) must gain it on open
/// and keep the values that get written, and a second call must be a no-op.
void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('ensureFormalNameColumn adds the column and preserves data', () async {
    final db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(version: 1),
    );
    // A contacts table WITHOUT formal_name — the pre-v20 state.
    await db.execute('''
      CREATE TABLE contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        first_name TEXT NOT NULL,
        last_name TEXT
      )
    ''');
    await db.insert('contacts', {'first_name': 'Anu'});

    await DatabaseHelper().ensureFormalNameColumn(db);

    final info = await db.rawQuery('PRAGMA table_info(contacts)');
    final columns = info.map((c) => c['name'] as String).toSet();
    expect(columns.contains('formal_name'), isTrue);

    // Existing row keeps NULL; a new value round-trips.
    final existing = await db.query('contacts', where: 'id = 1');
    expect(existing.first['formal_name'], isNull);

    await db.update(
      'contacts',
      {'formal_name': 'Shri Anu'},
      where: 'id = 1',
    );
    final updated = await db.query('contacts', where: 'id = 1');
    expect(updated.first['formal_name'], 'Shri Anu');

    // Idempotent: a second call does not throw or drop the value.
    await DatabaseHelper().ensureFormalNameColumn(db);
    final again = await db.query('contacts', where: 'id = 1');
    expect(again.first['formal_name'], 'Shri Anu');

    await db.close();
  });
}
