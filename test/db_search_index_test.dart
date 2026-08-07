import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/utils/malayalam_transliterator.dart';

/// Migration + repair tests for the v20 -> v21 search index: a contacts table
/// that predates `name_phonetic` must gain it on open and get every row's keys
/// filled in, and the Settings "Search index" card's detect/rebuild pair must
/// find and fix a key that has drifted from its name.
void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  /// A contacts table in the pre-v21 shape: it has `name_translit` but no
  /// `name_phonetic`.
  Future<Database> openLegacyDb() async {
    final db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(version: 1),
    );
    await db.execute('''
      CREATE TABLE contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        salutation TEXT,
        first_name TEXT NOT NULL,
        middle_name TEXT,
        last_name TEXT,
        formal_name TEXT,
        name_translit TEXT
      )
    ''');
    return db;
  }

  test('ensurePhoneticColumn adds the column and backfills every row', () async {
    final db = await openLegacyDb();
    await db.insert('contacts', {
      'first_name': 'മൈക്കിൾ',
      'name_translit': searchKey('മൈക്കിൾ'),
    });
    await db.insert('contacts', {'first_name': 'Suresh'});

    await DatabaseHelper().ensurePhoneticColumn(db);

    final info = await db.rawQuery('PRAGMA table_info(contacts)');
    final columns = info.map((c) => c['name'] as String).toSet();
    expect(columns.contains('name_phonetic'), isTrue);

    final rows = await db.query('contacts', orderBy: 'id');
    expect(rows[0]['name_phonetic'], phoneticCode('മൈക്കിൾ'));
    expect(rows[1]['name_phonetic'], phoneticCode('Suresh'));
    // The row inserted without one also gets its translit key filled in.
    expect(rows[1]['name_translit'], searchKey('Suresh'));

    // The whole point: the typed name and the stored name now share a key.
    expect(rows[0]['name_phonetic'], phoneticCode('Michael'));

    await db.close();
  });

  test('ensurePhoneticColumn is idempotent', () async {
    final db = await openLegacyDb();
    await db.insert('contacts', {'first_name': 'മൈക്കിൾ'});

    await DatabaseHelper().ensurePhoneticColumn(db);
    // A second run changes nothing, and does not throw on the existing column.
    await DatabaseHelper().ensurePhoneticColumn(db);
    expect(await DatabaseHelper().rebuildContactSearchKeys(db), 0);

    await db.close();
  });

  test('a drifted key is detected and repaired', () async {
    final db = await openLegacyDb();
    await db.insert('contacts', {'first_name': 'Suresh'});
    await DatabaseHelper().ensurePhoneticColumn(db);
    expect(await DatabaseHelper().staleContactSearchKeyCount(db), 0);

    // Simulate the real bug: the name is renamed by some path that forgot to
    // recompute the keys, so the stored keys still describe the old name.
    await db.update('contacts', {'first_name': 'Michael'}, where: 'id = 1');

    expect(await DatabaseHelper().staleContactSearchKeyCount(db), 1);
    expect(await DatabaseHelper().rebuildContactSearchKeys(db), 1);
    expect(await DatabaseHelper().staleContactSearchKeyCount(db), 0);

    final row = (await db.query('contacts', where: 'id = 1')).first;
    expect(row['name_phonetic'], phoneticCode('Michael'));
    expect(row['name_translit'], searchKey('Michael'));

    await db.close();
  });

  test('keys cover every name part the repository writes', () async {
    final db = await openLegacyDb();
    await db.insert('contacts', {
      'salutation': 'Dr',
      'first_name': 'Suresh',
      'middle_name': 'K',
      'last_name': 'Nair',
      'formal_name': 'Suresh Kumar',
    });
    await DatabaseHelper().ensurePhoneticColumn(db);

    // Every part is included, in the repository's order — if the two ever
    // disagree, the staleness check flags every row forever.
    final row = (await db.query('contacts', where: 'id = 1')).first;
    expect(row['name_phonetic'], phoneticCode('Dr Suresh K Nair Suresh Kumar'));
    expect(await DatabaseHelper().staleContactSearchKeyCount(db), 0);

    await db.close();
  });
}
