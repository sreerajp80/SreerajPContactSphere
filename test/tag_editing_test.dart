// Tests for editing tags as a whole — rename, merge, add/remove members, and
// the "only delete an unused tag" guard.
//
// A tag is not a row of its own; it exists only as the tag rows on contacts.
// That makes two behaviours worth pinning down: a merge must not leave a contact
// holding the same tag twice (the `tags` table has no unique constraint), and
// deleting must refuse while any contact still carries the tag.
//
// Runs sqflite on the host VM via sqflite_common_ffi (the default sqflite factory
// is Android-only and unavailable under `flutter test`).

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/models/contact.dart';
import 'package:smart_contacts_dialer/repositories/contact_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const dbName = 'smart_contacts_test_tag_editing.db';

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.setTestDatabaseName(dbName);
  });

  setUp(() async {
    await DatabaseHelper().close();
    await databaseFactory.deleteDatabase(join(await getDatabasesPath(), dbName));
  });

  tearDown(() async {
    await DatabaseHelper().close();
  });

  final repo = ContactRepository();

  Future<int> addContact(String name, List<String> tags) async {
    return repo.insertContact(Contact(firstName: name)..tags = tags);
  }

  /// The tag rows a contact holds, in insertion order — including duplicates, so
  /// a merge that leaves two identical rows would show up here.
  Future<List<String>> tagsOf(int contactId) async {
    final db = await DatabaseHelper().database;
    final rows = await db.query(
      'tags',
      columns: ['name'],
      where: 'contact_id = ?',
      whereArgs: [contactId],
      orderBy: 'id ASC',
    );
    return rows.map((r) => r['name'] as String).toList();
  }

  Future<Map<String, int>> counts() async {
    final rows = await repo.getTagCounts();
    return {for (final r in rows) r.name: r.count};
  }

  group('retagAll — rename', () {
    test('renames a tag onto an unused name for every carrier', () async {
      final a = await addContact('Anu', ['familly']);
      final b = await addContact('Binu', ['familly']);

      final changed = await repo.retagAll('familly', 'family');

      expect(changed, 2);
      expect(await tagsOf(a), ['family']);
      expect(await tagsOf(b), ['family']);
      expect(await counts(), {'family': 2});
    });

    test('leaves a contact\'s other tags alone', () async {
      final a = await addContact('Anu', ['familly', 'work']);

      await repo.retagAll('familly', 'family');

      expect(await tagsOf(a), containsAll(['family', 'work']));
      expect((await tagsOf(a)).length, 2);
    });

    test('a case-only change rewrites the stored spelling', () async {
      final a = await addContact('Anu', ['family']);

      final changed = await repo.retagAll('family', 'Family');

      expect(changed, 1);
      expect(await tagsOf(a), ['Family']);
    });

    test('matches the old name case-insensitively', () async {
      final a = await addContact('Anu', ['Family']);

      await repo.retagAll('family', 'clan');

      expect(await tagsOf(a), ['clan']);
    });

    test('a blank name on either side changes nothing', () async {
      final a = await addContact('Anu', ['family']);

      expect(await repo.retagAll('family', '   '), 0);
      expect(await repo.retagAll('  ', 'family'), 0);
      expect(await tagsOf(a), ['family']);
    });
  });

  group('retagAll — merge', () {
    test('moves carriers onto an existing tag', () async {
      final a = await addContact('Anu', ['familly']);
      final b = await addContact('Binu', ['family']);

      final changed = await repo.retagAll('familly', 'family');

      expect(changed, 1);
      expect(await tagsOf(a), ['family']);
      expect(await tagsOf(b), ['family']);
      expect(await counts(), {'family': 2});
    });

    test('a contact holding both tags ends up with one row', () async {
      // The case the missing unique constraint would otherwise corrupt.
      final both = await addContact('Anu', ['familly', 'family']);

      await repo.retagAll('familly', 'family');

      expect(await tagsOf(both), ['family']);
    });

    test('an existing case-split collapses to the chosen spelling', () async {
      // "Family" and "family" are two chips in the cloud but one tag on tap;
      // a merge is where that inconsistency gets cleaned up.
      final a = await addContact('Anu', ['Family']);
      final b = await addContact('Binu', ['family']);
      final c = await addContact('Cinu', ['kin']);

      await repo.retagAll('kin', 'family');

      expect(await tagsOf(a), ['family']);
      expect(await tagsOf(b), ['family']);
      expect(await tagsOf(c), ['family']);
      expect(await counts(), {'family': 3});
    });
  });

  group('addTagToContacts', () {
    test('adds the tag and skips contacts that already carry it', () async {
      final a = await addContact('Anu', ['family']);
      final b = await addContact('Binu', const []);
      final c = await addContact('Cinu', const []);

      final inserted = await repo.addTagToContacts('family', {a, b, c});

      expect(inserted, 2);
      expect(await tagsOf(a), ['family']);
      expect(await tagsOf(b), ['family']);
      expect(await tagsOf(c), ['family']);
    });

    test('skips case-insensitively, so no duplicate spelling appears', () async {
      final a = await addContact('Anu', ['Family']);

      final inserted = await repo.addTagToContacts('family', {a});

      expect(inserted, 0);
      expect(await tagsOf(a), ['Family']);
    });

    test('a blank tag or empty selection does nothing', () async {
      final a = await addContact('Anu', const []);

      expect(await repo.addTagToContacts('  ', {a}), 0);
      expect(await repo.addTagToContacts('family', <int>{}), 0);
      expect(await tagsOf(a), isEmpty);
    });
  });

  group('removeTagFromContacts', () {
    test('removes from the named contacts only', () async {
      final a = await addContact('Anu', ['family']);
      final b = await addContact('Binu', ['family']);

      final removed = await repo.removeTagFromContacts('family', {a});

      expect(removed, 1);
      expect(await tagsOf(a), isEmpty);
      expect(await tagsOf(b), ['family']);
    });

    test('leaves the contact\'s other tags in place', () async {
      final a = await addContact('Anu', ['family', 'work']);

      await repo.removeTagFromContacts('family', {a});

      expect(await tagsOf(a), ['work']);
    });
  });

  group('deleteEmptyTag', () {
    test('refuses while a contact still carries the tag', () async {
      final a = await addContact('Anu', ['family']);

      expect(await repo.deleteEmptyTag('family'), isFalse);
      expect(await tagsOf(a), ['family']);
    });

    test('succeeds once the last carrier is removed', () async {
      final a = await addContact('Anu', ['family']);
      await repo.removeTagFromContacts('family', {a});

      expect(await repo.deleteEmptyTag('family'), isTrue);
      expect(await counts(), isEmpty);
    });

    test('a blank name is rejected', () async {
      expect(await repo.deleteEmptyTag('   '), isFalse);
    });
  });
}
