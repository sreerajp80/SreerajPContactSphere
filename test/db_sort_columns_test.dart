import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:smart_contacts_dialer/database/database_helper.dart';

/// Regression test for the empty-contact-list bug: a DB that reached a version
/// with no `sort_first` / `sort_last` columns (e.g. bumped during development
/// before the migration existed) must self-heal on open, not stay broken.
void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('ensureSortColumns adds and backfills missing sort keys', () async {
    final db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(version: 1),
    );
    // A contacts table WITHOUT the sort columns — the "stuck" state.
    await db.execute('''
      CREATE TABLE contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        first_name TEXT NOT NULL,
        last_name TEXT
      )
    ''');
    await db.insert('contacts', {'first_name': 'Anu'});
    await db.insert('contacts', {'first_name': 'രമേഷ്', 'last_name': 'കുമാർ'});

    await DatabaseHelper().ensureSortColumns(db);

    final info = await db.rawQuery('PRAGMA table_info(contacts)');
    final columns = info.map((c) => c['name'] as String).toSet();
    expect(columns.contains('sort_first'), isTrue);
    expect(columns.contains('sort_last'), isTrue);

    final rows = await db.query('contacts', orderBy: 'id');
    expect(rows[0]['sort_first'], 'anu');
    // Malayalam name romanized for sorting, so it interleaves with English.
    expect(rows[1]['sort_first'], 'ramesh');
    expect(rows[1]['sort_last'], 'kumaar');

    // Idempotent: a second call changes nothing and does not throw.
    await DatabaseHelper().ensureSortColumns(db);
    final again = await db.query('contacts', orderBy: 'id');
    expect(again[1]['sort_first'], 'ramesh');

    await db.close();
  });
}
