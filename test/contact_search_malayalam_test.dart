// End-to-end tests for ContactRepository.searchContactSummaries — the search
// behind the Contacts screen — covering the reported bug: an English-typed
// query must find a contact whose name is written in Malayalam.
//
// Runs sqflite on the host VM via sqflite_common_ffi (the default sqflite
// factory is Android-only and unavailable under `flutter test`).

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/models/contact.dart';
import 'package:smart_contacts_dialer/repositories/contact_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const dbName = 'smart_contacts_test_ml_search.db';

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.setTestDatabaseName(dbName);
  });

  setUp(() async {
    await DatabaseHelper().close();
    await databaseFactory.deleteDatabase(
      join(await getDatabasesPath(), dbName),
    );
  });

  tearDown(() async {
    await DatabaseHelper().close();
  });

  final repo = ContactRepository();

  Future<void> addContact(String firstName) async {
    await repo.insertContact(Contact(firstName: firstName));
  }

  Future<List<String>> search(String query) async {
    final hits = await repo.searchContactSummaries(query);
    return hits.map((c) => c.firstName).toList();
  }

  test('an English query finds a Malayalam-spelled name', () async {
    await addContact('മൈക്കിൾ');
    await addContact('സുരേഷ്');
    await addContact('ശ്രീരാജ്');

    expect(await search('Michael'), contains('മൈക്കിൾ'));
    expect(await search('Suresh'), contains('സുരേഷ്'));
    expect(await search('Sreeraj'), contains('ശ്രീരാജ്'));
  });

  test('the vowel spelling used does not matter', () async {
    await addContact('സുരേശ്'); // "ri", not the "re" the user types

    expect(await search('Suresh'), contains('സുരേശ്'));
  });

  test('unrelated names are not dragged in', () async {
    await addContact('മൈക്കിൾ');
    await addContact('Ramesh');
    await addContact('Vinu');

    expect(await search('Michael'), ['മൈക്കിൾ']);
    expect(await search('Binu'), isEmpty); // v is not folded into b
  });

  test('plain English search still works unchanged', () async {
    await addContact('Ramesh');
    await addContact('Ramya');

    expect(await search('Ram'), containsAll(['Ramesh', 'Ramya']));
    expect(await search('esh'), contains('Ramesh'));
  });

  test(
    'Ale and Alex search matches Malayalam Alex while excluding unrelated names',
    () async {
      await addContact('അലക്സ്');
      await addContact('അലക്സ് കുമാർ');
      await addContact('City Time Gallery');
      await addContact('Kumar Electrician');
      await addContact('ലൂക്കോസ്');

      final aleHits = await search('Ale');
      expect(aleHits, containsAll(['അലക്സ്', 'അലക്സ് കുമാർ']));
      expect(aleHits, isNot(contains('City Time Gallery')));

      final alexHits = await search('Alex');
      expect(alexHits, containsAll(['അലക്സ്', 'അലക്സ് കുമാർ']));

      final mlHits = await search('അലക');
      expect(mlHits, containsAll(['അലക്സ്', 'അലക്സ് കുമാർ']));
      expect(mlHits, isNot(contains('Kumar Electrician')));
      expect(mlHits, isNot(contains('ലൂക്കോസ്')));
    },
  );

  test('renaming a contact keeps its search keys correct', () async {
    await addContact('Suresh');
    final before = await repo.searchContactSummaries('Suresh');
    final contact = await repo.getContactById(before.first.id!);

    contact!.firstName = 'മൈക്കിൾ';
    await repo.updateContact(contact);

    expect(await search('Michael'), contains('മൈക്കിൾ'));
    expect(await search('Suresh'), isEmpty);

    // And the update path leaves no drift behind for the Settings card to find.
    final db = await DatabaseHelper().database;
    expect(await DatabaseHelper().staleContactSearchKeyCount(db), 0);
  });

  test('letters are read the way people type them', () async {
    await addContact('ആന്റണി'); // ന്റ is typed "nt"
    await addContact('കൃഷ്ണൻ'); // ൃ is typed "ri"
    await addContact('മറ്റത്തിൽ'); // റ്റ is typed "tt"
    await addContact('ഫാത്തിമ'); // ഫ is typed "f"

    expect(await search('Antony'), contains('ആന്റണി'));
    expect(await search('Krishnan'), contains('കൃഷ്ണൻ'));
    expect(await search('Mattathil'), contains('മറ്റത്തിൽ'));
    expect(await search('Fathima'), contains('ഫാത്തിമ'));
  });

  test('spaces in the query or the name do not matter', () async {
    await addContact('ശ്രീരാജ്');
    await repo.insertContact(Contact(firstName: 'Sreeraj', lastName: 'P'));

    expect(await search('sree raj'), contains('ശ്രീരാജ്'));
    expect(await search('sreerajp'), contains('Sreeraj'));
  });

  test('a similar name is found, below the exact match', () async {
    await addContact('Vijayam Store'); // sorts before Vijayan
    await addContact('വിജയൻ');

    // One letter off, and not a sound-alike either (m is not n).
    expect(await search('Vijayam'), containsAll(['Vijayam Store', 'വിജയൻ']));
    expect(await search('Vijayan'), ['വിജയൻ', 'Vijayam Store']);
  });

  test('short names and a different first letter stay apart', () async {
    await addContact('Vinu');
    await addContact('Minu');

    expect(await search('Binu'), isEmpty);
    expect(await search('Sinu'), isEmpty);
  });
}
